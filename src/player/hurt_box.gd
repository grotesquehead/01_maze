extends Area2D


signal hit()


func take_damage():
    hit.emit()
