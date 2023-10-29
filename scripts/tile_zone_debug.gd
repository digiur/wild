@tool
class_name TileZoneDebug
extends Camera2D

@export var speed:float = 25
@export var tileZone:TileZone
@export var generateViewportCells:bool = false
@export var generateMouseRadius:int = 5
@export var color:Color

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not generateViewportCells:
		return

	var visibleRect:Rect2 = get_viewport().get_visible_rect()
	var center:Vector2 = get_screen_center_position()
	visibleRect.position = center - visibleRect.size / 2

	for i:int in range(visibleRect.size.x / tileZone.tileSize):
		for j:int in range(visibleRect.size.y / tileZone.tileSize):
			var x:int = roundi(visibleRect.position.x) + (i * tileZone.tileSize)
			var y:int = round(visibleRect.position.y) + (j * tileZone.tileSize)
			var tilePos:Vector2i = tileZone.local_to_map(Vector2(x, y))

			if tileZone.get_cell_source_id(0, tilePos) == -1:
				tileZone.set_tile(tilePos)


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
	var zoneSize:Vector2 = tileZone.zoneTiles * tileZone.tile_set.tile_size.x
	var topLeft:Vector2 = tileZone.position - position
	var topRight:Vector2 = Vector2(tileZone.position.x + zoneSize.x, tileZone.position.y) - position
	var bottomLeft:Vector2 = Vector2(tileZone.position.x, tileZone.position.y + zoneSize.y) - position
	var bottomRight:Vector2 = tileZone.position + zoneSize - position

	draw_line(topLeft, topRight, color)
	draw_line(topRight, bottomRight, color)
	draw_line(bottomRight, bottomLeft, color)
	draw_line(bottomLeft, topLeft, color)
	
	var finalCurveOffset:Vector2 = ((((tileZone.zoneTiles as Vector2) - (tileZone.curveTiles as Vector2)) + (tileZone.curveTilesOffset as Vector2)) / 2) * tileZone.tile_set.tile_size.x
	var curveSize:Vector2 = tileZone.curveTiles * tileZone.tile_set.tile_size.x
	topLeft = tileZone.position - position + finalCurveOffset
	topRight = Vector2(tileZone.position.x + curveSize.x, tileZone.position.y) - position + finalCurveOffset
	bottomLeft = Vector2(tileZone.position.x, tileZone.position.y + curveSize.y) - position + finalCurveOffset
	bottomRight = tileZone.position + curveSize - position + finalCurveOffset
	
	draw_line(topLeft, topRight, color)
	draw_line(topRight, bottomRight, color)
	draw_line(bottomRight, bottomLeft, color)
	draw_line(bottomLeft, topLeft, color)


func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		var keyEvent:InputEventKey = event as InputEventKey
		if keyEvent.keycode == KEY_SPACE and (keyEvent.pressed or keyEvent.echo):
			var tilePos:Vector2i = tileZone.local_to_map(get_local_mouse_position())
			for x:int in range(tilePos.x - generateMouseRadius, tilePos.x + generateMouseRadius):
				for y:int in range(tilePos.y - generateMouseRadius, tilePos.y + generateMouseRadius):
					tileZone.set_tile(Vector2i(x,y))

	if event is InputEventMouseButton:
		var mouseEvent:InputEventMouseButton = event as InputEventMouseButton
		if mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.pressed:
			var tilePos:Vector2i = tileZone.local_to_map(get_local_mouse_position())
			var tileType:Enum.TileType = tileZone.getTileType(tilePos)
			var zonePos:Vector2 = tileZone.map_to_zone(tilePos)
			var curvePos:Vector2 =  tileZone.map_to_curve(tilePos)
			var elevation:float = tileZone.curve_to_elevation(curvePos)
			var soil:float = tileZone.curve_to_soil(curvePos)
			print("==============================")
			print("tilePos ", tilePos)
			print("tileType ", tileType)
			print("zonePos ", zonePos)
			print("curvePos ", curvePos)
			print("elevation ", elevation)
			print("soil ", soil)

