class_name Game
extends RefCounted
## The rules of Second Spark, ported from src/engine.js. Pure game logic: no nodes, no drawing.
## State lives in S (a JSON-safe Dictionary, so it can be saved). Every human decision and every
## animation goes through `ui`, a presenter object (see scripts/rules/null_presenter.gd for the
## full list of methods). With the null presenter and all players on AI, a game runs headless.

const SAVE_PATH := "user://second-spark-save.json"
const SAVE_V := 1

var D: Dictionary            # game data from data/game.json
var S: Dictionary = {}       # game state
var ui                       # presenter
var token = 0               # bumps when a game is abandoned, so a running loop stops
var LOC = {}
var SPACE = {}
var LABSPOT = {}
var EVENT = {}
var ENC = {}
var OBJ = {}


func _init(data: Dictionary, presenter) -> void:
	D = data
	ui = presenter
	for l in D.LOCS:
		LOC[l.id] = l
		for s in l.spaces:
			var sp: Dictionary = s.duplicate()
			sp.loc = l.id
			sp.key = l.id + "." + s.k
			SPACE[sp.key] = sp
	for l in D.LABSPOTS:
		LABSPOT[l.id] = l
	for e in D.EVENTS:
		EVENT[e.id] = e
	for e in D.ENCOUNTERS:
		ENC[e.id] = e
	for o in D.OBJECTIVES:
		OBJ[o.id] = o


## Loads data/game.json and turns whole-number floats into ints (JSON has only floats).
static func load_data(path := "res://data/game.json") -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	return _ints(JSON.parse_string(f.get_as_text()))


static func _ints(v):
	if v is Dictionary:
		var o = {}
		for k in v:
			o[k] = _ints(v[k])
		return o
	if v is Array:
		return v.map(func(x): return _ints(x))
	if v is float and v == floor(v):
		return int(v)
	return v


# ================================================================ helpers

func rnd(n: int) -> int:
	return randi() % n if n > 0 else 0

func pick(a: Array):
	return a[rnd(a.size())]

func shuffled(a: Array) -> Array:
	var b = a.duplicate()
	b.shuffle()
	return b

func total(a: Array) -> int:
	var t = 0
	for x in a:
		t += x
	return t

func fr(n: int) -> String:
	return "%d franc%s" % [n, "" if n == 1 else "s"]

func uid() -> int:
	S.uid += 1
	return S.uid

func log_line(t: String, cls := "") -> void:
	S.log.append({"r": S.round, "t": t, "cls": cls})
	if S.log.size() > 220:
		S.log.pop_front()

func B(p: Dictionary) -> String:
	return "[b]%s[/b]" % p.name

func is_human(i: int) -> bool:
	return not S.players[i].ai

func indices(n: int) -> Array:
	var a = []
	for k in n:
		a.append(k)
	return a

func mat_text(t: String, n: int, stage: int) -> String:
	return "%d %s%s" % [n, D.MAT_N[t].to_lower(), (" " + D.ROMAN[stage - 1]) if stage > 0 else ""]

func mats_text(list: Array) -> String:
	var parts = []
	for m in list:
		if m[2] > 0:
			parts.append(mat_text(m[0], m[2], 0 if m[0] == "bone" else m[1]))
	return ", ".join(parts)

func gain_text(g: Dictionary) -> String:
	var t = []
	if g.get("exp", 0):
		t.append("%s%d expertise" % ["+" if g.exp > 0 else "", g.exp])
	if g.get("rep", 0):
		t.append("+%d reputation" % g.rep)
	if g.get("coin", 0):
		t.append("+" + fr(g.coin))
	if g.get("hum", 0):
		t.append("%s%d humanity" % ["+" if g.hum > 0 else "", g.hum])
	return ", ".join(t)


# ================================================================ cards

func cadaver_from_row(src: String, row: Array, k) -> Dictionary:
	var st: int = row[0]
	var m: Array = row[1]
	var mats = []
	var types = ["muscle", "organ", "blood", "bone"]
	for j in 4:
		if m[j]:
			mats.append([types[j], 0 if types[j] == "bone" else st, m[j]])
	var name: String = row[4] if row.size() > 4 else pick(D.OWNERS)
	return {"id": uid(), "kind": "cadaver", "src": src, "stage": st, "name": name, "named": row.size() > 4,
		"seed": 1 + rnd(9999), "mats": mats, "exp": row[2], "hcost": row[3], "cost": row[5] if row.size() > 5 else 0,
		"art": null if k == null else "%s-%02d" % [src, k + 1]}

func draw_cadaver(src: String) -> Dictionary:
	if S.decks[src].is_empty():
		S.decks[src] = shuffled(indices(D.CADAVERS[src].size()))
	var k: int = S.decks[src].pop_front()
	return cadaver_from_row(src, D.CADAVERS[src][k], k)

func make_scoundrel(k: int) -> Dictionary:
	var t: Dictionary = D.SCOUNDRELS[k]
	var c = t.duplicate(true)
	c.merge({"id": uid(), "kind": "scoundrel", "sk": t.kind, "tpl": k, "who": pick(D.SC_WHO[t.kind]), "seed": 1 + rnd(9999)}, true)
	return c

func draw_scoundrel() -> Dictionary:
	if S.decks.sc.is_empty():
		S.decks.sc = shuffled(indices(D.SCOUNDRELS.size()))
	return make_scoundrel(S.decks.sc.pop_front())

func draw_research() -> Dictionary:
	if S.decks.re.is_empty():
		S.decks.re = shuffled(indices(D.RESEARCH.size()))
	var c: Dictionary = D.RESEARCH[S.decks.re.pop_front()].duplicate(true)
	c.merge({"uid": uid(), "kind": "research"}, true)
	return c

func draw_humanity():
	if S.decks.hu.is_empty():
		S.decks.hu = shuffled(indices(D.HUMANITY.size()).filter(func(k): return not S.removed.has(D.HUMANITY[k].id)))
	if S.decks.hu.is_empty():
		return null
	var c: Dictionary = D.HUMANITY[S.decks.hu.pop_front()].duplicate(true)
	c.merge({"uid": uid(), "kind": "humanity"}, true)
	return c

func hosp_limits(p: Dictionary) -> Dictionary:
	return {"free": 1 if p.rep >= 7 else 0, "paid": (1 if S.ev == "corrupt" else 0) + (1 if p.rep >= 15 else 0)}

## Scoundrels keep their own kind (thief, dog, cut, snatch, bone) in "sk"; "kind" says it is a scoundrel card.
func sc_cost(c: Dictionary) -> int:
	return c.cost + (1 if S.ev == "graves" else 0) + (1 if S.ev == "plague" and c.sk == "dog" else 0)

func sc_hcost(c: Dictionary) -> int:
	return c.hcost + (1 if S.ev == "toussaint" and (c.sk == "thief" or c.sk == "snatch") else 0)

func sc_allowed(c: Dictionary) -> bool:
	return not (c.sk == "snatch" and S.closed.has("snatch"))


# ================================================================ player state

func mk_player(name: String, color: String, ai: bool, persona, char_id: String) -> Dictionary:
	return {"name": name, "color": color, "ai": ai, "persona": persona if persona != null else {}, "char": char_id,
		"coin": 0, "hum": 0, "exp": 0, "rep": 0, "maxRep": 0, "maxExp": 0, "vp": 0, "police": 0,
		"mats": {"muscle": [0, 0, 0, 0], "organ": [0, 0, 0, 0], "blood": [0, 0, 0, 0], "animal": [0, 0, 0, 0]},
		"bone": 0, "preserved": 0,
		"table": {"head": null, "torso": null, "armL": null, "armR": null, "legL": null, "legR": null},
		"jars": [false], "ice": 0, "hand": [], "left": {"scientist": 0, "assistant": 0}, "sel": "assistant",
		"labUsed": {}, "thrown": false, "aidPlayed": false, "sabotaged": 0, "noHumLoss": false,
		"odeonUsed": false, "zooUsed": false, "surgeonUsed": false, "lastDark": 0, "labDone": false}

func has_char(p: Dictionary, id: String) -> bool:
	return p.char == id

func sci_total(p) -> int:
	return 1 + (1 if p.rep >= 15 else 0)

func asst_total(p) -> int:
	return 2 + (1 if p.rep >= 7 else 0) - (1 if p.rep >= 15 else 0)

func left_n(p) -> int:
	return p.left.scientist + p.left.assistant

func blue_dice(p) -> int:
	return 2 if p.exp >= 20 else 1 if p.exp >= 10 else 0

func charged(p) -> int:
	return p.jars.filter(func(j): return j).size()

func on_table(p) -> Array:
	return D.SLOT6.filter(func(s): return p.table[s] != null)

func complete_count(p) -> int:
	return D.SLOT6.filter(func(s): return p.table[s] != null and p.table[s].side == "skin").size()

func alive_count(p) -> int:
	return D.SLOT6.filter(func(s): return p.table[s] != null and p.table[s].alive).size()

func dmg_total(p) -> int:
	var t = 0
	for s in D.SLOT6:
		if p.table[s] != null:
			t += p.table[s].dmg
	return t

func mat_total(p, t: String) -> int:
	return p.bone if t == "bone" else total(p.mats[t])

func flesh_on_track(p) -> int:
	return total(p.mats.muscle) + total(p.mats.organ)

func add_mat(p, t: String, stage: int, n: int) -> void:
	if n <= 0:
		return
	if t == "bone":
		p.bone = mini(12, p.bone + n)
		return
	p.mats[t][stage - 1] = mini(15, p.mats[t][stage - 1] + n)

func gain_mats(p, list: Array) -> void:
	for m in list:
		add_mat(p, m[0], m[1] if m[1] else 1, m[2])

func set_hum(p, d: int) -> int:
	if not d or has_char(p, "psycho"):
		return 0
	if d < 0 and p.noHumLoss:
		return 0
	var before: int = p.hum
	var nxt: int = before + d
	if d > 0 and has_char(p, "human"):
		p.vp += maxi(0, nxt - 10)
	p.hum = clampi(nxt, -10, 10)
	check_objectives()
	return p.hum - before

func set_rep(p, d: int) -> void:
	p.rep = maxi(0, p.rep + d)
	p.maxRep = maxi(p.maxRep, p.rep)
	check_objectives()

func set_exp(p, d: int) -> void:
	p.exp = maxi(0, p.exp + d)
	p.maxExp = maxi(p.maxExp, p.exp)
	check_objectives()

func apply_gain(p, g, src := "") -> void:
	if g == null:
		return
	if g.get("exp", 0):
		set_exp(p, g.exp + (1 if src == "research" and has_char(p, "heiress") and g.exp > 0 else 0))
	if g.get("rep", 0):
		set_rep(p, g.rep)
	if g.get("coin", 0):
		p.coin += g.coin
	if g.get("hum", 0):
		set_hum(p, g.hum)

func add_card(p, c) -> void:
	if c == null:
		return
	var same: Array = p.hand.filter(func(h): return h.kind == c.kind)
	if same.size() >= 3:
		p.hand.erase(same[0])
	p.hand.append(c)

func find_card(p, id: String):
	for h in p.hand:
		if h.id == id:
			return h
	return null

func has_card(p, id: String) -> bool:
	return find_card(p, id) != null

func discard(p, c) -> void:
	p.hand.erase(c)

func add_police(p) -> void:
	p.police = mini(2, p.police + 1)
	if p.police == 2 and has_char(p, "psycho"):
		set_rep(p, -1)

func check_objectives() -> void:
	if S.is_empty() or not S.has("objectives"):
		return
	var n: int = S.players.size()
	for id in S.objectives:
		if S.claimed.has(id) or id == "rich":
			continue
		for k in n:
			var i: int = (S.first + k) % n
			var p: Dictionary = S.players[i]
			var ok = false
			match id:
				"hum10": ok = p.hum >= 10
				"alive2": ok = alive_count(p) >= 2
				"exp27": ok = p.exp >= 27
				"parts6": ok = on_table(p).size() >= 6
				"rep23": ok = p.rep >= 23
			if ok:
				S.claimed[id] = i
				log_line("%s claims the bonus objective: %s (+10 VP)." % [B(p), OBJ[id].name])
				break


