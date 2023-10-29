@tool
class_name PixelZoneDebug
extends Camera2D

@export var speed:float = 25
@export var pixelZone:PixelZone
@export var generateMouseRadius:int = 5
@export var color:Color


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
	if Engine.is_editor_hint():
		return

	position.x += Input.get_axis("ui_left", "ui_right") * speed
	position.y += Input.get_axis("ui_up", "ui_down") * speed

func _draw() -> void:
	var zoneSize:Vector2 = pixelZone.zoneTiles
	var topLeft:Vector2 = pixelZone.position - position
	var topRight:Vector2 = Vector2(pixelZone.position.x + zoneSize.x, pixelZone.position.y) - position
	var bottomLeft:Vector2 = Vector2(pixelZone.position.x, pixelZone.position.y + zoneSize.y) - position
	var bottomRight:Vector2 = pixelZone.position + zoneSize - position

	draw_line(topLeft, topRight, color)
	draw_line(topRight, bottomRight, color)
	draw_line(bottomRight, bottomLeft, color)
	draw_line(bottomLeft, topLeft, color)
	
	var finalCurveOffset:Vector2 = ((((pixelZone.zoneTiles as Vector2) - (pixelZone.curveTiles as Vector2)) + (pixelZone.curveTilesOffset as Vector2)) / 2)
	var curveSize:Vector2 = pixelZone.curveTiles
	topLeft = pixelZone.position - position + finalCurveOffset
	topRight = Vector2(pixelZone.position.x + curveSize.x, pixelZone.position.y) - position + finalCurveOffset
	bottomLeft = Vector2(pixelZone.position.x, pixelZone.position.y + curveSize.y) - position + finalCurveOffset
	bottomRight = pixelZone.position + curveSize - position + finalCurveOffset
	
	draw_line(topLeft, topRight, color)
	draw_line(topRight, bottomRight, color)
	draw_line(bottomRight, bottomLeft, color)
	draw_line(bottomLeft, topLeft, color)

