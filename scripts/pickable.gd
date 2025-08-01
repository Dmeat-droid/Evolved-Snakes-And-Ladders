extends Node2D

signal picked_up
func _ready() -> void:
	$AnimatedSprite2D.play("spin")

func _on_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Player"):
		queue_free()
		picked_up.emit()
