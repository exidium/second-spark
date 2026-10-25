/* =========================================================
   CARD DATA
   Numbers and effects follow the physical game's cards (read from the
   Tabletop Simulator sheets). Names, wording and art are our own.
   Material arrays are [muscle, organ, blood, bone].
   ========================================================= */
const MAX_ROUNDS = 12, SAVE_KEY = 'second-spark-paris-v5';
const MATS = ['muscle','organ','blood','animal'];
const MAT_N = {muscle:'Muscle', organ:'Organ', blood:'Blood', bone:'Bone', animal:'Animal'};
const KEY = {M:'muscle', O:'organ', B:'blood', X:'bone'};
const ROMAN = ['I','II','III','IV'];
const SLOT6 = ['head','torso','armL','armR','legL','legR'];
const BODY_CENTRES = {"head": [49.7, 7.4], "torso": [49.7, 34.4], "armL": [21.5, 36.8], "armR": [77.9, 36.7], "legL": [41.0, 71.8], "legR": [58.4, 71.8]}; // part centres in % of the body image, from tools/body_parts.py
const SLOT_T = {head:'head', torso:'torso', armL:'arm', armR:'arm', legL:'leg', legR:'leg'};
const SLOT_N = {head:'Head', torso:'Torso', armL:'Left arm', armR:'Right arm', legL:'Left leg', legR:'Right leg'};
const PARTS = {
  head:  {n:'Head',  exp:14, start:{M:4,O:5,X:3}, comp:{M:2,O:2,B:3}, vpS:[10,8,5,3], vpC:[7,5,3,1], alive:6},
  torso: {n:'Torso', exp:8,  start:{M:5,O:4,B:2,X:3}, comp:{M:4,B:3}, vpS:[8,6,4,2], vpC:[6,4,3,1], alive:5},
  arm:   {n:'Arm',   exp:3,  start:{M:3,O:1,B:2,X:2}, comp:{M:3,B:2}, vpS:[5,4,2,1], vpC:[3,2,1,1], alive:3},
  leg:   {n:'Leg',   exp:0,  start:{M:4,B:2,X:3}, comp:{M:3,B:2}, vpS:[5,4,2,1], vpC:[3,2,1,1], alive:3},
};
const GRAY = ['alive','damage','damage','heart','blank','blank'];
const BLUE = ['alive','alive','damage','heart','blank','blank'];

// Cadaver decks: [stage, [M,O,B,X], expertise, humanity cost]
const CADAVERS = {
  cemetery: [[4,[0,3,0,3],1,0],[4,[2,2,0,3],1,0],[4,[2,2,0,2],1,0],[4,[2,1,0,3],1,0],[0,[0,0,0,5],0,0],[0,[0,0,0,5],0,0],
             [0,[0,0,0,4],0,0],[0,[0,0,0,4],0,0],[3,[3,4,0,3],1,1],[3,[3,4,0,2],1,1],[3,[3,3,0,2],1,1],[3,[2,3,0,3],1,1],[3,[1,2,0,3],1,0],[4,[3,4,0,2],1,0]],
  hospital: [[2,[2,3,1,2],1,0],[2,[3,2,1,2],1,0],[2,[2,2,1,3],1,0],[2,[1,2,1,1],1,0],[1,[2,3,1,3],2,0],[1,[3,2,1,3],2,0],[1,[2,3,2,1],2,0],
             [2,[2,3,2,2],1,0],[1,[2,4,2,2],2,0],[1,[2,3,2,2],2,0],[1,[2,3,1,3],2,0],[1,[3,2,1,3],2,0],[1,[2,3,2,1],2,0],[2,[2,4,2,2],1,0]],
  morgue:   [[2,[3,3,0,3],1,0],[3,[2,4,0,2],1,0],[3,[2,3,0,2],1,0],[3,[3,2,0,2],1,0],[3,[2,2,0,3],1,0],[3,[2,1,0,2],1,0],[3,[4,2,0,3],1,0],
             [3,[3,1,0,4],1,0],[2,[2,4,2,2],1,1],[2,[2,3,1,2],1,1],[2,[2,3,1,3],1,1],[2,[3,2,1,3],1,1],[2,[2,3,1,1],1,0],[2,[4,3,2,2],1,1]],
  square:   [[1,[4,3,2,4],2,0],[1,[3,3,3,4],2,0],[1,[2,4,3,3],2,0],[1,[2,4,2,3],2,0],[1,[2,3,2,3],2,0],[1,[3,2,2,3],2,0],[1,[4,2,1,2],2,0],
             [1,[4,4,3,3],2,0],[1,[4,4,3,2],2,0],[1,[4,4,4,4],3,0,'Big Gustave, the butcher of Rungis',1]],
};
const OWNERS = ['Jeanne, a laundress','Old Mathieu, water-carrier','an unnamed bargeman','Lucie, a flower seller','Pierre, a chimney sweep',
  'a dancing master','Marguerite, a wine-seller','Henri, a bookbinder','a cooper of Bercy','a pickpocket called Le Rat','Father Anselme',
  'Sophie, a wet-nurse','a Seine boatman','a street acrobat','Gaston, a tallow chandler','a police informer','a fiacre driver',
  'Odette, a milliner','a forger','a fishwife of Les Halles','an organ grinder','Bastien, a ratcatcher','a governess','a tanner',
  'a gravedigger','a veteran of Waterloo','a ballad singer','a printer’s apprentice','Agathe, a seamstress','a stonemason'];

