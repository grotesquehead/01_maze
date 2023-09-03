extends CharacterBody2D


signal dead()

const SPEED: int = 240
const BLINK_DURATION: float = 0.15
const BLINK_INTERVAL_MIN: float = 2.0 - BLINK_DURATION
const BLINK_INTERVAL_MAX: float = 10.0 - BLINK_DURATION

var input_enabled = true

@export var sprite_base: Texture
@export var sprite_blink: Texture

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer = $Timer
@onready var animation_tree: AnimationTree = $AnimationTree


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
    if input_enabled:
        return Vector2(input_direction_x, input_direction_y)
    else:
        return Vector2.ZERO


func _on_timer_timeout():
    if sprite.texture == sprite_blink:
        sprite.texture = sprite_base
        timer.wait_time = randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)
    else:
        sprite.texture = sprite_blink
        timer.wait_time = BLINK_DURATION
    timer.start()


func _on_hurt_box_hit():
    input_enabled = false
    $Sprite2D.visible = false
    $DeathSprite.visible = true
    $DeathSprite/AnimationPlayer.play("death")

func emit_death_signal():
    dead.emit()


func set_animation(direction):
    if direction:
        animation_tree.get("parameters/playback").travel("walk")
        animation_tree.set("parameters/idle/blend_position", direction)
        animation_tree.set("parameters/walk/blend_position", direction)
    else:
        animation_tree.get("parameters/playback").travel("idle")
