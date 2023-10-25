class_name CurveOctave
extends Curve

@export var amp:float = 0.5
@export var freq:float = 1
@export var enabled:bool = true

func sampleOctave(i:float) -> float:
	return (2 * amp * sample(fposmod(i * freq, 1))) - 1 if enabled else 0