// Scoundrels at the Docks. cost f, hcost, then options. kind: thief | dog | cut | snatch | bone
const SCOUNDRELS = [
  {kind:'thief', name:'Hospital Thief', cost:2, hcost:1, draw:2},
  {kind:'thief', name:'Hospital Thief', cost:2, hcost:1, draw:2},
  {kind:'thief', name:'Hospital Thief', cost:1, hcost:1, draw:1},
  {kind:'thief', name:'Hospital Thief', cost:1, hcost:1, draw:1},
  {kind:'dog', name:'Dog Catcher', cost:2, hcost:1, exp:3, expH:1, hum:5, mats:[['animal',1,8]]},
  {kind:'dog', name:'Dog Catcher', cost:1, hcost:0, exp:2, expH:1, hum:3, mats:[['animal',1,5]]},
  {kind:'dog', name:'Dog Catcher', cost:1, hcost:0, exp:2, expH:1, hum:3, mats:[['animal',1,4]]},
  {kind:'dog', name:'Dog Catcher', cost:1, hcost:0, exp:2, expH:1, hum:3, mats:[['animal',1,4]]},
  {kind:'cut', name:'Cutthroat', cost:2, hcost:1, exp:2, mats:[['muscle',1,4],['organ',1,4],['blood',1,4],['bone',0,3]]},
  {kind:'cut', name:'Cutthroat', cost:1, hcost:2, exp:2, mats:[['muscle',1,3],['organ',1,3],['blood',1,3],['bone',0,3]]},
  {kind:'cut', name:'Cutthroat', cost:1, hcost:1, exp:2, mats:[['muscle',1,4],['organ',1,3],['blood',1,3],['bone',0,2]]},
  {kind:'cut', name:'Cutthroat', cost:1, hcost:1, exp:2, mats:[['muscle',1,3],['organ',1,4],['blood',1,3],['bone',0,3]]},
  {kind:'snatch', name:'Body Snatcher', cost:2, hcost:0, exp:2, mats:[['muscle',3,6],['organ',3,4],['bone',0,5]]},
  {kind:'snatch', name:'Body Snatcher', cost:1, hcost:0, exp:1, mats:[['muscle',3,4],['organ',3,4],['bone',0,3]]},
  {kind:'snatch', name:'Body Snatcher', cost:1, hcost:0, exp:1, mats:[['muscle',3,4],['organ',3,3],['bone',0,4]]},
  {kind:'bone', name:'The Bone Collector', cost:1, hcost:0, mats:[['bone',0,8]]},
];
const SC_WHO = {thief:['a porter with a sack','a nurse who asks no questions','a sexton with a lantern','a girl with bloody sleeves'],
  dog:['a catcher with a net','Old Fernand and his cart','a woman with a muzzle pole','a boy in a feathered hat'],
  cut:['a smiling gentleman','a hooded woman','a lady in a red scarf','a knife-sharpener'],
  snatch:['a gravedigger with a spade','a man in a top hat','a tidy young widow'], bone:['an old man with a sack of bones']};