# ================================================================ setup

func new_game(name: String, n_rivals: int, char_id: String, opts := {}) -> void:
	token += 1
	S = {"v": SAVE_V, "uid": 1, "round": 1, "first": 0, "cur": 0, "phase": "event", "captain": 0, "ev": null, "card": null,
		"closed": {}, "occ": {}, "bump": [], "fast": opts.get("fast", false),
		"decks": {"cemetery": [], "hospital": [], "morgue": [], "square": [], "sc": [], "re": [], "hu": []},
		"removed": [], "hosp": [], "square": [], "docks": [], "researchRow": [], "humanityRow": [],
		"locEnc": null, "thwart": null, "log": [], "dawn": [], "final": null, "claimed": {},
		"objectives": shuffled(D.OBJECTIVES.map(func(o): return o.id)).slice(0, 4),
		"odeonOpen": false, "fireUsed": {}, "blocked": null}
	var chars = shuffled(D.CHARACTERS.map(func(c): return c.id).filter(func(c): return c != char_id))
	var mine: String = char_id if char_id != "" and char_id != "random" else chars.pop_back()
	var all_ai: bool = opts.get("allAI", false)
	S.players = [mk_player(name if name != "" else "Dr Torres", D.YOU_COLOR, all_ai, {"ruthless": 0, "scholar": 0, "careful": 0} if all_ai else null, mine)]
	for r in D.RIVALS.slice(0, n_rivals):
		S.players.append(mk_player(r.name, r.color, true, r, chars.pop_back()))
	var n: int = S.players.size()
	for p in S.players:
		p.coin = n
		if has_char(p, "charlatan"):
			set_rep(p, 3)
		if has_char(p, "human"):
			p.hum = 2
		if has_char(p, "surgeon"):
			set_exp(p, 2)
	S.first = rnd(n)
	# Event deck: one card a day, 4 encounters mixed into days 3 to 12.
	var enc_days = shuffled([3, 4, 5, 6, 7, 8, 9, 10, 11, 12]).filter(func(d): return D.ENCOUNTERS.any(func(e): return d >= e.r[0] and d <= e.r[1]))
	var enc_set: Array = enc_days.slice(0, 4)
	var used_e = {}
	var used_n = {}
	S.events = []
	for d in range(1, D.MAX_ROUNDS + 4):
		var card = null
		if enc_set.has(d):
			var os: Array = D.ENCOUNTERS.filter(func(e): return d >= e.r[0] and d <= e.r[1] and not used_n.has(e.id))
			if os.size():
				var e: Dictionary = pick(os)
				used_n[e.id] = 1
				card = {"t": "enc", "id": e.id}
		if card == null:
			var os: Array = D.EVENTS.filter(func(e): return d >= e.r[0] and d <= e.r[1] and not used_e.has(e.id))
			if os.is_empty():
				os = D.EVENTS.filter(func(e): return not used_e.has(e.id))
			if os.is_empty():
				os = D.EVENTS
			var e: Dictionary = pick(os)
			used_e[e.id] = 1
			card = {"t": "ev", "id": e.id}
		S.events.append(card)
	S.events[0] = {"t": "ev", "id": pick(["corrupt", "meat", "enemy", "grant", "darkres"])}
	for k in ["cemetery", "hospital", "morgue", "square"]:
		S.decks[k] = shuffled(indices(D.CADAVERS[k].size()))
	S.decks.sc = shuffled(indices(D.SCOUNDRELS.size()))
	S.decks.re = shuffled(indices(D.RESEARCH.size()))
	S.decks.hu = shuffled(indices(D.HUMANITY.size()))
	refresh_board()
	log_line("A letter in an enormous hand arrives. Twelve days, unless the Captain finds the Creature first.")


func refresh_board() -> void:
	S.hosp = [draw_cadaver("hospital"), draw_cadaver("hospital")]
	S.docks = [draw_scoundrel(), draw_scoundrel(), draw_scoundrel()]
	S.researchRow = [draw_research(), draw_research(), draw_research()]
	S.humanityRow = [draw_humanity(), draw_humanity(), draw_humanity()].filter(func(c): return c != null)
	S.square = []


# ================================================================ main loop

func sleep(ms: float) -> void:
	if not S.fast:
		await ui.sleep(ms)

func sync() -> void:
	if not S.fast:
		ui.sync()

## Runs the game until it ends (or a new game replaces it).
func run() -> void:
	var tok = token
	while tok == token and S.phase != "end":
		match S.phase:
			"event":
				await event_phase()
				if tok != token:
					return
				S.phase = "day"
				S.cur = S.first
				save()
				sync()
			"day":
				await city_phase(tok)
			"firstmove":
				await first_move_phase()
				S.phase = "lab"
				save()
				sync()
			"lab":
				await lab_phase()
			"dawn":
				await dawn_phase()
			_:
				return
		if tok != token:
			return
	sync()


# ---------------------------------------------------------------- event phase

func event_phase() -> void:
	S.occ = {}
	S.bump = []
	S.closed = {}
	S.thwart = null
	S.locEnc = null
	S.odeonOpen = false
	S.fireUsed = {}
	for p in S.players:
		p.left = {"scientist": sci_total(p), "assistant": asst_total(p)}
		p.labUsed = {}
		p.thrown = false
		p.aidPlayed = false
		p.odeonUsed = false
		p.zooUsed = false
		p.surgeonUsed = false
		p.noHumLoss = false
		p.labDone = false
		if not p.left[p.sel]:
			p.sel = "assistant" if p.left.assistant else "scientist"
		if has_char(p, "heiress") and p.coin <= 2:
			p.coin += 1
	var card: Dictionary = S.events[S.round - 1]
	S.card = card
	S.ev = card.id if card.t == "ev" else null
	S.dawn = []
	sync()
	if card.t == "ev":
		var e: Dictionary = EVENT[card.id]
		log_line("Day %d: %s." % [S.round, e.name], "day")
		var close_map = {"graves": ["cemetery"], "fire": ["academy"], "plague": ["slaughter"], "riots": ["alley", "docks"], "storm2": ["cemetery", "docks"], "purge": ["hospital"]}
		for l in close_map.get(e.id, []):
			S.closed[l] = 1
		if e.get("storm", 0):
			for p in S.players:
				p.jars = p.jars.map(func(_j): return true)
			log_line("Lightning: every Leyden jar is charged.")
		if e.get("exec", 0):
			await execution()
		if e.id == "odeon":
			S.odeonOpen = true
		if e.id == "betrayal":
			for p in S.players:
				if p.hum < 3 and p.jars.size():
					p.jars.pop_back()
					log_line("%s loses a Leyden jar." % B(p))
		if not S.fast:
			await ui.show_event(e)
		if e.id == "bourbon":
			for p in S.players:
				var pay: bool = p.coin >= 1 and (true if p.ai else await ui.ask_yn("Loyalty Pledges", "Pay 1 franc to gain 1 reputation? If not, you lose 1 reputation.", "Pay 1 franc", "Refuse"))
				if pay:
					p.coin -= 1
					set_rep(p, 1)
				else:
					set_rep(p, -1)
		if e.id == "darkres":
			for p in S.players:
				var take: bool = (ai_needs(p).expGap > 0 and p.hum > -6) if p.ai else await ui.ask_yn("A Dead Man’s Notes", "Lose 1 humanity to gain 2 expertise?", "Read them", "Burn them")
				if take:
					set_hum(p, -1)
					set_exp(p, 2)
		if e.id == "fire":
			for p in S.players:
				if p.coin < 2:
					continue
				var pay: bool = (p.coin >= 4 and randf() < .6) if p.ai else await ui.ask_yn("Fire at the Academy", "Pay 2 francs toward the rebuilding to gain 2 reputation?", "Pay 2 francs", "Not now")
				if pay:
					p.coin -= 2
					set_rep(p, 2)
					log_line("%s pays for the rebuilding." % B(p))
			var t = await fp_choose_target("Who receives the Captain’s plea?", indices(S.players.size()), "any")
			if t != null:
				await outcome_c2(t)
		if e.id == "enemy":
			for p in S.players:
				if p.hum > 0:
					var take: bool = true if p.ai else await ui.ask_yn("An Anonymous Letter", "Take a humanity card?", "Take one", "No")
					if take:
						add_card(p, draw_humanity())
			var top: int = S.players.map(func(p): return p.hum).max()
			var ti: int = S.players.map(func(p): return p.hum).find(top)
			set_hum(S.players[ti], 1)
			log_line("%s hears a confession and gains 1 humanity." % B(S.players[ti]))
	else:
		var e: Dictionary = ENC[card.id]
		log_line("Day %d: an encounter." % S.round, "day")
		if e.has("loc"):
			S.locEnc = {"id": e.id, "holder": S.first}
			log_line("%s holds a secret encounter at one of the spaces in Paris." % B(S.players[S.first]))
			if not S.fast:
				await ui.show_secret_encounter(e, is_human(S.first))
		else:
			var t = await encounter_target(e)
			if t == null:
				log_line("No one fits the encounter. It passes.")
			else:
				await run_encounter(e, t, {})
	save()
	sync()


func execution() -> void:
	for p in S.players:
		var c = find_card(p, "mercy")
		if c == null or p.coin < 2:
			continue
		var use: bool = (p.hum < 3 and p.coin >= 4) if p.ai else await ui.ask_yn("Royal Pardon", "An execution is announced. Pay 2 francs and play your Royal Pardon to stop it? (+2 humanity, +2 reputation)", "Stop it", "Let it happen")
		if use:
			p.coin -= 2
			discard(p, c)
			apply_gain(p, c.gain)
			log_line("%s wins a royal pardon. The execution is cancelled." % B(p))
			return
	var k = 2 if S.players.size() > 2 else 1
	for j in k:
		S.square.append(draw_cadaver("square"))
	log_line("Execution: fresh bodies at the Public Square.")


# ---------------------------------------------------------------- encounters

func fp_choose_target(title: String, cands: Array, mood := ""):
	if cands.is_empty():
		return null
	if cands.size() == 1:
		return cands[0]
	var fp: int = S.first
	if is_human(fp) and not S.fast:
		var opts = []
		for k in cands:
			opts.append({"label": S.players[k].name + (" (you)" if k == 0 else ""), "value": k})
		return await ui.ask({"title": title, "text": "As first player, you choose.", "options": opts, "locked": true})
	if mood == "good" and cands.has(fp):
		return fp
	var others = cands.filter(func(k): return k != fp)
	var pool: Array = others if others.size() else cands
	pool.sort_custom(func(a, b): return score(S.players[a]) > score(S.players[b]))
	return pool[0]

func score(p) -> float:
	return p.vp + alive_count(p) * 4 + p.rep / 2.0 + p.exp / 3.0

func _tied(idx: Array, f: Callable) -> Array:
	var m = idx.map(f).max()
	return idx.filter(func(k): return f.call(k) == m)

func encounter_target(e: Dictionary):
	var P: Array = S.players
	var idx = indices(P.size())
	match e.target:
		"maxExp":
			return await fp_choose_target("Who is visited?", _tied(idx, func(k): return P[k].exp))
		"fewestComplete":
			return await fp_choose_target("Who is visited?", _tied(idx, func(k): return -complete_count(P[k])))
		"maxHum":
			return await fp_choose_target("Who is visited?", _tied(idx, func(k): return P[k].hum))
		"fpOther":
			return await fp_choose_target("Who does the Creature visit?", idx.filter(func(k): return k != S.first))
		"fp":
			return await fp_choose_target("Who does the visitor find?", idx)
		"fpWithPart":
			return await fp_choose_target("Who does the Creature watch?", idx.filter(func(k): return on_table(P[k]).size() > 0))
		"lastDark":
			var best: int = idx.map(func(k): return P[k].lastDark).max()
			if not best:
				return null
			for k in idx:
				if P[k].lastDark == best:
					return k
		"mostHumCards":
			var f = func(k): return P[k].hand.filter(func(h): return h.kind == "humanity").size()
			if idx.map(f).max() == 0:
				return await fp_choose_target("Who is visited?", idx)
			return await fp_choose_target("Who is visited?", _tied(idx, f))
	return null

