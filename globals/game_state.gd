extends Node
var player

var enemies = []

var stock_options : Array[Stock] = []

func _process(_delta):
	clear_enemies()

func generate_stock_options():
	var dir_name := "res://player/stocks/"
	# This "open" method returns an instance for accessing your dir
	var dir := DirAccess.open(dir_name)
	var file_names := dir.get_files()
	var resources: Array[Stock] = []
	for file_name in file_names:
		if 'tres' not in file_name:
			continue
		resources.append(load(dir_name + file_name))
	resources.shuffle()
	stock_options = resources.slice(0, 5)

func clear_enemies():
	var indices = []
	for i in range(len(enemies)):
		if not enemies[i]:
			indices.append(i)
	var j = 0
	for i in indices:
		if i >= len(indices):
			break
		enemies.remove_at(i - j)
		j += 1