// Research cards. play: what playing it does. mit: shock-dice mitigation when used after a throw.
//  when: 'any' (play any time on your turn) | a context key used by an action
const RESEARCH = [
  {id:'counter', name:'Countermeasures', when:'react', text:'Cancels a rival’s humanity card aimed at you (used automatically).', gain:{coin:2}, mit:'ignoreDmg'},
  {id:'unethical', name:'Unethical Experiment', when:'alley', text:'At the Dark Alley or hiring a Cutthroat: spend 1 charged jar and skip the normal benefit.', gain:{exp:5, hum:-1}, mit:'rerollAny'},
  {id:'preserve', name:'Pickling Jars', when:'market', text:'At the Market: +1 franc for every sale of preserved flesh.', gain:{}, mit:'ignoreHeart'},
  {id:'steady', name:'Steady Hands', when:'build', text:'When building a part: need 1 fewer of each material.', gain:{exp:2}, mit:'rerollDmg'},
  {id:'tutor', name:'Private Pupil', when:'any', text:'Take on a wealthy pupil.', gain:{rep:2, coin:3}, mit:'ignoreDmg'},
  {id:'guest', name:'Guest Lecturer', when:'lecture', text:'When lecturing: gain this as well.', gain:{rep:2, coin:2}, mit:'rerollAny'},
  {id:'healing', name:'Healing Salve', when:'any', text:'Remove all damage from your parts.', gain:{exp:2}, mit:'rerollGray', effect:'heal'},
  {id:'midnight', name:'Burning the Candle', when:'turn', text:'On your turn: use one of your placed meeples’ spaces again, paying its costs. It is not a new placement.', gain:{}, mit:'rerollBlue'},
  {id:'daisy', name:'Fresh as Morning', when:'cadaver', text:'When resolving a cadaver: its materials count as stage I.', gain:{rep:2, coin:2}, mit:'rerollDmg'},
  {id:'dissect', name:'Close Dissection', when:'cadaver12', text:'When resolving a stage I or II cadaver: pay its cost, discard it, gain this instead.', gain:{exp:4}, mit:'rerollGray'},
  {id:'study2', name:'Evening Study', when:'any', text:'Read late into the night.', gain:{exp:2}, mit:'rerollGray'},
  {id:'study3', name:'Practical Study', when:'any', text:'Practise on a cat.', gain:{exp:3}, mit:'rerollBlue'},
  {id:'electro', name:'Electrolysis', when:'cadaver123', text:'When resolving a stage I to III cadaver: spend 1 charged jar, pay its cost, discard it, gain this instead.', gain:{exp:4, rep:2}, mit:'rerollGray'},
  {id:'demo', name:'Public Galvanism', when:'any', text:'Spend 1 charged jar and 2 animal to make a dead dog dance for a crowd.', gain:{exp:3, rep:2, coin:1, hum:-1}, mit:'rerollBlue', effect:'demo'},
  {id:'transfusion', name:'Transfusion', when:'blood', text:'When giving blood: gain this instead of the blood.', gain:{exp:3, rep:1, coin:1}, mit:'rerollGray'},
  {id:'publish', name:'Publish a Paper', when:'turn', text:'On your turn: your unplaced scientist sits out this round to write.', gain:{exp:2, rep:3, coin:1}, mit:'rerollDmg', effect:'publish'},
];
const MIT_N = {ignoreDmg:'Ignore all bolts', rerollAny:'Re-roll any dice', ignoreHeart:'Ignore broken hearts', rerollDmg:'Re-roll dice showing bolts',
  rerollGray:'Re-roll gray dice', rerollBlue:'Re-roll blue dice'};

