extends Node

@export var curve:Curve
@export var noise:FastNoiseLite
@export var curveOctave:CurveOctave
@export var noiseOctave:NoiseOctave

func _ready() -> void:

	print("=======================================")
	var min:float = INF
	var max:float = -INF
	for i:float in range(101):
		var j:float = i / 100
		var sample:float = curve.sample(j)
		min = minf(sample, min)
		max = maxf(sample, max)
		print("curve ", j, " ", sample)

	print("min ", min)
	print("max ", max)


	print("=======================================")
	min = INF
	max = -INF
	for i:float in range(101):
		var j:float = i * 10
		var sample:float = noise.get_noise_1d(j)
		min = minf(sample, min)
		max = maxf(sample, max)
		print("noise ", j, " ", sample)

	print("min ", min)
	print("max ", max)


	print("=======================================")
	min = INF
	max = -INF
	for i:float in range(101):
		var j:float = i / 100
		var sample:float = curveOctave.sampleOctave(j)
		min = minf(sample, min)
		max = maxf(sample, max)
		print("curveOctave ", j, " ", sample)

	print("min ", min)
	print("max ", max)


	print("=======================================")
	min = INF
	max = -INF
	for i:float in range(101):
		var j:float = i * 10
		var sample:float = noiseOctave.sampleOctave(j)
		min = minf(sample, min)
		max = maxf(sample, max)
		print("noiseOctave ", j, " ", sample)

	print("min ", min)
	print("max ", max)