## The encounter tests that src/data.js writes as functions.
func enc_test(e: Dictionary, p: Dictionary) -> bool:
	match e.id:
		"e8": return alive_count(p) >= 2
		"e6": return complete_count(p) >= 3
		"e4": return complete_count(p) >= 4
		"e22": return alive_count(p) >= 1
		"e18": return p.exp >= 13
	return true

func enc_has_test(e: Dictionary) -> bool:
	return e.has("testText")

func who_name(e: Dictionary) -> String:
	return "Captain" if e.who == "captain" else "stranger" if e.who == "woman" else "Creature"

func run_encounter(e: Dictionary, t: int, ctx: Dictionary) -> Dictionary:
	var p: Dictionary = S.players[t]
	if e.get("now", 0) and e.who == "creature":
		var trap = find_card(p, "trap")
		if trap != null and charged(p) > 0:
			var use: bool = p.hum <= 2 if p.ai else await ui.ask_yn("A Trap of Your Own", "The Creature is coming for you. Spend 1 charged jar to set your trap and send him away?", "Spring the trap", "Face him")
			if use:
				discharge_one(p)
				discard(p, trap)
				apply_gain(p, trap.gain)
				log_line("%s springs a trap and the Creature withdraws." % B(p))
				return {}
	var branch = "a"
	if enc_has_test(e):
		branch = "a" if enc_test(e, p) else "b"
	elif e.has("choice"):
		if p.ai:
			branch = ai_encounter_choice(e, p)
		else:
			branch = await ui.ask({"title": "An encounter", "encounter": e, "text": "This encounter is for you.",
				"options": [{"label": e.choice[0], "value": "a"}, {"label": e.choice[1], "value": "b"}], "locked": true})
	var key: String = e.a if branch == "a" else e.b
	if is_human(t) and enc_has_test(e) and not S.fast:
		await ui.ask({"title": "An encounter", "encounter": e, "text": "Test: %s. %s." % [e.testText, "Yes" if branch == "a" else "No"],
			"buttons": [{"label": "See what happens", "primary": true, "value": 1}], "locked": true})
	elif not is_human(t):
		log_line("%s meets the %s." % [B(p), who_name(e)])
	var res: Dictionary = await outcome(key, t, ctx)
	if is_human(t) and res.has("msg") and not S.fast:
		await ui.ask({"title": "What happens", "text": res.msg, "buttons": [{"label": "Continue", "primary": true, "value": 1}]})
	log_line("%s: %s" % [B(p), res.get("msg", "nothing more comes of it.")])
	return res

func ai_encounter_choice(e: Dictionary, p: Dictionary) -> String:
	match e.id:
		"e14": return "a" if flesh_on_track(p) >= 4 else "b"
		"e10": return "a"
		"e2": return "b" if p.hum >= 0 else "a"
		"e28": return "a" if p.hum < 0 else "b"
		"e26": return "b" if p.hum < -2 else "a"
		"e24": return "b"
		"e20": return "a"
		"e16": return "a" if p.hum > -2 else "b"
		"e29": return "a"
	return "a"

func discharge_one(p) -> void:
	var k: int = p.jars.find(true)
	if k >= 0:
		p.jars[k] = false

func take_first(i: int) -> void:
	S.first = i

func _rank_part(p, s: String) -> int:
	var t: Dictionary = p.table[s]
	return (0 if t.alive else 10 if t.side == "skin" else 20) + D.PARTS[D.SLOT_T[s]].alive

func downgrade_one(p) -> String:
	var parts = on_table(p)
	if parts.is_empty():
		return "nothing to damage"
	parts.sort_custom(func(a, b): return _rank_part(p, a) < _rank_part(p, b))
	var s: String = parts[0]
	var t: Dictionary = p.table[s]
	t.dmg = 0
	var nm: String = D.SLOT_N[s].to_lower()
	if t.alive:
		t.alive = false
		return "the %s dies again" % nm
	if t.side == "skin":
		t.side = "muscle"
		return "the %s loses its skin" % nm
	p.table[s] = null
	return "the %s is destroyed" % nm

func place_forced(i: int, key: String, kind: String) -> bool:
	var p: Dictionary = S.players[i]
	if not p.left[kind]:
		return false
	if key.begins_with("lab."):
		var s = key.substr(4)
		if p.labUsed.has(s):
			return false
		p.labUsed[s] = kind
	else:
		if S.occ.has(key):
			return false
		S.occ[key] = {"p": i, "kind": kind}
	p.left[kind] -= 1
	return true

func outcome(key: String, i: int, _ctx: Dictionary) -> Dictionary:
	var p: Dictionary = S.players[i]
	match key:
		"A2":
			set_hum(p, -2)
			if p.jars.size():
				p.jars.pop_back()
			return {"msg": "You point to the Captain’s hiding place. A gunshot, then silence. -2 humanity, and a jar shatters in the struggle."}
		"B2":
			set_exp(p, -1)
			set_hum(p, 2)
			return {"msg": "You hide him and are knocked senseless for it. -1 expertise, +2 humanity."}
		"A4":
			gain_mats(p, [["organ", 1, 1], ["muscle", 1, 2]])
			set_hum(p, -1)
			return {"msg": "He empties the bag on your table: an arm, freshly torn. +1 organ and +2 muscle at stage I, -1 humanity."}
		"B4":
			add_mat(p, "organ", 1, 1)
			set_hum(p, 1)
			return {"msg": "He presses an eyeball into your palm. +1 organ at stage I, +1 humanity."}
		"A6":
			if p.jars.size() < 4:
				p.jars.append(false)
			return {"msg": "“Breathe life into it, and quickly.” He leaves you an empty Leyden jar."}
		"B6":
			var ok = place_forced(i, "lab.blood", "scientist")
			if ok:
				add_mat(p, "blood", 1, 5)
			return {"msg": "He forces the lancet into your arm. Your scientist gives blood: +5 blood at stage I." if ok else "He bleeds you, but you have no scientist free. Nothing more."}
		"A8":
			take_first(i)
			return {"msg": "“Then I will show you the way.” You become first player."}
		"B8":
			add_card(p, draw_research())
			add_card(p, draw_research())
			return {"msg": "He leaves a sheaf of parchment. Draw 2 research cards."}
		"A10":
			take_first(i)
			var at = ""
			if p.left.scientist:
				p.left.scientist -= 1
				if not S.occ.has("docks.hire"):
					S.occ["docks.hire"] = {"p": i, "kind": "scientist"}
				at = " Your scientist spends the day at the Docks."
			add_card(p, draw_humanity())
			set_hum(p, 1)
			p.coin += 2
			return {"msg": "You meet the Captain by the river. You become first player, take a humanity card, +1 humanity and +2 francs." + at}
		"B10":
			S.captain = maxi(0, S.captain - 1)
			set_hum(p, -1)
			return {"msg": "You burn the note. The Captain loses your trail: he moves back 1 step. -1 humanity."}
		"A12":
			var c: Array
			if p.ai:
				var sh: Dictionary = ai_needs(p).short
				c = [2, 0, 2] if sh.B else [1, 2, 1] if sh.O else [2, 1, 1]
			else:
				c = await ui.ask({"title": "A blood-soaked bag", "text": "Gain 4 human materials at stage I. Choose:", "locked": true, "options": [
					{"label": "2 muscle, 1 organ, 1 blood", "value": [2, 1, 1]}, {"label": "1 muscle, 2 organ, 1 blood", "value": [1, 2, 1]},
					{"label": "2 muscle, 2 blood", "value": [2, 0, 2]}, {"label": "2 muscle, 2 organ", "value": [2, 2, 0]}]})
			gain_mats(p, [["muscle", 1, c[0]], ["organ", 1, c[1]], ["blood", 1, c[2]]])
			set_hum(p, -2)
			return {"msg": "You come back hours later, clutching a heavy, dripping bag. +4 materials at stage I, -2 humanity."}
		"A14":
			var n = 2
			for st in range(3, -1, -1):
				for t in ["organ", "muscle"]:
					var k: int = mini(n, p.mats[t][st])
					p.mats[t][st] -= k
					n -= k
			p.coin += 3
			return {"msg": "You stitch him with your own supplies. He drops a sack of coins. -2 flesh from your track, +3 francs."}
		"B14":
			if p.left.assistant:
				p.left.assistant -= 1
			elif p.left.scientist:
				p.left.scientist -= 1
			if S.captain < 11:
				S.captain += 1
			return {"msg": "You find one of your assistants dead in your bed. You lose 1 meeple today, and the Captain moves 1 step closer."}
		"A16":
			gain_mats(p, [["muscle", 2, 1], ["organ", 2, 1], ["blood", 2, 1], ["bone", 0, 1]])
			set_hum(p, -2)
			return {"msg": "The bag holds your old mentor. +1 muscle, organ, blood at stage II and 1 bone. -2 humanity."}
		"B16":
			var q: Dictionary = S.players[(i + 1) % S.players.size()]
			gain_mats(q, [["muscle", 1, 1], ["organ", 1, 1], ["blood", 1, 1], ["bone", 0, 1]])
			set_hum(p, 1)
			return {"msg": "He takes the bag to %s instead. They gain 1 of each human material. +1 humanity for you." % q.name}
		"A18":
			add_card(p, draw_research())
			return {"msg": "“Then read this.” Draw 1 research card."}
		"B18":
			var ok = place_forced(i, "lab.practice", "scientist")
			if ok:
				set_exp(p, 2)
			return {"msg": "He drags you back to your bench. Your scientist practises: +2 expertise." if ok else "He drags you to your bench, but you have no scientist free."}
		"A20":
			take_first(i)
			p.noHumLoss = true
			var at = ""
			for kind in ["scientist", "assistant"]:
				if p.left[kind] and not S.occ.has("church.atone"):
					S.occ["church.atone"] = {"p": i, "kind": kind}
					p.left[kind] -= 1
					if S.humanityRow.size():
						take_row_card(p, "humanityRow", S.humanityRow[0].uid)
					if kind == "scientist":
						set_hum(p, 1)
					at = " Your %s goes to Saint-Roch." % kind
					break
			return {"msg": "You agree to help. You become first player and cannot lose humanity today." + at}
		"B20":
			var d = set_hum(p, -2)
			if not d:
				for k in S.players.size():
					if k != i:
						set_hum(S.players[k], 1)
			return {"msg": "You refuse. -2 humanity." if d else "You refuse, but you have no humanity left to lose. Everyone else gains 1 humanity."}
		"A22":
			p.coin += 3
			return {"msg": "He leaves a few coins on the bench. +3 francs."}
		"B22":
			return {"msg": "He strikes your work in a fury: %s." % downgrade_one(p)}
		"A24":
			if p.coin >= 1:
				p.coin -= 1
			else:
				set_rep(p, -1)
			var all = []
			for k in D.SCOUNDRELS.size():
				var c = make_scoundrel(k)
				if sc_cost(c) <= p.coin and sc_allowed(c):
					all.append(c)
			if all.size():
				var c
				if p.ai:
					var b = ai_best_scoundrel(p, all)
					c = b.c if b != null else null
				else:
					c = await ui.choose_scoundrel(p, all, "She knows everyone. Hire any scoundrel in Paris.", false)
				if c != null:
					await hire_scoundrel(i, c.card, c.how, all, c.get("unethical", false))
			S.decks.sc = shuffled(indices(D.SCOUNDRELS.size()))
			S.docks = [draw_scoundrel(), draw_scoundrel(), draw_scoundrel()]
			return {"skip": true, "msg": "She takes a coin and leads you to the right man."}
		"B24":
			p.coin = maxi(0, p.coin - 2)
			return {"skip": true, "msg": "Her friends knock you down and empty your purse. -2 francs, and no business today."}
		"A26":
			set_hum(p, -1)
			return {"extra": 2, "msg": "You load a trolley with the dead. 2 extra cadavers this time, -1 humanity."}
		"B26":
			set_hum(p, 3)
			p.coin += 1
			return {"skip": true, "msg": "You roll up your sleeves and save who you can. +3 humanity, +1 franc."}
		"A28":
			set_hum(p, 2)
			return {"skip": true, "msg": "You listen to the Captain’s tale of Victor. +2 humanity, but no research today."}
		"B28":
			set_hum(p, -1)
			add_card(p, draw_research())
			return {"skip": true, "msg": "You gather your papers and leave. -1 humanity, draw 1 research card."}
		"A29":
			return {"fresh": true, "msg": "In the grave lie three bodies, alarmingly fresh. Bones-only cards are redrawn and every body counts as stage I. Resolving any costs 1 humanity in total."}
		"B29":
			return {"two": true, "msg": "You dig elsewhere. You draw only 2 cards, but none of them cost humanity."}
	return {}

