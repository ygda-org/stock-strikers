extends Area2D

var target_position

var value = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.lerp(target_position, delta)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerStats.money += value
		queue_free()
