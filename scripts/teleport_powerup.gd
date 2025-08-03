extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("spin")

func _on_body_entered(body):
	if body.is_in_group("players"):
		print("SEMUA PEMAIN akan berteleportasi secara diagonal!")

		# Panggil fungsi di Game_manager untuk menjalankan efeknya
		var game_manager = get_node("/root/Main_game/Game_manager")
		game_manager.apply_diagonal_teleport_effect()

		# Hancurkan power-up setelah diambil
		queue_free()
