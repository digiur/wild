class_name TileWorld
extends TileMap

@export var camera:Camera2D

@export var zoneWidth:int = 1000
@export var zoneHeight:int = 200
@export var zonePos:Vector2i = Vector2i(0,0)
@export var zoneBorder:int = 10

@export var curveOctaves: Array[CurveOctave] = []
@export var noiseOctaves: Array[NoiseOctave] = []
@export var soilOctave:CurveOctave

@export var rockTilemapVector:Vector2i
@export var soilTilemapVector:Vector2i
@export var emptyTilemapVector:Vector2i

@export var generateViewportCells:bool = false

var tileSize:int = tile_set.tile_size.x

func _ready() -> void:
	for x:int in range(-zoneBorder, zoneWidth + zoneBorder):
		for y:int in range(-zoneBorder, zoneHeight + zoneBorder):
			generate_tile(Vector2i(x,y))

func _process(_delta: float) -> void:
	
	if not generateViewportCells:
		return
	
	var visibleRect:Rect2 = get_viewport().get_visible_rect()
	# visibleRect = visibleRect.grow(tileSize * 2 + visibleRect.size.x / 2 * 1 / camera.zoom.x)
	var center:Vector2 = camera.get_screen_center_position()
	visibleRect.position = center - visibleRect.size / 2

	for i:int in range(visibleRect.size.x/tileSize):
		for j:int in range(visibleRect.size.y/tileSize):
			var x:int = visibleRect.position.x + (i * tileSize)
			var y:int = visibleRect.position.y + (j * tileSize)
			var tilePos:Vector2i = local_to_map(Vector2(x, y))
			
			if get_cell_source_id(0, tilePos) == -1:
				generate_tile(tilePos)

func generate_tile(tilePos:Vector2i) -> void:
	var localPos:Vector2 = map_to_local(zonePos + tilePos)
	var worldPos:Vector2 = Vector2.ZERO
	worldPos.x = localPos.x / zoneWidth / tileSize
	worldPos.y = -localPos.y / zoneHeight / tileSize

	var elevation:float = 0
	var ampSum:float = 0

	for octave:CurveOctave in curveOctaves:
		elevation += octave.sampleOctave(worldPos.x)
		ampSum += octave.amp

	for octave:NoiseOctave in noiseOctaves:
		elevation += octave.sampleOctave(worldPos.x)
		ampSum += octave.amp

	elevation /= ampSum
	elevation -= 1
	elevation *= 0.5
	
	var soil:float = soilOctave.sampleOctave(worldPos.x)

	if worldPos.y > elevation:
		set_cell(0, tilePos, 0, emptyTilemapVector)
	elif worldPos.y < elevation - soil:
		set_cell(0, tilePos, 0, rockTilemapVector)
	else:
		set_cell(0, tilePos, 0, soilTilemapVector)
