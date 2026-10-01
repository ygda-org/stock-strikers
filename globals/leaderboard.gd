extends Node

var leaderboards = []
var names = []
var new_best_score: int = -1

var save_path = "user://stock-strikers.save"

func _ready():
	if not FileAccess.file_exists(save_path):
		return # No file found
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	var parse = JSON.parse_string(save_file.get_line())
	leaderboards = parse["score"]
	names = parse["names"]

func game_finished():
	var score = GameState.cleared_floors
	var spot_found: bool = false
	for i in range(leaderboards.size()):
		if score > leaderboards[i]:
			leaderboards.insert(i, score)
			spot_found = true
			if i < 3:
				new_best_score = i
			break
	if not spot_found:
		leaderboards.append(score)
		spot_found = true
		if leaderboards.size() < 4:
			new_best_score = leaderboards.size()-1
	save()

func save():
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var save_dict = {
		"names": names,
		"score": leaderboards
	}
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

func get_top_three_string() -> String:
	var ret = "Best floors:\n"
	names.insert(new_best_score, "You")
	if names.size() > 3:
		names.remove_at(-1)
	for i in range(names.size()):
		ret += "{0}: {1}\n".format([names[i], str(leaderboards[i])])
	return ret
