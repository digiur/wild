extends Node

@export var curve:Curve
@export var noise:FastNoiseLite

func _ready() -> void:
	
	for i:float in range(101):
		var j:float = i / 100
		print("curve ", j, " ", curve.sample(j))

	for i:float in range(101):
		var j:float = i * 10
		print("noise ", j, " ", noise.get_noise_1d(j))

	for i:float in range(-10,10,1):
		print("fposmod ", i/3, " ", fposmod(i/3, 1))
