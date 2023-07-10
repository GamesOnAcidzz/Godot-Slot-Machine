extends Node2D
class_name SlotTile
signal spinned_down
var size :Vector2
var tile_position:Vector2
var value:int=0
const pictures := [
  preload("res://sprites/TileIcons/bat.png"),#0
  preload("res://sprites/TileIcons/cactus.png"),#1
  preload("res://sprites/TileIcons/card-exchange.png"),#2
  preload("res://sprites/TileIcons/card-joker.png"),#3
  preload("res://sprites/TileIcons/chess-knight.png"),#4
  preload("res://sprites/TileIcons/coffee-cup.png"),#5
  preload("res://sprites/TileIcons/companion-cube.png"),#6
  preload("res://sprites/TileIcons/cycling.png"),#7
  preload("res://sprites/TileIcons/dandelion-flower.png"),#8
  preload("res://sprites/TileIcons/eight-ball.png"),#9
  preload("res://sprites/TileIcons/hummingbird.png"),#10
  preload("res://sprites/TileIcons/kiwi-bird.png"),#11
  preload("res://sprites/TileIcons/owl.png"),#12
  preload("res://sprites/TileIcons/pc.png"),#13
  preload("res://sprites/TileIcons/pie-slice.png"),
  preload("res://sprites/TileIcons/plastic-duck.png"),
  preload("res://sprites/TileIcons/raven.png"),
  preload("res://sprites/TileIcons/rolling-dices.png"),
  preload("res://sprites/TileIcons/skull-crossed-bones.png"),
  preload("res://sprites/TileIcons/super-mushroom.png"),
  preload("res://sprites/TileIcons/tic-tac-toe.png"),
  preload("res://sprites/TileIcons/trojan-horse.png"),
  preload("res://sprites/TileIcons/udder.png")
]
func _ready():
  pass
func set_texture(tex):
  $Sprite.texture = tex
  set_size(size)
func roll_value():
	value = rand_range(0,pictures.size()-1)
	$Sprite.texture = pictures[value]
func get_value():
	return value
func set_tile_position(pos:Vector2):
	tile_position=pos
func get_tile_position()->Vector2:
	return tile_position
func set_size(new_size: Vector2):
  size = new_size
  $Sprite.scale = size / $Sprite.texture.get_size()
  
func set_speed(speed):
  $Tween.playback_speed = speed
  
func move_to(to: Vector2):
  $Tween.interpolate_property(self, "position",
	position, to, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
  $Tween.start()
func move_by(by: Vector2):
  move_to(position + by)
  
func spin_up():
  $Animations.play('SPIN_UP')
  clear_fire()

func spin_down():
  $Animations.play('SPIN_DOWN')

func emit_spinned_down_signal():
	emit_signal("spinned_down")

func trigger_fire():
	$Sprite/Sprite2/FireAnimations.play("Fire_up")

func clear_fire():
	$Sprite/Sprite2.modulate.a=0