func outcome_c2(t: int) -> void:
	var p: Dictionary = S.players[t]
	var aid: bool = p.hum < 2 if p.ai else await ui.ask_yn("A visitor in soot", "A man in soot begs you to help him destroy your patron. Will you aid Captain Walton?", "Aid him", "Send him away")
	if aid:
		add_card(p, draw_humanity())
		set_hum(p, 1)
		log_line("%s promises to help the Captain: a humanity card and +1 humanity." % B(p))
	else:
		add_card(p, draw_research())
		set_hum(p, -2)
		log_line("%s sends the Captain away: a research card and -2 humanity." % B(p))


# ================================================================ city phase

func space_list() -> Array:
	var keys = []
	for l in D.LOCS:
		if l.has("event") and not (l.event == "odeon" and S.odeonOpen):
			continue
		for s in l.spaces:
			keys.append(l.id + "." + s.k)
	return keys

func all_keys() -> Array:
	var keys = space_list()
	for l in D.LABSPOTS:
		keys.append("lab." + l.id)
	return keys

func bump_info(i: int, key: String):
	if not S.occ.has(key):
		return {"cost": 0, "bump": false}
	var o: Dictionary = S.occ[key]
	var sp: Dictionary = SPACE[key]
	if sp.get("nobump", 0):
		return null
	if sp.get("freebump", 0):
		return {"cost": 0, "bump": true, "free": true}
	var track: Array = D.BUMP_TRACK.get(str(S.players.size()), [1, 1, 2])
	if S.bump.size() >= track.size():
		return null
	return {"cost": 0 if o.p == i else track[S.bump.size()], "bump": true}

## Francs a space needs before bumping, or null when it can't be used.
func space_needs(i: int, key: String):
	var p: Dictionary = S.players[i]
	match key:
		"square.buy": return 1 if S.square.size() else null
		"morgue.buy": return 1
		"hospital.retrieve":
			if S.hosp.is_empty():
				return null
			if p.rep >= 7:
				return 0
			return 1 if S.ev == "corrupt" else null
		"hospital.work": return null if S.ev == "hardtimes" else 0
		"academy.donate": return 1
		"market.trade": return 0 if (p.coin >= 1 or p.bone >= 2 or p.preserved >= 3) else null
		"docks.hire":
			var c: Array = S.docks.filter(sc_allowed).map(sc_cost)
			return c.min() if c.size() else null
		"alley.murder": return null if p.police >= 2 else 0
		"odeon.show": return null if p.odeonUsed else 0
		"lab.repair": return 0 if dmg_total(p) > 0 else null
		"lab.charge": return 0 if p.jars.any(func(j): return not j) else null
	return 0

func can_place(i: int, key: String, kind := "") -> bool:
	var p: Dictionary = S.players[i]
	if kind == "":
		return can_place(i, key, "scientist") or can_place(i, key, "assistant")
	if not p.left[kind]:
		return false
	if key.begins_with("lab."):
		var s: Dictionary = LABSPOT[key.substr(4)]
		if p.labUsed.has(s.id):
			return false
		if s.get("sci", 0) and kind != "scientist":
			return false
		return space_needs(i, key) != null
	if not SPACE.has(key):
		return false
	var sp: Dictionary = SPACE[key]
	if S.closed.has(sp.loc):
		return false
	if sp.get("sci", 0) and kind != "scientist":
		return false
	if sp.loc == "academy" and S.ev == "parade" and kind != "scientist":
		return false
	if key == "academy.research" and S.researchRow.is_empty():
		return false
	if key == "church.atone" and S.humanityRow.is_empty() and kind != "scientist":
		return false
	var need = space_needs(i, key)
	if need == null:
		return false
	var b = bump_info(i, key)
	if b == null:
		return false
	return p.coin >= need + b.cost

func legal_any(i: int) -> bool:
	return all_keys().any(func(k): return can_place(i, k))

func kind_for(i: int, key: String):
	var p: Dictionary = S.players[i]
	if can_place(i, key, p.sel):
		return p.sel
	var o = "assistant" if p.sel == "scientist" else "scientist"
	return o if can_place(i, key, o) else null

func city_phase(tok: int) -> void:
	var n: int = S.players.size()
	var guard = 0
	while tok == token and guard < 200:
		guard += 1
		var nxt = -1
		for k in n:
			var i: int = (S.cur + k) % n
			var p: Dictionary = S.players[i]
			if left_n(p) > 0 and legal_any(i):
				nxt = i
				break
			elif left_n(p) > 0:
				log_line("%s has nowhere left to go and passes." % B(p))
				p.left = {"scientist": 0, "assistant": 0}
		if nxt < 0:
			break
		S.cur = nxt
		save()
		sync()
		if S.players[nxt].ai:
			await sleep(1000)
			if tok != token:
				return
			var log_at: int = S.log.size()
			var occ_before: Dictionary = S.occ.duplicate()
			var lab_before: Dictionary = S.players[nxt].labUsed.duplicate()
			await ai_turn(nxt)
			if tok != token:
				return
			sync()
			if not S.fast:
				var key = ""
				for k in S.occ:
					if not occ_before.has(k) and S.occ[k].p == nxt:
						key = k
				var kind = ""
				if key != "":
					kind = S.occ[key].kind
				else:
					for s in S.players[nxt].labUsed:
						if not lab_before.has(s):
							key = "lab." + s
							kind = S.players[nxt].labUsed[s]
				if key != "":
					await ui.rival_moved(nxt, key, kind, S.log.slice(log_at).map(func(l): return l.t))
				await sleep(1400)
		else:
			await human_turn(tok)
			if tok != token:
				return
		S.cur = (nxt + 1) % n
	if tok != token:
		return
	S.phase = "firstmove"
	save()
	sync()

## The human's turn: the presenter returns {key, kind, pre} once you have chosen a space and made its choices.
func human_turn(tok: int) -> void:
	var p: Dictionary = S.players[0]
	while tok == token:
		var mv = await ui.human_turn()
		if tok != token or mv == null:
			return
		var key: String = mv.key
		var sp = SPACE.get(key)
		if sp != null and S.thwart != null and S.thwart != 0:
			var by: Dictionary = S.players[S.thwart]
			S.thwart = null
			S.blocked = sp.loc
			log_line("%s crosses %s’s path at %s." % [by.name, B(p), LOC[sp.loc].name])
			await ui.ask({"title": "Your path is crossed", "text": "%s played Cross Their Path. You can’t go to %s this turn. Choose another space." % [by.name, LOC[sp.loc].name],
				"buttons": [{"label": "Choose again", "primary": true, "value": 1}]})
			sync()
			continue
		await place_and_resolve(0, key, mv.kind, mv.pre)
		S.blocked = null
		save()
		return

## Place a meeple on a space and resolve it. pre holds the choices made beforehand (AI or popup).
func place_and_resolve(i: int, key: String, kind: String, pre) -> void:
	var p: Dictionary = S.players[i]
	if pre == null:
		pre = {}
	if key.begins_with("lab."):
		p.labUsed[key.substr(4)] = kind
		p.left[kind] -= 1
		if not S.fast:
			await ui.placed(i, key, kind, null)
		await resolve_lab(i, key.substr(4), kind, pre)
		return
	var b = bump_info(i, key)
	var bumped = null
	if b != null and b.bump:
		var o: Dictionary = S.occ[key]
		var owner: Dictionary = S.players[o.p]
		bumped = o.duplicate()
		if b.get("free", false):
			owner.left[o.kind] += 1
			log_line("%s bumps %s from the theatre. Their meeple goes home." % [B(p), owner.name])
		else:
			S.bump.append(o)
			if b.cost:
				p.coin -= b.cost
				owner.coin += b.cost
			log_line("%s bumps %s from %s%s." % [B(p), owner.name, LOC[SPACE[key].loc].name, (" and pays them " + fr(b.cost)) if b.cost else ""])
			if SPACE[key].loc == "academy" and has_char(owner, "charlatan") and o.p != i:
				set_rep(owner, 1)
	S.occ[key] = {"p": i, "kind": kind}
	p.left[kind] -= 1
	if not S.fast:
		await ui.placed(i, key, kind, bumped)
	var mod = {}
	if S.locEnc != null:
		var e: Dictionary = ENC[S.locEnc.id]
		if e.loc == key and S.locEnc.holder != i:
			S.locEnc = null
			mod = await run_encounter(e, i, {"key": key})
	if mod.get("skip", false):
		return
	await resolve_space(i, key, kind, pre, mod)
	check_objectives()


# ---------------------------------------------------------------- space effects

