extends Area2D

@export var target_point_index: int = 0 # Indeks titik tujuan tangga di Path2D

## Mengembalikan indeks titik tujuan tangga
## @return: Indeks titik tujuan
func get_ladder_target() -> int:
	return target_point_index
