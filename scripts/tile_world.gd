class_name TileZone
extends TileMap

enum TileType {ROCK, SOIL, EMPTY}

@export_group("Zone")
@export var zoneSize:Vector2i = Vector2i(70, 30)
@export var curveSize:Vector2i = Vector2i(35, 15)
@export var curveOffset:Vector2i = Vector2i(0, 0)

@export_group("Curves")
@export var curveOctaves: Array[CurveOctave] = []
@export var noiseOctaves: Array[NoiseOctave] = []
@export var soilOctave:CurveOctave
@export var soilNoiseOctave:NoiseOctave

@export_group("Tiles")
@export var rockTilemapVector:Vector2i
@export var soilTilemapVector:Vector2i
@export var emptyTilemapVector:Vector2i

@export_group("Debug")
@export var camera:Camera2D
@export var generateViewportCells:bool = false
@export var generateMouseRadius:int = 5

@onready var tileSize:int = tile_set.tile_size.x
@onready var zoneHalfSize:Vector2 = (zoneSize as Vector2) / 2
@onready var curveHalfSize:Vector2 = (curveSize as Vector2) / 2
@onready var finalCurveOffset:Vector2i = (((zoneSize as Vector2) - (curveSize as Vector2)) + (curveOffset as Vector2)) / 2


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
	var zonePos:Vector2 = map_to_zone(tilePos)
	var elevation:float = curve_to_elevation(curvePos, zonePos)
	var soil:float = curve_to_soil(curvePos, zonePos)

	if curvePos.y > elevation + (soil if soil >= 0 else 0.0):
		return TileType.EMPTY

	elif curvePos.y < elevation + (soil if soil <= 0 else 0.0):
		return TileType.ROCK

	else:
		return TileType.SOIL


func map_to_zone(tilePos:Vector2i) -> Vector2:
	var zonePos:Vector2 = Vector2.ZERO
	zonePos.x = (tilePos.x as float + 0.5) / (zoneSize.x as float)
	zonePos.y = (2 * (zoneHalfSize.y - (tilePos.y as float + 0.5))) / (zoneSize.y  as float)
	return zonePos


func map_to_curve(tilePos:Vector2i) -> Vector2:
	var curvePos:Vector2 = Vector2.ZERO
	var curveTilePos:Vector2i = tilePos - finalCurveOffset
	curvePos.x = (curveTilePos.x as float + 0.5) / (curveSize.x as float)
	curvePos.y = ((curveHalfSize.y - (curveTilePos.y as float + 0.5))) / (curveSize.y  as float)
	return curvePos


func curve_to_elevation(curvePos:Vector2, zonePos:Vector2) -> float:
	var elevation:float = 0
	var ampSum:float = 0

	for octave:CurveOctave in curveOctaves:
		var i:float = curvePos.x if octave.sampleSpace == GameInfo.SampleSpace.CURVE else zonePos.x
		elevation += octave.sampleOctave(i)
		ampSum += octave.amp if octave.enabled else 0

	for octave:NoiseOctave in noiseOctaves:
		elevation += octave.sampleOctave(zonePos.x)
		ampSum += octave.amp if octave.enabled else 0

	return elevation / ampSum


func curve_to_soil(curvePos:Vector2, zonePos:Vector2) -> float:
	var i:float = curvePos.x if soilOctave.sampleSpace == GameInfo.SampleSpace.CURVE else zonePos.x
	var soil:float = soilOctave.sampleOctave(i)
	var ampSum:float = soilOctave.amp if soilOctave.enabled else 0
	
	soil += soilNoiseOctave.sampleOctave(zonePos.x)
	ampSum += soilNoiseOctave.amp if soilNoiseOctave.enabled else 0
	
	return soil / ampSum


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
			var zonePos:Vector2 = map_to_zone(tilePos)
			var curvePos:Vector2 = map_to_curve(tilePos)

