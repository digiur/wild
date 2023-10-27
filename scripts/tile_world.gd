class_name TileZone
extends TileMap

enum TileType {ROCK, SOIL, EMPTY}

@export_group("Zone")
@export var zoneSize:Vector2i = Vector2i(1000, 200)
@export var curveSize:Vector2i = Vector2i(500, 100)
@export var curveOffset:Vector2i = Vector2i(0,0)

@export_group("Curves")
@export var curveOctaves: Array[CurveOctave] = []
@export var noiseOctaves: Array[NoiseOctave] = []
@export var soilOctave:CurveOctave

@export_group("Tiles")
@export var rockTilemapVector:Vector2i
@export var soilTilemapVector:Vector2i
@export var emptyTilemapVector:Vector2i

@export_group("Debug")
@export var camera:Camera2D
@export var generateViewportCells:bool = false
@export var generateMouseRadius:int = 5

@onready var tileSize:int = tile_set.tile_size.x

func _ready() -> void:
	for x:int in range(zoneSize.x):
		for y:int in range(zoneSize.y):
			set_tile(Vector2i(x,y), getTileType(Vector2i(x,y)))

func _process(_delta: float) -> void:
	if camera == null or not generateViewportCells:
		return

	var visibleRect:Rect2 = get_viewport().get_visible_rect()
	var center:Vector2 = camera.get_screen_center_position()
	visibleRect.position = center - visibleRect.size / 2

	for i:int in range(visibleRect.size.x/tileSize):
		for j:int in range(visibleRect.size.y/tileSize):
			var x:int = roundi(visibleRect.position.x) + (i * tileSize)
			var y:int = round(visibleRect.position.y) + (j * tileSize)
			var tilePos:Vector2i = local_to_map(Vector2(x, y))

			if get_cell_source_id(0, tilePos) == -1:
				set_tile(tilePos, getTileType(tilePos))

func set_tile(tilePos:Vector2i, tileType:TileType) -> void:
	if tileType == TileType.EMPTY:
		set_cell(0, tilePos, 0, emptyTilemapVector)
	if tileType == TileType.ROCK:
		set_cell(0, tilePos, 0, rockTilemapVector)
	if tileType == TileType.SOIL:
		set_cell(0, tilePos, 0, soilTilemapVector)


func getTileType(tilePos:Vector2i) -> TileType:

	var curvePos:Vector2 = map_to_curve(tilePos)
	var elevation:float = curve_to_elevation(curvePos)
	var soil:float = curve_to_soil(curvePos)

	if curvePos.y > elevation + (soil if soil >= 0 else 0.0):
		return TileType.EMPTY

	elif curvePos.y < elevation + (soil if soil <= 0 else 0.0):
		return TileType.ROCK

	else:
		return TileType.SOIL

func map_to_curve(tilePos:Vector2i) -> Vector2:
	var curvePos:Vector2 = Vector2.ZERO
	curvePos.x = (tilePos.x as float) / (curveSize.x as float)
	curvePos.y = ((curveSize.y/2 - tilePos.y) as float) / (curveSize.y  as float)
	return curvePos

func curve_to_elevation(curvePos:Vector2) -> float:
	var elevation:float = 0
	var ampSum:float = 0

	for octave:CurveOctave in curveOctaves:
		elevation += octave.sampleOctave(curvePos.x)
		ampSum += octave.amp

	for octave:NoiseOctave in noiseOctaves:
		elevation += octave.sampleOctave(curvePos.x)
		ampSum += octave.amp

	return elevation / ampSum

func curve_to_soil(curvePos:Vector2) -> float:
	return soilOctave.sampleOctave(curvePos.x)

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		var keyEvent:InputEventKey = event as InputEventKey
		if keyEvent.keycode == KEY_SPACE and (keyEvent.pressed or keyEvent.echo):
			var tilePos:Vector2i = local_to_map(get_local_mouse_position())
			for x:int in range(tilePos.x - generateMouseRadius, tilePos.x + generateMouseRadius):
				for y:int in range(tilePos.y - generateMouseRadius, tilePos.y + generateMouseRadius):
					set_tile(Vector2i(x,y), getTileType(Vector2i(x,y)))

	if event is InputEventMouseButton:
		var mouseEvent:InputEventMouseButton = event as InputEventMouseButton
		if mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.pressed:
			var tilePos:Vector2i = local_to_map(get_local_mouse_position())
			var curvePos:Vector2 = Vector2.ZERO
			curvePos.x = (tilePos.x as float) / (curveSize.x as float)
			curvePos.y = (((curveSize.y / 2 - tilePos.y) * 2) as float) / (curveSize.y  as float)
			print(".")
			print("tilePos ",tilePos)
			print("curvePos ",curvePos)
