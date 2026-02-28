extends Node2D

@onready var sprite: Sprite2D = $Image

var state: int = Global.States.CLEAR
var curr_pos: Vector2i
var pre_pos: Vector2i



func setup(cell_state: int, pos: Vector2i) -> void:
	curr_pos = pos
	set_state(cell_state)


func set_state(new_state: int) -> void:
	if state == new_state:
		return

	state = new_state
	update_visual()
	animate_state()


func update_visual() -> void:
	match state:
		Global.States.CLEAR:
			sprite.texture = null
		Global.States.SUN:
			sprite.texture = load("res://assets/cell/state_sun.png")
		Global.States.PARTLY_CLOUD:
			sprite.texture = load("res://assets/cell/state_partly_cloud.png")
		Global.States.CLOUD:
			sprite.texture = load("res://assets/cell/state_cloud.png")
		Global.States.RAIN:
			sprite.texture = load("res://assets/cell/state_rain.png")
		Global.States.STORM:
			sprite.texture = load("res://assets/cell/state_storm.png")


func animate_state() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	if state == Global.States.CLEAR:
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	else:
		sprite.scale = Vector2.ZERO
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.25)
