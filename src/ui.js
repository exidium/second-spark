/* =========================================================
   EXTRA ART
   ========================================================= */
ART.first = sv('0 0 160 80', `${sky}<path d="M40 74V22h18v52M102 74V22h18v52" fill="${P2}"/><path d="M40 22l9-10 9 10M102 22l9-10 9 10"/><path d="M58 74V40h44v34" fill="${PP}"/>
  <circle cx="80" cy="50" r="8" fill="${PP}"/><path d="M80 42v16M72 50h16" opacity=".6"/><path d="M72 74V64a8 8 0 0 1 16 0v10" fill="${K}"/>
  <path d="M44 30h10M44 38h10M106 30h10M106 38h10" opacity=".6"/><path d="M16 76h128"/>
  <path d="M132 40q6-8 12 0v34h-12z" fill="${K}" opacity=".85"/><circle cx="138" cy="34" r="5" fill="${K}" opacity=".85"/>`);
ART.odeon = sv('0 0 160 80', `<path d="M14 74V34h132v40" fill="${P2}"/><path d="M10 34h140l-70-20z" fill="${PP}"/><path d="M24 36v38M40 36v38M56 36v38M72 36v38M88 36v38M104 36v38M120 36v38M136 36v38"/>
  <path d="M68 22q4 6 8 0M84 22q4 -6 8 0" /><path d="M6 76h148"/>`);

/* =========================================================
   MODALS (promise based)
   ========================================================= */
let modalFns=[], modalQueue=Promise.resolve();
function openModal(m){ modal=m; renderModal(); }
function closeModal(){ modal=null; renderModal(); }
function renderModal(){
  const root=document.getElementById('modalRoot');
  if(!modal){ root.innerHTML=''; return; }
  modalFns=[]; const reg=fn=>{ modalFns.push(fn); return modalFns.length-1; };
  const html = typeof modal.html==='function' ? modal.html(reg) : (modal.html||'');
  const opts=(modal.options||[]).map(o=>o.heading?`<div class="eyebrow" style="margin-top:6px">${o.heading}</div>`:`<button class="opt ${o.lead?'has-lead':''}" ${o.disabled?'disabled':''} data-mfn="${reg(o.fn)}">${o.lead||''}<span><span class="ot">${o.label}</span>${o.sub?`<small>${o.sub}</small>`:''}</span><span class="num">${o.right||''}</span></button>`).join('');
  const btns=(modal.buttons||[]).map(b=>`<button class="btn ${b.primary?'primary':''}" ${b.disabled?'disabled':''} data-mfn="${reg(b.fn)}">${b.label}</button>`).join('');
  root.innerHTML=`<div class="scrim" data-scrim="1"><div class="modal ${modal.wide?'wide':''} ${modal.xwide?'xwide':''} ${modal.hero?'hero':''}" role="dialog" aria-modal="true" aria-label="${esc(String(modal.title).replace(/<[^>]+>/g,''))}">
    ${modal.title?`<h2>${modal.title}</h2>`:''}${html}${opts?`<div class="opts">${opts}</div>`:''}<div class="actions">${btns}</div></div></div>`;
  const f=root.querySelector('.opt:not(:disabled), .btn.primary, .btn'); if(f) f.focus({preventScroll:true});
}
// ask(): resolves with an option's or button's value. html may be fn(reg, done).
function ask(m){
  return new Promise(res=>{
    const done=v=>{ closeModal(); res(v); };
    openModal({...m,
      html: typeof m.html==='function' ? (reg=>m.html(reg,done)) : m.html,
      options:(m.options||[]).map(o=>o.heading?o:{...o, fn:()=>done(o.value)}),
      buttons:(m.buttons||[]).map(b=>({...b, fn:()=>done(b.value)})),
      onDismiss:()=>done(m.dismissValue===undefined?null:m.dismissValue)});
  });
}
async function askYN(title, text, yes, no){ if(S&&S.fast) return false; return !!(await ask({title, html:`<p>${text}</p>`, buttons:[{label:'Refuse', value:false},{label:'Accept', primary:true, value:true}], locked:true})); }
function toast(t){ const d=document.createElement('div'); d.className='toastmsg'; d.innerHTML=t; document.body.appendChild(d); setTimeout(()=>d.remove(),4200); }
function flash(){ const f=document.createElement('div'); f.className='flash'; document.body.appendChild(f); setTimeout(()=>f.remove(),800); }

document.addEventListener('click', e=>{
  const m=e.target.closest('[data-mfn]'); if(m){ const fn=modalFns[+m.dataset.mfn]; if(fn) fn(); return; }
  if(e.target.dataset && e.target.dataset.scrim && modal && !modal.locked){ const d=modal.onDismiss; closeModal(); if(d) d(); return; }
  const a=e.target.closest('[data-act]'); if(a) handle(a.dataset.act, a.dataset, a);
});
document.addEventListener('keydown', e=>{
  if(e.key==='Escape' && modal && !modal.locked){ const d=modal.onDismiss; closeModal(); if(d) d(); }
  if((e.key==='Enter'||e.key===' ') && e.target.matches('[data-act][tabindex]')){ e.preventDefault(); handle(e.target.dataset.act, e.target.dataset, e.target); }
});
document.addEventListener('change', e=>{ if(e.target.matches('[data-opt]')){ uiOpts[e.target.dataset.opt]=e.target.checked; render(); } });

/* =========================================================
   TOOLTIP
   ========================================================= */
const tip=document.getElementById('tip');
function tipHTML(id){
  if(!S) return '';
  if(id.startsWith('lab.')){ const L=LABSPOT[id.slice(4)], p=S.players[0];
    return `<span class="tp">Your laboratory</span><b>${L.name}</b>${L.text}${L.sci?'<div style="color:var(--brass)">Scientist only.</div>':''}${p.labUsed[L.id]?'<div class="ts">Already used today.</div>':''}`; }
  const L=LOC[id]; if(!L) return '';
  const rows=L.spaces.map(s=>{ const k=L.id+'.'+s.k, o=S.occ[k]; return `<div>• ${esc(s.n)}${s.sci?' <span style="color:var(--brass)">(scientist)</span>':''}: ${o?`${esc(S.players[o.p].name)}’s ${o.kind}`:'free'}</div>`; }).join('');
  let st=''; if(S.closed[L.id]) st='Closed today.'; else if(isMyTurn() && L.spaces.some(s=>humanCan(L.id+'.'+s.k))) st='Click to send a meeple here.';
  const extra = L.id==='hospital' ? `<div>Cadavers in the stack: ${S.hosp.length}.</div>` : L.id==='square' ? `<div>Bodies on display: ${S.square.length}.</div>` : '';
  return `<span class="tp">${esc(L.place)}</span><b>${esc(L.name)}</b>${L.text}${L.yields?`<div class="tc">${L.yields}</div>`:''}${extra}${rows}${st?`<div class="ts">${st}</div>`:''}`;
}
function showTip(el,x,y){ tip.innerHTML=el.dataset.tipt!=null ? el.dataset.tipt : tipHTML(el.dataset.tip); tip.hidden=false; const w=tip.offsetWidth,h=tip.offsetHeight,vw=innerWidth,vh=innerHeight; let l=x+14,t=y+14; if(l+w>vw-8) l=x-w-14; if(t+h>vh-8) t=y-h-14; tip.style.left=Math.max(8,l)+'px'; tip.style.top=Math.max(8,t)+'px'; }
document.addEventListener('pointermove', e=>{ if(e.pointerType==='touch') return; const el=e.target.closest&&e.target.closest('[data-tipt],[data-tip]'); if(el && !modal) showTip(el,e.clientX,e.clientY); else tip.hidden=true; });
document.addEventListener('scroll', ()=>{ tip.hidden=true; }, true);

/* =========================================================
   HUMAN INPUT
   ========================================================= */
let busy=false, humanBlocked=null, prePick=null; const uiOpts={steady:false, surgeon:false};
function isMyTurn(){ return S && S.phase==='day' && S.cur===0 && !!humanResolve && !busy; }
function humanCan(key){ if(!isMyTurn()) return false; const sp=SPACE[key]; if(sp && humanBlocked===sp.loc) return false; return canPlace(0,key); }

