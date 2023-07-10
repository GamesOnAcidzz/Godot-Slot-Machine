extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func blur_in():
	$Tween.interpolate_property(self, "modulate:a",
	0, 1, 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func blur_out():
	$Tween.interpolate_property(self, "modulate:a",
	1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
