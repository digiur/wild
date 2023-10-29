class_name PixelZone
extends TextureRect

@export_group("Zone")
@export var zoneTiles:Vector2i = Vector2i(70, 30)
@export var curveTiles:Vector2i = Vector2i(35, 15)
@export var curveTilesOffset:Vector2i = Vector2i(0, 0)

@export_group("Octaves")
@export_subgroup("Surface")
@export var surfaceOctaves: Array[CurveOctave] = []
@export var surfaceNoiseOctaves: Array[NoiseOctave] = []
@export_subgroup("Soil")
@export var soilOctave:CurveOctave
@export var soilNoiseOctave:NoiseOctave

@export_group("Colors")
@export var emptyColor:Color = Color.LIGHT_SEA_GREEN
@export var soilColor:Color = Color.DARK_GREEN
@export var rockColor:Color = Color.SADDLE_BROWN

@onready var halfZoneTiles:Vector2 = (zoneTiles as Vector2) / 2
@onready var halfCurveTiles:Vector2 = (curveTiles as Vector2) / 2

@onready var img:Image = Image.create(zoneTiles.x, zoneTiles.y, true, Image.FORMAT_RGBA8)

# Do I want to round here?
@onready var finalCurveTilesOffset:Vector2i =\
	(((zoneTiles as Vector2) - (curveTiles as Vector2)) + (curveTilesOffset as Vector2)) / 2


func _ready() -> void:
	for x:int in range(zoneTiles.x):
		for y:int in range(zoneTiles.y):
			set_tile(Vector2i(x,y))
	texture = ImageTexture.create_from_image(img)


func set_tile(tilePos:Vector2i, tileType:Enum.TileType = Enum.TileType.VOID) -> void:
	if(tileType == Enum.TileType.VOID):
		tileType = getTileType(tilePos)

	if tileType == Enum.TileType.EMPTY:
		img.set_pixel(tilePos.x, tilePos.y, emptyColor)
	elif tileType == Enum.TileType.ROCK:
		img.set_pixel(tilePos.x, tilePos.y, rockColor)
	elif tileType == Enum.TileType.SOIL:
		img.set_pixel(tilePos.x, tilePos.y, soilColor)


func getTileType(tilePos:Vector2i) -> Enum.TileType:
	var zonePos:Vector2 = map_to_zone(tilePos)
	var curvePos:Vector2 = map_to_curve(tilePos)
	var elevation:float = curve_to_elevation(curvePos)
	var soil:float = curve_to_soil(curvePos)

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


func curve_to_elevation(curvePos:Vector2) -> float:
	var elevation:float = 0
	var ampSum:float = 0

	for octave:CurveOctave in surfaceOctaves:
		var i:float = curvePos.x
		elevation += octave.sampleOctave(i)
		ampSum += octave.amp if octave.enabled else 0

	for octave:NoiseOctave in surfaceNoiseOctaves:
		elevation += octave.sampleOctave(curvePos.x)
		ampSum += octave.amp if octave.enabled else 0

	return elevation / ampSum


func curve_to_soil(curvePos:Vector2) -> float:
	var soil:float = soilOctave.sampleOctave(curvePos.x)
	var ampSum:float = soilOctave.amp if soilOctave.enabled else 0

	soil += soilNoiseOctave.sampleOctave(curvePos.x)
	ampSum += soilNoiseOctave.amp if soilNoiseOctave.enabled else 0

	return soil / ampSum

