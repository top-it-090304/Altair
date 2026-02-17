extends Node2D
var time = 0.0
var speed = 2.0 
var amplitude = 80.0

signal hit

func _process(delta):
	time += delta * speed
	rotation_degrees = sin(time) * amplitude
	
