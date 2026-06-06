extends Node2D

## 0 vert, 1 horizontal
var orientation = 0 
var path


func _ready():
	GameState.doors.append(self)
	if orientation == 1:
		$Vertical.queue_free()
		path = $Horizontal
	else:
		$Horizontal.queue_free()
		path = $Vertical

func open(): 
	queue_free() # for now just die