async function handle(act,d,el){
  if(act==='start'){ const name=(document.getElementById('nm').value||'').trim()||'Dr Torres'; newGame(name, +document.getElementById('nr').value||3, chosenChar); return; }
  if(act==='pickchar'){ chosenChar=d.id; document.querySelectorAll('.charpick').forEach(el=>{ const on=el.dataset.id===chosenChar; el.classList.toggle('sel',on); el.setAttribute('aria-pressed',on); }); return; }
  if(act==='continue'){ const s=loadSaved(); if(s){ gameToken++; S=s; if(S.phase==='day'||S.phase==='firstmove'){} render(); loop(); } return; }
  if(act==='rules'){ openModal({title:'How to play', wide:true, html:`<div class="rules">${rulesHTML()}</div>`, buttons: S ? [{label:'Every card',fn:()=>handle('cards',{})},{label:'Close',primary:true,fn:closeModal}] : [{label:'Close',primary:true,fn:closeModal}]}); return; }
  if(act==='cards'){ openModal({title:'Every card in the game', wide:true, html:catalogHTML(), buttons:[{label:'Close',primary:true,fn:closeModal}]}); return; }
  if(act==='newgame'){ openModal({title:'Abandon this game?', html:'<p>Your laboratory and your creation will be lost.</p>',
     buttons:[{label:'Keep playing',fn:closeModal},{label:'Abandon',primary:true,fn:()=>{ closeModal(); gameToken++; S=null; humanResolve=null; labResolve=null; try{localStorage.removeItem(SAVE_KEY)}catch(e){} render(); }}]}); return; }
  if(act==='title'){ gameToken++; S=null; render(); return; }
  if(act==='rival'){ rivalModal(+d.i); return; }
  if(act==='sel'){ const p=S.players[0]; if(p.left[d.k]){ p.sel=d.k; render(); } return; }
  if(act==='space'){ tip.hidden=true; await clickSpace(d.key); return; }
  if(act==='loc'){ tip.hidden=true; if(busy) return; await placeModal(d.id); return; }
  if(act==='labplace'){ tip.hidden=true; if(busy) return; await labPlaceModal(); return; }
  if(!S) return;
  const p=S.players[0];
  if(act==='lab'){ labModal(); return; }
  if(act==='character'){ characterModal(); return; }
  if(act==='hand'){ handModal(); return; }
  if(act==='today'){ todayModal(); return; }
  if(act==='build'){ const r=build(0,d.slot,d.pol,{steady:uiOpts.steady, surgeon:uiOpts.surgeon}); if(r){ uiOpts.steady=false; uiOpts.surgeon=false; save(); render(); flash(); } return; }
  if(act==='throw'){ if(busy) return; const fromLab = modal && modal.kind==='lab'; busy=true; try{ await humanThrow(+d.n); } finally{ busy=false; render(); if(fromLab && S && S.phase==='lab') labModal(); } return; }
  if(act==='preserve'){ preserve(p,d.t,+d.n); save(); render(); return; }
  if(act==='police'){ if(p.coin>=3 && p.police){ p.coin-=3; p.police=0; log(`${B(p)} pays off the police.`); save(); render(); } return; }
  if(act==='zoo'){ if(hasChar(p,'zoo') && !p.zooUsed && p.jars.some(j=>!j)){ p.zooUsed=true; p.jars[p.jars.indexOf(false)]=true; log(`${B(p)} charges a jar with an eel.`); save(); render(); } return; }
  if(act==='endlab'){
    if(S.phase!=='lab') return;
    const fromLab = modal && modal.kind==='lab';
    const canB=SLOT6.some(s=>{ const a=planBuild(p,s,'fresh'); return a&&a.ok; });
    if(canB||canThrow(p)){ const ok=await ask({title:'Snuff the lamps?', html:`<p>${canB?'You can still build a part. ':''}${canThrow(p)?'You have not thrown the switch yet.':''}</p>`, buttons:[{label:'Keep working', value:false},{label:'End the night', primary:true, value:true}]}); if(!ok){ if(fromLab) labModal(); return; } }
    closeModal(); endLab(); return;
  }
  if(act==='play'){
    if(busy) return; const c=p.hand.find(h=>h.id===d.id); if(!c) return;
    let target;
    if(c.when==='target'){ const others=S.players.map((q,k)=>k).filter(k=>k!==0 && (c.effect!=='burn'||S.players[k].hand.filter(h=>h.kind==='research').length>=2));
      target=await ask({title:esc(c.name), html:`<p>${esc(c.text)}</p>`, options:others.map(k=>({label:esc(S.players[k].name), value:k})), buttons:[{label:'Cancel', value:null}]}); if(target==null) return; }
    const fromChar = modal && modal.kind==='character', fromHand = modal && modal.kind==='hand';
    busy=true; try{ await playCard(0,c.id,target); } finally { busy=false; } save(); render(); if(fromChar && !modal) characterModal(); if(fromHand && !modal) handModal(); return;
  }
}
async function clickSpace(key){
  if(!humanCan(key)) return;
  const p=S.players[0]; const kind=kindFor(0,key); if(!kind) return;
  const sp=SPACE[key];
  if(sp && S.thwart!=null && S.thwart!==0){ const by=S.players[S.thwart]; S.thwart=null; humanBlocked=sp.loc; log(`${esc(by.name)} crosses ${B(p)}’s path at ${esc(LOC[sp.loc].name)}.`);
    await ask({title:'Your path is crossed', html:`<p>${esc(by.name)} played <b>Cross Their Path</b>. You can’t go to ${esc(LOC[sp.loc].name)} this turn. Choose another space.</p>`, buttons:[{label:'Choose again', primary:true, value:1}]}); render(); return; }
  busy=true;
  try{
    if(kind!==p.sel) toast(`Sending your ${kind}: your ${p.sel} can’t go there.`);
    const b=bumpInfo(0,key);
    if(b && b.bump){ const o=S.occ[key]; const ok=await ask({title:'Bump?', html:`<p>${esc(S.players[o.p].name)}’s ${o.kind} is already there. Bump them${b.free?' for free (they go home)':b.cost?` and pay them <b>${fr(b.cost)}</b>`:' (free, it’s your own)'}? Their meeple ${b.free?'returns to them':'goes to the bump track and is out for the day'}.</p>`, buttons:[{label:'Cancel', value:false},{label:'Bump', primary:true, value:true}]}); if(!ok) return; }
    const pre=await humanPre(0,key,kind); if(pre===null) return;
    await placeAndResolve(0,key,kind,pre);
    save(); humanBlocked=null; busy=false; endHumanTurn();
  } finally { busy=false; render(); }
}
async function humanPre(i,key,kind,noCancel){
  const p=S.players[i]; const cancel = noCancel?[]:[{label:'Cancel', value:null}];
  switch(key){
    case 'square.buy': {
      const bury=p.hand.some(h=>h.id==='burial');
      return await ask({title:'Public Square', wide:true, html:(reg,done)=>`<p class="flavor">The crowd has gone home. 1 franc buys one body.</p>
        <div class="gcards">${S.square.map(c=>cardHTML(c,{acts:`<div class="gc-acts"><button class="tog" data-mfn="${reg(()=>done({card:c.id}))}">Buy this one</button>${bury?`<button class="tog" data-mfn="${reg(()=>done({card:c.id, bury:true}))}">Bury it (A Decent Burial)</button>`:''}</div>`})).join('')}</div>`, buttons:cancel});
    }
    case 'slaughter.take': if(prePick) return prePick; return await ask({title:'Slaughterhouse', html:'<p class="flavor">Animal stands in for muscle, organ or (at stage I or II) blood. Each part built with it scores 1 VP less, 2 less if you use 3 or more.</p>', options:[
      {label:`4 animal at stage II ${cube('animal',4,2)}`, value:{opt:'four'}},{label:`3 animal at stage I ${cube('animal',3,1)}`, value:{opt:'three'}}], buttons:cancel});
    case 'hospital.retrieve': {
      const lim=hospLimits(p); const max=Math.min(S.hosp.length, lim.free+lim.paid);
      const chosen=[];
      const cost=()=>Math.max(0,chosen.length-lim.free);
      return await ask({title:'Hospital', wide:true, html:(reg,done)=>{
        const rr=()=>renderModal();
        return `<p class="flavor">The porter lifts the sheets. ${lim.free?'Your reputation lets you take 1 for free.':'Your reputation is below 7: bribing the porter costs 1 franc.'}${lim.paid?` You may take ${lim.paid} more for 1 franc each${p.rep>=15?' (reputation 15)':''}${S.ev==='corrupt'?' (A Porter for Hire)':''}.`:''}</p>
        <div class="gcards">${S.hosp.map(c=>{ const on=chosen.includes(c.id); const can=on || (chosen.length<max && p.coin>=Math.max(0,chosen.length+1-lim.free));
          return cardHTML(c,{sel:on, acts:`<div class="gc-acts"><button class="tog ${on?'on':''}" ${can?'':'disabled'} data-mfn="${reg(()=>{ if(on) chosen.splice(chosen.indexOf(c.id),1); else chosen.push(c.id); rr(); })}">${on?'Taking':'Take'}${!on && chosen.length+1>lim.free?' (1 franc)':''}</button></div>`}); }).join('')}</div>
        <p class="num" style="text-align:right">Cost: <b>${fr(cost())}</b></p>
        <div class="actions">${noCancel?'':`<button class="btn" data-mfn="${reg(()=>done(null))}">Cancel</button>`}<button class="btn primary" ${chosen.length?'':'disabled'} data-mfn="${reg(()=>done({cards:[...chosen]}))}">Retrieve ${chosen.length}</button></div>`; }, locked:true});
    }
    case 'academy.adv': case 'academy.research': {
      if(!S.researchRow.length) return {};
      return await ask({title: key==='academy.adv'?'Advanced research':'Research', wide:true, html:(reg,done)=>`<p class="flavor">${key==='academy.adv'?'+1 expertise and choose a research card.':'Choose a research card.'}</p>
        <div class="gcards">${S.researchRow.map(c=>cardHTML(c,{acts:`<div class="gc-acts"><button class="tog" data-mfn="${reg(()=>done({card:c.id}))}">Take this</button></div>`})).join('')}</div>`, buttons:cancel});
    }
    case 'academy.lecture': {
      const alt=p.hand.filter(h=>['guest','animal','human'].includes(h.id));
      const r=1+(kind==='scientist'?1:0);
      if(!alt.length) return {};
      return await ask({title:'Lecture', html:'', options:[{label:'Lecture as usual', sub:`+${fr(S.ev==='hardtimes'?0:1)} and +${r} reputation.`, value:{}},
        ...alt.map(c=>({label:`Play ${esc(c.name)}`, sub:esc(c.text)+' '+gainTxt(c.gain), value:{card:c.id}}))], buttons:cancel});
    }
    case 'academy.donate': return await ask({title:'Donate', html:'<p>1 reputation per franc, up to 3.</p>', options:[1,2,3].map(n=>({label:`Donate ${fr(n)}`, value:{n}, disabled:p.coin<n})), buttons:cancel});
    case 'market.trade': if(prePick) return prePick; return await marketModal(p, cancel.length>0);
    case 'docks.hire': { if(prePick) return prePick; const c=await chooseScoundrel(p, S.docks, 'Three scoundrels lean on the bollards.', !noCancel); return c; }
    case 'alley.murder': {
      const un=p.hand.some(h=>h.id==='unethical') && charged(p)>0;
      return await ask({title:'Dark Alley', html:`<p>Murder someone for ${matsHTML([['muscle',1,4],['organ',1,4],['blood',1,3],['bone',0,2]])}</p><p class="flavor">Costs 3 humanity and earns a police marker. At 2 markers the Dark Alley is closed to you until you pay 3 francs.</p>`,
        options:[{label:'Do it', sub:grow(`<span class="gi neg"><b>3</b>${icon('heart-broken','💔')}</span>`, `<span class="gi neg"><b>1</b>${icon('police','⭐')}</span>`), value:{}}, ...(un?[{label:`${icon('cards','🃏','si')} Use card “Unethical Experiment”`, sub:grow(gtx('Spend'), gt(1,'jar','🏺'), gtx('·'), gt(5,'expertise','🧠'), `<span class="gi neg"><b>1</b>${icon('heart-broken','💔')}</span>`, gtx('· no materials')), value:{unethical:true}}]:[])], buttons:cancel});
    }
    case 'church.atone': {
      if(prePick) return prePick;
      if(!S.humanityRow.length) return {};
      return await ask({title:'Saint-Roch', wide:true, html:(reg,done)=>`<p class="flavor">Choose a humanity card.${kind==='scientist'?' Your scientist also gains 1 humanity.':' (A scientist would also gain 1 humanity.)'}</p>
        <div class="gcards">${S.humanityRow.map(c=>cardHTML(c,{acts:`<div class="gc-acts"><button class="tog" data-mfn="${reg(()=>done({card:c.id}))}">Take this</button></div>`})).join('')}</div>`, buttons:cancel});
    }
    case 'lab.blood': {
      if(!p.hand.some(h=>h.id==='transfusion')) return {};
      return await ask({title:'Give Blood', html:'', options:[{label:'Give blood', sub:grow(cube('blood',3,1)), value:{}},{label:`${icon('cards','🃏','si')} Use card “Transfusion”`, sub:grow(gt(3,'expertise','🧠'), gt(1,'reputation','🎖️'), gt(1,'coin','🪙')), value:{transfusion:true}}], buttons:cancel});
    }
    case 'cemetery.dig': case 'morgue.buy': case 'hospital.work': case 'hospital.volunteer': case 'first.first': case 'odeon.show':
    case 'lab.practice': case 'lab.repair': case 'lab.charge': return {};
  }
  return {};
}
async function chooseScoundrel(p, row, intro, canCancel){
  return await ask({title:'Docks', wide:true, html:(reg,done)=>`<p class="flavor">${intro}</p>
    <div class="gcards">${row.map(c=>{ const ok=scCost(c)<=p.coin && scAllowed(c); const un=c.kind==='cut' && p.hand.some(h=>h.id==='unethical') && charged(p)>0;
      const b=(label,v,primary)=>`<button class="btn ${primary?'primary':''} sm" ${ok?'':'disabled'} data-mfn="${reg(()=>done(v))}">${label}</button>`;
      const acts = c.kind==='thief' ? b(`Draw ${c.draw} from the Hospital`,{card:c.id,how:'mats'},true)
        : [b('Materials',{card:c.id,how:'mats'},true), c.exp?b(`+${c.exp} ${icon('expertise','🧠','si')}${c.expH?` −1 ${icon('heart-broken','💔','si')}`:''}`,{card:c.id,how:'exp'}):'', c.hum?b(`+${c.hum} ${icon('heart','❤️','si')}`,{card:c.id,how:'hum'}):'', un?b(`${icon('cards','🃏','si')} Use card “Unethical Experiment”`,{card:c.id,how:'exp',unethical:true}):''].join('');
      return cardHTML(c,{acts:`<div class="gc-acts col">${acts}</div>`}); }).join('')}</div>`, buttons:canCancel===false?[]:[{label:'Cancel', value:null}], locked:canCancel===false});
}
// Market trades: steppers for each trade and a running "francs after" total. Shared by the place popup and the second-use path.
function marketState(){ return {jars:0, ice:false, sellBone:0, sellPres:0, pickle:false}; }
function marketBody(p, o, reg){
  const hasPickle=p.hand.some(h=>h.id==='preserve');
  const jarCost=k=> S.ev==='hardtimes' ? Math.ceil(k/2)*2 : 2*k;
  const cash=()=>p.coin + o.sellBone + o.sellPres*(2+(o.pickle?1:0)) - jarCost(o.jars) - (o.ice?1:0);
  const rerender=()=>renderModal();
  const step=(k,d,max)=>reg(()=>{ o[k]=clamp(o[k]+d,0,max); if(cash()<0) o[k]-=d; rerender(); });
  const row=(label,sub,k,max)=>`<div class="opt" style="cursor:default"><span><span class="ot">${label}</span><small>${sub}</small></span>
    <span style="display:flex;gap:6px;align-items:center"><button class="btn" style="padding:2px 10px" data-mfn="${step(k,-1,max)}">−</button><b class="num">${o[k]}</b><button class="btn" style="padding:2px 10px" data-mfn="${step(k,1,max)}">+</button></span></div>`;
  return `<div class="opts">
    ${row('Sell 2 bone for 1 franc',`You have ${p.bone} bone.`,'sellBone',Math.floor(p.bone/2))}
    ${row(`Sell 3 preserved flesh for ${fr(2+(o.pickle?1:0))}`,`You have ${p.preserved} preserved. Preserve flesh in your lab at night.`,'sellPres',Math.floor(p.preserved/3))}
    ${row(`Buy a Leyden jar ${icon('jar','🏺','si')} (2 francs)`,`${S.ev==='hardtimes'?'Hard Times: buy 1, get 1 free. ':''}You have ${p.jars.length} of 4. New jars are empty unless lightning is in the air.`,'jars',4-p.jars.length)}
    <div class="opt" style="cursor:default"><span><span class="ot">Buy an ice block ${icon('ice','🧊','si')} (1 franc)</span><small>Stops decay for the next 2 dawns.${p.ice?` You have ${p.ice} left.`:''}</small></span><button class="tog" style="color:var(--parch);border-color:var(--line2)" data-mfn="${reg(()=>{ o.ice=!o.ice; if(cash()<0) o.ice=false; rerender(); })}">${o.ice?'Buying':'Buy'}</button></div>
    ${hasPickle?`<label class="opt" style="cursor:pointer"><span><span class="ot">Play Pickling Jars</span><small>+1 franc per preserved sale.</small></span><input type="checkbox" ${o.pickle?'checked':''} data-mfn="${reg(()=>{ o.pickle=!o.pickle; rerender(); })}"></label>`:''}
    </div><p class="num" style="text-align:right;margin-top:10px">Francs after: <b>${fr(cash())}</b></p>`;
}
async function marketModal(p, canCancel){
  const o=marketState();
  return await ask({title:'Market', html:(reg,done)=>`<p class="flavor">Les Halles. Do as many trades as you like.</p>${marketBody(p,o,reg)}
      <div class="actions"><button class="btn" data-mfn="${reg(()=>done(canCancel?null:{}))}">${canCancel?'Cancel':'Skip'}</button><button class="btn primary" data-mfn="${reg(()=>done({...o}))}">Trade</button></div>`, locked:!canCancel});
}
async function cadaverModal(p, cards, o){
  if(S.fast) return aiCadaverPicks(p,cards,o);
  const picks={}; cards.forEach(c=>picks[c.id]={how:'mats'});
  const cardsFor=c=>p.hand.filter(h=> (h.id==='daisy') || (h.id==='dissect'&&c.stage>=1&&c.stage<=2) || (h.id==='electro'&&c.stage>=1&&c.stage<=3&&charged(p)>0));
  return await ask({title:o.title, wide:true, locked:true, html:(reg,done)=>{
    const rr=()=>renderModal();
    return `<p class="flavor">${o.intro} For each cadaver, take its materials or its expertise, or leave it.</p>
    <div class="gcards">${cards.map(c=>{ const pk=picks[c.id]; const extra=cardsFor(c);
      const t=(label,how,dis)=>`<button class="tog ${pk.how===how?'on':''}" ${dis?'disabled':''} data-mfn="${reg(()=>{ pk.how=how; rr(); })}">${label}</button>`;
      const rc=extra.map(h=>`<button class="tog ${pk.card===h.id?'on':''}" data-mfn="${reg(()=>{ pk.card = pk.card===h.id?null:h.id; if(pk.how==='leave') pk.how='mats'; rr(); })}">${esc(h.name)}</button>`).join('');
      return cardHTML(c,{sel:pk.how!=='leave', acts:`<div class="gc-acts">${t('Materials','mats')}${c.exp?t(`+${c.exp} ${icon('expertise','🧠','si')}`,'exp'):''}${o.single?'':t('Leave','leave')}${rc}</div>`, noCost:o.noCardCost, extraH:o.extraH}); }).join('')}</div>
    ${o.flatCost||o.extraH?`<p style="font-size:12.5px;color:var(--muted);margin-top:10px">${o.flatCost?'Resolving any card costs 1 humanity in total. ':''}${o.extraH?'All Saints’ Day: every resolved card costs 1 extra humanity.':''}</p>`:''}
    <div class="actions"><button class="btn primary" data-mfn="${reg(()=>done(picks))}">Done</button></div>`; }});
}

