/* =========================================================
   HELPERS
   ========================================================= */
const rnd = n => Math.floor(Math.random()*n);
const pick = a => a[rnd(a.length)];
const shuffle = a => { a=[...a]; for(let i=a.length-1;i>0;i--){const j=rnd(i+1);[a[i],a[j]]=[a[j],a[i]]} return a; };
const clamp = (v,lo,hi) => Math.max(lo,Math.min(hi,v));
const esc = s => String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const sum = a => a.reduce((x,y)=>x+y,0);
// Francs are always written out: "1 franc", "3 francs". Player-facing text never uses the "f" abbreviation.
const fr = n => `${n} franc${n===1?'':'s'}`;
let S=null, modal=null, gameToken=0;
const sleep = ms => new Promise(r=>setTimeout(r, (S&&S.fast)?0:ms));
function uid(){ return S.uid++; }
function log(t, cls){ S.log.push({r:S.round,t,cls}); if(S.log.length>220) S.log.shift(); }
function dawnNote(t){ S.dawn.push(t); log(t); }
const B = p => `<b>${esc(p.name)}</b>`;
const isHuman = i => !S.players[i].ai;

function cube(t, n, stage){ return `<span class="mat" title="${n} ${MAT_N[t].toLowerCase()}${stage?' at stage '+ROMAN[stage-1]:''}"><i class="cube ${t}"></i><b>${n}</b> ${MAT_N[t].toLowerCase()}${stage?` <small>${ROMAN[stage-1]}</small>`:''}</span>`; }
function matsHTML(list){ return list.filter(x=>x[2]>0).map(([t,st,n])=>cube(t,n,t==='bone'?0:st)).join(''); }
function reqHTML(req){ return Object.entries(req).filter(([,n])=>n>0).map(([k,n])=>cube(KEY[k],n,0)).join(''); }

/* =========================================================
   CARDS
   ========================================================= */
function cadaverFromRow(src,row,k){
  const [st,m,exp,hc,name,cost]=row;
  const mats=[]; ['muscle','organ','blood','bone'].forEach((t,k)=>{ if(m[k]) mats.push([t, t==='bone'?0:st, m[k]]); });
  return {id:uid(), kind:'cadaver', src, stage:st, name:name||pick(OWNERS), named:!!name, seed:1+rnd(9999), mats, exp, hcost:hc, cost:cost||0, art: k==null?null:`${src}-${String(k+1).padStart(2,'0')}`};
}
function drawCadaver(src){
  const d=S.decks[src]; if(!d.length) S.decks[src]=shuffle(CADAVERS[src].map((r,k)=>k));
  const k=S.decks[src].shift(); return cadaverFromRow(src, CADAVERS[src][k], k);
}
function drawScoundrel(){ if(!S.decks.sc.length) S.decks.sc=shuffle(SCOUNDRELS.map((r,k)=>k)); const k=S.decks.sc.shift(); const t=SCOUNDRELS[k];
  return {id:uid(), kind:'scoundrel', tpl:k, ...t, who:pick(SC_WHO[t.kind]), seed:1+rnd(9999)}; }
function drawResearch(){ if(!S.decks.re.length) S.decks.re=shuffle(RESEARCH.map((r,k)=>k)); return {id:uid(), kind:'research', ...RESEARCH[S.decks.re.shift()]}; }
function drawHumanity(){ if(!S.decks.hu.length) S.decks.hu=shuffle(HUMANITY.map((r,k)=>k).filter(k=>!S.removed.includes(HUMANITY[k].id)));
  if(!S.decks.hu.length) return null; return {id:uid(), kind:'humanity', ...HUMANITY[S.decks.hu.shift()]}; }
function hospLimits(p){ return {free: p.rep>=7?1:0, paid: (S.ev==='corrupt'?1:0)+(p.rep>=15?1:0)}; }
function scCost(c){ return c.cost + (S.ev==='graves'?1:0) + (S.ev==='plague'&&c.kind==='dog'?1:0); }
function scHcost(c){ return c.hcost + (S.ev==='toussaint'&&(c.kind==='thief'||c.kind==='snatch')?1:0); }
function scAllowed(c){ return !(c.kind==='snatch' && S.closed.snatch); }

/* =========================================================
   PLAYER STATE
   ========================================================= */
function mkPlayer(name, color, ai, persona, charId){
  const p={name, color, ai, persona, char:charId, coin:S.players?0:0, hum:0, exp:0, rep:0, maxRep:0, maxExp:0, vp:0, police:0,
    mats:{muscle:[0,0,0,0],organ:[0,0,0,0],blood:[0,0,0,0],animal:[0,0,0,0]}, bone:0, preserved:0,
    table:{head:null,torso:null,armL:null,armR:null,legL:null,legR:null}, jars:[false], ice:0, hand:[],
    left:{scientist:0,assistant:0}, sel:'assistant', labUsed:{}, thrown:false, aidPlayed:false, sabotaged:0, noHumLoss:false,
    odeonUsed:false, zooUsed:false, surgeonUsed:false, lastDark:0, out:0};
  return p;
}
const hasChar=(p,id)=>p.char===id;
function sciTotal(p){ return 1 + (p.rep>=15?1:0); }
function asstTotal(p){ return 2 + (p.rep>=7?1:0) - (p.rep>=15?1:0); }
function leftN(p){ return p.left.scientist+p.left.assistant; }
function blueDice(p){ return p.exp>=20?2:p.exp>=10?1:0; }
function charged(p){ return p.jars.filter(Boolean).length; }
function onTable(p){ return SLOT6.filter(s=>p.table[s]); }
function completeCount(p){ return SLOT6.filter(s=>p.table[s]&&p.table[s].side==='skin').length; }
function aliveCount(p){ return SLOT6.filter(s=>p.table[s]&&p.table[s].alive).length; }
function dmgTotal(p){ return sum(SLOT6.map(s=>p.table[s]?p.table[s].dmg:0)); }
function matTotal(p,t){ return t==='bone'?p.bone:sum(p.mats[t]); }
function fleshOnTrack(p){ return sum(p.mats.muscle)+sum(p.mats.organ); }
function addMat(p,t,stage,n){ if(n<=0) return; if(t==='bone'){ p.bone=Math.min(12,p.bone+n); return; } p.mats[t][stage-1]=Math.min(15,p.mats[t][stage-1]+n); }
function gainMats(p, list){ list.forEach(([t,st,n])=>addMat(p,t,st||1,n)); }
function setHum(p,d){
  if(!d) return 0;
  if(hasChar(p,'psycho')) return 0;
  if(d<0 && p.noHumLoss) return 0;
  const before=p.hum; let next=before+d;
  if(d>0 && hasChar(p,'human')){ const over=Math.max(0,next-10); if(over){ p.vp+=over; } }
  p.hum=clamp(next,-10,10); checkObjectives(); return p.hum-before;
}
function setRep(p,d){ p.rep=Math.max(0,p.rep+d); p.maxRep=Math.max(p.maxRep,p.rep); checkObjectives(); }
function setExp(p,d){ p.exp=Math.max(0,p.exp+d); p.maxExp=Math.max(p.maxExp,p.exp); checkObjectives(); }
function applyGain(p,g,src){
  if(!g) return;
  if(g.exp) setExp(p, g.exp + (src==='research'&&hasChar(p,'heiress')&&g.exp>0?1:0));
  if(g.rep) setRep(p,g.rep);
  if(g.coin) p.coin+=g.coin;
  if(g.hum) setHum(p,g.hum);
}
function gainTxt(g){ const t=[]; if(g.exp) t.push(`${g.exp>0?'+':''}${g.exp} expertise`); if(g.rep) t.push(`+${g.rep} reputation`); if(g.coin) t.push(`+${fr(g.coin)}`); if(g.hum) t.push(`${g.hum>0?'+':''}${g.hum} humanity`); return t.join(', '); }
function addCard(p,c){ if(!c) return; const same=p.hand.filter(h=>h.kind===c.kind); if(same.length>=3){ p.hand.splice(p.hand.indexOf(same[0]),1); } p.hand.push(c); }
function addPolice(p){ p.police=Math.min(2,p.police+1); if(p.police===2 && hasChar(p,'psycho')) setRep(p,-1); }

/* Objectives */
function checkObjectives(){
  if(!S||!S.objectives) return;
  const order=S.players.map((_,k)=>(S.first+k)%S.players.length);
  for(const id of S.objectives){ if(S.claimed[id]!==undefined || id==='rich') continue;
    for(const i of order){ const p=S.players[i];
      const ok = id==='hum10'?p.hum>=10 : id==='alive2'?aliveCount(p)>=2 : id==='exp27'?p.exp>=27 : id==='parts6'?onTable(p).length>=6 : id==='rep23'?p.rep>=23 : false;
      if(ok){ S.claimed[id]=i; log(`${B(p)} claims the bonus objective: ${OBJECTIVES.find(o=>o.id===id).name} (+10 VP).`); break; } } }
}

/* =========================================================
   SETUP
   ========================================================= */
function newGame(name, nRivals, charId, opts){
  opts=opts||{}; const fast=opts.fast; gameToken++; humanResolve=null; labResolve=null;
  S = {v:5, uid:1, round:1, first:0, cur:0, phase:'event', captain:0, ev:null, card:null, closed:{}, occ:{}, bump:[], fast:!!fast,
       decks:{cemetery:[],hospital:[],morgue:[],square:[],sc:[],re:[],hu:[]}, removed:[], hosp:[], square:[], docks:[], researchRow:[], humanityRow:[],
       locEnc:null, thwart:null, log:[], dawn:[], final:null, claimed:{}, objectives:shuffle(OBJECTIVES.map(o=>o.id)).slice(0,4)};
  const chars=shuffle(CHARACTERS.map(c=>c.id).filter(c=>c!==charId));
  const mine = charId && charId!=='random' ? charId : chars.pop();
  S.players=[mkPlayer(name||'Dr Torres', YOU_COLOR, !!opts.allAI, opts.allAI?{ruthless:0,scholar:0,careful:0}:null, mine)];
  RIVALS.slice(0,nRivals).forEach(r=>S.players.push(mkPlayer(r.name, r.color, true, r, chars.pop())));
  const n=S.players.length;
  S.players.forEach(p=>{ p.coin=n; if(hasChar(p,'charlatan')) setRep(p,3); if(hasChar(p,'human')) p.hum=2; if(hasChar(p,'surgeon')) setExp(p,2); });
  S.first=rnd(n);
  // Event deck: 12 cards, events eligible for the day, 4 encounters mixed into days 3 to 12
  const encDays=shuffle([3,4,5,6,7,8,9,10,11,12]).filter(d=>ENCOUNTERS.some(e=>d>=e.r[0]&&d<=e.r[1]));
  const usedE=new Set(), usedN=new Set(); S.events=[];
  const encSet=new Set(encDays.slice(0,4));
  for(let d=1; d<=MAX_ROUNDS+3; d++){
    let card=null;
    if(encSet.has(d)){ const opts=ENCOUNTERS.filter(e=>d>=e.r[0]&&d<=e.r[1]&&!usedN.has(e.id)); if(opts.length){ const e=pick(opts); usedN.add(e.id); card={t:'enc', id:e.id}; } }
    if(!card){ let opts=EVENTS.filter(e=>d>=e.r[0]&&d<=e.r[1]&&!usedE.has(e.id)); if(!opts.length) opts=EVENTS.filter(e=>!usedE.has(e.id)); if(!opts.length) opts=EVENTS;
      const e=pick(opts); usedE.add(e.id); card={t:'ev', id:e.id}; }
    S.events.push(card);
  }
  S.events[0]={t:'ev', id:pick(['corrupt','meat','enemy','grant','darkres'])};
  for(const k of ['cemetery','hospital','morgue','square']) S.decks[k]=shuffle(CADAVERS[k].map((r,j)=>j));
  S.decks.sc=shuffle(SCOUNDRELS.map((r,k)=>k)); S.decks.re=shuffle(RESEARCH.map((r,k)=>k)); S.decks.hu=shuffle(HUMANITY.map((r,k)=>k));
  refreshBoard();
  log('A letter in an enormous hand arrives. Twelve days, unless the Captain finds the Creature first.');
  loop();
}
function refreshBoard(){
  const n=S.players.length;
  S.hosp=[drawCadaver('hospital'),drawCadaver('hospital')];
  S.docks=[drawScoundrel(),drawScoundrel(),drawScoundrel()];
  S.researchRow=[drawResearch(),drawResearch(),drawResearch()];
  S.humanityRow=[drawHumanity(),drawHumanity(),drawHumanity()].filter(Boolean);
  S.square=[];
}

