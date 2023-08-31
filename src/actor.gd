class_name Actor
extends CharacterBody2D


@onready var animation_tree: AnimationTree = $AnimationTree


func set_animation(direction):
	if direction:
		animation_tree.get("parameters/playback").travel("walk")
		animation_tree.set("parameters/idle/blend_position", direction)
		animation_tree.set("parameters/walk/blend_position", direction)
	else:
		animation_tree.get("parameters/playback").travel("idle")