/* =========================================================
   CARD RENDERING
   ========================================================= */
function gainIcons(g){ return gainTxt(g||{}); }
// Tall framed card (Bruno's engraved parchment front). The cartouche at the foot holds a short mark such as the stage numeral.
// Buttons sit under the frame so the art stays untouched. Falls back to the plain paper card when the image is missing.
const hasFrame = () => !!IMG['card-tall-front'];
function framedHTML(o){ return `<div class="gcard-wrap ${o.sel?'sel':''}"><div class="gcard framed"><span class="gc-kind">${o.kind}</span><span class="gc-title">${o.title}</span>
    <div class="gc-art">${o.art}</div><div class="gc-body">${o.body}</div>${o.mark?`<span class="gc-cartouche">${o.mark}</span>`:''}</div>${o.acts||''}</div>`; }
function cardHTML(c, extra){
  extra=extra||{};
  if(c.kind==='cadaver'){
    const hc=(extra.noCost?0:c.hcost+(extra.extraH||0));
    const body=`<div class="gc-row">${matsHTML(c.mats)}</div>${c.exp?`<div>or <b>+${c.exp} expertise</b></div>`:'<div>Bones only, no expertise</div>'}${hc?`<div class="gc-cost">−${hc} humanity to resolve</div>`:''}${c.cost?`<div class="gc-cost">+${fr(c.cost)} to buy</div>`:''}`;
    if(c.art && IMG[c.art]) return cadaverCardHTML(c, extra, hc);
    return `<div class="gcard ${extra.sel?'sel':''}"><span class="gc-kind">${esc(LOC[c.src].name)} · stage ${c.stage?ROMAN[c.stage-1]:'bones'}</span><span class="gc-title">${esc(c.name)}</span>
      <div class="gc-art">${cadaverArt(c)}</div>
      <div class="gc-body">${body}</div>
      ${extra.acts||''}</div>`;
  }
  if(SC_WHO[c.kind]){
    const opts=[]; if(c.exp) opts.push(`+${c.exp} expertise${c.expH?' (−1 humanity)':''}`); if(c.hum) opts.push(`+${c.hum} humanity`);
    const cost=S?scCost(c):c.cost, hc=S?scHcost(c):c.hcost;
    if(c.tpl!=null && IMG[`scoundrel-${String(c.tpl+1).padStart(2,'0')}`]) return scoundrelCardHTML(c, extra, cost, hc);
    return `<div class="gcard ${extra.sel?'sel':''}"><span class="gc-kind">Scoundrel · ${fr(cost)}${hc?` · −${hc} humanity`:''}</span><span class="gc-title">${esc(c.name)}</span>
      <div class="gc-art">${scoundrelArt(c)}</div>
      <div class="gc-body"><span class="soft">${esc(c.who||'')}</span>${c.kind==='thief'?`<div>Draw ${c.draw} cadaver${c.draw>1?'s':''} from the Hospital stack</div>`:`<div class="gc-row">${matsHTML(c.mats||[])}</div>${opts.length?`<div>or ${opts.join(' or ')}</div>`:''}`}</div>${extra.acts||''}</div>`;
  }
  if(c.kind==='research'){
    const art=ICONART[c.id==='demo'||c.id==='electro'?'jar':c.id==='healing'||c.id==='transfusion'?'flask':c.id==='tutor'||c.id==='guest'?'coin':'book'];
    const body=`${esc(c.text)}${gainTxt(c.gain)?`<div><b>${gainTxt(c.gain)}</b></div>`:''}<div style="border-top:1px solid rgba(59,45,34,.3);padding-top:4px">Or after a throw: <b>${MIT_N[c.mit]}</b></div>`;
    if(IMG['card-research-bg']) return `<div class="gcard-wrap ${extra.sel?'sel':''}"><div class="fcard"><div class="fface"><span class="femblem">${icon('book','📖')}</span><span class="ft">${esc(c.name)}</span><span class="fk">Research</span><p class="fx">${esc(c.text)}</p><div class="fg">${gainIconsHTML(c.gain)}</div></div>${diceStripHTML(c.mit)}</div>${extra.acts||''}</div>`;
    if(hasFrame()) return framedHTML({sel:extra.sel, kind:'Research', title:esc(c.name), art, body, mark:'', acts:extra.acts});
    return `<div class="gcard ${extra.sel?'sel':''}"><span class="gc-kind">Research</span><span class="gc-title">${esc(c.name)}</span>
      <div class="gc-art">${art}</div>
      <div class="gc-body">${body}</div>${extra.acts||''}</div>`;
  }
  if(c.kind==='humanity'){
    if(IMG['card-humanity-bg']) return `<div class="gcard-wrap ${extra.sel?'sel':''}"><div class="fcard hum"><div class="fface"><span class="femblem">${icon('cross','✝️')}</span><span class="ft">${esc(c.name)}</span><span class="fk">Humanity</span><p class="fx">${esc(c.text)}</p><div class="fg">${gainIconsHTML(c.gain)}</div></div></div>${extra.acts||''}</div>`;
    return `<div class="gcard ${extra.sel?'sel':''}"><span class="gc-kind">Humanity</span><span class="gc-title">${esc(c.name)}</span>
      <div class="gc-art">${ICONART.candle}</div><div class="gc-body">${esc(c.text)}${gainTxt(c.gain)?`<div><b>${gainTxt(c.gain)}</b></div>`:''}</div>${extra.acts||''}</div>`;
  }
  return '';
}
// Event scene: art/events/event-NN.png by position in EVENTS, else the SVG drawing of a related place.
function eventArt(e){ const k=EVENTS.indexOf(e); const src=k>=0&&IMG[`event-${String(k+1).padStart(2,'0')}`]; if(src) return `<img src="${src}" alt="">`;
  return e.exec?ART.square:e.storm?ICONART.jar:ART[{graves:'cemetery',fire:'academy',plague:'slaughter',riots:'alley',purge:'hospital',odeon:'odeon',meat:'slaughter',cholera:'hospital',corrupt:'hospital'}[e.id]||'church']; }
// Event card: landscape, the 4:3 scene across the top, the name over it, the text and the lightning or execution marks in a panel below.
function eventCardHTML(e){
  const marks=`${e.storm?'<span class="em storm" title="Lightning: every Leyden jar is charged">⚡ lightning</span>':''}${e.exec?'<span class="em exec" title="Execution: bodies go on display at the Public Square">☠ execution</span>':''}`;
  return `<div class="ecard"><div class="eart">${eventArt(e)}<span class="ek">Event · days ${e.r[0]} to ${e.r[1]}</span>${marks?`<div class="emarks">${marks}</div>`:''}<div class="eover"><span class="en">${esc(e.name)}</span><div class="ebody">${esc(e.text)}${e.storm?'<div><b>Lightning:</b> every Leyden jar is charged.</div>':''}${e.exec?'<div><b>Execution:</b> bodies go on display at the Public Square.</div>':''}</div></div></div></div>`;
}
// Encounter scene: art/encounters/encounter-NN.png by position in ENCOUNTERS, else the seeded SVG face.
function encounterArt(e){ const k=ENCOUNTERS.indexOf(e); const src=k>=0&&IMG[`encounter-${String(k+1).padStart(2,'0')}`]; return src ? `<img src="${src}" alt="">` : portrait(e.id.length*977, e.who==='captain'?'docks':'morgue', e.who!=='woman'); }
function encounterCardHTML(e){
  const who = e.who==='captain'?'Captain Walton':e.who==='woman'?'A stranger':'The Creature';
  const trig = e.loc ? `Hidden. Triggers on the first rival to use ${esc(LOC[e.loc.split('.')[0]].name)}: ${esc(SPACE[e.loc].n)}.` : `Now. ${({maxExp:'The scientist with the most expertise',fewestComplete:'The scientist with the fewest complete parts',maxHum:'The scientist with the most humanity',fpOther:'Someone the first player chooses (not themselves)',fp:'Someone the first player chooses',fpWithPart:'Someone with a part on the table, chosen by the first player',lastDark:'Whoever last killed or hired a Cutthroat',mostHumCards:'Whoever holds the most humanity cards'})[e.target]}.`;
  return `<div class="ecard"><div class="eart">${encounterArt(e)}<span class="ek">Encounter · days ${e.r[0]} to ${e.r[1]}</span><div class="eover"><span class="en">${who}</span><div class="ebody"><span class="soft">${esc(e.text)}</span><div>${trig}</div>${e.testText?`<div>Test: ${esc(e.testText)}.</div>`:''}${e.choice?`<div>Choice: ${esc(e.choice[0])} or ${esc(e.choice[1])}.</div>`:''}</div></div></div></div>`;
}
// Character portrait: generated image if art/character-<id>.* was embedded at build time, else the SVG portrait.
// Title logo: art/title.webp (gold lettering with a transparent ground), else the text heading.
function logoHTML(cls){ return `<h1 class="logo ${cls||''}">Second <span>Spark</span></h1>`; }
function charArt(id, cls){ const src=IMG['character-'+id]; if(src) return `<img class="${cls||''}" src="${src}" alt="">`;
  const svg=portrait(CHAR_SEED[id], CHAR_BG[id], false, CHAR_LOOK[id]); return cls?`<span class="${cls}">${svg}</span>`:svg; }
function charCardHTML(c){ return `<div class="hcard" style="align-items:flex-start">${charArt(c.id,'avatar')}<span><span class="eyebrow">${esc(c.role)}</span><br><b>${esc(c.name)}</b><br><span style="color:var(--parch-dim)">${esc(c.text)}</span></span></div>`; }
function catalogHTML(){
  const cad=src=>CADAVERS[src].map((r,k)=>{ const c=cadaverFromRowStatic(src,r,k); return cardHTML(c); }).join('');
  return `<p class="flavor">Numbers follow the physical game. Names, wording and art are ours.</p>
    <div class="sub">Graveyard cadavers (14)</div><div class="gcards">${cad('cemetery')}</div>
    <div class="sub">Morgue cadavers (14)</div><div class="gcards">${cad('morgue')}</div>
    <div class="sub">Hospital cadavers (14)</div><div class="gcards">${cad('hospital')}</div>
    <div class="sub">Public Square cadavers (10)</div><div class="gcards">${cad('square')}</div>
    <div class="sub">Scoundrels (16)</div><div class="gcards">${SCOUNDRELS.map((t,k)=>cardHTML({kind:'scoundrel',tpl:k,...t,who:SC_WHO[t.kind][0],seed:k*131+7})).join('')}</div>
    <div class="sub">Research (16)</div><div class="gcards">${RESEARCH.map(t=>cardHTML({kind:'research',...t})).join('')}</div>
    <div class="sub">Humanity (16)</div><div class="gcards">${HUMANITY.map(t=>cardHTML({kind:'humanity',...t})).join('')}</div>
    <div class="sub">Events (19)</div><div class="gcards">${EVENTS.map(eventCardHTML).join('')}</div>
    <div class="sub">Encounters (15)</div><div class="gcards">${ENCOUNTERS.map(encounterCardHTML).join('')}</div>
    <div class="sub">Characters (6)</div><div class="hand">${CHARACTERS.map(charCardHTML).join('')}</div>`;
}
function cadaverFromRowStatic(src,row,k){ const [st,m,exp,hc,name,cost]=row; const mats=[]; ['muscle','organ','blood','bone'].forEach((t,k)=>{ if(m[k]) mats.push([t,t==='bone'?0:st,m[k]]); });
  return {kind:'cadaver', src, stage:st, name:name||(st?`Stage ${ROMAN[st-1]} body`:'A heap of bones'), seed:(m[0]*7+m[1]*13+m[2]*17+m[3]*19+st*23)||5, mats, exp, hcost:hc, cost:cost||0, art: k==null?null:`${src}-${String(k+1).padStart(2,'0')}`}; }