/* =========================================================
   MAIN LOOP
   ========================================================= */
let runningTok=-1;
async function loop(){
  const tok=gameToken; if(runningTok===tok) return; runningTok=tok;
  try{
    while(S && tok===gameToken && S.phase!=='end'){
      if(S.phase==='event'){ await eventPhase(); if(tok!==gameToken) break; S.phase='day'; S.cur=S.first; save(); render(); }
      else if(S.phase==='day'){ await cityPhase(tok); }
      else if(S.phase==='firstmove'){ await firstMovePhase(); S.phase='lab'; save(); render(); }
      else if(S.phase==='lab'){ await labPhase(); }
      else if(S.phase==='dawn'){ await dawnPhase(); }
      else break;
    }
  } catch(err){ console.error(err); }
  if(runningTok===tok) runningTok=-1; if(tok===gameToken) render();
}

/* ---------- Event phase ---------- */
async function eventPhase(){
  S.occ={}; S.bump=[]; S.closed={}; S.thwart=null; S.locEnc=null; S.odeonOpen=false; S.fireUsed={};
  S.players.forEach(p=>{ p.left={scientist:sciTotal(p), assistant:asstTotal(p)}; p.labUsed={}; p.thrown=false; p.aidPlayed=false;
    p.odeonUsed=false; p.zooUsed=false; p.surgeonUsed=false; p.noHumLoss=false; p.forced=null; p.labDone=false;
    if(!p.left[p.sel]) p.sel=p.left.assistant?'assistant':'scientist';
    if(hasChar(p,'heiress') && p.coin<=2) p.coin+=1; });
  const card=S.events[S.round-1]; S.card=card; S.ev = card.t==='ev'?card.id:null;
  S.dawn=[];
  render();
  if(card.t==='ev'){
    const e=EVENTS.find(x=>x.id===card.id);
    log(`Day ${S.round}: ${esc(e.name)}.`, 'day');
    const closeMap={graves:['cemetery'], fire:['academy'], plague:['slaughter'], riots:['alley','docks'], storm2:['cemetery','docks'], purge:['hospital']};
    (closeMap[e.id]||[]).forEach(l=>S.closed[l]=1);
    if(e.storm){ S.players.forEach(p=>p.jars=p.jars.map(()=>true)); log('Lightning: every Leyden jar is charged.'); }
    if(e.exec) await execution();
    if(e.id==='odeon') S.odeonOpen=true;
    if(e.id==='betrayal') S.players.forEach(p=>{ if(p.hum<3 && p.jars.length){ p.jars.pop(); log(`${B(p)} loses a Leyden jar.`); } });
    await showEventCard(e);
    if(e.id==='bourbon') for(const [i,p] of S.players.entries()){ const pay = p.coin>=1 && (p.ai ? true : await askYN('Loyalty Pledge','Pay 1 franc to gain 1 reputation? If not, you lose 1 reputation.','Pay 1 franc','Refuse'));
      if(pay){ p.coin--; setRep(p,1); } else setRep(p,-1); }
    if(e.id==='darkres') for(const [i,p] of S.players.entries()){ const take = p.ai ? (aiNeeds(p).expGap>0 && p.hum>-6) : await askYN('A Dead Man’s Notes','Lose 1 humanity to gain 2 expertise?','Read them','Burn them');
      if(take){ setHum(p,-1); setExp(p,2); } }
    if(e.id==='fire') for(const [i,p] of S.players.entries()){ if(p.coin<2) continue; const pay = p.ai ? (p.coin>=4 && Math.random()<.6) : await askYN('Fire at the Academy','Pay 2 francs toward the rebuilding to gain 2 reputation?','Pay 2 francs','Not now');
      if(pay){ p.coin-=2; setRep(p,2); log(`${B(p)} pays for the rebuilding.`); } }
    if(e.id==='fire'){ const t=await fpChooseTarget('Who receives the Captain’s plea?', S.players.map((_,k)=>k), 'any'); if(t!=null) await outcomeC2(t); }
    if(e.id==='enemy'){ for(const [i,p] of S.players.entries()){ if(p.hum>0){ const take = p.ai ? true : await askYN('An Anonymous Letter','Take a humanity card?','Take one','No'); if(take){ addCard(p,drawHumanity()); } } }
      const top=Math.max(...S.players.map(p=>p.hum)); const t=S.players.findIndex(p=>p.hum===top); setHum(S.players[t],1); log(`${B(S.players[t])} hears a confession and gains 1 humanity.`); }
  } else {
    const e=ENCOUNTERS.find(x=>x.id===card.id);
    log(`Day ${S.round}: an encounter.`, 'day');
    if(e.loc){ S.locEnc={id:e.id, holder:S.first}; log(`${B(S.players[S.first])} holds a secret encounter at one of the spaces in Paris.`);
      if(isHuman(S.first) && !S.fast) await ask({title:'A secret encounter', html:`<p>You hold this card. The first rival to use <b>${esc(LOC[e.loc.split('.')[0]].name)}: ${esc(SPACE[e.loc].n)}</b> today will trigger it.</p>${encHTML(e)}`, buttons:[{label:'Keep it secret', primary:true, value:1}]});
      else if(!S.fast) await ask({title:'An encounter card', html:`<p>${esc(S.players[S.first].name)} holds a secret encounter. Whoever (other than them) first visits a certain place today will meet it.</p>`, buttons:[{label:'Continue', primary:true, value:1}]});
    } else {
      const t=await encounterTarget(e);
      if(t==null){ log('No one fits the encounter. It passes.'); }
      else await runEncounter(e, t);
    }
  }
  save(); render();
}
async function execution(){
  // Royal Pardon can stop it
  for(const [i,p] of S.players.entries()){
    const c=p.hand.find(h=>h.id==='mercy'); if(!c || p.coin<2) continue;
    const use = p.ai ? (p.hum<3 && p.coin>=4) : await askYN('Royal Pardon','An execution is announced. Pay 2 francs and play your Royal Pardon to stop it? (+2 humanity, +2 reputation)','Stop it','Let it happen');
    if(use){ p.coin-=2; p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain); log(`${B(p)} wins a royal pardon. The execution is cancelled.`); return; }
  }
  const k=S.players.length>2?2:1; for(let j=0;j<k;j++) S.square.push(drawCadaver('square'));
  log('Execution: fresh bodies at the Public Square.');
}
async function showEventCard(e){
  if(S.fast) return;
  await ask({title:`Day ${S.round}`, html:`<div class="gcards">${eventCardHTML(e)}</div>`, buttons:[{label:'Begin the day', primary:true, value:1}]});
}

