extends Node2D

@onready var image = $Image

func setimage(path):
	image.texture = load(path)
