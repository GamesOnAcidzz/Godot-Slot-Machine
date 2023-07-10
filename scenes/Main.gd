extends Node2D

onready var slot = $ViewportContainer/Viewport/SlotMachine

func _ready():
	$Roll.text = "Stop"

func _on_Roll_button_down():
	if $Roll.text == "Roll":
		slot.start()
		$Roll.text = "Stop"
	else:
		slot.stop()
		$Roll.text = "Roll"

func _on_Timer_timeout():
	$Roll.text = "Roll"
	pass # Replace with function body.