/* ---------- Encounters ---------- */
async function fpChooseTarget(title, cands, mood){
  if(!cands.length) return null;
  if(cands.length===1) return cands[0];
  const fp=S.first;
  if(isHuman(fp) && !S.fast){
    return await ask({title, html:'<p>As first player, you choose.</p>', options:cands.map(k=>({label:esc(S.players[k].name)+(k===0?' (you)':''), value:k}))});
  }
  // AI first player: aim harm at the leader, help at itself
  if(mood==='good' && cands.includes(fp)) return fp;
  const others=cands.filter(k=>k!==fp); const pool=others.length?others:cands;
  return pool.sort((a,b)=>score(S.players[b])-score(S.players[a]))[0];
}
function score(p){ return p.vp + aliveCount(p)*4 + p.rep/2 + p.exp/3; }
async function encounterTarget(e){
  const P=S.players, idx=P.map((_,k)=>k);
  const tied = f => { const m=Math.max(...idx.map(f)); return idx.filter(k=>f(k)===m); };
  switch(e.target){
    case 'maxExp': return fpChooseTarget('Who is visited?', tied(k=>P[k].exp));
    case 'fewestComplete': return fpChooseTarget('Who is visited?', tied(k=>-completeCount(P[k])));
    case 'maxHum': return fpChooseTarget('Who is visited?', tied(k=>P[k].hum));
    case 'fpOther': return fpChooseTarget('Who does the Creature visit?', idx.filter(k=>k!==S.first));
    case 'fp': return fpChooseTarget('Who does the visitor find?', idx);
    case 'fpWithPart': return fpChooseTarget('Who does the Creature watch?', idx.filter(k=>onTable(P[k]).length>0));
    case 'lastDark': { const best=Math.max(...idx.map(k=>P[k].lastDark)); if(!best) return null; return idx.find(k=>P[k].lastDark===best); }
    case 'mostHumCards': { const f=k=>P[k].hand.filter(h=>h.kind==='humanity').length; if(Math.max(...idx.map(f))===0) return fpChooseTarget('Who is visited?', idx); return fpChooseTarget('Who is visited?', tied(f)); }
  }
  return null;
}
function encHTML(e){
  const who = e.who==='captain'?'Captain Walton':e.who==='woman'?'A stranger':'The Creature';
  return `<div class="gcards">${encounterCardHTML(e)}</div>`;
}
async function runEncounter(e, t, ctx){
  const p=S.players[t];
  // A Trap of Your Own: send the Creature away (only for 'now' encounters with the Creature)
  if(e.now && e.who==='creature'){ const trap=p.hand.find(h=>h.id==='trap');
    if(trap && charged(p)>0){ const use = p.ai ? p.hum<=2 : await askYN('A Trap of Your Own', `The Creature is coming for you. Spend 1 charged jar to set your trap and send him away?`, 'Spring the trap','Face him');
      if(use){ dischargeOne(p); p.hand=p.hand.filter(h=>h!==trap); applyGain(p,trap.gain); log(`${B(p)} springs a trap and the Creature withdraws.`); return {}; } } }
  let branch;
  if(e.test){ branch = e.test(p) ? 'a':'b'; }
  else if(e.choice){ branch = p.ai ? aiEncounterChoice(e,p) : await ask({title:'An encounter', wide:true, html:encHTML(e)+`<p style="margin-top:10px">This encounter is for <b>you</b>.</p>`, options:[{label:e.choice[0], value:'a'},{label:e.choice[1], value:'b'}], locked:true}); }
  else branch='a';
  const key = branch==='a'?e.a:e.b;
  if(isHuman(t) && e.test && !S.fast) await ask({title:'An encounter', wide:true, html:encHTML(e)+`<p style="margin-top:10px">${e.testText?`Test: ${esc(e.testText)}. `:''}<b>${branch==='a'?'Yes':'No'}</b>.</p>`, buttons:[{label:'See what happens', primary:true, value:1}], locked:true});
  else if(!isHuman(t)) log(`${B(p)} meets the ${e.who==='captain'?'Captain':e.who==='woman'?'stranger':'Creature'}.`);
  const res = await OUT[key](t, ctx) || {};
  if(isHuman(t) && res.msg && !S.fast) await ask({title:'What happens', html:`<p>${res.msg}</p>`, buttons:[{label:'Continue', primary:true, value:1}]});
  log(`${B(p)}: ${res.msg||'nothing more comes of it.'}`);
  return res;
}
function aiEncounterChoice(e,p){
  switch(e.id){
    case 'e14': return fleshOnTrack(p)>=4?'a':'b';
    case 'e10': return 'a';
    case 'e2': return p.hum>=0?'b':'a';
    case 'e28': return p.hum<0?'a':'b';
    case 'e26': return p.hum<-2?'b':'a';
    case 'e24': return 'b';
    case 'e20': return 'a';
    case 'e16': return p.hum>-2?'a':'b';
    case 'e29': return 'a';
  }
  return 'a';
}
function dischargeOne(p){ const k=p.jars.indexOf(true); if(k>=0) p.jars[k]=false; }
function takeFirst(i){ S.first=i; }
function downgradeOne(p){
  const parts=onTable(p); if(!parts.length) return 'nothing to damage';
  const rank=s=>{ const t=p.table[s]; return (t.alive?0:t.side==='skin'?10:20)+PARTS[SLOT_T[s]].alive; };
  const s=parts.sort((a,b)=>rank(a)-rank(b))[0], t=p.table[s]; t.dmg=0;
  if(t.alive){ t.alive=false; return `the ${SLOT_N[s].toLowerCase()} dies again`; }
  if(t.side==='skin'){ t.side='muscle'; return `the ${SLOT_N[s].toLowerCase()} loses its skin`; }
  p.table[s]=null; return `the ${SLOT_N[s].toLowerCase()} is destroyed`;
}
async function placeForced(i, key, kind, effect){
  const p=S.players[i]; if(!p.left[kind]) return false;
  if(key.startsWith('lab.')){ const s=key.slice(4); if(p.labUsed[s]) return false; p.labUsed[s]=kind; }
  else { if(S.occ[key]) return false; S.occ[key]={p:i, kind}; }
  p.left[kind]--; if(effect) await effect(); return true;
}
const OUT = {
  A2: async i=>{ const p=S.players[i]; setHum(p,-2); if(p.jars.length) p.jars.pop(); return {msg:'You point to the Captain’s hiding place. A gunshot, then silence. −2 humanity, and a jar shatters in the struggle.'}; },
  B2: async i=>{ const p=S.players[i]; setExp(p,-1); setHum(p,2); return {msg:'You hide him and are knocked senseless for it. −1 expertise, +2 humanity.'}; },
  A4: async i=>{ const p=S.players[i]; gainMats(p,[['organ',1,1],['muscle',1,2]]); setHum(p,-1); return {msg:'He empties the bag on your table: an arm, freshly torn. +1 organ and +2 muscle at stage I, −1 humanity.'}; },
  B4: async i=>{ const p=S.players[i]; addMat(p,'organ',1,1); setHum(p,1); return {msg:'He presses an eyeball into your palm. +1 organ at stage I, +1 humanity.'}; },
  A6: async i=>{ const p=S.players[i]; if(p.jars.length<4) p.jars.push(false); return {msg:'“Breathe life into it, and quickly.” He leaves you an empty Leyden jar.'}; },
  B6: async i=>{ const p=S.players[i]; const ok = await placeForced(i,'lab.blood','scientist', async()=>{ addMat(p,'blood',1,5); });
    return {msg: ok ? 'He forces the lancet into your arm. Your scientist gives blood: +5 blood at stage I.' : 'He bleeds you, but you have no scientist free. Nothing more.'}; },
  A8: async i=>{ takeFirst(i); return {msg:'“Then I will show you the way.” You become first player.'}; },
  B8: async i=>{ const p=S.players[i]; addCard(p,drawResearch()); addCard(p,drawResearch()); return {msg:'He leaves a sheaf of parchment. Draw 2 research cards.'}; },
  A10: async i=>{ const p=S.players[i]; takeFirst(i); let at='';
    if(p.left.scientist){ p.left.scientist--; if(!S.occ['docks.hire']) S.occ['docks.hire']={p:i, kind:'scientist'}; at=' Your scientist spends the day at the Docks.'; }
    addCard(p,drawHumanity()); setHum(p,1); p.coin+=2; return {msg:`You meet the Captain by the river. You become first player, take a humanity card, +1 humanity and +2 francs.${at}`}; },
  B10: async i=>{ const p=S.players[i]; S.captain=Math.max(0,S.captain-1); setHum(p,-1); return {msg:'You burn the note. The Captain loses your trail: he moves back 1 step. −1 humanity.'}; },
  A12: async i=>{ const p=S.players[i]; let c;
    const opts=[{label:`2 muscle, 1 organ, 1 blood`, value:[2,1,1]},{label:`1 muscle, 2 organ, 1 blood`, value:[1,2,1]},{label:`2 muscle, 2 blood`, value:[2,0,2]},{label:`2 muscle, 2 organ`, value:[2,2,0]}];
    if(p.ai){ const sh=aiNeeds(p).short; c = sh.B? [2,0,2] : sh.O ? [1,2,1] : [2,1,1]; } else c=await ask({title:'A blood-soaked bag', html:'<p>Gain 4 human materials at stage I. Choose:</p>', options:opts, locked:true});
    gainMats(p,[['muscle',1,c[0]],['organ',1,c[1]],['blood',1,c[2]]]); setHum(p,-2); return {msg:'You come back hours later, clutching a heavy, dripping bag. +4 materials at stage I, −2 humanity.'}; },
  A14: async i=>{ const p=S.players[i]; let n=2; for(let st=3;st>=0&&n>0;st--) for(const t of ['organ','muscle']){ const k=Math.min(n,p.mats[t][st]); p.mats[t][st]-=k; n-=k; } p.coin+=3;
    return {msg:'You stitch him with your own supplies. He drops a sack of coins. −2 flesh from your track, +3 francs.'}; },
  B14: async i=>{ const p=S.players[i]; if(p.left.assistant) p.left.assistant--; else if(p.left.scientist) p.left.scientist--; if(S.captain<11) S.captain++;
    return {msg:'You find one of your assistants dead in your bed. You lose 1 meeple today, and the Captain moves 1 step closer.'}; },
  A16: async i=>{ const p=S.players[i]; gainMats(p,[['muscle',2,1],['organ',2,1],['blood',2,1],['bone',0,1]]); setHum(p,-2); return {msg:'The bag holds your old mentor. +1 muscle, organ, blood at stage II and 1 bone. −2 humanity.'}; },
  B16: async i=>{ const p=S.players[i]; const q=S.players[(i+1)%S.players.length]; gainMats(q,[['muscle',1,1],['organ',1,1],['blood',1,1],['bone',0,1]]); setHum(p,1);
    return {msg:`He takes the bag to ${esc(q.name)} instead. They gain 1 of each human material. +1 humanity for you.`}; },
  A18: async i=>{ addCard(S.players[i],drawResearch()); return {msg:'“Then read this.” Draw 1 research card.'}; },
  B18: async i=>{ const p=S.players[i]; const ok=await placeForced(i,'lab.practice','scientist', async()=>{ setExp(p,2); });
    return {msg: ok ? 'He drags you back to your bench. Your scientist practises: +2 expertise.' : 'He drags you to your bench, but you have no scientist free.'}; },
  A20: async i=>{ const p=S.players[i]; takeFirst(i); p.noHumLoss=true; let at='';
    for(const kind of ['scientist','assistant']){ if(p.left[kind] && !S.occ['church.atone']){ S.occ['church.atone']={p:i, kind}; p.left[kind]--; const c=S.humanityRow[0]; if(c) takeRowCard(p,S.humanityRow,c.id); if(kind==='scientist') setHum(p,1); at=` Your ${kind} goes to Saint-Roch.`; break; } }
    return {msg:`You agree to help. You become first player and cannot lose humanity today.${at}`}; },
  B20: async i=>{ const p=S.players[i]; const d=setHum(p,-2); if(!d) S.players.forEach((q,k)=>{ if(k!==i) setHum(q,1); }); return {msg: d? 'You refuse. −2 humanity.' : 'You refuse, but you have no humanity left to lose. Everyone else gains 1 humanity.'}; },
  A22: async i=>{ S.players[i].coin+=3; return {msg:'He leaves a few coins on the bench. +3 francs.'}; },
  B22: async i=>{ const r=downgradeOne(S.players[i]); return {msg:`He strikes your work in a fury: ${r}.`}; },
  // Location encounters (ctx says what the visit was)
  A24: async (i)=>{ const p=S.players[i]; if(p.coin>=1) p.coin--; else setRep(p,-1);
    const all=SCOUNDRELS.map((t,k)=>({id:uid(), kind:'scoundrel', tpl:k, ...t, who:pick(SC_WHO[t.kind]), seed:1+rnd(9999)})).filter(c=>scCost(c)<=p.coin && scAllowed(c));
    if(all.length){ let c; if(p.ai){ const b=aiBestScoundrel(p, all); c=b&&b.c; } else c=await chooseScoundrel(p, all, 'She knows everyone. Hire any scoundrel in Paris.');
      if(c) await hireScoundrel(i, c.card, c.how, all); }
    S.decks.sc=shuffle(SCOUNDRELS.map((r,k)=>k)); S.docks=[drawScoundrel(),drawScoundrel(),drawScoundrel()];
    return {skip:true, msg:'She takes a coin and leads you to the right man.'}; },
  B24: async i=>{ const p=S.players[i]; p.coin=Math.max(0,p.coin-2); return {skip:true, msg:'Her friends knock you down and empty your purse. −2 francs, and no business today.'}; },
  A26: async i=>{ setHum(S.players[i],-1); return {extra:2, msg:'You load a trolley with the dead. 2 extra cadavers this time, −1 humanity.'}; },
  B26: async i=>{ const p=S.players[i]; setHum(p,3); p.coin+=1; return {skip:true, msg:'You roll up your sleeves and save who you can. +3 humanity, +1 franc.'}; },
  A28: async i=>{ setHum(S.players[i],2); return {skip:true, msg:'You listen to the Captain’s tale of Victor. +2 humanity, but no research today.'}; },
  B28: async i=>{ const p=S.players[i]; setHum(p,-1); addCard(p,drawResearch()); return {skip:true, msg:'You gather your papers and leave. −1 humanity, draw 1 research card.'}; },
  A29: async i=>({fresh:true, msg:'In the grave lie three bodies, alarmingly fresh. Bones-only cards are redrawn and every body counts as stage I. Resolving any costs 1 humanity in total.'}),
  B29: async i=>({two:true, msg:'You dig elsewhere. You draw only 2 cards, but none of them cost humanity.'}),
};
async function outcomeC2(t){
  const p=S.players[t];
  const aid = p.ai ? p.hum<2 : await askYN('A visitor in soot','A man in soot begs you to help him destroy your patron. Will you aid Captain Walton?','Aid him','Send him away');
  if(aid){ addCard(p,drawHumanity()); setHum(p,1); log(`${B(p)} promises to help the Captain: a humanity card and +1 humanity.`); }
  else { addCard(p,drawResearch()); setHum(p,-2); log(`${B(p)} sends the Captain away: a research card and −2 humanity.`); }
}

