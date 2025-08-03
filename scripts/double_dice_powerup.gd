# DoubleDicePowerUp.gd
extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("spin")
# Fungsi ini akan otomatis terpanggil saat ada body yang masuk ke area deteksi
func _on_body_entered(body):
		# Kita cek apakah body yang masuk ada di grup 'players'
	if body.is_in_group("players"):
		print("Power-up disentuh oleh: " + body.name)
		# Panggil fungsi di script pemain untuk memberinya power-up
		# Kita akan membuat fungsi ini di Langkah 3
		body.gain_double_dice_power_up()

		# Hancurkan/hilangkan power-up dari papan setelah diambil
		queue_free()
