class_name TileZone
extends TileMap

@export_group("Zone")
@export var zoneTiles:Vector2i = Vector2i(70, 30)
@export var curveTiles:Vector2i = Vector2i(35, 15)
@export var curveTilesOffset:Vector2i = Vector2i(0, 0)

@export_group("Curves")
@export var curveOctaves: Array[CurveOctave] = []
@export var noiseOctaves: Array[NoiseOctave] = []
@export var soilOctave:CurveOctave
@export var soilNoiseOctave:NoiseOctave

@export_group("Tiles")
@export var rockTilemapVector:Vector2i
@export var soilTilemapVector:Vector2i
@export var emptyTilemapVector:Vector2i


@onready var tileSize:int = tile_set.tile_size.x
@onready var halfZoneTiles:Vector2 = (zoneTiles as Vector2) / 2
@onready var halfCurveTiles:Vector2 = (curveTiles as Vector2) / 2

# Do I want to round here?
@onready var finalCurveTilesOffset:Vector2i =\
	(((zoneTiles as Vector2) - (curveTiles as Vector2)) + (curveTilesOffset as Vector2)) / 2


func _ready() -> void:
	for x:int in range(zoneTiles.x):
		for y:int in range(zoneTiles.y):
			set_tile(Vector2i(x,y))


func set_tile(tilePos:Vector2i, tileType:Enum.TileType = Enum.TileType.VOID) -> void:

	print("set cell")
	if(tileType == Enum.TileType.VOID):
		tileType = getTileType(tilePos)
	print("tileType ", tileType)
	
	if tileType == Enum.TileType.EMPTY:
		set_cell(0, tilePos, 0, emptyTilemapVector)
	if tileType == Enum.TileType.ROCK:
		set_cell(0, tilePos, 0, rockTilemapVector)
	if tileType == Enum.TileType.SOIL:
		set_cell(0, tilePos, 0, soilTilemapVector)


func getTileType(tilePos:Vector2i) -> Enum.TileType:
	var zonePos:Vector2 = map_to_zone(tilePos)
	var curvePos:Vector2 = map_to_curve(tilePos)
	var elevation:float = curve_to_elevation(curvePos, zonePos)
	var soil:float = curve_to_soil(curvePos, zonePos)

	if curvePos.y > elevation + (soil if soil >= 0 else 0.0):
		return Enum.TileType.EMPTY

	elif curvePos.y < elevation + (soil if soil <= 0 else 0.0):
		return Enum.TileType.ROCK

	else:
		return Enum.TileType.SOIL


func map_to_zone(tilePos:Vector2i) -> Vector2:
	var zonePos:Vector2 = Vector2.ZERO
	zonePos.x = (tilePos.x as float + 0.5) / (zoneTiles.x as float)
	zonePos.y = (2 * (halfZoneTiles.y - (tilePos.y as float + 0.5))) / (zoneTiles.y as float)
	return zonePos


func map_to_curve(tilePos:Vector2i) -> Vector2:
	tilePos -= finalCurveTilesOffset
	var curvePos:Vector2 = Vector2.ZERO
	curvePos.x = (tilePos.x as float + 0.5) / (curveTiles.x as float)
	curvePos.y = (2 * (halfCurveTiles.y - (tilePos.y as float + 0.5))) / (curveTiles.y  as float)
	return curvePos


func curve_to_elevation(curvePos:Vector2, zonePos:Vector2) -> float:
	var elevation:float = 0
	var ampSum:float = 0

	for octave:CurveOctave in curveOctaves:
		var i:float = curvePos.x
		elevation += octave.sampleOctave(i)
		ampSum += octave.amp if octave.enabled else 0

	for octave:NoiseOctave in noiseOctaves:
		elevation += octave.sampleOctave(zonePos.x)
		ampSum += octave.amp if octave.enabled else 0

	return elevation / ampSum


func curve_to_soil(curvePos:Vector2, zonePos:Vector2) -> float:
	var soil:float = soilOctave.sampleOctave(curvePos.x)
	var ampSum:float = soilOctave.amp if soilOctave.enabled else 0
	
	soil += soilNoiseOctave.sampleOctave(zonePos.x)
	ampSum += soilNoiseOctave.amp if soilNoiseOctave.enabled else 0
	
	return soil / ampSum

