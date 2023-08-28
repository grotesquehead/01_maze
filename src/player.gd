extends CharacterBody2D


@export var speed: int


func _physics_process(_delta):
    var input_direction = get_input_direction()
    if input_direction:
        velocity = input_direction * speed
        $AnimationPlayer.play("walk_down")
    else:
        velocity = Vector2.ZERO
        $AnimationPlayer.play("idle")
    move_and_slide()


func get_input_direction() -> Vector2:
    var input_direction_x = Input.get_axis("move_left", "move_right")
    var input_direction_y = Input.get_axis("move_up", "move_down")
    return Vector2(input_direction_x, input_direction_y)