/* =========================================================
   CITY PHASE
   ========================================================= */
const spaceList = () => LOCS.filter(l=>!l.event || (l.event==='odeon'&&S.odeonOpen)).flatMap(l=>l.spaces.map(s=>l.id+'.'+s.k));
const allKeys = () => [...spaceList(), ...LABSPOTS.map(l=>'lab.'+l.id)];
function bumpInfo(i,key){
  const o=S.occ[key]; if(!o) return {cost:0, bump:false};
  const sp=SPACE[key]; if(sp.nobump) return null;
  if(sp.freebump) return {cost:0, bump:true, free:true};
  const track=BUMP_TRACK[S.players.length]||[1,1,2]; if(S.bump.length>=track.length) return null;
  return {cost: o.p===i?0:track[S.bump.length], bump:true};
}
function spaceNeeds(i,key){
  const p=S.players[i];
  switch(key){
    case 'square.buy': return S.square.length?1:null;
    case 'morgue.buy': return 1;
    case 'hospital.retrieve': { if(!S.hosp.length) return null; if(p.rep>=7) return 0; return S.ev==='corrupt'?1:null; }
    case 'hospital.work': return S.ev==='hardtimes'?null:0;
    case 'academy.donate': return 1;
    case 'market.trade': return (p.coin>=1||p.bone>=2||p.preserved>=3)?0:null;
    case 'docks.hire': { const c=S.docks.filter(scAllowed).map(scCost); return c.length?Math.min(...c):null; }
    case 'alley.murder': return p.police>=2?null:0;
    case 'odeon.show': return p.odeonUsed?null:0;
    case 'lab.repair': return dmgTotal(p)>0?0:null;
    case 'lab.charge': return p.jars.some(j=>!j)?0:null;
  }
  return 0;
}
function canPlace(i,key,kind){
  const p=S.players[i];
  if(!kind) return canPlace(i,key,'scientist')||canPlace(i,key,'assistant');
  if(!p.left[kind]) return false;
  if(key.startsWith('lab.')){ const s=LABSPOT[key.slice(4)]; if(p.labUsed[s.id]) return false; if(s.sci&&kind!=='scientist') return false; return spaceNeeds(i,key)!==null; }
  const sp=SPACE[key]; if(!sp) return false;
  if(S.closed[sp.loc]) return false;
  if(sp.sci && kind!=='scientist') return false;
  if(sp.loc==='academy' && S.ev==='parade' && kind!=='scientist') return false;
  const need=spaceNeeds(i,key); if(need===null) return false;
  const b=bumpInfo(i,key); if(!b) return false;
  return p.coin >= need + b.cost;
}
function legalAny(i){ return allKeys().some(k=>canPlace(i,k)); }
function kindFor(i,key){ const p=S.players[i]; if(canPlace(i,key,p.sel)) return p.sel; const o=p.sel==='scientist'?'assistant':'scientist'; return canPlace(i,key,o)?o:null; }

async function cityPhase(tok){
  const n=S.players.length; let guard=0;
  while(tok===gameToken && guard++<200){
    let next=-1;
    for(let k=0;k<n;k++){ const i=(S.cur+k)%n, p=S.players[i]; if(leftN(p)>0 && legalAny(i)){ next=i; break; } else if(leftN(p)>0){ log(`${B(p)} has nowhere left to go and passes.`); p.left={scientist:0,assistant:0}; } }
    if(next<0) break;
    S.cur=next; save(); render();
    if(S.players[next].ai){ await sleep(550); if(tok!==gameToken) return; await aiTurn(next); }
    else { await humanTurn(); if(tok!==gameToken) return; }
    S.cur=(next+1)%n;
  }
  if(tok!==gameToken) return;
  S.phase='firstmove'; save(); render();
}
let humanResolve=null;
function humanTurn(){ return new Promise(r=>{ humanResolve=r; render(); }); }
function endHumanTurn(){ const r=humanResolve; humanResolve=null; if(r) r(); }

// Place a meeple on a space and resolve it. choice may be precomputed (AI); human prompts happen inside.
async function placeAndResolve(i, key, kind, pre){
  const p=S.players[i];
  if(key.startsWith('lab.')){ p.labUsed[key.slice(4)]=kind; p.left[kind]--; await resolveLab(i,key.slice(4),kind,pre); return; }
  const b=bumpInfo(i,key);
  if(b && b.bump){ const o=S.occ[key], owner=S.players[o.p];
    if(b.free){ owner.left[o.kind]++; log(`${B(p)} bumps ${esc(owner.name)} from the theatre. Their meeple goes home.`); }
    else { S.bump.push(o); if(b.cost){ p.coin-=b.cost; owner.coin+=b.cost; } log(`${B(p)} bumps ${esc(owner.name)} from ${esc(LOC[SPACE[key].loc].name)}${b.cost?` and pays them ${fr(b.cost)}`:''}.`);
      if(SPACE[key].loc==='academy' && hasChar(owner,'charlatan') && o.p!==i) setRep(owner,1); }
  }
  S.occ[key]={p:i, kind}; p.left[kind]--;
  // Secret location encounters
  let mod={};
  if(S.locEnc){ const e=ENCOUNTERS.find(x=>x.id===S.locEnc.id); if(e.loc===key && S.locEnc.holder!==i){ S.locEnc=null; mod=await runEncounter(e,i,{key})||{}; } }
  if(mod.skip) return;
  await resolveSpace(i,key,kind,pre,mod);
  checkObjectives();
}

