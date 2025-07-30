extends PathFollow2D
signal movement_finished

@export var speed := 100 # Kecepatan gerakan
@export var hitbox: Area2D # Area2D untuk mendeteksi tangga
@onready var sprite = $CharacterBody2D/AnimatedSprite2D

var moving = false
var target_position = Vector2.ZERO
var current_point_index = 0
var steps_to_take = 0

## Inisialisasi posisi sprite dan menghubungkan sinyal random_generator
func _ready():
	var path = get_parent().curve
	if path != null and path.get_point_count() > 0:
		global_position = path.get_point_position(0)
		current_point_index = 1 # mulai dari point ke-1 (karena sudah di point 0)

## Menggerakkan sprite ke target_position setiap frame
## @param delta: Waktu antar frame
func _process(delta):
	if moving:
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta
		sprite.play("walk")
		
		if global_position.distance_to(target_position) < 5.0: # if jarak player dengan tujuan kurang dari 5 pixel
			global_position = target_position # snap posisi ke titik
			moving = false
			steps_to_take -= 1 # kurangi steps
			if steps_to_take > 0:
				_move_to_next_point()
			else:	
				movement_finished.emit()
	else:
		sprite.play("Idle")
				 

## Memulai pergerakan dengan jumlah langkah tertentu
## @param steps: Jumlah langkah yang akan ditempuh
func start_movement(steps: int):
	if not moving:
		var path = get_parent().curve # ambil data di Path2D
		if current_point_index < path.get_point_count(): # cek titik < titik tujuan
			steps_to_take = min(steps, path.get_point_count() - current_point_index) # set jml langkah
			_move_to_next_point()

## Mengatur pergerakan ke titik berikutnya di path
func _move_to_next_point():
	var path = get_parent().curve # ambil data di Path2D
	if current_point_index < path.get_point_count(): # cek titik < titik tujuan
		target_position = path.get_point_position(current_point_index)
		moving = true
		current_point_index += 1
		
func _on_area_2d_body_entered(_body: Node2D) -> void:
	if movement_finished and !moving:  # Jika movement_finished adalah sinyal, ini harus diganti pengecekan kondisi boolean
		var count = hitbox.target_point_index
		var path = get_parent().curve
		if count < path.get_point_count():
			current_point_index = count
			target_position = path.get_point_position(current_point_index)
			moving = true
			current_point_index += 1
			# Menunggu 1 frame agar animasi atau gerakan bisa dimulai
				
		else:
			print("Player cannot jump: index target melebihi jumlah point")
			movement_finished.emit()

		print(count)
	else:
		print("Player tidak bisa lompat: movement belum selesai")
