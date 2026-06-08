extends Node2D

## 0 vert, 1 horizontal
var orientation = 0 
var path : Sprite2D


func _ready():
	GameState.doors.append(self)
	if orientation == 1:
		$Vertical.queue_free()
		path = $Horizontal
	else:
		$Horizontal.queue_free()
		path = $Vertical

func open(): 
	path.visible = false
	path.find_child("CollisionShape2D").disabled = true
	#queue_free() # for now just die

func close():
	path.visible = true
	path.find_child("CollisionShape2D").disabled = false