/* ---------- Space effects ---------- */
async function resolveSpace(i,key,kind,pre,mod){
  const p=S.players[i]; pre=pre||{}; mod=mod||{};
  const sci = kind==='scientist';
  switch(key){
    case 'cemetery.dig': {
      let n = mod.two?2:3; if(S.ev==='cholera') n++;
      let cards=[]; for(let k=0;k<n;k++){ let c=drawCadaver('cemetery'); if(mod.fresh){ let g=0; while(!c.exp && g++<6) c=drawCadaver('cemetery'); } cards.push(c); }
      if(mod.fresh) cards.forEach(c=>{ c.mats=c.mats.map(([t,st,k])=>[t,t==='bone'?0:1,k]); c.stage=1; });
      const extraH = S.ev==='toussaint'?1:0;
      await resolveCadavers(i, cards, {title:'Graveyard', intro:'You dig by lantern light.', noCardCost: mod.fresh||mod.two, flatCost: mod.fresh?1:0, extraH});
      break; }
    case 'square.buy': {
      p.coin-=1; const card=S.square.find(x=>x.id===pre.card) || S.square[0]; S.square=S.square.filter(x=>x!==card);
      if(pre.bury){ const c=p.hand.find(h=>h.id==='burial'); if(c){ p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain); log(`${B(p)} gives ${esc(card.name)} a decent burial.`); break; } }
      if(card.cost) p.coin=Math.max(0,p.coin-card.cost);
      await resolveCadavers(i,[card],{title:'Public Square', intro:'The crowd has gone home.', single:true});
      break; }
    case 'morgue.buy': {
      p.coin-=1; let n=2+(S.ev==='cholera'?1:0); const cards=Array.from({length:n},()=>drawCadaver('morgue'));
      await resolveCadavers(i,cards,{title:'Morgue', intro:'The keeper pulls back the sheets.', extraH:S.ev==='toussaint'?1:0});
      break; }
    case 'slaughter.take': {
      const three = pre.opt==='three';
      if(three) addMat(p,'animal',1,3); else addMat(p,'animal',2,4);
      if(S.ev==='meat'){ addMat(p,'animal',three?1:2,2); p.coin+=1; }
      log(`${B(p)} takes ${three?'3 animal at stage I':'4 animal at stage II'} from the Slaughterhouse${S.ev==='meat'?', plus 2 more and 1 franc':''}.`);
      break; }
    case 'hospital.retrieve': {
      const lim=hospLimits(p); let want=(pre.cards&&pre.cards.length)?pre.cards.length:Math.max(1,lim.free);
      want=Math.min(want, lim.free+lim.paid, S.hosp.length); while(want>lim.free && p.coin < want-lim.free) want--;
      p.coin-=Math.max(0,want-lim.free);
      const chosen=(pre.cards||[]).map(id=>S.hosp.find(c=>c.id===id)).filter(Boolean).slice(0,want);
      for(const c of S.hosp){ if(chosen.length>=want) break; if(!chosen.includes(c)) chosen.push(c); }
      S.hosp=S.hosp.filter(c=>!chosen.includes(c));
      const cards=[...chosen]; for(let k=0;k<(mod.extra||0);k++) cards.push(drawCadaver('hospital'));
      await resolveCadavers(i,cards,{title:'Hospital', intro:'The porter wheels out the dead.', extraH:S.ev==='toussaint'?1:0});
      break; }
    case 'hospital.work': { const g=(p.exp>=13?4:p.exp>=7?3:2)+(S.ev==='cholera'?2:0); p.coin+=g; log(`${B(p)} works a shift at the Hospital: +${fr(g)}.`); break; }
    case 'hospital.volunteer': { setHum(p,1); setRep(p,2); log(`${B(p)} volunteers on the wards: +1 humanity, +2 reputation.`); break; }
    case 'academy.adv': { setExp(p,1); takeRowCard(p,S.researchRow,pre.card); if(S.ev==='grant') p.coin+=2; log(`${B(p)} does advanced research: +1 expertise and a research card.`); break; }
    case 'academy.research': { takeRowCard(p,S.researchRow,pre.card); if(S.ev==='grant') p.coin+=2; log(`${B(p)} takes a research card.`); break; }
    case 'academy.lecture': {
      if(pre.card){ const c=p.hand.find(h=>h.id===pre.card);
        if(c && (c.id==='animal'||c.id==='human')){ p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain,'humanity'); log(`${B(p)} lectures on ${c.id==='animal'?'mercy for beasts':'the dignity of the dead'}: +3 humanity.`); if(S.ev==='grant') p.coin+=2; break; } }
      const r=1+(sci?1:0); if(S.ev!=='hardtimes') p.coin+=1; setRep(p,r); if(S.ev==='grant') p.coin+=2;
      if(pre.card){ const c=p.hand.find(h=>h.id==='guest'&&h.id===pre.card); if(c){ p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain,'research'); } }
      log(`${B(p)} lectures at the Academy: +${r} reputation.`); break; }
    case 'academy.donate': { const n=clamp(pre.n||1,1,Math.min(3,p.coin)); p.coin-=n; setRep(p,n); log(`${B(p)} donates ${fr(n)}: +${n} reputation.`); break; }
    case 'market.trade': await doMarket(i,pre); break;
    case 'docks.hire': await hireScoundrel(i, pre.card, pre.how, S.docks, pre.unethical); break;
    case 'alley.murder': {
      p.lastDark=S.round;
      if(pre.unethical){ const c=p.hand.find(h=>h.id==='unethical'); if(c && charged(p)){ dischargeOne(p); p.hand=p.hand.filter(h=>h!==c); setHum(p,-3); addPolice(p); applyGain(p,c.gain,'research'); log(`${B(p)} conducts an unethical experiment in the Dark Alley.`); break; } }
      gainMats(p,[['muscle',1,4],['organ',1,4],['blood',1,3],['bone',0,2]]); setHum(p,-3); addPolice(p);
      log(`${B(p)} commits murder in the Dark Alley and earns a police marker.`); break; }
    case 'church.atone': { takeRowCard(p,S.humanityRow,pre.card); if(sci) setHum(p,1); log(`${B(p)} atones at Saint-Roch${sci?': +1 humanity and':', taking'} a humanity card.`); break; }
    case 'first.first': { takeFirst(i); log(`${B(p)} becomes first player.`); break; }
    case 'odeon.show': { p.odeonUsed=true; setRep(p,2); log(`${B(p)} is seen at the Odéon: +2 reputation.`); break; }
  }
}
function takeRowCard(p,row,cardId){
  let idx=row.findIndex(x=>x.id===cardId); if(idx<0) idx=0; if(!row[idx]) return;
  const c=row[idx]; const repl = c.kind==='research'?drawResearch():drawHumanity(); row.splice(idx,1); if(repl) row.splice(idx,0,repl);
  addCard(p,c);
  if(p.ai) aiMaybePlay(S.players.indexOf(p));
}
async function resolveLab(i,s,kind,pre){
  const p=S.players[i]; pre=pre||{};
  if(s==='practice'){ setExp(p,1); log(`${B(p)} practises: +1 expertise.`); }
  if(s==='blood'){ if(pre.transfusion){ const c=p.hand.find(h=>h.id==='transfusion'); if(c){ p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain,'research'); log(`${B(p)} performs a transfusion.`); return; } }
    addMat(p,'blood',1,3); log(`${B(p)} gives blood: 3 blood at stage I.`); }
  if(s==='repair'){ let r=3; for(const sl of SLOT6){ const t=p.table[sl]; if(t&&t.dmg&&r>0){ const k=Math.min(r,t.dmg); t.dmg-=k; r-=k; } } log(`${B(p)} repairs the parts on the table.`); }
  if(s==='charge'){ let r=kind==='scientist'?3:2; p.jars=p.jars.map(j=>{ if(!j&&r>0){r--; return true;} return j; }); log(`${B(p)} charges Leyden jars.`); }
  checkObjectives();
}

/* Cadaver resolution (shared) */
async function resolveCadavers(i, cards, o){
  const p=S.players[i]; if(!cards.length) return;
  let picks;
  if(p.ai) picks=aiCadaverPicks(p,cards,o);
  else picks=await cadaverModal(p,cards,o);
  let flatPaid=false;
  for(const c of cards){
    const pk=picks[c.id]||{how:'leave'}; if(pk.how==='leave') continue;
    const hc = o.noCardCost?0:(c.hcost + (o.extraH||0));
    if(o.flatCost && !flatPaid){ setHum(p,-o.flatCost); flatPaid=true; }
    if(hc) setHum(p,-hc);
    const card = pk.card ? p.hand.find(h=>h.id===pk.card) : null;
    if(card && (card.id==='dissect' || card.id==='electro')){ if(card.id==='electro') dischargeOne(p); p.hand=p.hand.filter(h=>h!==card); applyGain(p,card.gain,'research'); log(`${B(p)} studies ${esc(c.name)} closely (${esc(card.name)}).`); continue; }
    let mats=c.mats;
    if(card && card.id==='daisy'){ p.hand=p.hand.filter(h=>h!==card); applyGain(p,card.gain,'research'); mats=mats.map(([t,st,k])=>[t,t==='bone'?0:1,k]); }
    if(pk.how==='exp' && c.exp){ setExp(p,c.exp); log(`${B(p)} dissects ${esc(c.name)}: +${c.exp} expertise.`); }
    else { gainMats(p,mats); log(`${B(p)} takes ${esc(c.name)}: ${matsHTML(mats)}`); }
  }
  checkObjectives();
}

/* Scoundrels */
async function hireScoundrel(i, cardId, how, row, unethical){
  const p=S.players[i]; const c=row.find(x=>x.id===cardId); if(!c) return;
  const cost=scCost(c); if(cost>p.coin) return;
  p.coin-=cost; setHum(p,-scHcost(c));
  if(row===S.docks){ S.docks.splice(S.docks.indexOf(c),1,drawScoundrel()); }
  if(c.kind==='cut') p.lastDark=S.round;
  if(unethical && c.kind==='cut'){ const u=p.hand.find(h=>h.id==='unethical'); if(u && charged(p)){ dischargeOne(p); p.hand=p.hand.filter(h=>h!==u); applyGain(p,u.gain,'research'); log(`${B(p)} hires a Cutthroat for an unethical experiment.`); return; } }
  if(c.kind==='thief'){ const cards=[]; for(let k=0;k<c.draw;k++) cards.push(S.hosp.length?S.hosp.shift():drawCadaver('hospital'));
    log(`${B(p)} hires a Hospital Thief, who steals ${cards.length} ${cards.length===1?'body':'bodies'} from the Hospital (no reputation needed).`); await resolveCadavers(i,cards,{title:'Hospital Thief', intro:'The thief wheels in a covered trolley.', extraH:0}); return; }
  if(how==='exp' && c.exp){ setExp(p,c.exp); if(c.expH) setHum(p,-c.expH); log(`${B(p)} hires a ${esc(c.name)}: +${c.exp} expertise.`); }
  else if(how==='hum' && c.hum){ setHum(p,c.hum); log(`${B(p)} hires a ${esc(c.name)} and lets the dogs go: +${c.hum} humanity.`); }
  else { gainMats(p,c.mats); log(`${B(p)} hires a ${esc(c.name)}: ${matsHTML(c.mats)}`); }
}

/* Market */
async function doMarket(i,o){
  const p=S.players[i]; const bits=[];
  const sb=Math.min(o.sellBone||0, Math.floor(p.bone/2)); if(sb){ p.bone-=2*sb; p.coin+=sb; bits.push(`sells ${2*sb} bone`); }
  const sp=Math.min(o.sellPres||0, Math.floor(p.preserved/3)); if(sp){ p.preserved-=3*sp; let g=2*sp;
    const pick=o.pickle && p.hand.find(h=>h.id==='preserve'); if(pick){ p.hand=p.hand.filter(h=>h!==pick); g+=sp; }
    p.coin+=g; bits.push(`sells ${3*sp} preserved flesh`); }
  let bj=Math.min(o.jars||0, 4-p.jars.length); let paid=0;
  for(let k=0;k<bj;k++){ const free = S.ev==='hardtimes' && k%2===1; if(!free){ if(p.coin<2) break; p.coin-=2; } p.jars.push(S.ev==='storm'||S.ev==='meat'||S.ev==='graves'||S.ev==='cholera'||S.ev==='darkres'||S.ev==='storm2'); paid++; }
  if(paid) bits.push(`buys ${paid} jar${paid>1?'s':''}`);
  if(o.ice && p.coin>=1){ p.coin-=1; p.ice=2; bits.push('buys ice'); }
  log(`${B(p)} at the Market ${bits.join(', ')||'browses'}.`);
}

/* ---------- First player meeple may move ---------- */
async function firstMovePhase(){
  const o=S.occ['first.first']; if(!o) return;
  const i=o.p, p=S.players[i];
  const keys=spaceList().filter(k=>k!=='first.first' && !k.startsWith('lab.')).filter(k=>{ p.left[o.kind]++; const ok=canPlace(i,k,o.kind); p.left[o.kind]--; return ok; });
  if(!keys.length) return;
  let key=null, pre=null;
  if(p.ai){ const c=aiChoose(i, keys, o.kind); if(c && c.s>2.5){ key=c.key; pre=c.pre; } }
  else if(!S.fast){
    key=await ask({title:'The first player’s meeple', html:'<p>Everyone has finished. You may move your meeple from the First Player space to another space and use it.</p>',
      options:[...keys.map(k=>({label:`${esc(LOC[SPACE[k].loc].name)}: ${esc(SPACE[k].n)}`, sub:S.occ[k]?`Bump ${esc(S.players[S.occ[k].p].name)}`:'', value:k})), {label:'Stay put', value:null}], locked:true});
    if(key){ pre=await humanPre(i,key,o.kind); if(pre===null) key=null; }
  }
  if(!key) return;
  delete S.occ['first.first']; p.left[o.kind]++;
  log(`${B(p)} moves their meeple from the First Player space.`);
  await placeAndResolve(i,key,o.kind,pre);
  save(); render();
}

/* =========================================================
   LAB PHASE
   ========================================================= */
