extends PathFollow2D

signal movement_finished # Sinyal saat bot selesai bergerak

@export var speed := 200 # Kecepatan gerakan

var moving = false
var target_position = Vector2.ZERO
var current_point_index = 0
var steps_to_take = 0

## Inisialisasi posisi bot di titik awal path
func _ready():
	var path = get_parent().curve
	if path != null and path.get_point_count() > 0:
		global_position = path.get_point_position(0)
		current_point_index = 1 # mulai dari point ke-1

## Menggerakkan bot ke target_position setiap frame
## @param delta: Waktu antar frame
func _process(delta):
	if moving:
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta
		
		if global_position.distance_to(target_position) < 5.0:
			global_position = target_position
			moving = false
			steps_to_take -= 1
			if steps_to_take > 0:
				_move_to_next_point()
			else:
				movement_finished.emit() # Kirim sinyal saat selesai

## Memulai pergerakan dengan jumlah langkah tertentu
## @param steps: Jumlah langkah yang akan ditempuh
func start_movement(steps: int):
	if not moving:
		var path = get_parent().curve
		if current_point_index < path.get_point_count():
			steps_to_take = min(steps, path.get_point_count() - current_point_index)
			_move_to_next_point()		

## Mengatur pergerakan ke titik berikutnya di path
func _move_to_next_point():
	var path = get_parent().curve
	if current_point_index < path.get_point_count():
		target_position = path.get_point_position(current_point_index)
		moving = true
		current_point_index += 1