// Humanity cards. gain: what you receive when you play it.
const HUMANITY = [
  {id:'aid1', name:'Whisper to the Captain', when:'aid', text:'Pay 1 franc: the Captain moves 1 step closer to the end. Not from Day 11. One aid card per day.', cost:1, gain:{hum:2}, aid:1},
  {id:'aid2', name:'Fund the Captain', when:'aid', text:'Pay 2 francs: the Captain moves 1 step closer to the end. Not from Day 11. One aid card per day.', cost:2, gain:{hum:3}, aid:1},
  {id:'aid0', name:'Tell the Captain Everything', when:'aid', text:'The Captain moves 1 step closer to the end. Not from Day 11. One aid card per day.', cost:0, gain:{hum:1}, aid:1},
  {id:'influence', name:'Petition the Prefect', when:'any', text:'All cadavers waiting at the Hospital are given a burial.', gain:{hum:1}, effect:'clearHosp'},
  {id:'trap', name:'A Trap of Your Own', when:'react', text:'When the Creature visits you, spend 1 charged jar to send him away.', gain:{hum:3}},
  {id:'mercy', name:'Royal Pardon', when:'react', text:'When an execution is announced, pay 2 francs to stop it.', gain:{hum:2, rep:2}},
  {id:'burial', name:'A Decent Burial', when:'square', text:'When buying a body at the Public Square, bury it instead.', gain:{hum:3, rep:2}},
  {id:'graveguard', name:'Night at the Graves', when:'any', text:'The Graveyard and hiring Body Snatchers are closed for the rest of today.', gain:{hum:1}, close:['cemetery','snatch']},
  {id:'moral', name:'Shame the Morgue', when:'any', text:'The Morgue is closed for the rest of today.', gain:{hum:1}, close:['morgue']},
  {id:'animal', name:'Mercy for Beasts', when:'lecture', text:'When lecturing, argue against vivisection instead of gaining the normal benefit.', gain:{hum:3}},
  {id:'patrol', name:'Walk the Quays', when:'any', text:'The Docks are closed for the rest of today.', gain:{hum:1}, close:['docks']},
  {id:'sabotage', name:'Cut the Wires', when:'target', text:'Choose a rival: their next throw of the switch loses 1 die.', gain:{hum:1}, effect:'sabotage'},
  {id:'thwart', name:'Cross Their Path', when:'any', text:'The next rival to place in Paris must choose a different space.', gain:{hum:2}, effect:'thwart'},
  {id:'human', name:'The Dignity of the Dead', when:'lecture', text:'When lecturing, speak for the dead instead of gaining the normal benefit.', gain:{hum:3}},
  {id:'snatcher', name:'Urchin Raid', when:'target', text:'Choose a rival: throw away up to 3 of their materials, one of each colour.', gain:{hum:2}, effect:'snatch'},
  {id:'burn', name:'A Careless Lantern', when:'target', text:'Choose a rival with 2+ research cards: one of them burns.', gain:{hum:2}, effect:'burn'},
];

// Events: round range, icons (storm charges every jar; exec puts bodies at the Public Square)
const EVENTS = [
  {id:'corrupt', name:'A Porter for Hire', r:[1,5], text:'At the Hospital, pay 1 franc to take one more cadaver than your reputation allows.'},
  {id:'meat', name:'Glut of Meat', r:[1,5], storm:1, text:'The Slaughterhouse gives 2 extra animal and 1 franc.'},
  {id:'hardtimes', name:'Hard Times', r:[1,5], text:'No work at the Hospital. Lectures pay reputation only. Leyden jars: buy 1, get 1 free.'},
  {id:'enemy', name:'An Anonymous Letter', r:[1,5], text:'Anyone with humanity above 0 may take a humanity card. The kindest scientist hears a confession.'},
  {id:'graves', name:'Patrols at the Graves', r:[1,4], storm:1, text:'The Graveyard is closed. Every scoundrel costs 1 franc more.'},
  {id:'fire', name:'Fire at the Academy', r:[1,4], exec:1, text:'The Academy is closed. Once today, anyone may pay 2 francs to gain 2 reputation for the rebuilding.'},
  {id:'plague', name:'Cattle Plague', r:[1,5], text:'The Slaughterhouse is closed. Dog Catchers cost 1 franc more.'},
  {id:'cholera', name:'Cholera', r:[1,7], storm:1, text:'Hospital shifts pay 2 francs more. The Graveyard and Morgue draw 1 extra card.'},
  {id:'parade', name:'Student Parade', r:[1,4], text:'Only scientists may go to the Academy.'},
  {id:'bourbon', name:'Loyalty Pledges', r:[1,5], exec:1, text:'Everyone pays 1 franc to gain 1 reputation, or loses 1 reputation.'},
  {id:'riots', name:'Student Riots', r:[1,7], exec:1, text:'The Dark Alley and the Docks are closed.'},
  {id:'darkres', name:'A Dead Man’s Notes', r:[1,7], storm:1, text:'Anyone may lose 1 humanity to gain 2 expertise.'},
  {id:'toussaint', name:'All Saints’ Day', r:[1,6], text:'Graveyard, Morgue, Hospital cadavers, Hospital Thieves and Body Snatchers all cost 1 extra humanity.'},
  {id:'grant', name:'A Widow’s Bequest', r:[1,5], exec:1, text:'Research and lectures at the Academy pay 2 francs extra.'},
  {id:'betrayal', name:'The Captain’s Wrath', r:[7,12], exec:1, text:'Anyone with humanity below 3 loses 1 Leyden jar.'},
  {id:'odeon', name:'Opening Night at the Odéon', r:[5,12], text:'The theatre is a new location today: +2 reputation. Each player may go once. Anyone there can be bumped for free and goes home.'},
  {id:'willing', name:'The Flesh Is Willing', r:[7,12], exec:1, text:'Every throw of the switch may re-roll up to 2 dice for free.'},
  {id:'storm2', name:'Storm from the Sea', r:[7,12], storm:1, text:'The Graveyard and the Docks are closed.'},
  {id:'purge', name:'Inquiry at the Hospital', r:[6,12], exec:1, text:'The Hospital is closed.'},
];

