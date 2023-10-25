class_name DebugCamera2D
extends Camera2D

@export var speed:float = 50

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey:
		var inputEventKey:InputEventKey = event as InputEventKey
		if inputEventKey.pressed and inputEventKey.keycode == KEY_ESCAPE:
			get_tree().quit()
		if inputEventKey.pressed and inputEventKey.keycode == KEY_Q:
			zoom *= 2
		if inputEventKey.pressed and inputEventKey.keycode == KEY_E:
			zoom *= 0.5

func _physics_process(_delta:float) -> void:
	position.x += Input.get_axis("ui_left", "ui_right") * speed
	position.y += Input.get_axis("ui_up", "ui_down") * speed