let labResolve=null;
async function labPhase(){
  log('Night. The laboratories light their lamps.', 'day');
  S.players.forEach((p,i)=>{ if(p.ai && !p.labDone){ aiLab(i); p.labDone=true; } });
  save(); render();
  if(!S.players[0].ai){ await new Promise(r=>{ labResolve=r; render(); }); labResolve=null; }
  const done=S.players.filter(p=>aliveCount(p)===6);
  if(done.length){ finish('alive'); return; }
  S.phase='dawn'; save();
}
function endLab(){ if(labResolve) labResolve(); }

function nextStep(p,slot){ const t=p.table[slot]; return !t?'start' : t.side==='muscle'?'comp' : null; }
function planBuild(p, slot, policy, opts){
  opts=opts||{};
  const type=SLOT_T[slot], step=nextStep(p,slot); if(!step) return null;
  const P=PARTS[type]; const req0 = step==='start'?P.start:P.comp; const req={...req0};
  if(opts.steady) for(const k in req) req[k]=Math.max(0,req[k]-1);
  if(opts.surgeon){ const k=opts.surgeon in req && req[opts.surgeon]>0 ? opts.surgeon : Object.keys(req).sort((a,b)=>req[b]-req[a])[0]; req[k]=Math.max(0,req[k]-1); }
  const m = JSON.parse(JSON.stringify(p.mats)); let bone=p.bone, worst=0, animal=0, ok=true;
  const order = policy==='old' ? [3,2,1,0] : [0,1,2,3];
  for(const [k,n0] of Object.entries(req)){
    let n=n0; if(!n) continue;
    if(k==='X'){ if(bone<n){ ok=false; break; } bone-=n; continue; }
    const t=KEY[k];
    for(const st of order){ const take=Math.min(n,m[t][st]); if(take){ m[t][st]-=take; n-=take; worst=Math.max(worst,st+1);} if(!n) break; }
    if(n){ const allowed = t==='blood' ? order.filter(s=>s<=1) : order;
      for(const st of allowed){ const take=Math.min(n,m.animal[st]); if(take){ m.animal[st]-=take; n-=take; animal+=take; worst=Math.max(worst,st+1);} if(!n) break; } }
    if(n){ ok=false; break; }
  }
  const expOK = p.exp>=P.exp;
  const table = step==='start'?P.vpS:P.vpC;
  const vp = ok ? Math.max(0, table[Math.max(1,worst)-1] - (animal>=3?2:animal?1:0)) : 0;
  return {ok: ok&&expOK, matsOK:ok, expOK, step, req, vp, worst, animal, mats:m, bone};
}
function build(i, slot, policy, opts){
  const p=S.players[i]; if(S.phase!=='lab') return null; opts=opts||{};
  if(opts.steady && !p.hand.some(h=>h.id==='steady')) opts.steady=false;
  if(opts.surgeon && (!hasChar(p,'surgeon')||p.surgeonUsed)) opts.surgeon=false;
  const pl=planBuild(p,slot,policy,opts); if(!pl||!pl.ok) return null;
  p.mats=pl.mats; p.bone=pl.bone;
  if(opts.steady){ const c=p.hand.find(h=>h.id==='steady'); p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain,'research'); }
  if(opts.surgeon) p.surgeonUsed=true;
  if(pl.step==='start') p.table[slot]={side:'muscle', alive:false, dmg:0}; else { p.table[slot].side='skin'; }
  p.vp+=pl.vp; setExp(p,1);
  log(`${B(p)} ${pl.step==='start'?'starts':'completes'} the ${SLOT_N[slot].toLowerCase()} (+${pl.vp} VP).`);
  checkObjectives();
  return pl;
}
function preserve(p,t,n){ const room=9-p.preserved; n=Math.min(n,room); let moved=0;
  for(let st=3;st>=0&&moved<n;st--){ const k=Math.min(n-moved,p.mats[t][st]); p.mats[t][st]-=k; moved+=k; } p.preserved+=moved; return moved; }
function placeDamage(p){
  const parts=onTable(p); if(!parts.length) return null;
  const minD=Math.min(...parts.map(s=>p.table[s].dmg));
  const rank=s=>{ const t=p.table[s]; return (t.alive?0:t.side==='skin'?10:20) + PARTS[SLOT_T[s]].alive; };
  const s=parts.filter(s=>p.table[s].dmg===minD).sort((a,b)=>rank(a)-rank(b))[0];
  const t=p.table[s]; t.dmg++;
  if(t.dmg>=2){ t.dmg=0;
    if(t.alive){ t.alive=false; return `The ${SLOT_N[s].toLowerCase()} dies again.`; }
    if(t.side==='skin'){ t.side='muscle'; return `The ${SLOT_N[s].toLowerCase()} splits its skin.`; }
    p.table[s]=null; return `The ${SLOT_N[s].toLowerCase()} is destroyed.`;
  }
  return null;
}
function canThrow(p){ return S.phase==='lab' && !p.thrown && charged(p)>0 && SLOT6.some(s=>p.table[s]&&p.table[s].side==='skin'); }
function rollDice(p, n, extraGray){
  const nd=2*n; let blue=Math.min(nd, blueDice(p));
  const dice=[]; for(let d=0;d<nd;d++) dice.push(d<blue?{c:'blue',f:pick(BLUE)}:{c:'gray',f:pick(GRAY)});
  for(let k=0;k<(extraGray||0);k++) dice.push({c:'gray',f:pick(GRAY)});
  return dice;
}
function reroll(d){ d.f = pick(d.c==='blue'?BLUE:GRAY); }
function applyMitigation(dice, mit, st){
  switch(mit){
    case 'ignoreDmg': st.ignoreDmg=true; break;
    case 'ignoreHeart': st.ignoreHeart=true; break;
    case 'rerollAny': dice.forEach(d=>{ if(d.f!=='alive') reroll(d); }); break;
    case 'rerollDmg': dice.forEach(d=>{ if(d.f==='damage') reroll(d); }); break;
    case 'rerollGray': dice.forEach(d=>{ if(d.c==='gray'&&d.f!=='alive') reroll(d); }); break;
    case 'rerollBlue': dice.forEach(d=>{ if(d.c==='blue'&&d.f!=='alive') reroll(d); }); break;
    case 'willing': { let k=0; dice.forEach(d=>{ if(k<2 && (d.f==='damage'||d.f==='heart'||d.f==='blank')){ reroll(d); k++; } }); break; }
  }
}
function resolveThrow(i, dice, st){
  const p=S.players[i]; const cnt=f=>dice.filter(d=>d.f===f).length; const notes=[];
  let dmg=st.ignoreDmg?0:cnt('damage'); for(let d=0;d<dmg;d++){ const r=placeDamage(p); if(r) notes.push(r); }
  if(cnt('heart') && !st.ignoreHeart){ if(setHum(p,-1)) notes.push('The screams cost you 1 humanity.'); }
  let lit=[];
  for(let a=0;a<cnt('alive');a++){
    const s=SLOT6.filter(s=>p.table[s]&&p.table[s].side==='skin'&&!p.table[s].alive).sort((x,y)=>PARTS[SLOT_T[y]].alive-PARTS[SLOT_T[x]].alive)[0];
    if(!s) break; p.table[s].alive=true; lit.push(SLOT_N[s].toLowerCase());
  }
  if(lit.length) notes.unshift(`Alive: ${lit.join(', ')}.`);
  log(`${B(p)} throws the switch. ${lit.length?`It lives: ${lit.join(', ')}.`:'Nothing stirs.'}`);
  checkObjectives();
  return notes;
}
function startThrow(i,n,useZoo){
  const p=S.players[i]; n=clamp(n,1,Math.min(3,charged(p)));
  let k=n; p.jars=p.jars.map(j=>{ if(j&&k>0){k--; return false;} return j; });
  p.thrown=true;
  const extra = (useZoo && hasChar(p,'zoo') && !p.zooUsed) ? 1 : 0; if(extra) p.zooUsed=true;
  const dice=rollDice(p,n,extra);
  if(p.sabotaged && dice.length){ dice.splice(rnd(dice.length),1); p.sabotaged--; log(`Cut wires: ${esc(p.name)} loses a die.`); }
  return dice;
}
async function humanThrow(n){
  const p=S.players[0]; if(!canThrow(p)) return;
  const dice=startThrow(0,n,true); const st={}; let willing = S.ev==='willing';
  render();
  while(true){
    const cards=p.hand.filter(h=>h.kind==='research');
    const choice=await ask({title:'You throw the switch', wide:true, locked:true, html:`<div class="sdice">${dice.map(d=>`<span class="sdie ${d.c} roll" title="${d.f}">${DIEICON[d.f]}</span>`).join('')}</div>
      <p class="sum">Eye: a finished part comes alive · Bolt: damage · Broken heart: −1 humanity${st.ignoreDmg?' · <b>bolts ignored</b>':''}${st.ignoreHeart?' · <b>hearts ignored</b>':''}</p>
      ${cards.length||willing?'<p style="font-size:13px;color:var(--parch-dim)">Before the result counts, you may spend research cards to change the dice.</p>':''}`,
      options:[...(willing?[{label:'The Flesh Is Willing', sub:'Re-roll up to 2 bad dice, free.', value:'willing'}]:[]),
        ...cards.map(c=>({label:`${esc(c.name)}: ${MIT_N[c.mit]}`, sub:'Discards the card.', value:c.id}))],
      buttons:[{label:'Accept the result', primary:true, value:'ok'}]});
    if(choice==='ok') break;
    if(choice==='willing'){ applyMitigation(dice,'willing',st); willing=false; continue; }
    const c=p.hand.find(h=>h.id===choice); if(c){ p.hand=p.hand.filter(h=>h!==c); applyMitigation(dice,c.mit,st); }
  }
  const notes=resolveThrow(0,dice,st); save(); render();
  if(dice.some(d=>d.f==='alive')) flash();
  if(!S.fast) await ask({title:'The current fades', html:notes.length?`<ul class="dawnlist">${notes.map(x=>`<li>${x}</li>`).join('')}</ul>`:'<p style="text-align:center">The current crackles through dead flesh. Nothing stirs.</p>', buttons:[{label:'Continue', primary:true, value:1}]});
}

/* =========================================================
   DAWN (reset)
   ========================================================= */