// Encounters: trigger 'now' with a target rule, or 'loc' on a space (first other player to visit).
//  Each has a test or a choice leading to an A or B outcome (keys into OUTCOMES).
const ENCOUNTERS = [
  {id:'e14', r:[7,12], now:1, target:'maxExp', who:'creature', text:'The Creature leans on your door, bleeding. “Tend to me, doctor.”', choice:['Stitch him up','Turn him away'], a:'A14', b:'B14'},
  {id:'e12', r:[7,12], now:1, target:'fewestComplete', who:'creature', text:'“Your progress is lacking. Come with me.” You have no choice.', a:'A12'},
  {id:'e10', r:[7,12], now:1, target:'maxHum', who:'captain', text:'A boy presses a note into your hand: “Meet me at the docks. R.W.”', choice:['Go to the Docks','Burn the note'], a:'A10', b:'B10'},
  {id:'e8', r:[6,12], now:1, target:'fpOther', who:'creature', text:'Lightning shows a shape in the window. “Are the angels angry, doctor?”', test:p=>aliveCount(p)>=2, a:'A8', b:'B8', testText:'2 or more parts alive'},
  {id:'e6', r:[7,12], now:1, target:'fp', who:'creature', text:'A heat wave. The stench is unbearable. “No ice, doctor?”', test:p=>completeCount(p)>=3, a:'A6', b:'B6', testText:'3 or more complete parts'},
  {id:'e4', r:[8,12], now:1, target:'fp', who:'creature', text:'He walks in with a dripping bag. “Are you pleased with your progress?”', test:p=>completeCount(p)>=4, a:'A4', b:'B4', testText:'4 or more complete parts'},
  {id:'e2', r:[7,12], now:1, target:'fp', who:'captain', text:'The Captain bursts in, bleeding, and hides from the Creature behind your shelves.', choice:['Give him up','Hide him'], a:'A2', b:'B2'},
  {id:'e28', r:[7,12], loc:'academy.adv', who:'captain', text:'In the library, the Captain finds you: “This fiend is no Prometheus.”', choice:['Stay and listen','Leave with your books'], a:'A28', b:'B28'},
  {id:'e26', r:[8,12], loc:'hospital.retrieve', who:'creature', text:'Screams upstairs: a massacre near the Bastille. The wards overflow with the dying.', choice:['Claim the dead','Help the living'], a:'A26', b:'B26'},
  {id:'e24', r:[6,12], loc:'docks.hire', who:'woman', text:'A woman steps out of the fog by the river. “Looking for something, doctor?”', choice:['Ask her help','Walk on'], a:'A24', b:'B24'},
  {id:'e22', r:[5,12], now:1, target:'fpWithPart', who:'creature', text:'“Please, don’t let me interrupt.” He watches you work.', test:p=>aliveCount(p)>=1, a:'A22', b:'B22', testText:'at least 1 part alive'},
  {id:'e20', r:[7,12], now:1, target:'lastDark', who:'captain', text:'The Captain sits by your bed with a pistol. “Rediscover your humanity, or be ruined.”', choice:['Agree to help','Refuse'], a:'A20', b:'B20'},
  {id:'e18', r:[6,12], now:1, target:'fp', who:'creature', text:'He flips through your books. “Without proper study, doctor? Or fairy tales?”', test:p=>p.exp>=13, a:'A18', b:'B18', testText:'expertise 13 or more'},
  {id:'e16', r:[7,12], now:1, target:'mostHumCards', who:'creature', text:'“I wonder about your loyalty. Some assistance, perhaps?” He holds out a bag.', choice:['Take the bag','Refuse it'], a:'A16', b:'B16'},
  {id:'e29', r:[1,5], loc:'cemetery.dig', who:'creature', text:'Something watches from the dark as you dig. The open grave holds three bodies, too fresh.', choice:['Climb into the grave','Dig elsewhere'], a:'A29', b:'B29'},
];

