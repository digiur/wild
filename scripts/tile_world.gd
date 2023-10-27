class_name TileWorld
extends TileMap

@export_group("Zone")
@export var curveSize:Vector2i = Vector2i(1000, 200)

@export var genLeft:int = 0
@export var genRight:int = 0
@export var genUp:int = 0
@export var genDown:int = 0

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

@onready var tileSize:int = tile_set.tile_size.x

func _ready() -> void:
	for x:int in range(-genLeft, curveSize.x + genRight):
		for y:int in range(-genUp, curveSize.y + genDown):
			generate_tile(Vector2i(x,y))

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
				generate_tile(tilePos)

func generate_tile(tilePos:Vector2i) -> void:
	var worldPos:Vector2 = Vector2.ZERO
	worldPos.x = (tilePos.x as float + 0.5) / curveSize.x as float + 0.5
	worldPos.y = (-tilePos.y as float + 0.5) / curveSize.y  as float

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

	if worldPos.y > elevation + (soil if soil >= 0 else 0.0):
		set_cell(0, tilePos, 0, emptyTilemapVector)

	elif worldPos.y < elevation + (soil if soil <= 0 else 0.0):
		set_cell(0, tilePos, 0, rockTilemapVector)

	else:
		set_cell(0, tilePos, 0, soilTilemapVector)

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		var keyEvent:InputEventKey = event as InputEventKey
		if keyEvent.keycode == KEY_SPACE and (keyEvent.pressed or keyEvent.echo):
			generate_tile(local_to_map(get_local_mouse_position()))

	if event is InputEventMouseButton:
		var mouseEvent:InputEventMouseButton = event as InputEventMouseButton
		if mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.pressed:
			generate_tile(local_to_map(get_local_mouse_position()))
