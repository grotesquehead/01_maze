extends ColorRect

var fade_in = false
var direction = .05



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if fade_in:
        modulate.a += direction
    else:
        modulate.a -= direction
    
    if not fade_in and modulate.a <= 0:
        get_tree().paused = false
        