func resolve_space(i: int, key: String, kind: String, pre: Dictionary, mod: Dictionary) -> void:
	var p: Dictionary = S.players[i]
	var sci = kind == "scientist"
	match key:
		"cemetery.dig":
			var n = 2 if mod.get("two", false) else 3
			if S.ev == "cholera":
				n += 1
			var cards = []
			for k in n:
				var c = draw_cadaver("cemetery")
				if mod.get("fresh", false):
					var g = 0
					while not c.exp and g < 6:
						g += 1
						c = draw_cadaver("cemetery")
				cards.append(c)
			if mod.get("fresh", false):
				for c in cards:
					c.mats = c.mats.map(func(m): return [m[0], 0 if m[0] == "bone" else 1, m[2]])
					c.stage = 1
			await resolve_cadavers(i, cards, {"title": "Graveyard", "intro": "You dig by lantern light.", "noCardCost": mod.get("fresh", false) or mod.get("two", false),
				"flatCost": 1 if mod.get("fresh", false) else 0, "extraH": 1 if S.ev == "toussaint" else 0})
		"square.buy":
			p.coin -= 1
			var card = null
			for c in S.square:
				if c.id == pre.get("card", -1):
					card = c
			if card == null:
				card = S.square[0]
			S.square.erase(card)
			if pre.get("bury", false):
				var c = find_card(p, "burial")
				if c != null:
					discard(p, c)
					apply_gain(p, c.gain)
					log_line("%s gives %s a decent burial." % [B(p), card.name])
					return
			if card.cost:
				p.coin = maxi(0, p.coin - card.cost)
			await resolve_cadavers(i, [card], {"title": "Public Square", "intro": "The crowd has gone home.", "single": true})
		"morgue.buy":
			p.coin -= 1
			var n = 2 + (1 if S.ev == "cholera" else 0)
			var cards = []
			for k in n:
				cards.append(draw_cadaver("morgue"))
			await resolve_cadavers(i, cards, {"title": "Morgue", "intro": "The keeper pulls back the sheets.", "extraH": 1 if S.ev == "toussaint" else 0})
		"slaughter.take":
			var three: bool = pre.get("opt", "four") == "three"
			if three:
				add_mat(p, "animal", 1, 3)
			else:
				add_mat(p, "animal", 2, 4)
			if S.ev == "meat":
				add_mat(p, "animal", 1 if three else 2, 2)
				p.coin += 1
			log_line("%s takes %s from the Slaughterhouse%s." % [B(p), "3 animal at stage I" if three else "4 animal at stage II", ", plus 2 more and 1 franc" if S.ev == "meat" else ""])
		"hospital.retrieve":
			var lim = hosp_limits(p)
			var want_ids: Array = pre.get("cards", [])
			var want: int = want_ids.size() if want_ids.size() else maxi(1, lim.free)
			want = mini(want, mini(lim.free + lim.paid, S.hosp.size()))
			while want > lim.free and p.coin < want - lim.free:
				want -= 1
			p.coin -= maxi(0, want - lim.free)
			var chosen = []
			for id in want_ids:
				for c in S.hosp:
					if c.id == id and chosen.size() < want:
						chosen.append(c)
			for c in S.hosp:
				if chosen.size() >= want:
					break
				if not chosen.has(c):
					chosen.append(c)
			S.hosp = S.hosp.filter(func(c): return not chosen.has(c))
			var cards = chosen.duplicate()
			for k in mod.get("extra", 0):
				cards.append(draw_cadaver("hospital"))
			await resolve_cadavers(i, cards, {"title": "Hospital", "intro": "The porter wheels out the dead.", "extraH": 1 if S.ev == "toussaint" else 0})
		"hospital.work":
			var g: int = (4 if p.exp >= 13 else 3 if p.exp >= 7 else 2) + (2 if S.ev == "cholera" else 0)
			p.coin += g
			log_line("%s works a shift at the Hospital: +%s." % [B(p), fr(g)])
		"hospital.volunteer":
			set_hum(p, 1)
			set_rep(p, 2)
			log_line("%s volunteers on the wards: +1 humanity, +2 reputation." % B(p))
		"academy.adv":
			set_exp(p, 1)
			take_row_card(p, "researchRow", pre.get("card", -1))
			if S.ev == "grant":
				p.coin += 2
			log_line("%s does advanced research: +1 expertise and a research card." % B(p))
		"academy.research":
			take_row_card(p, "researchRow", pre.get("card", -1))
			if S.ev == "grant":
				p.coin += 2
			log_line("%s takes a research card." % B(p))
		"academy.lecture":
			var pc: String = str(pre.get("card", "")) if pre.get("card") != null else ""
			if pc != "":
				var c = find_card(p, pc)
				if c != null and (c.id == "animal" or c.id == "human"):
					discard(p, c)
					apply_gain(p, c.gain, "humanity")
					log_line("%s lectures on %s: +3 humanity." % [B(p), "mercy for beasts" if c.id == "animal" else "the dignity of the dead"])
					if S.ev == "grant":
						p.coin += 2
					return
			var r = 1 + (1 if sci else 0)
			if S.ev != "hardtimes":
				p.coin += 1
			set_rep(p, r)
			if S.ev == "grant":
				p.coin += 2
			if pc == "guest":
				var c = find_card(p, "guest")
				if c != null:
					discard(p, c)
					apply_gain(p, c.gain, "research")
			log_line("%s lectures at the Academy: +%d reputation." % [B(p), r])
		"academy.donate":
			var n: int = clampi(pre.get("n", 1), 1, mini(3, p.coin))
			p.coin -= n
			set_rep(p, n)
			log_line("%s donates %s: +%d reputation." % [B(p), fr(n), n])
		"market.trade":
			do_market(i, pre)
		"docks.hire":
			await hire_scoundrel(i, pre.get("card", -1), pre.get("how", "mats"), S.docks, pre.get("unethical", false))
		"alley.murder":
			p.lastDark = S.round
			if pre.get("unethical", false):
				var c = find_card(p, "unethical")
				if c != null and charged(p):
					discharge_one(p)
					discard(p, c)
					set_hum(p, -3)
					add_police(p)
					apply_gain(p, c.gain, "research")
					log_line("%s conducts an unethical experiment in the Dark Alley." % B(p))
					return
			gain_mats(p, [["muscle", 1, 4], ["organ", 1, 4], ["blood", 1, 3], ["bone", 0, 2]])
			set_hum(p, -3)
			add_police(p)
			log_line("%s commits murder in the Dark Alley and earns a police marker." % B(p))
		"church.atone":
			take_row_card(p, "humanityRow", pre.get("card", -1))
			if sci:
				set_hum(p, 1)
			log_line("%s atones at Saint-Roch%s a humanity card." % [B(p), ": +1 humanity and" if sci else ", taking"])
		"first.first":
			take_first(i)
			log_line("%s becomes first player." % B(p))
		"odeon.show":
			p.odeonUsed = true
			set_rep(p, 2)
			log_line("%s is seen at the Odéon: +2 reputation." % B(p))

## Takes a card from a face-up row. No refill during the day: the rows are dealt again at dawn.
func take_row_card(p: Dictionary, row: String, card_uid) -> void:
	var r: Array = S[row]
	if r.is_empty():
		return
	var idx = 0
	for k in r.size():
		if r[k].uid == card_uid:
			idx = k
	var c: Dictionary = r[idx]
	r.remove_at(idx)
	add_card(p, c)
	if p.ai:
		ai_maybe_play(S.players.find(p))

func resolve_lab(i: int, s: String, kind: String, pre: Dictionary) -> void:
	var p: Dictionary = S.players[i]
	match s:
		"practice":
			set_exp(p, 1)
			log_line("%s practises: +1 expertise." % B(p))
		"blood":
			if pre.get("transfusion", false):
				var c = find_card(p, "transfusion")
				if c != null:
					discard(p, c)
					apply_gain(p, c.gain, "research")
					log_line("%s performs a transfusion." % B(p))
					return
			add_mat(p, "blood", 1, 3)
			log_line("%s gives blood: 3 blood at stage I." % B(p))
		"repair":
			var r = 3
			for sl in D.SLOT6:
				var t = p.table[sl]
				if t != null and t.dmg and r > 0:
					var k: int = mini(r, t.dmg)
					t.dmg -= k
					r -= k
			log_line("%s repairs the parts on the table." % B(p))
		"charge":
			var r = 3 if kind == "scientist" else 2
			for k in p.jars.size():
				if not p.jars[k] and r > 0:
					p.jars[k] = true
					r -= 1
			log_line("%s charges Leyden jars." % B(p))
	check_objectives()


# ---------------------------------------------------------------- cadavers

func resolve_cadavers(i: int, cards: Array, o: Dictionary) -> void:
	var p: Dictionary = S.players[i]
	if cards.is_empty():
		return
	var picks: Dictionary
	if p.ai or S.fast:
		picks = ai_cadaver_picks(p, cards, o)
	else:
		picks = await ui.cadaver_picks(p, cards, o)
	var flat_paid = false
	for c in cards:
		var pk: Dictionary = picks.get(c.id, {"how": "leave"})
		if pk.how == "leave":
			continue
		var hc: int = 0 if o.get("noCardCost", false) else c.hcost + o.get("extraH", 0)
		if o.get("flatCost", 0) and not flat_paid:
			set_hum(p, -o.flatCost)
			flat_paid = true
		if hc:
			set_hum(p, -hc)
		var card = find_card(p, pk.card) if pk.get("card") != null else null
		if card != null and (card.id == "dissect" or card.id == "electro"):
			if card.id == "electro":
				discharge_one(p)
			discard(p, card)
			apply_gain(p, card.gain, "research")
			log_line("%s studies %s closely (%s)." % [B(p), c.name, card.name])
			continue
		var mats: Array = c.mats
		if card != null and card.id == "daisy":
			discard(p, card)
			apply_gain(p, card.gain, "research")
			mats = mats.map(func(m): return [m[0], 0 if m[0] == "bone" else 1, m[2]])
		if pk.how == "exp" and c.exp:
			set_exp(p, c.exp)
			log_line("%s dissects %s: +%d expertise." % [B(p), c.name, c.exp])
		else:
			gain_mats(p, mats)
			log_line("%s takes %s: %s." % [B(p), c.name, mats_text(mats)])
	check_objectives()


# ---------------------------------------------------------------- scoundrels and market

func hire_scoundrel(i: int, card_id, how: String, row: Array, unethical := false) -> void:
	var p: Dictionary = S.players[i]
	var c = null
	for x in row:
		if x.id == card_id:
			c = x
	if c == null:
		return
	var cost = sc_cost(c)
	if cost > p.coin:
		return
	p.coin -= cost
	set_hum(p, -sc_hcost(c))
	if row == S.docks:
		S.docks[S.docks.find(c)] = draw_scoundrel()
	if c.sk == "cut":
		p.lastDark = S.round
	if unethical and c.sk == "cut":
		var u = find_card(p, "unethical")
		if u != null and charged(p):
			discharge_one(p)
			discard(p, u)
			apply_gain(p, u.gain, "research")
			log_line("%s hires a Cutthroat for an unethical experiment." % B(p))
			return
	if c.sk == "thief":
		var cards = []
		for k in c.draw:
			cards.append(S.hosp.pop_front() if S.hosp.size() else draw_cadaver("hospital"))
		log_line("%s hires a Hospital Thief, who steals %d %s from the Hospital (no reputation needed)." % [B(p), cards.size(), "body" if cards.size() == 1 else "bodies"])
		await resolve_cadavers(i, cards, {"title": "Hospital Thief", "intro": "The thief wheels in a covered trolley.", "extraH": 0})
		return
	if how == "exp" and c.get("exp", 0):
		set_exp(p, c.exp)
		if c.get("expH", 0):
			set_hum(p, -c.expH)
		log_line("%s hires a %s: +%d expertise." % [B(p), c.name, c.exp])
	elif how == "hum" and c.get("hum", 0):
		set_hum(p, c.hum)
		log_line("%s hires a %s and lets the dogs go: +%d humanity." % [B(p), c.name, c.hum])
	else:
		gain_mats(p, c.mats)
		log_line("%s hires a %s: %s." % [B(p), c.name, mats_text(c.mats)])

func do_market(i: int, o: Dictionary) -> void:
	var p: Dictionary = S.players[i]
	var bits = []
	var sb: int = mini(o.get("sellBone", 0), p.bone / 2)
	if sb:
		p.bone -= 2 * sb
		p.coin += sb
		bits.append("sells %d bone" % (2 * sb))
	var sp: int = mini(o.get("sellPres", 0), p.preserved / 3)
	if sp:
		p.preserved -= 3 * sp
		var g = 2 * sp
		var pk = find_card(p, "preserve") if o.get("pickle", false) else null
		if pk != null:
			discard(p, pk)
			g += sp
		p.coin += g
		bits.append("sells %d preserved flesh" % (3 * sp))
	var bj: int = mini(o.get("jars", 0), 4 - p.jars.size())
	var paid = 0
	for k in bj:
		var free: bool = S.ev == "hardtimes" and k % 2 == 1
		if not free:
			if p.coin < 2:
				break
			p.coin -= 2
		p.jars.append(S.ev in ["storm", "meat", "graves", "cholera", "darkres", "storm2"])
		paid += 1
	if paid:
		bits.append("buys %d jar%s" % [paid, "s" if paid > 1 else ""])
	if o.get("ice", false) and p.coin >= 1:
		p.coin -= 1
		p.ice = 2
		bits.append("buys ice")
	log_line("%s at the Market %s." % [B(p), ", ".join(bits) if bits.size() else "browses"])


