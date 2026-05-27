extends Node
var player

var enemies = []

func _process(_delta):
	clear_enemies()

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
