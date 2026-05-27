extends Node2D

"""var pool : Array[PackedScene] = [
	preload("res://level/rooms/test_rooms/test_room_E.tscn"),
	preload("res://level/rooms/test_rooms/test_room_EW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_N.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NE.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NEW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NS.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NSE.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NSEW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NSW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_NW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_S.tscn"),
	preload("res://level/rooms/test_rooms/test_room_SE.tscn"),
	preload("res://level/rooms/test_rooms/test_room_SEW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_SW.tscn"),
	preload("res://level/rooms/test_rooms/test_room_W.tscn"),
]"""
var pool = []
var room_size := Vector2(16,16)
var tile_width := 16

var starting_room : PackedScene = null

var max_room_count := 10
var min_room_count := 4

var room_cord_neighbors : Dictionary[Vector2, Array] = {}

var directions = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for room_file in DirAccess.get_files_at("res://level/rooms/room_for_real/"):
		pool.append(load("res://level/rooms/room_for_real/" + room_file))
	var start_state
	if starting_room == null:
		starting_room = pool.pick_random()
	var c = 5
	while c > 1:
		c = 0
		starting_room = pool.pick_random()
		start_state = starting_room.get_state()
		for i in range(start_state.get_node_property_count(0)):
			if start_state.get_node_property_name(0,i) in "has_northhas_easthas_southhas_west":
				c += 1
	for i in range(start_state.get_node_property_count(0)):
		print(start_state.get_node_property_name(0,i))
	randomize()
	generate()

func generate() -> void:
	for child in get_children():
		if child.name == "Effects":
			continue
		child.queue_free()
	var seed = randi() % 100000
	print('seed:', seed)
	seed(seed)
	generate_placement()
	place_rooms()

func generate_placement():
	var q : Array[Vector2] = [Vector2.ZERO]
	room_cord_neighbors[Vector2.ZERO] = []
	while q:
		if room_cord_neighbors.keys().size() == max_room_count:
			break
		var loc = q.pop_front()
		directions.shuffle()
		for d in directions:
			if room_cord_neighbors.keys().size() == max_room_count:
				break
			var neighbor_ct := room_cord_neighbors[loc].size()
			#If there is no neighbor, add atleast one
			if neighbor_ct == 0:
				room_cord_neighbors[loc].append(d)
				if loc + d not in room_cord_neighbors:
					room_cord_neighbors[loc + d] = []
				room_cord_neighbors[loc + d].append(-d)
				continue
			#If we already have three neighbors, uuuuuh lets not
			if neighbor_ct == 3:
				break
			var num := randf()
			#If condition met (dependent on num of preexisiting neighbors)
			# then add the direction and the opposing one
			#Or... if we are below minimum, force atleast one expansion
			if neighbor_ct == 1 and (num > 0.5 or room_cord_neighbors.keys().size() <= min_room_count - 2):
				room_cord_neighbors[loc].append(d)
				if loc + d not in room_cord_neighbors:
					room_cord_neighbors[loc + d] = []
				room_cord_neighbors[loc + d].append(-d)
				q.append(loc + d)
				continue
			elif neighbor_ct == 2 and num > 0.25:
				room_cord_neighbors[loc].append(d)
				if loc + d not in room_cord_neighbors:
					room_cord_neighbors[loc + d] = []
				room_cord_neighbors[loc + d].append(-d)
				q.append(loc + d)
				continue

func place_rooms():
	for k in room_cord_neighbors.keys():
		var dirs = room_cord_neighbors[k]
		var needs_left : bool = Vector2.LEFT in dirs
		var needs_right : bool = Vector2.RIGHT in dirs
		var needs_up : bool = Vector2.UP in dirs
		var needs_down : bool = Vector2.DOWN in dirs
		pool.shuffle()
		for r in pool:
			var room : Room = r.instantiate()
			if needs_left != room.has_west:
				continue
			if needs_right != room.has_east:
				continue
			if needs_up != room.has_north:
				continue
			if needs_down != room.has_south:
				continue
			room.position = k * 16 * 16
			add_child(room)
			break

#func _process(delta: float) -> void:
	#var input = Input.get_vector("move_left","move_right","move_up","move_down")
	#
	#var cam : Camera2D = get_child(0)
	#
	#cam.position += input * 200 * delta
	#
	#if Input.is_action_pressed("ui_up"):
		#cam.zoom += Vector2(delta, delta)
	#if Input.is_action_pressed("ui_down"):
		#cam.zoom -= Vector2(delta, delta)
	#
	#if Input.is_action_just_pressed("ui_accept"):
		#generate()