# ---------------------------------------------------------------- first player's meeple

func first_move_phase() -> void:
	if not S.occ.has("first.first"):
		return
	var o: Dictionary = S.occ["first.first"]
	var i: int = o.p
	var p: Dictionary = S.players[i]
	var keys = []
	for k in space_list():
		if k == "first.first":
			continue
		p.left[o.kind] += 1
		var ok = can_place(i, k, o.kind)
		p.left[o.kind] -= 1
		if ok:
			keys.append(k)
	if keys.is_empty():
		return
	var key = null
	var pre = null
	if p.ai:
		var c = ai_choose(i, keys, o.kind)
		if c != null and c.s > 2.5:
			key = c.key
			pre = c.pre
	elif not S.fast:
		var opts = []
		for k in keys:
			opts.append({"label": "%s: %s" % [LOC[SPACE[k].loc].name, SPACE[k].n], "sub": ("Bump " + S.players[S.occ[k].p].name) if S.occ.has(k) else "", "value": k})
		opts.append({"label": "Stay put", "value": null})
		key = await ui.ask({"title": "The first player’s meeple", "text": "Everyone has finished. You may move your meeple from the First Player space to another space and use it.", "options": opts, "locked": true})
		if key != null:
			pre = await ui.human_pre(key, o.kind, true)
			if pre == null:
				key = null
	if key == null:
		return
	S.occ.erase("first.first")
	p.left[o.kind] += 1
	log_line("%s moves their meeple from the First Player space." % B(p))
	await place_and_resolve(i, key, o.kind, pre)
	save()
	sync()


# ================================================================ lab phase (night)

func lab_phase() -> void:
	log_line("Night. The laboratories light their lamps.", "day")
	for i in S.players.size():
		var p: Dictionary = S.players[i]
		if p.ai and not p.labDone:
			ai_lab(i)
			p.labDone = true
	save()
	sync()
	if not S.players[0].ai:
		await ui.human_night()
	if S.players.any(func(p): return alive_count(p) == 6):
		finish("alive")
		return
	S.phase = "dawn"
	save()

func next_step(p, slot: String):
	var t = p.table[slot]
	if t == null:
		return "start"
	return "comp" if t.side == "muscle" else null

## What building a step of a part would use and score. policy "fresh" uses the freshest materials first, "old" the oldest.
func plan_build(p, slot: String, policy: String, opts := {}):
	var type: String = D.SLOT_T[slot]
	var step = next_step(p, slot)
	if step == null:
		return null
	var P: Dictionary = D.PARTS[type]
	var req: Dictionary = (P.start if step == "start" else P.comp).duplicate()
	if opts.get("steady", false):
		for k in req:
			req[k] = maxi(0, req[k] - 1)
	var sg = opts.get("surgeon", false)
	if sg:
		var k: String = sg if sg is String and req.get(sg, 0) > 0 else ""
		if k == "":
			var best = -1
			for kk in req:
				if req[kk] > best:
					best = req[kk]
					k = kk
		req[k] = maxi(0, req[k] - 1)
	var m: Dictionary = p.mats.duplicate(true)
	var bone: int = p.bone
	var worst = 0
	var animal = 0
	var ok = true
	var order = [3, 2, 1, 0] if policy == "old" else [0, 1, 2, 3]
	for k in req:
		var n: int = req[k]
		if not n:
			continue
		if k == "X":
			if bone < n:
				ok = false
				break
			bone -= n
			continue
		var t: String = D.KEY[k]
		for st in order:
			var take: int = mini(n, m[t][st])
			if take:
				m[t][st] -= take
				n -= take
				worst = maxi(worst, st + 1)
			if not n:
				break
		if n:
			var allowed: Array = order.filter(func(s): return s <= 1) if t == "blood" else order
			for st in allowed:
				var take: int = mini(n, m.animal[st])
				if take:
					m.animal[st] -= take
					n -= take
					animal += take
					worst = maxi(worst, st + 1)
				if not n:
					break
		if n:
			ok = false
			break
	var exp_ok: bool = p.exp >= P.exp
	var table: Array = P.vpS if step == "start" else P.vpC
	var vp: int = maxi(0, table[maxi(1, worst) - 1] - (2 if animal >= 3 else 1 if animal else 0)) if ok else 0
	return {"ok": ok and exp_ok, "matsOK": ok, "expOK": exp_ok, "step": step, "req": req, "vp": vp, "worst": worst, "animal": animal, "mats": m, "bone": bone}

func build(i: int, slot: String, policy: String, opts := {}):
	var p: Dictionary = S.players[i]
	if S.phase != "lab":
		return null
	opts = opts.duplicate()
	if opts.get("steady", false) and not has_card(p, "steady"):
		opts.steady = false
	if opts.get("surgeon", false) and (not has_char(p, "surgeon") or p.surgeonUsed):
		opts.surgeon = false
	var pl = plan_build(p, slot, policy, opts)
	if pl == null or not pl.ok:
		return null
	p.mats = pl.mats
	p.bone = pl.bone
	if opts.get("steady", false):
		var c = find_card(p, "steady")
		discard(p, c)
		apply_gain(p, c.gain, "research")
	if opts.get("surgeon", false):
		p.surgeonUsed = true
	if pl.step == "start":
		p.table[slot] = {"side": "muscle", "alive": false, "dmg": 0}
	else:
		p.table[slot].side = "skin"
	p.vp += pl.vp
	set_exp(p, 1)
	log_line("%s %s the %s (+%d VP)." % [B(p), "starts" if pl.step == "start" else "completes", D.SLOT_N[slot].to_lower(), pl.vp])
	check_objectives()
	return pl

func preserve(p, t: String, n: int) -> int:
	n = mini(n, 9 - p.preserved)
	var moved = 0
	for st in range(3, -1, -1):
		if moved >= n:
			break
		var k: int = mini(n - moved, p.mats[t][st])
		p.mats[t][st] -= k
		moved += k
	p.preserved += moved
	return moved

func place_damage(p):
	var parts = on_table(p)
	if parts.is_empty():
		return null
	var min_d: int = parts.map(func(s): return p.table[s].dmg).min()
	var cands = parts.filter(func(s): return p.table[s].dmg == min_d)
	cands.sort_custom(func(a, b): return _rank_part(p, a) < _rank_part(p, b))
	var s: String = cands[0]
	var t: Dictionary = p.table[s]
	t.dmg += 1
	var nm: String = D.SLOT_N[s].to_lower()
	if t.dmg >= 2:
		t.dmg = 0
		if t.alive:
			t.alive = false
			return "The %s dies again." % nm
		if t.side == "skin":
			t.side = "muscle"
			return "The %s splits its skin." % nm
		p.table[s] = null
		return "The %s is destroyed." % nm
	return null

func can_throw(p) -> bool:
	return S.phase == "lab" and not p.thrown and charged(p) > 0 and D.SLOT6.any(func(s): return p.table[s] != null and p.table[s].side == "skin")

func roll_dice(p, n: int, extra_gray: int) -> Array:
	var nd = 2 * n
	var blue: int = mini(nd, blue_dice(p))
	var dice = []
	for d in nd:
		dice.append({"c": "blue", "f": pick(D.BLUE)} if d < blue else {"c": "gray", "f": pick(D.GRAY)})
	for k in extra_gray:
		dice.append({"c": "gray", "f": pick(D.GRAY)})
	return dice

func reroll(d: Dictionary) -> void:
	d.f = pick(D.BLUE if d.c == "blue" else D.GRAY)

func apply_mitigation(dice: Array, mit: String, st: Dictionary) -> void:
	match mit:
		"ignoreDmg": st.ignoreDmg = true
		"ignoreHeart": st.ignoreHeart = true
		"rerollAny":
			for d in dice:
				if d.f != "alive":
					reroll(d)
		"rerollDmg":
			for d in dice:
				if d.f == "damage":
					reroll(d)
		"rerollGray":
			for d in dice:
				if d.c == "gray" and d.f != "alive":
					reroll(d)
		"rerollBlue":
			for d in dice:
				if d.c == "blue" and d.f != "alive":
					reroll(d)
		"willing":
			var k = 0
			for d in dice:
				if k < 2 and d.f in ["damage", "heart", "blank"]:
					reroll(d)
					k += 1

func resolve_throw(i: int, dice: Array, st: Dictionary) -> Array:
	var p: Dictionary = S.players[i]
	var cnt = func(f): return dice.filter(func(d): return d.f == f).size()
	var notes = []
	var dmg: int = 0 if st.get("ignoreDmg", false) else cnt.call("damage")
	for d in dmg:
		var r = place_damage(p)
		if r != null:
			notes.append(r)
	if cnt.call("heart") and not st.get("ignoreHeart", false):
		if set_hum(p, -1):
			notes.append("The screams cost you 1 humanity.")
	var lit = []
	for a in cnt.call("alive"):
		var cands: Array = D.SLOT6.filter(func(s): return p.table[s] != null and p.table[s].side == "skin" and not p.table[s].alive)
		if cands.is_empty():
			break
		cands.sort_custom(func(x, y): return D.PARTS[D.SLOT_T[x]].alive > D.PARTS[D.SLOT_T[y]].alive)
		p.table[cands[0]].alive = true
		lit.append(D.SLOT_N[cands[0]].to_lower())
	if lit.size():
		notes.push_front("Alive: %s." % ", ".join(lit))
	log_line("%s throws the switch. %s" % [B(p), ("It lives: %s." % ", ".join(lit)) if lit.size() else "Nothing stirs."])
	check_objectives()
	return notes

func start_throw(i: int, n: int, use_zoo: bool) -> Array:
	var p: Dictionary = S.players[i]
	n = clampi(n, 1, mini(3, charged(p)))
	var k = n
	for j in p.jars.size():
		if p.jars[j] and k > 0:
			p.jars[j] = false
			k -= 1
	p.thrown = true
	var extra = 1 if use_zoo and has_char(p, "zoo") and not p.zooUsed else 0
	if extra:
		p.zooUsed = true
	var dice = roll_dice(p, n, extra)
	if p.sabotaged and dice.size():
		dice.remove_at(rnd(dice.size()))
		p.sabotaged -= 1
		log_line("Cut wires: %s loses a die." % p.name)
	return dice

## You throw the switch with n jars. The presenter shows the dice and offers research cards to change them.
func human_throw(n: int) -> void:
	var p: Dictionary = S.players[0]
	if not can_throw(p):
		return
	var dice = start_throw(0, n, true)
	var st = {}
	var willing: bool = S.ev == "willing"
	var rolled = indices(dice.size())
	while true:
		var opts = []
		if willing:
			opts.append({"label": "The Flesh Is Willing", "sub": "Re-roll up to 2 bad dice, free.", "value": "willing"})
		for c in p.hand:
			if c.kind == "research":
				opts.append({"label": "%s: %s" % [c.name, D.MIT_N[c.mit]], "sub": "Discards the card.", "value": c.id})
		var choice = await ui.throw_dialog(dice, st, rolled, opts)
		if choice == "ok" or choice == null:
			break
		var before = dice.map(func(d): return d.f)
		if choice == "willing":
			apply_mitigation(dice, "willing", st)
			willing = false
		else:
			var c = find_card(p, choice)
			if c != null:
				discard(p, c)
				apply_mitigation(dice, c.mit, st)
		rolled = indices(dice.size()).filter(func(k): return dice[k].f != before[k])
	var notes = resolve_throw(0, dice, st)
	save()
	sync()
	await ui.throw_result(notes, dice.any(func(d): return d.f == "alive"))


# ================================================================ dawn

func decay(p) -> void:
	for t in D.MATS:
		var a: Array = p.mats[t]
		p.mats[t] = [0, a[0], 0 if t == "blood" else a[1], a[2]]

