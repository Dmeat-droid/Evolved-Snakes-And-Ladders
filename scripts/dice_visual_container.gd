extends Node2D

@onready var dice_scene = preload("res://Scenes/dice_visual.tscn")
var dice_instance: Node2D
var animation_node: AnimatedSprite2D

func _ready():
	dice_instance = dice_scene.instantiate()
	add_child(dice_instance)
	animation_node = dice_instance.find_child("dice_animation")
func get_dice_animation_node() -> AnimatedSprite2D:
	return animation_node
