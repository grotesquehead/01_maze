extends Actor


const SPEED: int = 240
const BLINK_DURATION: float = 0.1875
const BLINK_INTERVAL_MIN: float = 2.0 - BLINK_DURATION
const BLINK_INTERVAL_MAX: float = 10.0 - BLINK_DURATION

@export var sprite_base: Texture
@export var sprite_blink: Texture

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer = $Timer


func _ready():
	timer.wait_time = randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)
	timer.start()


func _physics_process(_delta):
	var input_direction = get_input_direction()
	if input_direction:
		velocity = input_direction * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	set_animation(velocity)


func get_input_direction() -> Vector2:
	var input_direction_x = Input.get_axis("move_left", "move_right")
	var input_direction_y = Input.get_axis("move_up", "move_down")
	return Vector2(input_direction_x, input_direction_y)


func _on_timer_timeout():
	if sprite.texture == sprite_blink:
		sprite.texture = sprite_base
		timer.wait_time = randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)
	else:
		sprite.texture = sprite_blink
		timer.wait_time = BLINK_DURATION
	timer.start()
