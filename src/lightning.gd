extends PointLight2D


const LIGHTNING_DURATION: float = 0.25
const LIGHTNING_INTERVAL_MIN: float = 5.0 - LIGHTNING_DURATION
const LIGHTNING_INTERVAL_MAX: float = 20.0 - LIGHTNING_DURATION
const LIGHTNING_BRIGHTNESS_MAX: float = 0.5

var change: float = -2.5

@onready var thunder_sound: AudioStreamPlayer2D = $Thunder
@onready var timer: Timer = $Timer


func _ready():
    color.a = 0
    timer.wait_time = randf_range(LIGHTNING_INTERVAL_MIN, LIGHTNING_INTERVAL_MAX)
    timer.start()


func _process(delta):
    color.a += change * delta
    color.a = clamp(color.a, 0, LIGHTNING_BRIGHTNESS_MAX)


func _on_timer_timeout():
    change = -change
    if change > 0:
        timer.wait_time = LIGHTNING_DURATION
    else:
        timer.wait_time = randf_range(LIGHTNING_INTERVAL_MIN, LIGHTNING_INTERVAL_MAX)
        thunder_sound.play()
    timer.start()
