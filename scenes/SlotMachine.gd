extends Node2D

const SlotTile := preload("res://scenes/SlotTile.tscn")
# Stores the SlotTile's SPIN_UP animation distance
const SPIN_UP_DISTANCE = 100.0
signal stopped

export(int,1,20) var reels := 5
export(int,1,20) var tiles_per_reel := 4
# Defines how long the reels are spinning
export(float,0,10) var runtime := 1.0
# Defines how fast the reels are spinning
export(float,0.1,10) var speed := 5.0
# Defines the start delay between each reel
export(float,0,2) var reel_delay := 0.2
var is_spinning=false
# Adjusts tile size to viewport
var reset_matchs=true
onready var initial_viewport_height= get_parent().size.y
onready var viewport_height= initial_viewport_height
onready var size := get_viewport_rect().size
onready var tile_size := size / Vector2(reels, tiles_per_reel)
# Normalizes the speed for consistancy independent of the number of tiles
onready var speed_norm := speed * tiles_per_reel
# Add additional tiles outside the viewport of each reel for smooth animation
# Add it twice for above and below the grid
onready var extra_tiles := int(ceil(SPIN_UP_DISTANCE / tile_size.y) * 2)
onready var blur_effect= $"../../../BlurEffectRect"
onready var timer =$"../../../Timer"
# Stores the actual number of tiles
onready var rows := tiles_per_reel + extra_tiles
onready var visible_tiles=[]

enum State {OFF, ON, STOPPED}
var state = State.OFF
var result := {}

# Stores SlotTile instances
const tiles := []
# Stores the top left corner of each grid cell
const grid_pos := []

# 1/speed*runtime*reels times
# Stores the desured number of movements per reel
onready var expected_runs :int = int(runtime * speed_norm)
# Stores the current number of movements per reel
var tiles_moved_per_reel := []
# When force stopped, stores the current number of movements 
var runs_stopped := 0
# Store the runs independent of how they are achieved
var total_runs : int

func _ready():
  # Initializes grid of tiles
	for col in reels:
		grid_pos.append([])
		tiles_moved_per_reel.append(0)
		if col==0 || col==reels-1:
			rows= 2+extra_tiles
		for row in range(rows):
		  # Position extra tiles above and below the viewport
		  grid_pos[col].append(Vector2(col, row-0.5*extra_tiles) * tile_size)
		  _add_tile(col, row)
		rows=tiles_per_reel+extra_tiles
	start()
# Stores and initializes a new tile at the given grid cell
func _add_tile(col :int, row :int) -> void:
	var newTile= SlotTile.instance()
	tiles.append(newTile)
	newTile.connect("spinned_down",self,"_spinned_down")
	newTile.get_node('Tween').connect("tween_completed", self, "_on_tile_moved")
	newTile.roll_value()
	newTile.set_size(tile_size)
	newTile.set_tile_position(Vector2(col,row))
	newTile.position = grid_pos[col][row]
	newTile.set_speed(speed_norm)
	add_child(newTile)

func _spinned_down():
	if !is_spinning && reset_matchs:
		reset_matchs=false
		check_for_matchs()
# Returns the tile at the given grid cell
func get_tile(col :int, row :int) -> SlotTile:
  return tiles[(col * rows) + row]

func get_tile_by_position(tile_position:Vector2)->SlotTile:
	var tile_to_return=null
	for tile in tiles:
		if tile.get_tile_position()==tile_position:
			tile_to_return=tile
	return tile_to_return
func start() -> void:
	blur_effect.blur_in()
	reset_matchs=true
  # Only start if it is not running yet
	_spin_reel()
  
# Force the machine to stop before runtime ends
func stop():
	
	timer.stop()
	
	blur_effect.blur_out()
	is_spinning=false
	
	# Tells the machine to stop at the next possible moment
	state = State.STOPPED
	# Store the current runs of the first reel
	# Add runs to update the tiles to the result images
	runs_stopped = current_runs()
	total_runs = runs_stopped + tiles_per_reel + 1
	
func set_visible_tiles():
	visible_tiles.clear()
	visible_tiles=[]
	for tile in tiles:
		if (tile.position.y < viewport_height && tile.position.y>=0 ):
			visible_tiles.append(tile)
	viewport_height=initial_viewport_height
# Is called when the animation stops
func _stop() -> void:
	
	for reel in reels:
		tiles_moved_per_reel[reel] = 0
		state = State.OFF
		emit_signal("stopped")

# Starts moving all tiles of the given reel
func _spin_reel() -> void:
	timer.start()
	is_spinning=true
	for tile in tiles:
		_move_tile(tile)

func _move_tile(tile :SlotTile) -> void:
  # Plays a spin up animation
	tile.spin_up()
	
	yield(tile.get_node("Animations"), "animation_finished")
	# Moves reel by one tile at a time to avoid artifacts when going too fast
	tile.move_by(Vector2(0, tile_size.y))
	# The reel will move further through the _on_tile_moved function
  
func _on_tile_moved(tile: SlotTile, _nodePath) -> void:    
	# Calculates the reel that the tile is on
	var reel := int(tile.position.x / tile_size.x)
	# Count how many tiles moved per reel
	tiles_moved_per_reel[reel] += 1
	var reel_runs := current_runs(reel)
	
	# If tile moved out of the viewport, move it to the invisible row at the top
	if tile.get_tile_position().x==0|| tile.get_tile_position().x==reels-1:
		viewport_height=viewport_height/2.5
	if (tile.position.y > viewport_height):
		tile.position.y = -tile.size.y
		tile.roll_value()
		if (visible_tiles.has(tile)):
			visible_tiles.remove(visible_tiles.find(tile))
	else:
		visible_tiles.append(tile)
	viewport_height=initial_viewport_height
	# Set a new random texture
	
	if is_spinning:
		tile.move_by(Vector2(0, tile_size.y))
	else:
		tile.spin_down()

	# When last reel stopped, machine is stopped
	if reel == reels - 1:
	  _stop()

# Divide it by the number of tiles to know how often the whole reel moved
# Since this function is called by each tile, the number changes (e.g. for 6 tiles: 1/6, 2/6, ...)
# We use ceil, so that both 1/7, as well as 7/7 return that the reel ran 1 time
func current_runs(reel := 0) -> int:
  return int(ceil(float(tiles_moved_per_reel[reel]) / rows))
func _get_result() -> void:
  result = {
	"tiles": [
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ]
	]
  }
func check_for_matchs():
	set_visible_tiles()
	for index in range (0,4):
		var same_line_tiles_values=[]
		var same_line_tiles=[]
		for tile in visible_tiles:
			var tile_position = tile.position.y/200
			if tile_position==index:
				if index>1:
					if tile_position !=0 && tile_position !=4:
						same_line_tiles_values.append(tile.get_value())
						same_line_tiles.append(tile)
				else:
					same_line_tiles_values.append(tile.get_value())
					same_line_tiles.append(tile)
		if same_line_tiles.size()>5:#band-aid fix for some bizarre reason sometimes it has 6 or 7 elements
				same_line_tiles.remove(0)
				same_line_tiles_values.remove(0)
		if same_line_tiles.size()>5:
				same_line_tiles.remove(4)
				same_line_tiles_values.remove(4)
		for tile in same_line_tiles:
			if same_line_tiles_values.count(tile.get_value())>1:
				tile.trigger_fire()
			
func _on_Timer_timeout():
	stop()
	pass # Replace with function body.