func dawn_phase() -> void:
	log_line("Dawn.", "day")
	for p in S.players:
		var before: int = 0
		for t in D.MATS:
			before += p.mats[t][3]
		before += p.mats.blood[1]
		if p.ice > 0:
			p.ice -= 1
			if not p.ai:
				S.dawn.append("Your ice keeps everything fresh. It is half melted now." if p.ice else "Your ice keeps everything fresh, then melts away.")
		else:
			decay(p)
			if before and not p.ai:
				S.dawn.append("%d of your materials rotted away." % before)
	refresh_board()
	S.captain += 1
	if S.captain >= D.MAX_ROUNDS:
		finish("captain")
		return
	S.round += 1
	S.phase = "event"
	save()
	sync()
	if not S.players[0].ai and not S.fast:
		var lines: Array = S.dawn if S.dawn.size() else ["A grey dawn. Your materials have aged one stage."]
		var steps: int = D.MAX_ROUNDS - S.captain
		await ui.dawn_report(S.round, lines, "Captain Walton is %d step%s from the Creature. %s is first player." % [steps, "" if steps == 1 else "s", S.players[S.first].name])


# ================================================================ cards in hand

func card_playable(i: int, c: Dictionary, human_turn_open := false) -> bool:
	var p: Dictionary = S.players[i]
	var day: bool = S.phase == "day"
	var lab: bool = S.phase == "lab"
	var my_turn: bool = day and S.cur == i and (human_turn_open if not p.ai else true)
	if c.kind == "research":
		if c.when == "any":
			if c.get("effect", "") == "demo":
				return charged(p) > 0 and mat_total(p, "animal") >= 2
			if c.get("effect", "") == "heal":
				return true
			return day or lab
		if c.id == "midnight":
			return my_turn and S.occ.keys().any(func(k): return S.occ[k].p == i and k != "first.first")
		if c.id == "publish":
			return my_turn and p.left.scientist > 0
		return false
	if c.when == "aid":
		return (day or S.phase == "event") and not p.aidPlayed and S.round < 11 and p.coin >= c.cost
	if c.when == "any":
		if c.get("effect", "") == "thwart":
			return day and S.thwart == null
		return day
	if c.when == "target":
		var others = indices(S.players.size()).filter(func(k): return k != i and (c.get("effect", "") != "burn" or S.players[k].hand.filter(func(h): return h.kind == "research").size() >= 2))
		return (day or lab) and others.size() > 0
	return false

func card_targets(i: int, c: Dictionary) -> Array:
	return indices(S.players.size()).filter(func(k): return k != i and (c.get("effect", "") != "burn" or S.players[k].hand.filter(func(h): return h.kind == "research").size() >= 2))

func play_card(i: int, card_id: String, target = null, human_turn_open := false) -> bool:
	var p: Dictionary = S.players[i]
	var c = find_card(p, card_id)
	if c == null or not card_playable(i, c, human_turn_open):
		return false
	if c.when == "target":
		if target == null:
			return false
		var q: Dictionary = S.players[target]
		discard(p, c)
		apply_gain(p, c.gain, "humanity")
		var ctr = find_card(q, "counter")
		if ctr != null:
			discard(q, ctr)
			apply_gain(q, ctr.gain, "research")
			log_line("%s plays %s on %s, who had Countermeasures ready. Cancelled." % [B(p), c.name, q.name])
			return true
		match c.get("effect", ""):
			"sabotage":
				q.sabotaged += 1
				log_line("%s cuts %s’s wires: their next throw loses a die." % [B(p), q.name])
			"snatch":
				var took = []
				for t in ["muscle", "organ", "blood", "animal"]:
					if took.size() >= 3:
						break
					for st in 4:
						if q.mats[t][st] > 0:
							q.mats[t][st] -= 1
							took.append(t)
							break
				if took.size() < 3 and q.bone > 0:
					q.bone -= 1
					took.append("bone")
				log_line("%s sends urchins into %s’s lab: %d materials gone." % [B(p), q.name, took.size()])
			"burn":
				var rs: Array = q.hand.filter(func(h): return h.kind == "research")
				var b: Dictionary = pick(rs)
				discard(q, b)
				log_line("%s’s lantern burns %s’s %s." % [B(p), q.name, b.name])
		if not q.ai and not S.fast and i != 0:
			ui.toast("%s played %s on you." % [p.name, c.name])
		return true
	discard(p, c)
	if c.kind == "research":
		var eff: String = c.get("effect", "")
		if eff == "demo":
			discharge_one(p)
			var n = 2
			for st in range(3, -1, -1):
				var k: int = mini(n, p.mats.animal[st])
				p.mats.animal[st] -= k
				n -= k
		if eff == "heal":
			for s in D.SLOT6:
				if p.table[s] != null:
					p.table[s].dmg = 0
		if eff == "publish":
			p.left.scientist -= 1
		if c.id == "midnight":
			# The human then picks a space to use again: the UI calls midnight_oil(0) after this returns.
			apply_gain(p, c.gain, "research")
			log_line("%s burns the candle at both ends." % B(p))
			return true
		apply_gain(p, c.gain, "research")
		log_line("%s plays %s%s." % [B(p), c.name, (": " + gain_text(c.gain)) if gain_text(c.gain) != "" else ""])
	else:
		if c.get("aid", 0):
			p.coin -= c.cost
			p.aidPlayed = true
			S.captain = mini(D.MAX_ROUNDS - 1, S.captain + 1)
			S.removed.append(c.id)
			log_line("%s helps Captain Walton. He moves 1 step closer to the Creature." % B(p))
		for l in c.get("close", []):
			S.closed[l] = 1
		if c.get("effect", "") == "clearHosp":
			S.hosp = []
		if c.get("effect", "") == "thwart":
			S.thwart = i
		apply_gain(p, c.gain, "humanity")
		log_line("%s plays %s%s." % [B(p), c.name, (": " + gain_text(c.gain)) if gain_text(c.gain) != "" else ""])
	check_objectives()
	return true

func midnight_oil(i: int) -> void:
	var keys = S.occ.keys().filter(func(k): return S.occ[k].p == i and k != "first.first")
	var opts = []
	for k in keys:
		opts.append({"label": "%s: %s" % [LOC[SPACE[k].loc].name, SPACE[k].n], "value": k})
	var key = await ui.ask({"title": "Burning the Candle", "text": "Use one of your placed meeples’ spaces again. You pay its costs again.", "options": opts, "buttons": [{"label": "Never mind", "value": null}]})
	if key == null:
		return
	var pre = await ui.human_pre(key, S.occ[key].kind, true)
	if pre == null:
		return
	var need = space_needs(0, key)
	if need != null and S.players[0].coin < need:
		return
	await resolve_space(0, key, S.occ[key].kind, pre, {})
	save()
	sync()


# ================================================================ scoring

func finish(reason: String) -> void:
	S.phase = "end"
	S.endReason = reason
	var n: int = S.players.size()
	if S.objectives.has("rich"):
		var m: int = S.players.map(func(p): return p.coin).max()
		for k in n:
			var i: int = (S.first + k) % n
			if S.players[i].coin == m:
				S.claimed.rich = i
				break
	var hum_top: int = S.players.map(func(p): return p.hum).max()
	var rows = []
	for i in n:
		var p: Dictionary = S.players[i]
		var alive_pts = 0
		for s in D.SLOT6:
			if p.table[s] != null and p.table[s].alive:
				alive_pts += D.PARTS[D.SLOT_T[s]].alive
		var obj: int = S.claimed.values().filter(func(k): return k == i).size() * 10
		var capt = 5 if reason == "captain" and p.hum == hum_top and hum_top > 0 else 0
		var row = {"i": i, "name": p.name, "color": p.color, "vp": p.vp, "alivePts": alive_pts, "obj": obj,
			"repPts": p.maxRep / 2, "expPts": p.maxExp / 3, "humPts": p.hum, "capt": capt, "alive": alive_count(p), "coin": p.coin}
		row.total = row.vp + alive_pts + obj + row.repPts + row.expPts + row.humPts + capt
		rows.append(row)
	rows.sort_custom(func(a, b):
		if a.total != b.total:
			return a.total > b.total
		if a.alive != b.alive:
			return a.alive > b.alive
		return a.coin > b.coin)
	S.final = {"rows": rows, "reason": reason, "round": S.round}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


# ================================================================ AI

func ai_needs(p) -> Dictionary:
	var steps = []
	for s in D.SLOT6:
		var st = next_step(p, s)
		if st == null:
			continue
		var P: Dictionary = D.PARTS[D.SLOT_T[s]]
		steps.append({"s": s, "st": st, "req": P.start if st == "start" else P.comp, "exp": P.exp})
	steps.sort_custom(func(a, b):
		var ca = 0 if a.st == "comp" else 1
		var cb = 0 if b.st == "comp" else 1
		if ca != cb:
			return ca < cb
		return a.exp < b.exp)
	var near = steps.filter(func(x): return x.exp <= p.exp + 4).slice(0, 2)
	var need = {"M": 0, "O": 0, "B": 0, "X": 0}
	for x in near:
		for k in x.req:
			need[k] += x.req[k]
	var have = {"M": mat_total(p, "muscle"), "O": mat_total(p, "organ"), "B": p.mats.blood[0] + p.mats.blood[1], "X": p.bone}
	var ani = total(p.mats.animal)
	var short = {}
	for k in ["M", "O", "B", "X"]:
		var s: int = maxi(0, need[k] - have[k])
		if k != "X":
			var u: int = mini(s, ani)
			s -= u
			ani -= u
		short[k] = s
	var bigger = steps.filter(func(x): return x.exp > p.exp)
	bigger.sort_custom(func(a, b): return a.exp < b.exp)
	var exp_gap: int = bigger[0].exp - p.exp if bigger.size() else 0
	var skin_not_alive: int = D.SLOT6.filter(func(s): return p.table[s] != null and p.table[s].side == "skin" and not p.table[s].alive).size()
	return {"short": short, "expGap": exp_gap, "skinNotAlive": skin_not_alive, "totalShort": short.M + short.O + short.B + short.X}

func ai_cadaver_picks(p, cards: Array, o: Dictionary) -> Dictionary:
	var n = ai_needs(p)
	var P: Dictionary = p.persona
	var picks = {}
	for c in cards:
		var hc: int = 0 if o.get("noCardCost", false) else c.hcost + o.get("extraH", 0)
		if hc and not P.get("ruthless", 0) and p.hum <= -6:
			picks[c.id] = {"how": "leave"}
			continue
		var useful = 0.0
		for m in c.mats:
			var t: String = m[0]
			var hit: bool = (t == "muscle" and n.short.M) or (t == "organ" and n.short.O) or (t == "blood" and n.short.B) or (t == "bone" and n.short.X)
			useful += (m[2] if hit else m[2] * .4) * (.5 if m[1] >= 4 else 1.0)
		var how = "exp" if (n.expGap > 0 and c.exp >= 2 and useful < 3) else "mats"
		if not c.exp:
			how = "mats"
		var pk = {"how": how}
		if how == "mats" and c.stage >= 2 and has_card(p, "daisy"):
			pk.card = "daisy"
		picks[c.id] = pk
	return picks

func ai_best_scoundrel(p, row: Array):
	var n = ai_needs(p)
	var best = null
	for c in row:
		if sc_cost(c) > p.coin or not sc_allowed(c):
			continue
		var hc = sc_hcost(c)
		if c.sk == "thief":
			var s: float = 1.5 + c.draw * 1.6 * (1.0 if n.totalShort > 0 else .5) - sc_cost(c) * .6 - hc * .4
			if best == null or s > best.s:
				best = {"s": s, "c": {"card": c.id, "how": "mats"}}
			continue
		var mv = 0.0
		for m in c.get("mats", []):
			var t: String = m[0]
			var st: int = m[1]
			var hit: bool = ((t == "muscle" or t == "animal") and n.short.M) or (t == "organ" and n.short.O) or (t == "blood" and n.short.B) or (t == "bone" and n.short.X)
			mv += m[2] * (.5 if st >= 4 else .75 if st >= 3 else 1.0) * (.9 if hit else .35)
		var opts = [{"how": "mats", "v": mv}]
		if c.get("exp", 0):
			opts.append({"how": "exp", "v": c.exp * (1.6 if n.expGap > 0 else .6) - c.get("expH", 0) * .5})
		if c.get("hum", 0):
			opts.append({"how": "hum", "v": c.hum * (.9 if p.hum < 0 else .4)})
		for o in opts:
			var s: float = 1.2 + o.v * .6 - sc_cost(c) * .6 - hc * (.1 if p.persona.get("ruthless", 0) else .5)
			if best == null or s > best.s:
				best = {"s": s, "c": {"card": c.id, "how": o.how}}
	return best