// Cadaver picture: the generated portrait when art/cadavers/<deck>-NN.png exists, else the seeded SVG face.
// Cadaver card in the physical game's layout: the portrait fills the card, a strip at the foot shows the stage numeral and the
// muscle, organ, blood and bone counts in the material colours, and a small row above it carries expertise and humanity cost.
function cadaverCardHTML(c, extra, hc){
  const n=t=>{ const m=c.mats.find(x=>x[0]===t); return m?m[2]:0; };
  const cells=[['muscle',n('muscle')],['organ',n('organ')],['blood',n('blood')],['bone',n('bone')]].map(([t,v])=>`<span class="cs ${t} ${v?'':'z'}" title="${v} ${t}">${v}</span>`).join('');
  const icons=`${c.exp?`<span class="ci" title="or +${c.exp} expertise">+${c.exp}${icon('expertise','🧠','si')}</span>`:'<span class="ci dim">bones</span>'}${hc?`<span class="ci cost" title="−${hc} humanity to resolve">−${hc}${icon('heart-broken','💔','si')}</span>`:''}${c.cost?`<span class="ci cost" title="${fr(c.cost)} to buy">${c.cost}${icon('coin','🪙','si')}</span>`:''}`;
  return `<div class="gcard-wrap ${extra.sel?'sel':''}"><div class="ccard" title="${esc(c.name)}"><img src="${IMG[c.art]}" alt="">
      <span class="ck">${esc(LOC[c.src].name)}</span><span class="cn">${esc(c.name)}</span>
      <div class="cicons">${icons}</div>
      <div class="cstrip"><span class="cs stage">${c.stage?ROMAN[c.stage-1]:'✕'}</span>${cells}</div></div>${extra.acts||''}</div>`;
}
// Scoundrel picture: the generated portrait for its template (art/scoundrels/scoundrel-NN.png), else the seeded SVG face.
// Place illustration: the generated scene (art/locations/location-<id>.png or lab-<id>.png) if present, else the SVG drawing.
// Place popup header: the scene flush to the modal's top and sides, the place name large in white over it.
function placeHero(id, name, lab, text){ return `<div class="phero">${placeArt(id, lab)}<span class="phname">${esc(name)}</span>${text?`<p class="ptext">${text}</p>`:''}</div>`; }
function placeArt(id, lab){ const src=IMG[(lab?'lab-':'location-')+id]; return src ? `<img src="${src}" alt="">` : (ART[id]||''); }
// Scoundrel card in the physical game's layout: full-bleed portrait, cost and humanity marks top left, a title band across the
// middle with the name and a line of flavour, a benefit row (expertise, humanity, materials), and the stage and counts strip at the foot.
// Hospital Thieves draw from the Hospital instead, so they get a text panel where the strip would be.
// Icon images (art/icons/icon-*.png, transparent) with emoji fallback.
function icon(name, fallback, cls){ const src=IMG['icon-'+name]; return src ? `<img class="ico ${cls||''}" src="${src}" alt="${fallback}">` : `<span class="ico ${cls||''}">${fallback}</span>`; }
// Gain row on research and humanity cards: a number beside the matching icon (expertise brain, reputation medal, coin, heart).
function gainIconsHTML(g){ g=g||{}; const parts=[];
  if(g.exp) parts.push(`<span class="gi"><b>${g.exp}</b>${icon('expertise','🧠')}</span>`);
  if(g.rep) parts.push(`<span class="gi"><b>${g.rep}</b>${icon('reputation','🎖️')}</span>`);
  if(g.coin) parts.push(`<span class="gi"><b>${g.coin}</b>${icon('coin','🪙')}</span>`);
  if(g.hum) parts.push(`<span class="gi"><b>${Math.abs(g.hum)}</b>${g.hum>0?icon('heart','❤️'):icon('heart-broken','💔')}</span>`);
  return parts.join(''); }
// Dice strip under a research card: a gray or blue die with the eye face, and what the card does to the dice.
function diceStripHTML(mit){ const blue=mit==='rerollBlue'; return `<div class="rdice"><span class="rdie ${blue?'blue':'gray'}">${DIEICON.alive}</span><span>${MIT_N[mit]}</span></div>`; }
function coins(n){ return Array.from({length:n},()=>icon('coin','🪙')).join(''); }
function hearts(n, broken){ return Array.from({length:n},()=>icon(broken?'heart-broken':'heart', broken?'💔':'❤️')).join(''); }
function scoundrelCardHTML(c, extra, cost, hc){
  const n=t=>{ const m=(c.mats||[]).find(x=>x[0]===t); return m?m[2]:0; };
  const st=(c.mats||[]).find(x=>x[0]!=='bone'); const stage=st?ROMAN[st[1]-1]:'';
  const marks=`<span class="cm coins" title="${cost} francs">${coins(cost)}</span>${hc?`<span class="cm hearts" title="−${hc} humanity">${hearts(hc,true)}</span>`:''}`;
  const ben=[ c.exp?`<span class="ci" title="or +${c.exp} expertise${c.expH?', −1 humanity':''}">+${c.exp} <span class="soft">exp</span>${c.expH?hearts(1,true):''}</span>`:'',
              c.hum?`<span class="ci" title="or +${c.hum} humanity">+${c.hum} ${hearts(1)}</span>`:'',
              (c.mats&&c.mats.length)?`<span class="ci" title="or the materials below">mats</span>`:'' ].join('');
  const foot = c.kind==='thief'
    ? `<div class="cstrip text">Draw ${c.draw} from the Hospital stack<br><small>(or the deck, if the stack is empty)</small></div>`
    : `<div class="cstrip"><span class="cs stage">${stage||'✕'}</span>${[['muscle',n('muscle')],['organ',n('organ')],['blood',n('blood')],['animal',n('animal')],['bone',n('bone')]].filter(([t])=>t!=='animal'||n('animal')).slice(0,4).map(([t,v])=>`<span class="cs ${t} ${v?'':'z'}">${v}</span>`).join('')}</div>`;
  return `<div class="gcard-wrap ${extra.sel?'sel':''}"><div class="ccard sc"><img src="${IMG[`scoundrel-${String(c.tpl+1).padStart(2,'0')}`]}" alt="">
      <div class="cmarks">${marks}</div>
      <span class="ck">Scoundrel</span><span class="cn">${esc(c.name)}</span>
      ${(c.kind==='thief'||extra.acts)?'':`<div class="cicons">${ben}</div>`}${foot}</div>${extra.acts||''}</div>`;
}
function scoundrelArt(c){ const k=c.tpl==null?null:`scoundrel-${String(c.tpl+1).padStart(2,'0')}`; const src=k&&IMG[k]; return src ? `<img src="${src}" alt="">` : portrait(c.seed||7,'docks',true); }
function cadaverArt(c){ const src=c.art&&IMG[c.art]; return src ? `<img src="${src}" alt="">` : portrait(c.seed, c.src, false); }

/* =========================================================
   BOARD RENDERING
   ========================================================= */
function bar(filled,n,cls,opts){ opts=opts||{}; return `<div class="bar ${cls}" style="--n:${n}">${Array.from({length:n},(_,k)=>{ const mk=opts.marks&&opts.marks.includes(k+1); const t=mk&&opts.tips?opts.tips[k+1]:'';
  return `<i class="${k<filled?'on':''} ${mk?'mk':''}" ${t?`data-tipt="${esc(t)}" aria-label="${esc(t.replace(/<[^>]+>/g,''))}"`:''}></i>`; }).join('')}</div>`; }
const EXP_TIPS={3:'<b>Expertise 3</b>You can build arms.',8:'<b>Expertise 8</b>You can build the torso.',10:'<b>Expertise 10</b>One of your shock dice becomes a blue die (more eyes, fewer bolts).',14:'<b>Expertise 14</b>You can build the head.',20:'<b>Expertise 20</b>Two of your shock dice become blue.',27:'<b>Expertise 27</b>Bonus objective, if it is in play this game: the first to reach it gains 10 VP.'};
const REP_TIPS={7:'<b>Reputation 7</b>The Hospital lets you retrieve a cadaver for free. You hire a 3rd assistant.',15:'<b>Reputation 15</b>An assistant is promoted to a 2nd scientist. At the Hospital you may take a 2nd cadaver for 1 franc.',23:'<b>Reputation 23</b>Bonus objective, if it is in play this game: the first to reach it gains 10 VP.'};
const SLOT_ORDER=[['legR','R Leg'],['legL','L Leg'],['armR','R Arm'],['armL','L Arm'],['torso','Torso'],['head','Head']];
function humBar(h){ return `<div class="bar hd" style="--n:20">${Array.from({length:20},(_,k)=>{ const v=k-10; const on = h<0 ? (v>=h&&v<0) : (v>=0&&v<h); return `<i class="${on?'on '+(h<0?'neg':'pos'):''}" ${k===10?'style="box-shadow:-2px 0 0 var(--parch-dim)"':''}></i>`; }).join('')}</div>`; }
function statBars(p, small){
  return `<div class="tracks ${small?'small':''}">
      <div class="track"><span class="lab">${icon(p.hum<0?'heart-broken':'heart','❤️','si')}Humanity</span>${humBar(p.hum)}<span class="num">${p.hum>0?'+':''}${p.hum}</span></div>
      <div class="track"><span class="lab">${icon('expertise','🧠','si')}Expertise</span>${bar(Math.min(p.exp,30),30,'e',{marks:[3,8,10,14,20,27], tips:EXP_TIPS})}<span class="num">${p.exp}</span></div>
      <div class="track"><span class="lab">${icon('reputation','🎖️','si')}Reputation</span>${bar(Math.min(p.rep,30),30,'r',{marks:[7,15,23], tips:REP_TIPS})}<span class="num">${p.rep}</span></div>
    </div>`;
}
// Meeples: flat single-colour silhouettes drawn on a 14x20 pixel grid (one path of unit squares, so they stay crisp at any size).
// Scientist: top hat, narrow shoulders, split coat tails. Assistant: flat cap with a brim, round shoulders, solid apron. Colour is the player's.
const MEEPLE_GRID = {
  scientist: [
    '....######....','....######....','....######....','..##########..','.....####.....','....######....','....######....','.....####.....',
    '...########...','..##########..','..##########..','..##########..','..##########..','..##########..','..####..####..','..####..####..','..####..####..','..............','..............','..............'],
  assistant: [
    '..............','..............','....######....','...#########..','.....####.....','....######....','....######....','.....####.....',
    '...########...','..##########..','.############.','.############.','.############.','.############.','.############.','.############.','..##########..','..............','..............','..............'],
};
const MEEPLE_PATH = Object.fromEntries(Object.entries(MEEPLE_GRID).map(([k,rows])=>[k, rows.map((r,y)=>[...r].map((ch,x)=>ch==='#'?`M${x} ${y}h1v1h-1z`:'').join('')).join('')]));
// size is the assistant's height; a scientist is drawn 1.5x taller so the two tell apart at a glance.
function meeple(kind,color,size){
  size=(size||18)*(kind==='scientist'?1.5:1); const d=MEEPLE_PATH[kind]||MEEPLE_PATH.assistant;
  return `<svg width="${size*.7}" height="${size}" viewBox="0 0 14 20" aria-hidden="true" shape-rendering="crispEdges"><path d="${d}" fill="${color}"/></svg>`;
}
// Operating table as pixel art: the table image under six part images (muscle, skin or alive), empty slots as a faint ghost, damage badges at each part's centre.
function tableHTML(p,key){
  if(!(IMG['table'] && IMG['muscle-head'])) return tableSVG(p,key);
  const parts=SLOT6.map(s=>{ const t=p.table[s]; const st=!t?'':t.alive?'alive':t.side==='skin'?'skin':'muscle'; const c=BODY_CENTRES[s];
    const img=st?`<img class="bp ${st}" src="${IMG[st+'-'+s]}" alt="">`:`<img class="bp ghost" src="${IMG['muscle-'+s]}" alt="">`;
    const dmg=t&&t.dmg?`<span class="bdmg" style="left:${c[0]}%;top:${c[1]}%" title="${SLOT_N[s]}: ${t.dmg} damage">⚡${t.dmg}</span>`:'';
    return img+dmg; }).join('');
  return `<div class="tablefig" role="img" aria-label="Operating table: ${onTable(p).length} parts built, ${completeCount(p)} with skin, ${aliveCount(p)} alive, ${dmgTotal(p)} damage"><img class="bt" src="${IMG['table']}" alt=""><div class="body">${parts}</div></div>`;
}
function tableSVG(p,key){
  key=key||0;
  const EMPTY=`fill="none" stroke="var(--line2)" stroke-dasharray="3 3"`;
  const fill=s=>{ const t=p.table[s]; if(!t) return EMPTY;
    if(t.alive) return `fill="#9fd0ff" stroke="#d7ecff" stroke-width="2" filter="url(#glw${key})"`;
    if(t.side==='skin') return `fill="#e0b22e" stroke="#f6d35a" stroke-width="1.6"`;
    return `fill="#b23a2b" stroke="#e0533f" stroke-width="1.6"`; };
  const dm=(s,x,y)=>{ const t=p.table[s]; if(!t||!t.dmg) return '';
    return `<g transform="translate(${x},${y})"><title>${SLOT_N[s]}: ${t.dmg} damage</title><rect x="-12" y="-8" width="24" height="16" rx="8" fill="#17121a" stroke="#ffd36a" stroke-width="1.2"/>
      <path d="M-4 -6l-4 7h4l-2 6 7-8h-4l2-5z" fill="#ffd36a"/><text x="6" y="4.5" text-anchor="middle" font-size="11" font-weight="700" fill="#ffd36a" font-family="EB Garamond, Georgia, serif">${t.dmg}</text></g>`; };
  const sk=s=>p.table[s]&&p.table[s].side==='skin'&&!p.table[s].alive;
  return `<svg viewBox="0 0 120 210" role="img" aria-label="Operating table: ${onTable(p).length} parts built, ${completeCount(p)} with skin, ${aliveCount(p)} alive, ${dmgTotal(p)} damage">
    <defs><filter id="glw${key}" x="-40%" y="-40%" width="180%" height="180%"><feGaussianBlur stdDeviation="2.5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>
    <rect x="6" y="2" width="108" height="206" rx="6" fill="#2a2420" stroke="var(--line2)"/><path d="M14 70h92M14 140h92" stroke="#4b4152" stroke-width="5" opacity=".6"/>
    <path ${fill('head')} d="M60 10c12 0 19 8 19 20s-7 22-19 22-19-10-19-22 7-20 19-20z"/><path ${fill('torso')} d="M40 56h40l5 10-3 58H38l-3-58z"/>
    <path ${fill('armL')} d="M34 58l-11 6-8 62 8 2 8-54 6-6z"/><path ${fill('armR')} d="M86 58l11 6 8 62-8 2-8-54-6-6z"/>
    <path ${fill('legL')} d="M39 126h19l-2 74h-12z"/><path ${fill('legR')} d="M62 126h19l-5 74h-12z"/>
    ${sk('head')?'<path d="M44 26h32M48 24v4M54 24v4M60 24v4M66 24v4M72 24v4" stroke="#7a5a12" fill="none"/>':''}${sk('torso')?'<path d="M60 60v60M57 70h6M57 82h6M57 94h6M57 106h6" stroke="#7a5a12" fill="none"/>':''}
    ${dm('head',60,31)}${dm('torso',60,92)}${dm('armL',22,98)}${dm('armR',98,98)}${dm('legL',48,168)}${dm('legR',70,168)}</svg>`;
}
function visibleLocs(){ return LOCS.filter(l=>!l.event || (l.event==='odeon'&&S.odeonOpen)); }
// ---------- The board: Bruno's painted Paris with places, meeple slots and card slots overlaid ----------
function faceUp(id){ return id==='hospital'?S.hosp : id==='academy'?S.researchRow : id==='church'?S.humanityRow : id==='docks'?S.docks : id==='square'?S.square : []; }
// Research scene: art/research/research-NN.png by the card's position in RESEARCH, else the small SVG icon.
function researchArt(c){ const k=RESEARCH.findIndex(r=>r.id===c.id); const src=k>=0&&IMG[`research-${String(k+1).padStart(2,'0')}`]; return src ? `<img src="${src}" alt="">` : researchIcon(c); }
function researchIcon(c){ return ICONART[c.id==='demo'||c.id==='electro'?'jar':c.id==='healing'||c.id==='transfusion'?'flask':c.id==='tutor'||c.id==='guest'?'coin':'book']; }
function slotDot(key){ const o=S.occ[key]; if(!o) return '<i class="slot"></i>'; return `<i class="slot on ${o.kind==='scientist'?'sci':''}">${meeple(o.kind,S.players[o.p].color,16)}</i>`; }
function miniArt(c){ if(c.kind==='cadaver') return cadaverArt(c); if(SC_WHO[c.kind]) return scoundrelArt(c); if(c.kind==='research') return researchArt(c); if(c.kind==='humanity') return ICONART.candle; return ''; }
// Mini card on the board: art and name only. The place popup shows the same card at full size.
function miniCard(c){
  if(c.kind==='cadaver' && c.art && IMG[c.art]){ const n=t=>{ const m=c.mats.find(x=>x[0]===t); return m?m[2]:0; };
    return `<div class="mcard cad" title="${esc(c.name)}"><span class="mart"><img src="${IMG[c.art]}" alt=""></span><span class="mstrip"><span class="stage">${c.stage?ROMAN[c.stage-1]:'✕'}</span>${['muscle','organ','blood','bone'].map(t=>`<span class="${t} ${n(t)?'':'z'}">${n(t)}</span>`).join('')}</span></div>`; }
  if(SC_WHO[c.kind] && c.tpl!=null && IMG[`scoundrel-${String(c.tpl+1).padStart(2,'0')}`]){ const n=t=>{ const m=(c.mats||[]).find(x=>x[0]===t); return m?m[2]:0; }; const st=(c.mats||[]).find(x=>x[0]!=='bone');
    const strip = c.kind==='thief' ? `<span class="mstrip one">Draw ${c.draw}</span>` : `<span class="mstrip"><span class="stage">${st?ROMAN[st[1]-1]:'✕'}</span>${['muscle','organ','blood','bone'].map(t=>`<span class="${t} ${n(t)?'':'z'}">${n(t)}</span>`).join('')}</span>`;
    return `<div class="mcard cad" title="${esc(c.name)}: ${fr(scCost(c))}"><span class="mart"><img src="${IMG[`scoundrel-${String(c.tpl+1).padStart(2,'0')}`]}" alt=""></span>${strip}</div>`; }
  if((c.kind==='research' && IMG['card-research-bg']) || (c.kind==='humanity' && IMG['card-humanity-bg'])){ const hum=c.kind==='humanity';
    return `<div class="mcard face ${hum?'hum':''}" title="${esc(c.name)}"><span class="memblem">${icon(hum?'cross':'book', hum?'✝':'📖')}</span></div>`; }
  const framed = hasFrame() && c.kind==='research';
  return `<div class="mcard ${framed?'framed':''}"><span class="mart">${miniArt(c)}</span><span class="mname">${esc(c.name)}</span></div>`; }
