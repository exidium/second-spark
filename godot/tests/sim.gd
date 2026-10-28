extends SceneTree
## AI-only simulation of the GDScript rules, like tests/sim.js for the web build.
## Usage: godot --headless --path godot --script res://tests/sim.gd -- 20

func _init() -> void:
	var n := 20
	for a in OS.get_cmdline_user_args():
		if a.is_valid_int():
			n = int(a)
	var data := Game.load_data()
	var endings := []
	var wins := {}
	var stuck := 0
	var alive_sum := 0
	var t0 := Time.get_ticks_msec()
	for g in n:
		var game := Game.new(data, NullPresenter.new())
		game.new_game("Sim", 3, "random", {"fast": true, "allAI": true})
		await game.run()
		var S := game.S
		if S.phase != "end":
			stuck += 1
			continue
		endings.append("%d%s" % [S.final.round, "A" if S.final.reason == "alive" else "C"])
		var w: String = S.final.rows[0].name
		wins[w] = wins.get(w, 0) + 1
		for p in S.players:
			alive_sum += game.alive_count(p)
	print("stuck games: ", stuck)
	print("endings (day + A=alive / C=captain): ", ", ".join(endings))
	print("wins: ", wins)
	print("average parts alive: %.2f" % (alive_sum / float(maxi(1, (n - stuck) * 4))))
	print("time: %d ms" % (Time.get_ticks_msec() - t0))
	quit(1 if stuck else 0)