func ai_space_options(i: int, key: String, kind: String) -> Array:
	var p: Dictionary = S.players[i]
	var P: Dictionary = p.persona
	var ru: int = P.get("ruthless", 0)
	var sch: int = P.get("scholar", 0)
	var car: int = P.get("careful", 0)
	var n = ai_needs(p)
	var sh: Dictionary = n.short
	var late: bool = S.round >= D.MAX_ROUNDS - 1
	var human_short: int = sh.M + sh.O
	var o = []
	match key:
		"cemetery.dig":
			o.append({"s": 2.2 + mini(human_short, 5) * .45 + mini(sh.X, 4) * .6 + ru * .5 - (2 if not ru and p.hum <= -5 else 0)})
		"square.buy":
			var c = S.square[0] if S.square.size() else null
			o.append({"s": 6.5, "pre": {"card": c.id if c != null else -1, "bury": p.hum < -3 and has_card(p, "burial")}})
		"morgue.buy":
			o.append({"s": 2.4 + mini(human_short, 5) * .5 + (.5 if car else 0.0)})
		"slaughter.take":
			o.append({"s": 1.1 + (1.8 if n.totalShort > 3 else 0.0) + (1.5 if S.ev == "meat" else 0.0), "pre": {"opt": "four"}})
		"hospital.retrieve":
			var lim = hosp_limits(p)
			var k: int = mini(S.hosp.size(), lim.free + (lim.paid if p.coin >= 2 else 0))
			if k == 0:
				k = 1
			var best: Array = S.hosp.duplicate()
			best.sort_custom(func(a, b): return a.mats.reduce(func(s, m): return s + m[2], 0) > b.mats.reduce(func(s, m): return s + m[2], 0))
			o.append({"s": 3.2 + mini(n.totalShort, 5) * .55 + (1.0 if sh.B else 0.0) + (1.0 if car else 0.0), "pre": {"cards": best.slice(0, k).map(func(c): return c.id)}})
		"hospital.work":
			o.append({"s": 4.0 if p.coin < 3 else 1.2})
		"hospital.volunteer":
			o.append({"s": 1.4 + (1.2 if p.hum < 0 else 0.0) + (1.8 if p.rep < 7 else 0.0) + (1.2 if p.rep >= 12 and p.rep < 15 else 0.0)})
		"academy.adv":
			var c = S.researchRow[0].uid if S.researchRow.size() else -1
			o.append({"s": (3 + mini(n.expGap, 6) * .3 + sch * 2) if n.expGap > 0 else (1.6 + sch), "pre": {"card": c}})
		"academy.research":
			var c = S.researchRow[0].uid if S.researchRow.size() else -1
			o.append({"s": 1.5 + sch * .5, "pre": {"card": c}})
		"academy.lecture":
			var rights = null
			for h in p.hand:
				if h.id == "animal" or h.id == "human":
					rights = h
			var guest = find_card(p, "guest")
			o.append({"s": 1.8 + (.5 if kind == "scientist" else 0.0) + (1.0 if late else 0.0) + (1.5 if S.ev == "grant" else 0.0) + (1.5 if guest != null else 0.0),
				"pre": {"card": guest.id if guest != null else (rights.id if rights != null and p.hum < -2 else null)}})
		"academy.donate":
			if p.coin >= 4:
				o.append({"s": 1.2 + (1.0 if late else 0.0) + (1.5 if p.rep >= 5 and p.rep < 7 else 0.0), "pre": {"n": mini(3, p.coin - 1)}})
		"market.trade":
			var want_jars: bool = p.jars.size() < 3 and p.coin >= 2 and on_table(p).size() >= 1
			var all_m = 0
			for t in D.MATS:
				all_m += total(p.mats[t])
			var many: bool = all_m >= 8 and p.ice == 0 and p.coin >= 1
			var sell_bone = 1 if p.bone > sh.X + 6 else 0
			var sell_pres: int = p.preserved / 3 if p.preserved >= 3 else 0
			if want_jars or many or sell_bone or sell_pres:
				o.append({"s": (3.2 if want_jars else 0.0) + (2.0 if many else 0.0) + sell_bone + sell_pres * 1.2,
					"pre": {"jars": mini(2, 3 - p.jars.size()) if want_jars else 0, "ice": many, "sellBone": sell_bone, "sellPres": sell_pres, "pickle": true}})
		"docks.hire":
			var b = ai_best_scoundrel(p, S.docks)
			if b != null:
				o.append({"s": b.s, "pre": b.c})
		"alley.murder":
			o.append({"s": 2 + ru * 3 + (1 if n.totalShort > 4 else 0) - (1.5 if p.police >= 1 else 0.0) - (3 if not ru and p.hum <= -3 else 0),
				"pre": {"unethical": n.expGap > 3 and has_card(p, "unethical") and charged(p) > 1}})
		"church.atone":
			var c = S.humanityRow[0].uid if S.humanityRow.size() else -1
			o.append({"s": ((2 + (-p.hum) * .3) if p.hum < 0 else 1.1) + (.4 if kind == "scientist" else 0.0), "pre": {"card": c}})
		"first.first":
			o.append({"s": 1.6 + (0.0 if S.round >= D.MAX_ROUNDS - 2 else .5)})
		"odeon.show":
			o.append({"s": 3.0})
		"lab.practice":
			o.append({"s": (2.2 + sch) if n.expGap > 0 else .8})
		"lab.blood":
			o.append({"s": (3.2 + sh.B * .4) if sh.B > 0 else .4, "pre": {"transfusion": n.expGap > 0 and has_card(p, "transfusion") and sh.B == 0}})
		"lab.repair":
			o.append({"s": 2 + dmg_total(p) * 1.2})
		"lab.charge":
			o.append({"s": (3 + p.jars.filter(func(j): return not j).size() * .6) if (n.skinNotAlive or on_table(p).size() >= 2) else .3})
	return o

func ai_choose(i: int, keys: Array, force_kind := ""):
	var p: Dictionary = S.players[i]
	var best = null
	for key in keys:
		var kinds = [force_kind] if force_kind != "" else ["assistant", "scientist"]
		for kind in kinds:
			if force_kind == "" and not can_place(i, key, kind):
				continue
			for o in ai_space_options(i, key, kind):
				var b = bump_info(i, key) if not key.begins_with("lab.") else {"cost": 0}
				if b == null:
					b = {"cost": 0}
				var sp_sci: bool = (SPACE[key].get("sci", 0) if SPACE.has(key) else LABSPOT[key.substr(4)].get("sci", 0)) == 1
				var s: float = o.s + randf() * 1.2 - b.cost * .8 - (.5 if kind == "scientist" and p.left.assistant and not sp_sci else 0.0)
				if best == null or s > best.s:
					best = {"key": key, "kind": kind, "pre": o.get("pre", {}), "s": s}
	return best

func ai_maybe_play(i: int) -> void:
	var p: Dictionary = S.players[i]
	for c in p.hand.duplicate():
		if not card_playable(i, c):
			continue
		if c.kind == "research" and c.when == "any":
			if c.get("effect", "") == "heal" and dmg_total(p) == 0:
				continue
			if c.get("effect", "") == "demo" and p.hum < -4:
				continue
			play_card(i, c.id)
			continue
		if c.get("aid", 0) and p.hum < 2 and p.coin >= c.cost + 2 and randf() < .25:
			play_card(i, c.id)
			continue
		if c.when == "target" and S.phase == "day" and randf() < .4:
			var others = card_targets(i, c)
			if others.size():
				others.sort_custom(func(a, b): return score(S.players[a]) > score(S.players[b]))
				play_card(i, c.id, others[0])
			continue
		if c.id == "thwart" and S.phase == "day" and randf() < .3:
			play_card(i, c.id)
			continue
		if (c.has("close") or c.get("effect", "") == "clearHosp") and S.phase == "day" and randf() < .2:
			play_card(i, c.id)
			continue

func ai_turn(i: int) -> void:
	var p: Dictionary = S.players[i]
	ai_maybe_play(i)
	if not left_n(p):
		return
	var keys = all_keys()
	var tries = 0
	while tries < 3:
		tries += 1
		var c = ai_choose(i, keys.filter(func(k): return can_place(i, k)))
		if c == null:
			p.left = {"scientist": 0, "assistant": 0}
			return
		if S.thwart != null and S.thwart != i and not c.key.begins_with("lab."):
			var by: Dictionary = S.players[S.thwart]
			S.thwart = null
			log_line("%s crosses %s’s path. They must go elsewhere." % [by.name, B(p)])
			var loc: String = SPACE[c.key].loc
			keys = keys.filter(func(k): return not SPACE.has(k) or SPACE[k].loc != loc)
			continue
		await place_and_resolve(i, c.key, c.kind, c.pre)
		return

func ai_lab(i: int) -> void:
	var p: Dictionary = S.players[i]
	for t in ["muscle", "organ"]:
		if p.mats[t][3] > 0:
			preserve(p, t, p.mats[t][3])
	var guard = 12
	while guard > 0:
		guard -= 1
		var best = null
		for s in D.SLOT6:
			for pol in ["fresh", "old"]:
				for steady in ([false, true] if has_card(p, "steady") else [false]):
					for surgeon in ([false, true] if has_char(p, "surgeon") and not p.surgeonUsed else [false]):
						var pl = plan_build(p, s, pol, {"steady": steady, "surgeon": surgeon})
						if pl != null and pl.ok:
							var v: float = pl.vp + (.5 if pol == "old" else 0.0) - (2 if steady else 0) - (.5 if surgeon else 0.0)
							if best == null or v > best.v:
								best = {"s": s, "pol": pol, "v": v, "steady": steady, "surgeon": surgeon}
		if best == null:
			break
		build(i, best.s, best.pol, {"steady": best.steady, "surgeon": best.surgeon})
	if can_throw(p):
		var dice = start_throw(i, mini(3, charged(p)), true)
		var st = {}
		if S.ev == "willing":
			apply_mitigation(dice, "willing", st)
		var dmg: int = dice.filter(func(d): return d.f == "damage").size()
		if dmg >= 1:
			var c = null
			for h in p.hand:
				if h.kind == "research" and h.mit in ["ignoreDmg", "rerollDmg", "rerollAny", "rerollGray"]:
					c = h
					break
			if c != null and (dmg >= 2 or on_table(p).any(func(s): return p.table[s].dmg)):
				discard(p, c)
				apply_mitigation(dice, c.mit, st)
		resolve_throw(i, dice, st)
	if has_char(p, "zoo") and not p.zooUsed and p.jars.has(false):
		p.zooUsed = true
		p.jars[p.jars.find(false)] = true
	if p.police >= 2 and p.coin >= 5:
		p.coin -= 3
		p.police = 0
		log_line("%s pays off the police." % B(p))


# ================================================================ persistence

func save() -> void:
	if S.is_empty() or S.fast or S.phase == "end":
		return
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(S))

static func load_saved():
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var s = JSON.parse_string(f.get_as_text())
	if s is Dictionary and s.get("v") == SAVE_V and s.get("phase") != "end":
		return _ints(s)
	return null