function miniBack(name,left){ return IMG['card-tall-back'] ? `<div class="mcard back"><span class="plate">${esc(name)}</span><span class="mcount">${left}</span></div>` : `<div class="mcard back plain"><span class="mname">${esc(name)} deck</span><span class="mcount">${left}</span></div>`; }
function slotsHTML(l){
  const b=BOARD_POS[l.id]||{}; if(!b.cards) return '';
  let inner='';
  if(l.id==='cemetery') inner=miniBack('Grave', S.decks.cemetery.length);
  else if(l.id==='morgue') inner=miniBack('Morgue', S.decks.morgue.length);
  else { const rows=faceUp(l.id).slice(0,3); const fixed=l.id==='academy'||l.id==='church'||l.id==='docks'; const pad=fixed ? Math.max(0,3-rows.length) : (rows.length?0:1);
    inner = rows.map(miniCard).join('') + '<i class="mslot"></i>'.repeat(pad); }
  return `<div class="slots">${inner}</div>`;
}
function boardHTML(){
  const p=S.players[0];
  const places = visibleLocs().map(l=>{
    const keys=l.spaces.map(sp=>l.id+'.'+sp.k), can=keys.some(humanCan), closed=!!S.closed[l.id], b=BOARD_POS[l.id]||{x:50,y:50};
    if(closed) return `<div class="place closed cards-none" style="left:${b.x}%;top:${b.y}%" data-id="${l.id}" title="Closed" aria-label="${esc(l.name)}, closed today"><div class="pchip"><span class="pname">${esc(l.name)}</span><span class="pcross" aria-hidden="true"></span></div></div>`;
    return `<div class="place ${can?'can':''} cards-${b.cards||'none'}" style="left:${b.x}%;top:${b.y}%" data-act="loc" data-id="${l.id}" tabindex="0" role="button" aria-label="${esc(l.name)}">
      <div class="pchip"><span class="pname">${esc(l.name)}</span><span class="pslots">${keys.map(slotDot).join('')}</span></div>${slotsHTML(l)}</div>`;
  }).join('');
  const labCan=LABSPOTS.some(L=>humanCan('lab.'+L.id));
  const lab = `<div class="place ${labCan?'can':''} cards-none" style="left:${LAB_POS.x}%;top:${LAB_POS.y}%" data-act="labplace" data-id="lab" tabindex="0" role="button" aria-label="Your laboratory"><div class="pchip"><span class="pname">Your laboratory</span><span class="pslots">${LABSPOTS.map(L=>{ const used=p.labUsed[L.id]; return used?`<i class="slot on ${used==='scientist'?'sci':''}">${meeple(used,p.color,16)}</i>`:'<i class="slot"></i>'; }).join('')}</span></div></div>`;
  return `<div class="board" aria-label="Paris, 1819">${places}${lab}</div>`;
}
// Small gain tokens for option rows: a number with an icon, a material cube, or a short text.
const gt = (n, name, fb) => `<span class="gi"><b>${n}</b>${icon(name, fb)}</span>`;
const gtx = t => `<span class="gi txt">${t}</span>`;
const grow = (...parts) => `<span class="gainrow">${parts.filter(Boolean).join('')}</span>`;
function spaceGain(key, kind){
  const p=S.players[0]; const sci=kind==='scientist';
  switch(key){
    case 'cemetery.dig': case 'morgue.buy': case 'market.trade': case 'docks.hire': return '';
    case 'square.buy': return grow(gt(1,'coin','🪙'), gtx('one body shown below'));
    case 'slaughter.take': return grow(cube('animal',4,2), gtx('or'), cube('animal',3,1), S.ev==='meat' ? gtx('· plus')+cube('animal',2,0)+gt(1,'coin','🪙') : '');
    case 'hospital.retrieve': { const l=hospLimits(p);
      if(l.free) return grow(gtx('Free · take 1 body below'), l.paid ? gtx(`· up to ${l.paid} more at`)+gt(1,'coin','🪙')+gtx('each') : '');
      return S.ev==='corrupt' ? grow(gt(1,'coin','🪙'), gtx('bribe · take 1 body below')) : grow(gtx('Needs'), gt(7,'reputation','🎖️')); }
    case 'hospital.work': return S.ev==='hardtimes' ? 'Closed today' : grow(gt((p.exp>=13?4:p.exp>=7?3:2)+(S.ev==='cholera'?2:0),'coin','🪙'));
    case 'hospital.volunteer': return grow(gt(1,'heart','❤️'), gt(2,'reputation','🎖️'));
    case 'academy.adv': return grow(gt(1,'expertise','🧠'), gtx('· 1 research card below'), S.ev==='grant'?gt(2,'coin','🪙'):'');
    case 'academy.research': return grow(gtx('1 research card below'), S.ev==='grant'?gt(2,'coin','🪙'):'');
    case 'academy.lecture': return grow(S.ev==='hardtimes'?'':gt(1,'coin','🪙'), gt(1+(sci?1:0),'reputation','🎖️'), sci?'':gtx('(scientist: +2)'), S.ev==='grant'?gt(2,'coin','🪙'):'');
    case 'academy.donate': return grow(gtx('Pay 1 to 3'), icon('coin','🪙'), gtx('· +1'), icon('reputation','🎖️'), gtx('per franc'));
    case 'alley.murder': return grow(cube('muscle',4,1), cube('organ',4,1), cube('blood',3,1), cube('bone',2,0), `<span class="gi neg"><b>3</b>${icon('heart-broken','💔')}</span>`, `<span class="gi neg"><b>1</b>${icon('police','⭐')}</span>`);
    case 'church.atone': return grow(gtx('1 humanity card below'), sci ? gt(1,'heart','❤️') : gtx('(scientist: +1 humanity)'));
    case 'first.first': return '(can’t be bumped)';
    case 'odeon.show': return grow(gt(2,'reputation','🎖️'));
    case 'lab.practice': return grow(gt(1,'expertise','🧠'));
    case 'lab.blood': return grow(cube('blood',3,1));
    case 'lab.repair': return 'Remove up to 3 damage';
    case 'lab.charge': return grow(gtx('Charge'), gt(sci?3:2,'jar','🏺'), sci?'':gtx('(scientist: 3)'));
  }
  return '';
}
// Deck marker: Bruno's wooden card back with the deck name on the brass plate, plus how many cards remain before a reshuffle.
function deckHTML(name, left, total){ if(!IMG['card-tall-back']) return `<p>${esc(name)} deck: ${left} of ${total} cards left.</p>`; return `<div class="deckrow"><div class="cardback" role="img" aria-label="${esc(name)} deck"><span class="plate">${esc(name)}</span></div><div class="deckinfo"><b>${esc(name)} deck</b><span>${left} of ${total} cards left</span></div></div>`; }
const ROW_LABEL = {hospital:'Bodies waiting today', academy:'Research on offer', church:'Humanity cards on offer', docks:'Scoundrels for hire', square:'Bodies on display'};
function occupantLine(key, can){ const o=S.occ[key]; if(!o) return ''; const b=can?bumpInfo(0,key):null;
  return `${esc(S.players[o.p].name)}’s ${o.kind}${can&&b?(b.free?' · bump free':b.cost?` · bump ${fr(b.cost)}`:' · bump'):''}`; }
// The occupant's meeple, drawn large at the left of an option row.
// Two meeple slots at the left of every option, scientist then assistant, dotted when empty.
// A space holds one meeple; the occupant fills the slot of its kind. A scientist-only space keeps both slots so every row lines up.
function slotsLead(occ, mine){ const o=occ; const col=o?S.players[o.p].color:null;
  const slot=k=>`<span class="mslot2 ${o&&o.kind===k?'on':''}">${o&&o.kind===k?meeple(k,col,22):meeple(k,'#ece0c6',22)}</span>`;
  return `<span class="optlead two">${slot('scientist')}${slot('assistant')}</span>`; }