// Display order alternates men and women (Bruno's request).
const CHARACTERS = [
  {id:'psycho', name:'Lucien Vautrin', role:'Psychopath', text:'Your humanity never moves from 0. Each time you get a second police marker, lose 1 reputation.'},
  {id:'human', name:'Amara Okafor', role:'Humanitarian', text:'Start with humanity 2. Gain 1 VP for each humanity you would gain while at 10.'},
  {id:'zoo', name:'Sir Bartholomew Pike', role:'Zoologist', text:'Once per day: roll 1 extra gray die when you throw the switch, or charge 1 jar.'},
  {id:'heiress', name:'Lucrezia Fontana', role:'Heiress', text:'Start of each day: +1 franc if you have 2 or less. Research cards that give expertise give 1 more.'},
  {id:'charlatan', name:'Count Achille Duval', role:'Charlatan', text:'Start with reputation 3. Gain 1 reputation each time you are bumped at the Academy.'},
  {id:'surgeon', name:'Dr Hélène Marchand', role:'Surgeon', text:'Start with expertise 2. Once per night, build a part with 1 less material of your choice.'},
];
const OBJECTIVES = [
  {id:'hum10', name:'First to humanity 10'}, {id:'alive2', name:'First with 2 parts alive'}, {id:'exp27', name:'First to expertise 27'},
  {id:'parts6', name:'First with 6 parts on the table'}, {id:'rich', name:'Most francs at the end'}, {id:'rep23', name:'First to reputation 23'},
];

