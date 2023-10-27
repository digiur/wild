class_name NoiseOctave
extends FastNoiseLite

@export var amp:float = 0.25
@export var scale:float = 1000
@export var enabled:bool = true

func _init() -> void:
	noise_type = FastNoiseLite.TYPE_SIMPLEX
	if seed == 0:
		seed = randi()

func sampleOctave(i:float) -> float:
	return amp * get_noise_1d(i * scale) * (enabled as int)