function occupantLead(key){ return slotsLead(S.occ[key]); }
// Place popup: what the place does, one option per action space with its exact gain and cost, and the cards there at full size.
async function placeModal(id){
  const L=LOC[id], p=S.players[0], mine=isMyTurn(), closed=!!S.closed[id];
  let opts=L.spaces.map(sp=>{ const key=L.id+'.'+sp.k, can=humanCan(key), kind=kindFor(0,key)||p.sel, who=occupantLine(key,can);
    const gain=spaceGain(key,kind); return {label:`${esc(sp.n)}${sp.sci?'<small class="scitag">scientist</small>':''}`, sub:`${gain}${who?(gain?'<br>':'')+who:''}`, value:key, disabled:!can, lead:occupantLead(key)}; });
  if(id==='church'){ const key='church.atone', can=humanCan(key), kind=kindFor(0,key)||p.sel, who=occupantLine(key,can); let picked=null;
    const html=(reg,done)=>`${placeHero(id, L.name, false, L.text)}${closed?'<p class="closedline">Closed today.</p>':''}${mine?'':'<p class="flavor">Not your move right now. You can look, not act.</p>'}${who?`<p class="flavor">${who}</p>`:''}
      <div class="sub">Take a humanity card${kind==='scientist'?' <span class="gi"><b>+1</b>'+icon('heart','❤️')+'</span>':''}</div>
      <div class="gcards">${S.humanityRow.map(c=>cardHTML(c,{acts:`<div class="gc-acts col"><button class="btn primary sm" ${can?'':'disabled'} data-mfn="${reg(()=>{ picked={card:c.id}; done(key); })}">Take this</button></div>`})).join('')||'<p class="flavor">None left today.</p>'}</div>`;
    const k=await ask({title:'', hero:true, wide:true, html, buttons:[{label:'Close', value:null}]});
    if(k && picked){ prePick=picked; await clickSpace(k); prePick=null; }
    return; }
  if(id==='cemetery'||id==='morgue'){ const key=id==='cemetery'?'cemetery.dig':'morgue.buy', can=humanCan(key), who=occupantLine(key,can);
    const n=(id==='cemetery'?3:2)+(S.ev==='cholera'?1:0);
    opts=[{label: id==='cemetery' ? `Dig up to ${n} cadavers` : `Buy up to ${n} cadavers <span class="optcost">${coins(1)}</span>`, sub: who, value:key, disabled:!can, lead:occupantLead(key)}]; }
  if(id==='slaughter'){ const key='slaughter.take', can=humanCan(key), who=occupantLine(key,can), extra=S.ev==='meat'?' Glut of Meat: +2 animal and +1 franc.':'';
    opts=[{label:`Take 4 animal at stage II ${cube('animal',4,2)}`, sub:`${extra.trim()}${who?(extra?'<br>':'')+who:''}`, value:{key, pre:{opt:'four'}}, disabled:!can, lead:occupantLead(key)},
          {label:`Take 3 animal at stage I ${cube('animal',3,1)}`, sub:extra.trim(), value:{key, pre:{opt:'three'}}, disabled:!can, lead:occupantLead(key)}]; }
  let cards='';
  if(id==='docks'){ const key='docks.hire', can=humanCan(key); let picked=null;
    const html=(reg,done)=>`${placeHero(id, L.name, false, L.text)}${closed?'<p class="closedline">Closed today.</p>':''}${mine?'':'<p class="flavor">Not your move right now. You can look, not act.</p>'}
      <div class="sub">Hire one of the scoundrels</div><div class="gcards">${S.docks.map(c=>{ const ok=can && scCost(c)<=p.coin && scAllowed(c); const un=c.kind==='cut' && p.hand.some(h=>h.id==='unethical') && charged(p)>0;
        const b=(label,v,primary)=>`<button class="btn ${primary?'primary':''} sm" ${ok?'':'disabled'} data-mfn="${reg(()=>{ picked=v; done(key); })}">${label}</button>`;
        const acts = c.kind==='thief' ? b(`Draw ${c.draw} from the Hospital`,{card:c.id,how:'mats'},true)
          : [b('Materials',{card:c.id,how:'mats'},true), c.exp?b(`+${c.exp} ${icon('expertise','🧠','si')}${c.expH?` −1 ${icon('heart-broken','💔','si')}`:''}`,{card:c.id,how:'exp'}):'', c.hum?b(`+${c.hum} ${icon('heart','❤️','si')}`,{card:c.id,how:'hum'}):'', un?b(`${icon('cards','🃏','si')} Use card “Unethical Experiment”`,{card:c.id,how:'exp',unethical:true}):''].join('');
        return cardHTML(c,{acts:`<div class="gc-acts col">${acts}</div>`}); }).join('')}</div>`;
    const k=await ask({title:'', hero:true, wide:true, html, buttons:[{label:'Close', value:null}]});
    if(k && picked){ prePick=picked; await clickSpace(k); prePick=null; }
    return; }
  if(id==='market'){ const key='market.trade', can=humanCan(key), who=occupantLine(key,can); const o=marketState(); let go=false;
    const html=(reg,done)=>`${placeHero(id, L.name, false, L.text)}${closed?'<p class="closedline">Closed today.</p>':''}${mine?'':'<p class="flavor">Not your move right now. You can look, not act.</p>'}${who?`<p class="flavor">${who}</p>`:''}
      <div class="sub">Do as many trades as you like</div>${marketBody(p,o,reg)}
      <div class="actions"><button class="btn" data-mfn="${reg(()=>done(null))}">Close</button><button class="btn primary" ${can?'':'disabled'} data-mfn="${reg(()=>{ go=true; done(key); })}">Trade</button></div>`;
    const k=await ask({title:'', hero:true, wide:true, html, locked:true});
    if(k && go){ prePick={...o}; await clickSpace(k); prePick=null; }
    return; }
  if(id==='cemetery'||id==='morgue') cards='';
  else { const rows=faceUp(id); if(ROW_LABEL[id]) cards=`<div class="sub">${ROW_LABEL[id]}</div>${rows.length?`<div class="gcards">${rows.map(c=>cardHTML(c)).join('')}</div>`:'<p class="flavor">None left today.</p>'}`; }
  const key=await ask({title:'', hero:true, wide:true, html:`${placeHero(id, L.name, false, L.text)}${closed?'<p class="closedline">Closed today.</p>':''}${mine?'':'<p class="flavor">Not your move right now. You can look, not act.</p>'}${cards}`,
    options:opts, buttons:[{label:'Close', value:null}]});
  if(key && key.pre){ prePick=key.pre; await clickSpace(key.key); prePick=null; }
  else if(key) await clickSpace(key);
}
async function labPlaceModal(){
  const p=S.players[0], mine=S.phase==='day'&&isMyTurn();
  const options=LABSPOTS.map(L=>{ const key='lab.'+L.id, can=humanCan(key), kind=kindFor(0,key)||p.sel, used=p.labUsed[L.id];
    return {label:`${esc(L.name)}${L.sci?'<small class="scitag">Scientist</small>':''}`, sub:`${spaceGain(key,kind)}${used?'<span class="usedtag">Used today</span>':''}`, value:key, disabled:!can, lead:slotsLead(used?{p:0,kind:used}:null)}; });
  const k=await ask({title:'', hero:true, html:`${placeHero('lab', 'Your laboratory', false, 'Four spaces of your own. Each can be used once a day.')}${mine?'':'<p class="flavor">Not your move right now. You can look, not act.</p>'}`, options, buttons:[{label:'Close', value:null}]});
  if(k) await clickSpace(k);
}
// Night falls: everyone is home. Offer the laboratory or the end of the night right away.
async function nightPrompt(){
  const go=await ask({title:`Night ${S.round}`, html:'<p>Everyone is home. Build, throw the switch and preserve in your laboratory, or end the night now.</p>', buttons:[{label:'End the night', value:false},{label:'Go to the laboratory', primary:true, value:true}]});
  if(go) labModal(); else handle('endlab',{});
}
function todayModal(){
  const c=S.card; if(!c) return;
  const card = c.t==='ev' ? eventCardHTML(EVENTS.find(x=>x.id===c.id)) : encounterCardHTML(ENCOUNTERS.find(x=>x.id===c.id));
  openModal({title:`Day ${S.round}`, wide:true, html:`${eventNowHTML()}<div class="gcards">${card}</div>`, buttons:[{label:'Close',primary:true,fn:closeModal}]});
}
function todayLabel(){ const c=S.card; if(!c) return ''; if(c.t==='ev') return esc(EVENTS.find(x=>x.id===c.id).name); const e=ENCOUNTERS.find(x=>x.id===c.id); return `Encounter: ${e.who==='captain'?'Captain Walton':e.who==='woman'?'a stranger':'the Creature'}`; }
function captainTrack(){
  return `<div class="captain" title="Captain Walton closes in. When he reaches the skull, the game ends.">${Array.from({length:MAX_ROUNDS},(_,k)=>`<i class="${k<S.captain?'past':''} ${k===S.captain?'now':''}"></i>`).join('')}<span class="skull">☠</span></div>`;
}
function objectivesHTML(){
  return `<div class="objs">${S.objectives.map(id=>{ const o=OBJECTIVES.find(x=>x.id===id); const c=S.claimed[id]; return `<span class="obj ${c!==undefined?'got':''}" title="10 VP">${c!==undefined?`<span class="dot" style="background:${S.players[c].color}"></span>`:''}${esc(o.name)}</span>`; }).join('')}</div>`;
}
function eventNowHTML(){
  const c=S.card; if(!c) return '';
  if(c.t==='ev'){ const e=EVENTS.find(x=>x.id===c.id); return `<div class="eventcard"><span class="eyebrow">Today · event${e.storm?' · lightning':''}${e.exec?' · execution':''}</span><h3>${esc(e.name)}</h3><p>${esc(e.text)}</p></div>`; }
  const e=ENCOUNTERS.find(x=>x.id===c.id);
  return `<div class="eventcard"><span class="eyebrow">Today · encounter</span><h3>${e.who==='captain'?'Captain Walton':e.who==='woman'?'A stranger':'The Creature'}</h3><p>${e.loc? (S.locEnc ? `${esc(S.players[S.locEnc.holder].name)} holds a secret encounter somewhere in Paris.` : 'The secret encounter has been met.') : 'An encounter took place this morning. See the chronicle.'}</p></div>`;
}
function vpLine(arr){ return `VP by oldest material used: ${arr.map((v,k)=>`<span class="vpst">${ROMAN[k]} <b>${v}</b></span>`).join(' ')}`; }
function pointsTable(){
  const row=(n,P,cnt)=>`<tr><td>${n}${cnt>1?` <small>×${cnt}</small>`:''}</td>${P.vpS.map(v=>`<td class="m">${v}</td>`).join('')}${P.vpC.map(v=>`<td class="s">${v}</td>`).join('')}<td class="a">${P.alive}</td></tr>`;
  return `<div class="ptable"><table><thead>
    <tr><th></th><th colspan="4" class="m">Muscle (start)</th><th colspan="4" class="s">Skin (complete)</th><th class="a">Alive</th></tr>
    <tr><th>Part</th>${['I','II','III','IV'].map(r=>`<th class="m">${r}</th>`).join('')}${['I','II','III','IV'].map(r=>`<th class="s">${r}</th>`).join('')}<th class="a">end</th></tr></thead><tbody>
    ${row('Head',PARTS.head,1)}${row('Torso',PARTS.torso,1)}${row('Arm',PARTS.arm,2)}${row('Leg',PARTS.leg,2)}</tbody></table>
    <p>Each step scores VP by the stage of the oldest material you use (I is freshest). Animal costs 1 VP (2 if 3 or more). Alive points count at the end of the game.</p></div>`;
}
function anatomyHTML(p,ro){
  const lab=!ro&&S.phase==='lab';
  return SLOT6.map(s=>{
    const t=p.table[s], P=PARTS[SLOT_T[s]], step=nextStep(p,s);
    const state = !t?'<span class="state">Not started</span>' : t.alive?'<span class="state alive">Alive</span>' : t.side==='skin'?'<span class="state skin">Complete</span>':'<span class="state muscle">Muscle</span>';
    let body='';
    if(step){
      const opts={steady:!ro&&uiOpts.steady, surgeon:!ro&&uiOpts.surgeon};
      const f=planBuild(p,s,'fresh',opts), o=planBuild(p,s,'old',opts);
      const lack = !f.expOK ? `Needs expertise ${P.exp}` : !f.matsOK ? 'Not enough materials' : '';
      const btns = lab ? (f.ok ? `<button class="animate" data-act="build" data-slot="${s}" data-pol="fresh">${step==='start'?'Start':'Add skin'} · +${f.vp} VP</button>${o.ok&&o.vp!==f.vp?`<button class="chip" data-act="build" data-slot="${s}" data-pol="old">Use oldest first · +${o.vp} VP</button>`:''}` : `<span style="font-size:12px;color:var(--muted)">${lack}</span>`)
        : ro ? (f.ok?`<span style="font-size:12px;color:var(--crim)">Could build this tonight</span>`:'') : (f.ok?`<span style="font-size:12px;color:var(--verd)">Ready to build tonight</span>`:`<span style="font-size:12px;color:var(--muted)">${lack}</span>`);
      body=`<div class="areq">${step==='start'?'Start (muscle)':'Add skin'}: ${P.exp?`exp ${P.exp} · `:''}${reqHTML(f.req)} </div><div class="areq vpline">${vpLine(step==='start'?P.vpS:P.vpC)} · alive later: <b>${P.alive}</b></div><div class="abtns">${btns}</div>`;
    } else if(!t.alive) body=`<div class="areq">Complete. Throw the switch to bring it to life: <b>+${P.alive} points</b> at the end.</div>`;
    else body=`<div class="areq">Alive: <b>+${P.alive} points</b> at the end, as long as it stays alive.</div>`;
    return `<div class="arow"><div class="atop"><span class="aname">${SLOT_N[s]}</span><span>${t&&t.dmg?`<span class="dmg">damaged · </span>`:''}${state}</span></div>${body}</div>`;
  }).join('');
}
function decayGridHTML(p){
  const cell=(t,n,k)=>{ const rot=n&&(k===3||(t==='blood'&&k===1)); return `<b class="dg-cell ${n?'on '+t:''} ${rot?'rot':''}">${n||''}</b>`; };
  const rows=MATS.map(t=>`<div class="dg-row"><span class="dg-name"><i class="cube ${t}"></i>${MAT_N[t]}</span>${p.mats[t].map((n,k)=>cell(t,n,k)).join('')}</div>`).join('');
  return `<div class="decaygrid"><span class="eyebrow">Decomposition</span><div class="dg-row dg-head"><span class="dg-name"></span><b>I</b><b>II</b><b>III</b><b>IV</b></div>${rows}
    <div class="dg-foot"><span><i class="cube bone"></i>Bone <b>${p.bone}</b></span><span>Preserved <b>${p.preserved}</b><small>/9</small></span>${p.ice?`<span class="ice">${icon('ice','🧊','si')}no decay for ${p.ice} dawn${p.ice>1?'s':''}</span>`:''}</div></div>`; }
