@tool
class_name CurveOctave
extends Curve

enum CurveWrapMode {WRAP, MIRROR, FLIP, FLAT}

@export var amp:float = 0.5
@export var freq:float = 2
@export var enabled:bool = true
@export var wrapMode:CurveWrapMode = CurveWrapMode.WRAP

func _init() -> void:
	min_value = -1
	max_value = 1

func sampleOctave(i:float) -> float:

	print(i)
	match wrapMode:
		CurveWrapMode.WRAP:
			i = fposmod(i * freq, 1)
		CurveWrapMode.MIRROR:
			i = fposmod(absf(i - 0.5) * freq, 1)
		CurveWrapMode.FLIP:
			if floori(i) % 2 == 0:
				i = fposmod(i * freq, 1)
			else:
				i = 1 - fposmod(i * freq, 1)
		CurveWrapMode.FLAT:
			if i > 1:
				i = 1
			elif i < 0:
				i = 0
			else:
				i = fposmod(i * freq, 1)
	print(i)

	return amp * sample(i) * (enabled as int)