function decay(p){ for(const t of MATS){ const a=p.mats[t]; p.mats[t]=[0, a[0], t==='blood'?0:a[1], a[2]]; } }
async function dawnPhase(){
  log('Dawn.', 'day');
  S.players.forEach(p=>{
    const before=sum(MATS.map(t=>p.mats[t][3]))+p.mats.blood[1];
    if(p.ice>0){ p.ice--; if(!p.ai) S.dawn.push(p.ice?'Your ice keeps everything fresh. It is half melted now.':'Your ice keeps everything fresh, then melts away.'); }
    else { decay(p); if(before && !p.ai) S.dawn.push(`${before} of your materials rotted away.`); }
  });
  refreshBoard();
  S.captain++;
  if(S.captain>=MAX_ROUNDS){ finish('captain'); return; }
  S.round++; S.phase='event'; save(); render();
  if(!S.players[0].ai && !S.fast){
    const lines=S.dawn.length?S.dawn:['A grey dawn. Your materials have aged one stage.'];
    await ask({title:`Dawn of Day ${S.round}`, html:`<ul class="dawnlist">${lines.map(l=>`<li>${l}</li>`).join('')}</ul>
      <p class="flavor" style="margin-top:12px">Captain Walton is ${MAX_ROUNDS-S.captain} step${MAX_ROUNDS-S.captain!==1?'s':''} from the Creature. ${esc(S.players[S.first].name)} is first player.</p>`,
      buttons:[{label:`Begin Day ${S.round}`, primary:true, value:1}], locked:true});
  }
}

/* =========================================================
   CARDS IN HAND (play)
   ========================================================= */
function cardPlayable(i,c){
  const p=S.players[i], day=S.phase==='day', lab=S.phase==='lab', myTurnNow = day && S.cur===i && !p.ai ? !!humanResolve : day && S.cur===i;
  if(c.kind==='research'){
    if(c.when==='any'){ if(c.effect==='demo') return charged(p)>0 && matTotal(p,'animal')>=2; if(c.effect==='heal') return dmgTotal(p)>0 || true; return day||lab; }
    if(c.id==='midnight') return myTurnNow && Object.keys(S.occ).some(k=>S.occ[k].p===i && k!=='first.first');
    if(c.id==='publish') return myTurnNow && p.left.scientist>0;
    return false;
  }
  if(c.when==='aid') return (day||S.phase==='event') && !p.aidPlayed && S.round<11 && p.coin>=c.cost;
  if(c.when==='any'){ if(c.effect==='thwart') return day && S.thwart==null; return day; }
  if(c.when==='target'){ const others=S.players.filter((q,k)=>k!==i && (c.effect!=='burn' || q.hand.filter(h=>h.kind==='research').length>=2)); return (day||lab) && others.length>0; }
  return false;
}
async function playCard(i, cardId, targetIdx){
  const p=S.players[i]; const c=p.hand.find(h=>h.id===cardId); if(!c || !cardPlayable(i,c)) return false;
  // targeted humanity cards can be countered
  if(c.when==='target'){
    const q=S.players[targetIdx]; if(!q) return false;
    p.hand=p.hand.filter(h=>h!==c); applyGain(p,c.gain,'humanity');
    const ctr=q.hand.find(h=>h.id==='counter');
    if(ctr){ q.hand=q.hand.filter(h=>h!==ctr); applyGain(q,ctr.gain,'research'); log(`${B(p)} plays ${esc(c.name)} on ${esc(q.name)}, who had Countermeasures ready. Cancelled.`); return true; }
    if(c.effect==='sabotage'){ q.sabotaged++; log(`${B(p)} cuts ${esc(q.name)}’s wires: their next throw loses a die.`); }
    if(c.effect==='snatch'){ const took=[]; for(const t of ['muscle','organ','blood','animal']){ if(took.length>=3) break; for(let st=0;st<4;st++){ if(q.mats[t][st]>0){ q.mats[t][st]--; took.push(t); break; } } }
      if(took.length<3 && q.bone>0){ q.bone--; took.push('bone'); }
      log(`${B(p)} sends urchins into ${esc(q.name)}’s lab: ${took.length} materials gone.`); }
    if(c.effect==='burn'){ const rs=q.hand.filter(h=>h.kind==='research'); const b=pick(rs); q.hand=q.hand.filter(h=>h!==b); log(`${B(p)}’s lantern burns ${esc(q.name)}’s ${esc(b.name)}.`); }
    if(!q.ai && !S.fast && i!==0) toast(`${esc(p.name)} played ${esc(c.name)} on you.`);
    return true;
  }
  p.hand=p.hand.filter(h=>h!==c);
  if(c.kind==='research'){
    if(c.effect==='demo'){ dischargeOne(p); let n=2; for(let st=3;st>=0&&n>0;st--){ const k=Math.min(n,p.mats.animal[st]); p.mats.animal[st]-=k; n-=k; } }
    if(c.effect==='heal') SLOT6.forEach(s=>{ if(p.table[s]) p.table[s].dmg=0; });
    if(c.effect==='publish'){ p.left.scientist--; }
    if(c.id==='midnight'){ applyGain(p,c.gain,'research'); log(`${B(p)} burns the candle at both ends.`); if(!p.ai) await midnightOil(i); return true; }
    applyGain(p,c.gain,'research'); log(`${B(p)} plays ${esc(c.name)}${gainTxt(c.gain)?': '+gainTxt(c.gain):''}.`);
  } else {
    if(c.aid){ p.coin-=c.cost; p.aidPlayed=true; S.captain=Math.min(MAX_ROUNDS-1,S.captain+1); S.removed.push(c.id); log(`${B(p)} helps Captain Walton. He moves 1 step closer to the Creature.`); }
    if(c.close) c.close.forEach(l=>S.closed[l]=1);
    if(c.effect==='clearHosp'){ S.hosp=[]; }
    if(c.effect==='thwart'){ S.thwart=i; }
    applyGain(p,c.gain,'humanity'); log(`${B(p)} plays ${esc(c.name)}${gainTxt(c.gain)?': '+gainTxt(c.gain):''}.`);
  }
  checkObjectives(); return true;
}
async function midnightOil(i){
  const keys=Object.keys(S.occ).filter(k=>S.occ[k].p===i && k!=='first.first');
  const key=await ask({title:'Burning the Candle', html:'<p>Use one of your placed meeples’ spaces again. You pay its costs again.</p>', options:keys.map(k=>({label:`${esc(LOC[SPACE[k].loc].name)}: ${esc(SPACE[k].n)}`, value:k})), buttons:[{label:'Never mind', value:null}]});
  if(!key) return;
  const pre=await humanPre(0,key,S.occ[key].kind,true); if(pre===null) return;
  const need=spaceNeeds(0,key); if(need!==null && S.players[0].coin<need) return;
  await resolveSpace(0,key,S.occ[key].kind,pre,{});
  save(); render();
}

/* =========================================================
   SCORING
   ========================================================= */
function finish(reason){
  S.phase='end'; S.endReason=reason;
  const rich = S.objectives.includes('rich') ? (()=>{ const m=Math.max(...S.players.map(p=>p.coin)); const order=S.players.map((_,k)=>(S.first+k)%S.players.length); return order.find(k=>S.players[k].coin===m); })() : null;
  if(rich!=null) S.claimed.rich=rich;
  const humTop = Math.max(...S.players.map(p=>p.hum));
  const rows=S.players.map((p,i)=>{
    const alivePts=sum(SLOT6.map(s=>p.table[s]&&p.table[s].alive?PARTS[SLOT_T[s]].alive:0));
    const obj=Object.values(S.claimed).filter(k=>k===i).length*10;
    const repPts=Math.floor(p.maxRep/2), expPts=Math.floor(p.maxExp/3), humPts=p.hum;
    const capt = reason==='captain' && p.hum===humTop && humTop>0 ? 5 : 0;
    return {i,name:p.name,color:p.color,vp:p.vp,alivePts,obj,repPts,expPts,humPts,capt,alive:aliveCount(p),coin:p.coin,
      total:p.vp+alivePts+obj+repPts+expPts+humPts+capt};
  }).sort((a,b)=>b.total-a.total||b.alive-a.alive||b.coin-a.coin);
  S.final={rows, reason, round:S.round};
  try{ localStorage.removeItem(SAVE_KEY); }catch(e){}
  closeModal(); render();
}

/* =========================================================
   AI
   ========================================================= */