function decayHTML(p,ro){
  const lab=!ro&&S.phase==='lab';
  const rows=MATS.map(t=>`<tr><td><i class="cube ${t}"></i> ${MAT_N[t]}</td>${p.mats[t].map((n,k)=>`<td class="${n?'':'z'} ${(k===3||(t==='blood'&&k===1))&&n?'rot':''}">${n}</td>`).join('')}</tr>`).join('');
  const pres = lab ? ['muscle','organ'].map(t=>{ const n=Math.min(sum(p.mats[t]),9-p.preserved); return n?`<button class="chip" data-act="preserve" data-t="${t}" data-n="${Math.min(3,n)}">Preserve ${Math.min(3,n)} ${t}</button>`:''; }).join('') : '';
  return `<table class="decay"><thead><tr><th>Material</th><th>I</th><th>II</th><th>III</th><th>IV</th></tr></thead><tbody>${rows}
    <tr><td><i class="cube bone"></i> Bone</td><td colspan="4" style="text-align:left">${p.bone} <span style="color:var(--muted)">· never rots (max 12)</span></td></tr>
    <tr><td>Preserved</td><td colspan="4" style="text-align:left">${p.preserved} of 9 <span style="color:var(--muted)">· flesh kept for selling at the Market</span></td></tr></tbody></table>
    ${pres?`<div class="row" style="display:flex;gap:6px;flex-wrap:wrap;margin-top:6px">${pres}</div>`:''}
    <p style="font-size:12px;color:var(--muted);margin:6px 0 0">Each dawn materials age one stage. Red cells rot at the next dawn.${p.ice?` <b style="color:var(--spark)">Ice: no decay for ${p.ice} more dawn${p.ice>1?'s':''}.</b>`:''}</p>`;
}
function handHTML(p){
  if(!p.hand.length) return '<div style="font-size:13px;color:var(--muted)">No cards. Research comes from the Academy, humanity cards from Saint-Roch.</div>';
  return p.hand.map(c=>{ const can=cardPlayable(0,c) && !busy;
    const WHERE={preserve:'Use it: offered at the Market when you sell preserved flesh.', steady:'Use it: at night, tick the Steady Hands box above your parts, then build.', guest:'Use it: offered when you lecture at the Academy.',
      daisy:'Use it: offered when you resolve a cadaver.', dissect:'Use it: offered when you resolve a stage I or II cadaver.', electro:'Use it: offered when you resolve a stage I to III cadaver (needs a charged jar).',
      transfusion:'Use it: offered at Give Blood in your lab.', unethical:'Use it: offered at the Dark Alley or when hiring a Cutthroat (needs a charged jar).', counter:'Works by itself when a rival plays a humanity card on you.',
      burial:'Use it: offered at the Public Square.', animal:'Use it: offered when you lecture.', human:'Use it: offered when you lecture.', trap:'Use it: offered when the Creature visits you.', mercy:'Use it: offered when an execution is announced.',
      midnight:'Use it: press Play during your turn in the city phase.', publish:'Use it: press Play during your turn, while your scientist is still at home.'};
    const how = WHERE[c.id] || (c.when==='any'||c.when==='aid'||c.when==='target' ? 'Use it: press Play.' : '');
    const acts=`<div class="gc-acts col">${can?`<button class="btn primary" data-act="play" data-id="${c.id}">Play</button>`:''}${how?`<span class="huse">${esc(how)}</span>`:''}</div>`;
    return cardHTML(c,{acts}); }).join('');
}
// ---------- Laboratory popup (night actions) ----------
function switchBoxHTML(p){
  const ch=charged(p);
  return `<div class="switchbox"><div class="sub" style="margin:0">Throw the switch</div>
      <div style="font-size:13px;color:var(--parch-dim)">Each charged jar rolls 2 shock dice. ${blueDice(p)?`Your expertise makes ${blueDice(p)} of them blue.`:'Expertise 10 makes one of them blue.'}${p.sabotaged?' <span style="color:var(--crim)">Your wires are cut: you lose a die.</span>':''}${hasChar(p,'zoo')&&!p.zooUsed?' Zoologist: +1 gray die.':''}</div>
      ${p.thrown?'<div style="margin-top:6px;color:var(--muted)">Thrown for tonight.</div>':
        `<div class="row">${[1,2,3].map(n=>`<button class="btn ${n===Math.min(3,ch)?'primary':''}" data-act="throw" data-n="${n}" ${canThrow(p)&&n<=ch?'':'disabled'}>${n} ${icon('jar','🏺','si')} jar${n>1?'s':''}</button>`).join('')}</div>
         ${!SLOT6.some(s=>p.table[s]&&p.table[s].side==='skin')?'<div style="font-size:12px;color:var(--muted);margin-top:4px">You need at least one complete (skinned) part.</div>':ch?'':'<div style="font-size:12px;color:var(--muted);margin-top:4px">No charged jars. Charge them in your lab during the day.</div>'}`}</div>`;
}
function labBody(){
  const p=S.players[0], lab=S.phase==='lab';
  const toggles = lab ? `${p.hand.some(h=>h.id==='steady')?`<label class="chip" style="cursor:pointer"><input type="checkbox" data-opt="steady" ${uiOpts.steady?'checked':''}> Steady Hands: 1 fewer of each material</label>`:''}
    ${hasChar(p,'surgeon')&&!p.surgeonUsed?`<label class="chip" style="cursor:pointer"><input type="checkbox" data-opt="surgeon" ${uiOpts.surgeon?'checked':''}> Surgeon: 1 less material</label>`:''}` : '';
  return `<p class="flavor" style="margin-top:0">${lab?'Build parts (as many as you can), throw the switch once, and preserve spare flesh for the Market.':'By day you can only look. Building and the switch happen at night.'}</p>
    <div class="lab3">
      <div class="labcol"><div class="sub" style="margin-top:0">Operating table</div><div class="figure big">${tableHTML(p,'lab')}</div><div class="legend"><span class="bl muscle">■ muscle ${onTable(p).length-completeCount(p)}</span><span class="bl skin">■ skin ${completeCount(p)-aliveCount(p)}</span><span class="bl alive">■ alive ${aliveCount(p)}</span><span class="bl dmgl">⚡ damage ${dmgTotal(p)}</span></div><p class="num" style="font-size:12.5px;color:var(--parch-dim);text-align:center;margin:4px 0">${p.vp} VP built</p>${lab?switchBoxHTML(p):''}</div>
      <div class="labcol"><div class="sub" style="margin-top:0">Body parts</div>${toggles.trim()?`<div class="row" style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px">${toggles}</div>`:''}<div class="anat">${anatomyHTML(p)}</div></div>
      <div class="labcol"><div class="sub" style="margin-top:0">Decomposition track</div>${decayHTML(p)}<div class="sub">Points per part and quality</div>${pointsTable()}</div>
    </div>`;
}
// Live modals re-render on every render(), so builds, preserves and card plays refresh in place.
function labModal(){ openModal({kind:'lab', live:true, title:'Your laboratory', wide:true, xwide:true, html:()=>labBody(),
  buttons: S.phase==='lab' ? [{label:'Close',fn:closeModal},{label:'End the night',primary:true,fn:()=>handle('endlab',{})}] : [{label:'Close',primary:true,fn:closeModal}]}); }
function characterModal(){
  const p=S.players[0], C=CHARACTERS.find(c=>c.id===p.char);
  openModal({kind:'character', live:true, title:esc(p.name), wide:true, html:()=>`<div style="display:flex;gap:14px;align-items:flex-start">${charArt(p.char,'avatar lg')}<div><b style="font-family:var(--f-display);font-size:18px">${esc(C.name)}</b>, ${esc(C.role.toLowerCase())}.<br><span style="color:var(--parch-dim)">${esc(C.text)}</span>
      ${hasChar(p,'zoo')&&!p.zooUsed&&p.jars.some(j=>!j)&&S.phase!=='end'?`<div style="margin-top:6px"><button class="chip" data-act="zoo">Charge 1 ${icon('jar','🏺','si')} jar with the eel</button></div>`:''}
      ${p.police?`<p class="hint" style="margin:8px 0 0">You have <b>${p.police} police marker${p.police>1?'s':''}</b> from the Dark Alley. ${p.police>=2?'The Dark Alley is closed to you. ':''}<button class="chip" data-act="police" ${p.coin>=3?'':'disabled'}>Pay 3 francs to clear them</button></p>`:''}</div></div>
    <div class="res four" style="margin-top:12px"><div><b>${p.vp}</b><span>VP built</span></div><div><b>${aliveCount(p)}<small>/6</small></b><span>Alive</span></div><div><b>${p.left.scientist}</b><span>Scientists home</span></div><div><b>${p.left.assistant}</b><span>Assistants home</span></div></div>
    <div class="sub">Cards in hand <span style="font-size:12px;color:var(--muted)">(up to 3 of each kind)</span></div><div class="gcards">${handHTML(p)}</div>`,
    buttons:[{label:'Close',primary:true,fn:closeModal}]});
}
// Your hand: research and humanity cards picked up at the Academy, Saint-Roch and elsewhere, with Play buttons.
function handModal(){
  const p=S.players[0];
  openModal({kind:'hand', live:true, title:'Your cards', wide:true, html:()=>`<p class="flavor" style="margin-top:0">Research cards come from the Academy, humanity cards from Saint-Roch. You may hold up to 3 of each kind; a 4th replaces the oldest.</p><div class="gcards">${handHTML(p)}</div>`, buttons:[{label:'Close',primary:true,fn:closeModal}]});
}
// ---------- Right column ----------
function rivalsRow(){
  return S.players.slice(1).map((p,k)=>{ const C=CHARACTERS.find(c=>c.id===p.char);
    return `<button class="rivalmini" data-act="rival" data-i="${k+1}" style="--pc:${p.color}" aria-label="See ${esc(p.name)}’s laboratory">${charArt(p.char,'avatar')}<span class="rbody"><span class="rname"><b title="${esc(p.name)}">${esc(p.name)}</b><small>${C?esc(C.role):''}</small></span>
      <span class="rcounts"><span><b>${onTable(p).length-completeCount(p)}</b>Muscle</span><span><b>${completeCount(p)-aliveCount(p)}</b>Skin</span><span><b>${aliveCount(p)}</b>Alive</span></span>
      <span class="rstats"><span>${icon(p.hum<0?'heart-broken':'heart','❤️','si')}Humanity<b>${p.hum>0?'+':''}${p.hum}</b></span><span>${icon('expertise','🧠','si')}Expertise<b>${p.exp}</b></span><span>${icon('reputation','🎖️','si')}Reputation<b>${p.rep}</b></span></span></span></button>`; }).join('');
}
function handTipHTML(p){ if(!p.hand.length) return '<b>Cards in hand</b>No cards yet. Research at the Academy, atone at Saint-Roch.';
  return '<b>Cards in hand</b>'+p.hand.map(c=>`<div>• <b style="display:inline;font-size:inherit">${esc(c.name)}</b> <span class="tp" style="display:inline">${c.kind}</span><br>${esc(c.text||'')}</div>`).join(''); }
// Your people: one figure per meeple. At home it is solid in your colour and picks the kind to send; placed, it leaves a dotted slot naming where it went.
function peoplePanel(){
  const p=S.players[0], mine=S.phase==='day'&&isMyTurn();
  const where=k=>Object.entries(S.occ).filter(([key,o])=>o.p===0&&o.kind===k).map(([key])=>key.startsWith('lab.')?LABSPOT[key.slice(4)].name:LOC[key.split('.')[0]].name);
  const row=k=>{ const total=k==='scientist'?sciTotal(p):asstTotal(p), home=p.left[k], out=where(k); const items=[];
    for(let i=0;i<total;i++){ const isHome=i<home;
      if(isHome) items.push(`<button class="mp home ${p.sel===k?'sel':''}" data-act="sel" data-k="${k}" ${mine?'':'disabled'} aria-pressed="${p.sel===k}" title="${k==='scientist'?'Scientist':'Assistant'} at home"><span class="mslot2">${meeple(k,p.color,26)}</span><small>${k==='scientist'?'Scientist':'Assistant'}</small></button>`);
      else { const at=out[i-home]||''; items.push(`<span class="mp used" title="${esc(at)}"><span class="mslot2">${meeple(k,'#ece0c6',26)}</span><small>${esc(at)||'out'}</small></span>`); } }
    return items.join(''); };
  let head;
  if(mine) head='Pick a meeple, then a location';
  else if(S.phase==='day'){ const c=S.players[S.cur]; head=`<span class="dot" style="background:${c.color}"></span> ${esc(c.name)} is choosing…`; }
  else if(S.phase==='lab') head=`Night ${S.round}`;
  else head=S.phase==='event'?'Event phase':S.phase==='firstmove'?'The first player moves':'Dawn';
  return `<section class="panel people ${mine?'you':''}" aria-label="Your people"><span class="eyebrow">Your people</span><strong class="phead">${head}</strong><div class="prow">${row('scientist')}${row('assistant')}</div></section>`;
}
function sideColumn(){
  const p=S.players[0], ch=charged(p), lab=S.phase==='lab';
  return `<aside class="sidecol">
    <div class="sidebtns"><button class="btn" data-act="character">Your character</button><button class="btn" data-act="rules">Help</button><button class="btn" data-act="newgame">New game</button></div>
    <section class="panel">${statBars(p)}
      <div class="res five"><div><b>${icon('coin','🪙','si')}${p.coin}</b><span>Francs</span></div><div><b>${icon('jar','🏺','si')}${ch}<small>/${p.jars.length}</small></b><span>Jars</span></div><div><b>${icon('ice','🧊','si')}${p.ice}</b><span>Ice</span></div><div title=""><b style="color:${p.police?'var(--crim)':'inherit'}">${icon('police','⭐','si')}${p.police}<small>/2</small></b><span>Police</span></div>
        <button class="cardsbtn" data-act="hand" data-tipt="${esc(handTipHTML(p))}" aria-label="Cards in hand">${icon('cards','🃏')}<b class="count">${p.hand.length}</b><span>Cards</span></button></div>
    </section>
    <section class="panel labsum" aria-label="Your laboratory">
      <span class="eyebrow">Your laboratory</span>
      <div class="labsum-row"><div class="lableft"><button class="figure tablebtn" data-act="lab" aria-label="Open your laboratory">${tableHTML(p,'me')}</button></div>
        <div class="labright">${decayGridHTML(p)}</div></div>
      <div class="row labbtns"><button class="btn ${lab?'primary pulse':''}" data-act="lab">Laboratory</button>${lab?'<button class="btn" data-act="endlab">End the night</button>':''}</div>
    </section>
    ${peoplePanel()}
    ${logPanel()}
  </aside>`;
}
// Rival lab popup: the same three columns as your Laboratory, read-only, with the rival's portrait and character on top.
function rivalModal(i){
  const p=S.players[i]; const C=CHARACTERS.find(c=>c.id===p.char);
  openModal({kind:'rival', live:true, title:`${esc(p.name)}’s Laboratory`, wide:true, xwide:true, html:()=>`
    <div class="rivalhead" style="--pc:${p.color}">${charArt(p.char,'avatar lg')}<div class="rivalinfo"><b>${C?esc(C.name):''}</b>, ${C?esc(C.role.toLowerCase()):''}.<br><span style="color:var(--parch-dim)">${C?esc(C.text):''}</span>
      <div class="res four" style="margin-top:8px"><div><b>${p.vp}</b><span>VP built</span></div><div><b>${p.coin}</b><span>Francs</span></div><div><b>${icon('jar','🏺','si')}${charged(p)}<small>/${p.jars.length}</small></b><span>Jars</span></div><div><b style="color:${p.police?'var(--crim)':'inherit'}">${p.police}<small>/2</small></b><span>Police</span></div></div>
      ${statBars(p)}
      <p style="font-size:13px;color:var(--parch-dim);margin:0">${p.hand.filter(h=>h.kind==='research').length} research and ${p.hand.filter(h=>h.kind==='humanity').length} humanity cards · Ice ${p.ice}${S.phase==='day'?` · at home: ${p.left.scientist} scientist, ${p.left.assistant} assistant${p.left.assistant!==1?'s':''}`:''}</p></div></div>
    <div class="lab3">
      <div class="labcol"><div class="sub" style="margin-top:0">Operating table</div><div class="figure big">${tableHTML(p,'m'+i)}</div><div class="legend"><span class="bl muscle">■ muscle ${onTable(p).length-completeCount(p)}</span><span class="bl skin">■ skin ${completeCount(p)-aliveCount(p)}</span><span class="bl alive">■ alive ${aliveCount(p)}</span><span class="bl dmgl">⚡ damage ${dmgTotal(p)}</span></div></div>
      <div class="labcol"><div class="sub" style="margin-top:0">Body parts</div><div class="anat">${anatomyHTML(p,true)}</div></div>
      <div class="labcol"><div class="sub" style="margin-top:0">Decomposition track</div>${decayHTML(p,true)}<div class="sub">Points per part and quality</div>${pointsTable()}</div>
    </div>`,
    buttons:[{label:'Close',primary:true,fn:closeModal}]});
}
function logPanel(){ return `<section class="panel" aria-label="Chronicle"><h2 style="margin-bottom:8px">Chronicle</h2><div class="log">${[...S.log].reverse().slice(0,90).map(l=>`<p class="${l.cls==='day'?'day':''}">${l.t}</p>`).join('')}</div></section>`; }

function rulesHTML(){
  return `<h3>The goal</h3><p>Build all six parts of a companion (head, torso, two arms, two legs) and bring each to life. The game ends at the end of a night when someone’s companion is fully alive, or when Captain Walton reaches the end of his track (after Day 12, sooner if people help him). Most points wins.</p>
  <h3>Each day</h3><ul><li><b>Event phase:</b> an event changes the rules for the day, or an encounter visits someone. Some encounters hide on a space and trigger on the first rival who goes there.</li>
    <li><b>City phase:</b> take turns placing your <b>scientist</b> and <b>assistants</b> one at a time. Each space holds one meeple. To use a taken space, <b>bump</b> it: pay the next bump-track cost to its owner, and their meeple is out for the day. You can’t bump the First Player space.</li>
    <li><b>Lab phase:</b> build parts, throw the switch once, and preserve flesh.</li>
    <li><b>Dawn:</b> materials age, the Hospital, Docks, Academy and Saint-Roch get fresh cards, and the Captain moves 1 step.</li></ul>
  <h3>Scientists and assistants</h3><ul><li>You start with 1 scientist and 2 assistants. Reputation 7 hires a 3rd assistant. Reputation 15 promotes one to a 2nd scientist.</li>
    <li>Scientist only: Hospital work and volunteering, advanced research, donating, the Dark Alley, Practice and Repair. A scientist also lectures for 1 more reputation, gains humanity at Saint-Roch, and charges 3 jars instead of 2.</li></ul>
  <h3>Cadavers and materials</h3><ul><li>Cadaver cards give <b>materials</b> or <b>expertise</b>, your choice per card. Some cost humanity.</li>
    <li>Materials have a stage from I (fresh) to IV. Each dawn they age. Stage IV rots away, blood rots after stage II. Ice stops decay for 2 dawns. Bone never rots.</li>
    <li>Animal (Slaughterhouse, Dog Catchers) stands in for other materials but costs VP.</li></ul>
  <h3>Building and the switch</h3><ul><li>Each part is built in two steps: <b>start</b> it as muscle, then <b>add skin</b>. Each step needs expertise and materials, gives VP (fresher is better) and +1 expertise.</li>
    <li><b>Throw the switch</b> once a night with 1 to 3 charged jars, 2 dice each. Eye: a complete part comes alive. Bolt: damage (2 on one part downgrades it). Broken heart: −1 humanity.</li>
    <li>After rolling, research cards can be spent to ignore or re-roll dice.</li></ul>
  <h3>Police</h3><p>Each murder in the Dark Alley gives a police marker. At 2, the Dark Alley is closed to you. Pay 3 francs any time to clear them.</p>
  <h3>Final score</h3><ul><li>VP from building, plus alive parts (head 6, torso 5, arms and legs 3 each).</li>
    <li>10 VP per bonus objective claimed.</li><li>Half your highest reputation, a third of your highest expertise, and your humanity (plus or minus).</li>
    <li>If the Captain ends the game, the kindest scientist (highest positive humanity) gains 5 VP.</li></ul>`;
}
let chosenChar='random';
const CHAR_SEED={psycho:4441, zoo:812, charlatan:2290, human:3707, heiress:5150, surgeon:6603};
const CHAR_BG={psycho:'morgue', zoo:'docks', charlatan:'square', human:'hospital', heiress:'square', surgeon:'hospital'};
const CHAR_LOOK={psycho:{hair:3,hat:'brim',alive:1}, zoo:{hair:0,hat:'top',alive:1}, charlatan:{hair:2,hat:'top',alive:1}, human:{hair:4,hat:0,alive:1}, heiress:{hair:2,hat:'brim',alive:1}, surgeon:{hair:2,hat:0,alive:1}};
const CHAR_PERK={psycho:'Humanity locked at 0', zoo:'+1 die or +1 charge each day', charlatan:'Starts at reputation 3', human:'Starts at humanity 2', heiress:'Never broke, studies faster', surgeon:'Starts at expertise 2, builds cheaper'};
function titleScreen(){
  const saved=loadSaved();
  return `<div class="wrap title-wrap"><div class="title-actions"><button class="linkbtn" data-act="rules">How to play</button></div><div class="hero">
    <span class="eyebrow hero-sub">Galvanism and grave-robbing in 1819 Paris, for one scientist and up to three rivals</span>
    ${logoHTML('hero-logo')}
    <div class="setup">
      <div class="field"><label for="nm">Your name</label><input id="nm" value="Dr Torres" maxlength="28"></div>
      <div class="field"><label for="nr">Rivals</label><select id="nr"><option value="1">One rival</option><option value="2">Two rivals</option><option value="3" selected>Three rivals</option></select></div>
      <button class="btn primary" data-act="start">Light the lamps</button>
      ${saved?`<button class="btn" data-act="continue">Continue Day ${saved.round}</button>`:''}
    </div>
    <div class="sub">Choose your scientist</div>
    <div class="charpicker" role="group" aria-label="Choose your character">${CHARACTERS.map(c=>`<button class="scard charpick ${chosenChar===c.id?'sel':''}" data-act="pickchar" data-id="${c.id}" aria-pressed="${chosenChar===c.id}">
        <span class="sc-card"><span class="sc-port">${charArt(c.id)}</span><span class="sc-text"><span class="sc-name">${esc(c.name)}</span><span class="sc-body">${esc(c.text)}</span><span class="sc-role">${esc(c.role)}</span></span></span></button>`).join('')}
      <button class="scard charpick ${chosenChar==='random'?'sel':''}" data-act="pickchar" data-id="random" aria-pressed="${chosenChar==='random'}">
        <span class="sc-card"><span class="sc-port sc-dice"><svg viewBox="0 0 60 80" aria-hidden="true"><g fill="none" stroke="#2b2420" stroke-width="2"><rect x="8" y="18" width="44" height="44" rx="6" fill="#ece6d6"/><circle cx="20" cy="30" r="4" fill="#2b2420"/><circle cx="40" cy="50" r="4" fill="#2b2420"/><circle cx="30" cy="40" r="4" fill="#2b2420"/></g></svg></span><span class="sc-text"><span class="sc-name">Random scientist</span><span class="sc-body">You are dealt one of the six at random. Your rivals always get random ones.</span><span class="sc-role">Fate decides</span></span></span></button>
    </div></div></div>`;
}
function endScreen(){
  const F=S.final, top=F.rows[0], youWon=top.i===0;
  const why = F.reason==='alive' ? 'It’s alive.' : 'Captain Walton has found the Creature.';
  const verdict = F.reason==='alive' ? (youWon ? 'Lifeless flesh twitches and writhes against the straps. The Creature gently moves you aside to see her first face. “At last. You will know only compassion.” Then, to you: “Our work is not finished. It has only begun.”' : `${esc(top.name)} receives the Creature’s thanks. Your laboratory goes quiet.`)
    : 'The Captain and the Creature struggle on the embankment and fall together into the dark Seine. Whatever you built stays on your table, unfinished.';
  return `<div class="wrap"><div class="hero" style="max-width:940px">
    <span class="eyebrow">Day ${F.round} · ${why}</span>
    <h1>${youWon?'You <span>Win</span>':esc(top.name)+' <span>Wins</span>'}</h1>
    <div class="letter"><p>${verdict}</p></div>
    <div class="scoretable"><table><thead><tr><th>Scientist</th><th>Build VP</th><th>Alive</th><th>Objectives</th><th>Reputation</th><th>Expertise</th><th>Humanity</th><th>Captain</th><th>Total</th></tr></thead><tbody>
      ${F.rows.map((r,k)=>`<tr class="${k===0?'win':''}"><td><span class="dot" style="background:${r.color}"></span> ${esc(r.name)}</td><td>${r.vp}</td><td>${r.alive}/6 · +${r.alivePts}</td><td>+${r.obj}</td><td>+${r.repPts}</td><td>+${r.expPts}</td><td>${r.humPts>0?'+':''}${r.humPts}</td><td>${r.capt?'+'+r.capt:''}</td><td><b>${r.total}</b></td></tr>`).join('')}
    </tbody></table></div>
    <div class="setup"><button class="btn primary" data-act="title">Play again</button></div></div></div>`;
}
function topRowHTML(){
  return `<div class="objrow toprow">${logoHTML('brand-logo')}<span class="eyebrow">Bonus objectives (10 VP)</span>${objectivesHTML()}<div class="captainbox"><span class="eyebrow">Captain Walton</span>${captainTrack()}</div></div>`;
}
function toolbarHTML(){
  const ph=({event:'Event phase',day:'City phase',firstmove:'City phase',lab:'Lab phase',dawn:'Dawn'})[S.phase]||'';
  return `<div class="toolbar"><span class="eyebrow">Day ${S.round} · ${ph} · first player: ${esc(S.players[S.first].name)}</span><button class="todaybtn" data-act="today">${icon('note','📜','si')}Today’s note: ${todayLabel()}</button></div>`;
}
function render(){
  const app=document.getElementById('app');
  if(!S){ app.innerHTML=titleScreen(); return; }
  if(S.phase==='end'){ app.innerHTML=endScreen(); return; }
  if(S.fast) return;
  app.innerHTML=`<div class="wrap game">
    <div class="grid2">
      <div class="col">
        ${topRowHTML()}
        ${toolbarHTML()}
        <div class="boardscroll">${boardHTML()}</div>
        <div class="underbar"><div class="rivalrow" aria-label="Rival scientists">${rivalsRow()}</div></div>
      </div>
      ${sideColumn()}
    </div></div>`;
  if(modal && modal.live) renderModal();
}
/* =========================================================
   BOOT
   ========================================================= */
function start(data){
  if(data && data.S && data.S.v===5){ S=data.S; render(); loop(); }
  else { S=null; render(); }
}
if(IMG['bg-wall']) document.documentElement.style.setProperty('--bg-tile', `url("${IMG['bg-wall']}")`);
if(IMG['card-tall-front']) document.documentElement.style.setProperty('--card-front', `url("${IMG['card-tall-front']}")`);
if(IMG['card-tall-back']) document.documentElement.style.setProperty('--card-back', `url("${IMG['card-tall-back']}")`);
if(IMG['board']) document.documentElement.style.setProperty('--board', `url("${IMG['board']}")`);
if(IMG['card-research-bg']) document.documentElement.style.setProperty('--card-research', `url("${IMG['card-research-bg']}")`);
if(IMG['card-humanity-bg']) document.documentElement.style.setProperty('--card-humanity', `url("${IMG['card-humanity-bg']}")`);
if(IMG['card-scientist-bg']) document.documentElement.style.setProperty('--card-scientist', `url("${IMG['card-scientist-bg']}")`);
try{ window.claude?.hot?.snapshot?.(()=>({S})); }catch(e){}
window.__spark={ get S(){return S}, set S(v){S=v;}, newGame, loop, endLab, planBuild, build, playCard, canPlace, allKeys, aiChoose };
window.claude?.hot?.ready ? window.claude.hot.ready(start) : start(window.claude?.hot?.data ?? {});
