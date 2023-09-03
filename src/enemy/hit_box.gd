extends Area2D


func _on_area_entered(hurt_box):
    hurt_box.take_damage()
    $"../Sprite2D2".visible = true
    $"../Sprite2D".visible = false
    $"../AnimationPlayer".play("swing")
