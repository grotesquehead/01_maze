extends Actor


@export var speed: int


func _physics_process(_delta):
	var input_direction = get_input_direction()
	if input_direction:
		velocity = input_direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	set_animation(velocity)


func get_input_direction() -> Vector2:
	var input_direction_x = Input.get_axis("move_left", "move_right")
	var input_direction_y = Input.get_axis("move_up", "move_down")
	return Vector2(input_direction_x, input_direction_y)
