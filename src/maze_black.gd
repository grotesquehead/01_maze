extends ColorRect

var fade_in = false
var direction = .05
var active = true

signal on_fade_in()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if active:
        if fade_in:
            modulate.a += direction
        else:
            modulate.a -= direction
        
        if not fade_in and modulate.a <= 0:
            get_tree().paused = false
            active = false
        elif fade_in and modulate.a >= 1:
            emit_signal("on_fade_in")
            fade_in = false
        
