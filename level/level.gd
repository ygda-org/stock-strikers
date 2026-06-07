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

var max_room_count := 8
var min_room_count := 4

var room_cord_neighbors : Dictionary[Vector2, Array] = {}
var rooms_after_placement: Dictionary[Vector2, Node2D]

var directions = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]

const TOP_FIX = preload("uid://cuiyvc7560r16")
const TOP_FIX_ENTRANCE = preload("uid://c8rfeoo72jgoo")
const TOP_FIX_ENTRANCE3 = preload("uid://bj8jigk37cq0h")

const DOOR = preload("res://level/rooms/door.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "max_room_ct" in PlayerStats.permanent_upgrades_loaded.keys():
		max_room_count += int(PlayerStats.permanent_upgrades_loaded["max_room_ct"])
	if "min_room_ct" in PlayerStats.permanent_upgrades_loaded.keys():
		min_room_count += int(PlayerStats.permanent_upgrades_loaded["min_room_ct"])
	for room_file in ResourceLoader.list_directory("res://level/rooms/room_for_real/"):# DirAccess.get_files_at("res://level/rooms/room_for_real/"):
		pool.append(load("res://level/rooms/room_for_real/" + room_file))
	if starting_room == null:
		starting_room = pool.pick_random()
	generate()
	if "no_four_split" in PlayerStats.permanent_upgrades_loaded.keys():
		while check_four_split():
			generate()
	check_top_replacements()
	place_doors()
	randomize_tilemaps()
	set_player_position()

func generate() -> void:
	for child in get_children():
		if child.name == "Effects":
			continue
		child.queue_free()
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
	var elevator_placed = false
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
			room.z_index = k.y
			rooms_after_placement[k] = room
			if room.full_size and not room.has_north and (not elevator_placed or randi()%2):
				var elevator = load("uid://cq7h3giq4ix6y").instantiate()
				room.add_child(elevator)
				elevator.position.x += 128
				elevator_placed = true
			add_child(room)
			break

func check_top_replacements():
	for coord in rooms_after_placement.keys():
		var above = Vector2(coord.x, coord.y-1)
		if above in room_cord_neighbors.keys() and rooms_after_placement[coord].north_edge_fix:
			if rooms_after_placement[coord].full_size:
				var top_fix
				if not rooms_after_placement[coord].has_north:
					top_fix = TOP_FIX.instantiate()
				elif above in rooms_after_placement.keys() and rooms_after_placement[above].full_size:
					top_fix = TOP_FIX_ENTRANCE.instantiate()
				else:
					top_fix = TOP_FIX_ENTRANCE3.instantiate()
				top_fix.position = coord * 16 * 16
				add_child(top_fix)

func check_four_split(): # returns true if has four split
	for k in room_cord_neighbors.keys():
		if k.has_north and k.has_east and k.has_south and k.has_west:
			return true
	return false

func place_doors():
	for room_cord in rooms_after_placement.keys():
		var room = rooms_after_placement[room_cord]
		var placements = []
		var orientations = []
		if room.has_north:
			placements.append(room_cord*256+Vector2(128,0))
			orientations.append(0)
		if room.has_east:
			placements.append(room_cord*256+Vector2(256,128))
			orientations.append(1)
		if room.has_south:
			placements.append(room_cord*256+Vector2(128,256))
			orientations.append(0)
		if room.has_west:
			placements.append(room_cord*256+Vector2(0,128))
			orientations.append(1)
		for i in range(len(placements)):
			var door = DOOR.instantiate()
			door.orientation = orientations[i]
			add_child(door)
			door.global_position = placements[i]
			

func _on_debt_timer_timeout():
	PlayerStats.interest()

func randomize_tilemaps():
	var floor = randi() % 4
	var walls = randi() % 3
	for room_pos in rooms_after_placement.keys():
		var room = rooms_after_placement[room_pos]
		room.set_floor(floor)
		room.set_walls(walls)

func set_player_position():
	var player_pos = get_parent().get_node("Player").position
	var min_dist = 100000000
	var closest_room
	for room_cord in rooms_after_placement.keys():
		var room = rooms_after_placement[room_cord]
		var dist = (player_pos - room.player_spawn).length()
		if dist < min_dist:
			closest_room = room
			min_dist = dist
	player_pos = closest_room.player_spawn
	for room_cord in rooms_after_placement.keys():
		var room = rooms_after_placement[room_cord]
		if room != closest_room:
			room.spawn_enemies() # only spawn enemies in rooms which aren't the closest room to the player spawn
	#for enemy in closest_room.my_enemies:
	#	enemy.queue_free()
	#	closest_room.on_all_enemies_dead()
