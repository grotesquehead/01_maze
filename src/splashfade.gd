extends Node2D


var fade_in = false
var direction = .01



# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _anykey_down(event) -> bool:
    return event is InputEventMouseButton or event is InputEventKey or event is InputEventJoypadButton
    

func _input(event):
    if $Black.modulate.a <= 0 :
        if _anykey_down(event):
            fade_in = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if fade_in:
        $Black.modulate.a += direction
    else:
        $Black.modulate.a -= direction
    
    if fade_in and $Black.modulate.a >= 1:
        get_tree().change_scene_to_file("res://maze.tscn")
