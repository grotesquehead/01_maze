extends CharacterBody2D


@export var speed: int

@onready var animation_tree: AnimationTree = $AnimationTree


func _physics_process(_delta):
	var input_direction = get_input_direction()
	if input_direction:
		velocity = input_direction * speed
		animation_tree.get("parameters/playback").travel("walk")
		animation_tree.set("parameters/idle/blend_position", input_direction)
		animation_tree.set("parameters/walk/blend_position", input_direction)
	else:
		velocity = Vector2.ZERO
		animation_tree.get("parameters/playback").travel("idle")
	move_and_slide()
	set_animation(input_direction)


func get_input_direction() -> Vector2:
	var input_direction_x = Input.get_axis("move_left", "move_right")
	var input_direction_y = Input.get_axis("move_up", "move_down")
	return Vector2(input_direction_x, input_direction_y)


func set_animation(direction):
	if direction:
		animation_tree.get("parameters/playback").travel("walk")
		animation_tree.set("parameters/idle/blend_position", direction)
		animation_tree.set("parameters/walk/blend_position", direction)
	else:
		animation_tree.get("parameters/playback").travel("idle")