// Locations and their action spaces (one meeple per space, bumping allowed)
const LOCS = [
  {id:'cemetery', name:'Graveyard', place:'Père Lachaise', spaces:[{k:'dig', n:'Dig up cadavers'}],
   text:'Draw 3 cadavers. Resolve any you like for materials or expertise.', yields:'Stage III to IV muscle and organs, bone'},
  {id:'square', name:'Public Square', place:'Place de Grève', spaces:[{k:'buy', n:'Buy a body (1 franc)'}],
   text:'Pay 1 franc for one of the executed bodies on display. Only after an execution.', yields:'Stage I, the freshest you can get'},
  {id:'morgue', name:'Morgue', place:'Quai du Marché-Neuf', spaces:[{k:'buy', n:'Buy cadavers (1 franc)'}],
   text:'Pay 1 franc, draw 2 unclaimed cadavers, resolve any.', yields:'Stage II to III materials'},
  {id:'slaughter', name:'Slaughterhouse', place:'Montmartre', spaces:[{k:'take', n:'Animal parts'}],
   text:'Take 4 animal at stage II, or 3 at stage I.', yields:'Animal stands in for most materials, for a little less VP'},
  {id:'hospital', name:'Hospital', place:'Hôpital de la Charité',
   spaces:[{k:'retrieve', n:'Retrieve cadaver'},{k:'work', n:'Work', sci:1},{k:'volunteer', n:'Volunteer', sci:1}],
   text:'Retrieve a cadaver (reputation 7+), work a shift, or volunteer.', yields:'Stage I to II materials, francs, humanity'},
  {id:'academy', name:'Academy', place:'Institut de France',
   spaces:[{k:'adv', n:'Advanced research', sci:1},{k:'research', n:'Research'},{k:'lecture', n:'Lecture'},{k:'donate', n:'Donate', sci:1}],
   text:'Research for cards and expertise, lecture, or donate for reputation.', yields:'Expertise, research cards, reputation'},
  {id:'market', name:'Market', place:'Les Halles', spaces:[{k:'trade', n:'Buy and sell'}],
   text:'Sell bone and preserved flesh. Buy Leyden jars and ice.', yields:'Jars, ice, francs'},
  {id:'docks', name:'Docks', place:'Port Saint-Nicolas', spaces:[{k:'hire', n:'Hire a scoundrel'}],
   text:'Hire one of the three scoundrels on offer.', yields:'Materials, expertise or humanity'},
  {id:'alley', name:'Dark Alley', place:'Faubourg Saint-Marcel', spaces:[{k:'murder', n:'Murder', sci:1}],
   text:'Murder for fresh materials. Costs 3 humanity and earns a police marker.', yields:'Stage I muscle 4, organ 4, blood 3, bone 2'},
  {id:'church', name:'Saint-Roch', place:'Rue Saint-Honoré', spaces:[{k:'atone', n:'Atone'}],
   text:'Take a humanity card. A scientist also gains 1 humanity.', yields:'Humanity cards'},
  {id:'first', name:'First Player', place:'Parvis Notre-Dame', spaces:[{k:'first', n:'Become first player for the next day', nobump:1}],
   text:'Become first player. Can’t be bumped. When everyone has finished, you may move this meeple to another space and use it.', yields:''},
  {id:'odeon', name:'Théâtre de l’Odéon', place:'Rive gauche', event:'odeon', spaces:[{k:'show', n:'Be seen (+2 rep)', freebump:1}],
   text:'Opening night. +2 reputation. Each player may go once; bumping here is free and sends the meeple home.', yields:''},
];
// Where each place sits on the board image (percent of width and height) and on which side its card slots go.
const BOARD_POS = {
  cemetery:{x:12,y:17,cards:'right'}, square:{x:26,y:31,cards:'right'}, slaughter:{x:55,y:15,cards:null}, church:{x:79,y:17,cards:'left'},
  market:{x:73,y:36,cards:null}, first:{x:48,y:45,cards:null}, morgue:{x:62,y:55,cards:'right'}, hospital:{x:20,y:64,cards:'right'},
  academy:{x:45,y:75,cards:'right'}, docks:{x:70,y:69,cards:'right'}, alley:{x:84,y:84,cards:null}, odeon:{x:30,y:89,cards:null},
};
const LAB_POS = {x:20, y:86};
const LOC = Object.fromEntries(LOCS.map(l=>[l.id,l]));
const SPACE = {}; LOCS.forEach(l=>l.spaces.forEach(s=>{ SPACE[l.id+'.'+s.k]={...s, loc:l.id, key:l.id+'.'+s.k}; }));
const LABSPOTS = [
  {id:'practice', name:'Practice', sci:1, text:'+1 expertise.'},
  {id:'blood', name:'Give Blood', text:'Gain 3 blood at stage I, from your own arm.'},
  {id:'repair', name:'Repair', sci:1, text:'Remove up to 3 damage from your parts.'},
  {id:'charge', name:'Charge Jars', text:'Charge Leyden jars: 3 with a scientist, 2 with an assistant.'},
];
const LABSPOT = Object.fromEntries(LABSPOTS.map(l=>[l.id,l]));
const BUMP_TRACK = {2:[1], 3:[1,2], 4:[1,1,2]};
const RIVALS = [
  {name:'Dr Ambrose Pell', color:'#d6675f', ruthless:1, scholar:0, careful:0},
  {name:'Mme Odile Varnier', color:'#74b393', ruthless:0, scholar:0, careful:1},
  {name:'Prof Horace Quill', color:'#cda65c', ruthless:0, scholar:1, careful:0},
];
const YOU_COLOR = '#9fd0ff';