function aiNeeds(p){
  const steps=[];
  for(const s of SLOT6){ const st=nextStep(p,s); if(!st) continue; const P=PARTS[SLOT_T[s]]; steps.push({s, st, req:st==='start'?P.start:P.comp, exp:P.exp}); }
  steps.sort((a,b)=>(a.st==='comp'?-1:0)-(b.st==='comp'?-1:0) || a.exp-b.exp);
  const near=steps.filter(x=>x.exp<=p.exp+4).slice(0,2);
  const need={M:0,O:0,B:0,X:0}; near.forEach(x=>Object.entries(x.req).forEach(([k,n])=>need[k]+=n));
  const have={M:matTotal(p,'muscle'), O:matTotal(p,'organ'), B:p.mats.blood[0]+p.mats.blood[1], X:p.bone};
  let ani=sum(p.mats.animal);
  const short={}; for(const k of ['M','O','B','X']){ let s=Math.max(0,need[k]-have[k]); if(k!=='X'){ const u=Math.min(s,ani); s-=u; ani-=u; } short[k]=s; }
  const nextBig = steps.filter(x=>x.exp>p.exp).sort((a,b)=>a.exp-b.exp)[0];
  const expGap = nextBig ? nextBig.exp-p.exp : 0;
  const skinNotAlive = SLOT6.filter(s=>p.table[s]&&p.table[s].side==='skin'&&!p.table[s].alive).length;
  return {short, expGap, skinNotAlive, totalShort:short.M+short.O+short.B+short.X};
}
function aiCadaverPicks(p, cards, o){
  const n=aiNeeds(p), P=p.persona||{}; const picks={};
  cards.forEach(c=>{
    const hc=o&&o.noCardCost?0:c.hcost+((o&&o.extraH)||0);
    if(hc && !P.ruthless && p.hum<=-6){ picks[c.id]={how:'leave'}; return; }
    const useful = c.mats.reduce((a,[t,st,k])=>a + ((t==='muscle'&&n.short.M)||(t==='organ'&&n.short.O)||(t==='blood'&&n.short.B)||(t==='bone'&&n.short.X) ? k : k*.4) * (st>=4?.5:1),0);
    let how = (n.expGap>0 && c.exp>=2 && useful<3) ? 'exp' : 'mats';
    if(!c.exp) how='mats';
    const pk={how};
    if(how==='mats' && c.stage>=2 && p.hand.some(h=>h.id==='daisy')) pk.card='daisy';
    picks[c.id]=pk;
  });
  return picks;
}
function aiBestScoundrel(p, row){
  const n=aiNeeds(p); let best=null;
  for(const c of row){
    if(scCost(c)>p.coin || !scAllowed(c)) continue;
    const hc=scHcost(c);
    if(c.kind==='thief'){ const s=1.5+c.draw*1.6*(n.totalShort>0?1:.5)-scCost(c)*.6-hc*.4; if(!best||s>best.s) best={s,c:{card:c.id,how:'mats'}}; continue; }
    const mv = (c.mats||[]).reduce((a,[t,st,k])=>a+k*(st>=4?.5:st>=3?.75:1)*(((t==='muscle'||t==='animal')&&n.short.M)||(t==='organ'&&n.short.O)||(t==='blood'&&n.short.B)||(t==='bone'&&n.short.X)?.9:.35),0);
    const opts=[{how:'mats', v:mv}]; if(c.exp) opts.push({how:'exp', v:c.exp*(n.expGap>0?1.6:.6)-(c.expH||0)*.5}); if(c.hum) opts.push({how:'hum', v:c.hum*(p.hum<0?.9:.4)});
    for(const o of opts){ const s=1.2+o.v*.6-scCost(c)*.6-hc*(p.persona&&p.persona.ruthless?.1:.5); if(!best||s>best.s) best={s, c:{card:c.id, how:o.how}}; }
  }
  return best;
}
function aiSpaceOptions(i,key,kind){
  const p=S.players[i], P=p.persona||{}, n=aiNeeds(p), sh=n.short, late=S.round>=MAX_ROUNDS-1;
  const humanShort=sh.M+sh.O, o=[];
  switch(key){
    case 'cemetery.dig': o.push({s:2.2 + Math.min(humanShort,5)*.45 + Math.min(sh.X,4)*.6 + P.ruthless*.5 - (!P.ruthless&&p.hum<=-5?2:0)}); break;
    case 'square.buy': { const c=S.square[0]; o.push({s:6.5, pre:{card:c&&c.id, bury: p.hum<-3 && p.hand.some(h=>h.id==='burial')}}); break; }
    case 'morgue.buy': o.push({s:2.4 + Math.min(humanShort,5)*.5 + (P.careful?.5:0)}); break;
    case 'slaughter.take': o.push({s:1.1 + (n.totalShort>3?1.8:0) + (S.ev==='meat'?1.5:0), pre:{opt:'four'}}); break;
    case 'hospital.retrieve': { const lim=hospLimits(p); const k=Math.min(S.hosp.length, lim.free + (p.coin>=2?lim.paid:0)) || 1; const best=[...S.hosp].sort((a,b)=>sum(b.mats.map(m=>m[2]))-sum(a.mats.map(m=>m[2]))).slice(0,k);
      o.push({s:3.2 + Math.min(n.totalShort,5)*.55 + (sh.B?1:0) + (P.careful?1:0), pre:{cards:best.map(c=>c.id)}}); } break;
    case 'hospital.work': o.push({s:p.coin<3?4:1.2}); break;
    case 'hospital.volunteer': o.push({s:1.4 + (p.hum<0?1.2:0) + (p.rep<7?1.8:0) + (p.rep>=12&&p.rep<15?1.2:0)}); break;
    case 'academy.adv': o.push({s: n.expGap>0 ? 3 + Math.min(n.expGap,6)*.3 + P.scholar*2 : 1.6 + P.scholar, pre:{card:S.researchRow[0]&&S.researchRow[0].id}}); break;
    case 'academy.research': o.push({s:1.5 + P.scholar*.5, pre:{card:S.researchRow[0]&&S.researchRow[0].id}}); break;
    case 'academy.lecture': { const rights=p.hand.find(h=>h.id==='animal'||h.id==='human'); const guest=p.hand.find(h=>h.id==='guest');
      o.push({s:1.8 + (kind==='scientist'?.5:0) + (late?1:0) + (S.ev==='grant'?1.5:0) + (guest?1.5:0), pre:{card: guest?guest.id : (rights&&p.hum<-2?rights.id:null)}}); break; }
    case 'academy.donate': if(p.coin>=4) o.push({s:1.2 + (late?1:0) + (p.rep>=5&&p.rep<7?1.5:0), pre:{n:Math.min(3,p.coin-1)}}); break;
    case 'market.trade': {
      const wantJars = p.jars.length<3 && p.coin>=2 && onTable(p).length>=1;
      const many = sum(MATS.map(t=>sum(p.mats[t])))>=8 && p.ice===0 && p.coin>=1;
      const sellBone = p.bone>sh.X+6 ? 1:0, sellPres = p.preserved>=3?Math.floor(p.preserved/3):0;
      if(wantJars||many||sellBone||sellPres) o.push({s:(wantJars?3.2:0)+(many?2:0)+(sellBone?1:0)+sellPres*1.2, pre:{jars:wantJars?Math.min(2,3-p.jars.length):0, ice:many, sellBone, sellPres, pickle:true}});
      break; }
    case 'docks.hire': { const b=aiBestScoundrel(p,S.docks); if(b) o.push({s:b.s, pre:b.c}); break; }
    case 'alley.murder': o.push({s:2 + P.ruthless*3 + (n.totalShort>4?1:0) - (p.police>=1?1.5:0) - (!P.ruthless&&p.hum<=-3?3:0), pre:{unethical: n.expGap>3 && p.hand.some(h=>h.id==='unethical') && charged(p)>1}}); break;
    case 'church.atone': o.push({s: (p.hum<0 ? 2 + (-p.hum)*.3 : 1.1) + (kind==='scientist'?.4:0), pre:{card:S.humanityRow[0]&&S.humanityRow[0].id}}); break;
    case 'first.first': o.push({s: 1.6 + (S.round>=MAX_ROUNDS-2?0:.5)}); break;
    case 'odeon.show': o.push({s:3}); break;
    case 'lab.practice': o.push({s: n.expGap>0 ? 2.2 + P.scholar : .8}); break;
    case 'lab.blood': o.push({s: sh.B>0 ? 3.2 + sh.B*.4 : .4, pre:{transfusion: n.expGap>0 && p.hand.some(h=>h.id==='transfusion') && sh.B===0}}); break;
    case 'lab.repair': o.push({s: 2 + dmgTotal(p)*1.2}); break;
    case 'lab.charge': o.push({s: (n.skinNotAlive||onTable(p).length>=2) ? 3 + p.jars.filter(j=>!j).length*.6 : .3}); break;
  }
  return o;
}
function aiChoose(i, keys, forceKind){
  const p=S.players[i]; let best=null;
  for(const key of keys){
    const kinds = forceKind ? [forceKind] : ['assistant','scientist'];
    for(const kind of kinds){
      if(!forceKind && !canPlace(i,key,kind)) continue;
      for(const o of aiSpaceOptions(i,key,kind)){
        const b=bumpInfo(i,key)||{cost:0};
        let s=o.s + Math.random()*1.2 - b.cost*.8 - (kind==='scientist' && p.left.assistant && !(SPACE[key]||LABSPOT[key.slice(4)]||{}).sci ? .5 : 0);
        if(!best||s>best.s) best={key, kind, pre:o.pre||{}, s};
      }
    }
  }
  return best;
}
function aiMaybePlay(i){
  const p=S.players[i]; const P=p.persona||{};
  for(const c of [...p.hand]){
    if(!cardPlayable(i,c)) continue;
    if(c.kind==='research' && c.when==='any'){
      if(c.effect==='heal' && dmgTotal(p)===0) continue;
      if(c.effect==='demo' && p.hum<-4) continue;
      playCard(i,c.id); continue;
    }
    if(c.aid && p.hum<2 && p.coin>=c.cost+2 && Math.random()<.25){ playCard(i,c.id); continue; }
    if(c.when==='target' && S.phase==='day' && Math.random()<.4){
      const others=S.players.map((q,k)=>k).filter(k=>k!==i && (c.effect!=='burn' || S.players[k].hand.filter(h=>h.kind==='research').length>=2));
      if(others.length){ const t=others.sort((a,b)=>score(S.players[b])-score(S.players[a]))[0]; playCard(i,c.id,t); }
      continue; }
    if(c.id==='thwart' && S.phase==='day' && Math.random()<.3){ playCard(i,c.id); continue; }
    if((c.close||c.effect==='clearHosp') && S.phase==='day' && Math.random()<.2){ playCard(i,c.id); continue; }
  }
}
async function aiTurn(i){
  const p=S.players[i];
  aiMaybePlay(i);
  if(!leftN(p) || !legalAny(i)) { if(!leftN(p)) return; }
  let keys=allKeys(); let tries=0;
  while(tries++<3){
    const c=aiChoose(i, keys.filter(k=>canPlace(i,k)));
    if(!c){ p.left={scientist:0,assistant:0}; return; }
    if(S.thwart!=null && S.thwart!==i && !c.key.startsWith('lab.')){
      const by=S.players[S.thwart]; S.thwart=null; log(`${esc(by.name)} crosses ${B(p)}’s path. They must go elsewhere.`);
      keys=keys.filter(k=>SPACE[k]?SPACE[k].loc!==SPACE[c.key].loc:true); continue;
    }
    await placeAndResolve(i,c.key,c.kind,c.pre);
    return;
  }
}
function aiLab(i){
  const p=S.players[i]; let guard=12;
  // preserve spare flesh that would rot, for selling
  for(const t of ['muscle','organ']) if(p.mats[t][3]>0) preserve(p,t,p.mats[t][3]);
  while(guard--){
    let best=null;
    for(const s of SLOT6){ for(const pol of ['fresh','old']){ for(const steady of [false, p.hand.some(h=>h.id==='steady')]){ for(const surgeon of [false, hasChar(p,'surgeon')&&!p.surgeonUsed]){
      const pl=planBuild(p,s,pol,{steady,surgeon}); if(pl&&pl.ok){ const v=pl.vp+(pol==='old'?.5:0)-(steady?2:0)-(surgeon?.5:0); if(!best||v>best.v) best={s,pol,v,steady,surgeon}; } } } } }
    if(!best) break; build(i,best.s,best.pol,{steady:best.steady, surgeon:best.surgeon});
  }
  if(canThrow(p)){
    const dice=startThrow(i, Math.min(3,charged(p)), true); const st={};
    if(S.ev==='willing') applyMitigation(dice,'willing',st);
    const dmg=dice.filter(d=>d.f==='damage').length;
    if(dmg>=1){ const c=p.hand.find(h=>h.kind==='research' && ['ignoreDmg','rerollDmg','rerollAny','rerollGray'].includes(h.mit)); if(c && (dmg>=2 || onTable(p).some(s=>p.table[s].dmg))){ p.hand=p.hand.filter(h=>h!==c); applyMitigation(dice,c.mit,st); } }
    resolveThrow(i,dice,st);
  }
  if(hasChar(p,'zoo') && !p.zooUsed && p.jars.some(j=>!j)){ p.zooUsed=true; const k=p.jars.indexOf(false); p.jars[k]=true; }
  if(p.police>=2 && p.coin>=5){ p.coin-=3; p.police=0; log(`${B(p)} pays off the police.`); }
}

/* =========================================================
   PERSISTENCE
   ========================================================= */
function save(){ try{ if(S && !S.fast) localStorage.setItem(SAVE_KEY, JSON.stringify(S)); }catch(e){} }
function loadSaved(){ try{ const t=localStorage.getItem(SAVE_KEY); if(!t) return null; const s=JSON.parse(t); return s&&s.v===5&&s.phase!=='end'?s:null; }catch(e){ return null; } }
