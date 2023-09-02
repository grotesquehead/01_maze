extends ColorRect

var fade_in = false
var direction = .005
var active = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if active:
        if fade_in:
            modulate.a += direction
        else:
            modulate.a -= direction
        
        if not fade_in and modulate.a <= 0:
            print(":dsfsdfsdfsdf")
            get_tree().paused = false
            active = false
        elif fade_in and modulate.a >= 1:
            var p = get_parent().get_parent()
            p.reset(true)
            fade_in = false
        
