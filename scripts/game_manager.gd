extends Node

# --- PENGATURAN PAPAN PERMAINAN ---
const BOARD_SIZE = 100 # Jumlah total kotak di papan
const TILE_COUNT = 101 # Jumlah total ubin (1-100, indeks 0 tidak dipakai)

# Ini adalah jantung dari mekanisme Ular Tangga kita.
var special_tiles = {
	# Contoh Tangga (naik)
	4: 14,
	9: 31,
	20: 38,
	28: 84,
	40: 59,
	51: 67,
	63: 81,
	71: 91,
	# Contoh Ular (turun)
	17: 7,
	54: 34,
	62: 19,
	64: 60,
	87: 24,
	93: 73,
	95: 75,
	99: 78
}

@export var player_nodes: Array[CharacterBody2D]

# Variabel global untuk durasi tween, dapat diatur di Inspector
@export var step_by_step_tween_duration: float = 0.3 # Durasi pergerakan tween per kotak (saat dadu)
@export var pause_between_steps_duration: float = 0.1 # Jeda waktu setelah setiap langkah selesai (saat dadu)
@export var fast_tween_duration: float = 0.8 # Durasi pergerakan cepat (ular/tangga)

# --- FUNGSI POWER-UP BARU ---
@export var power_up_scene: PackedScene # Export untuk memuat scene power-up dari Inspector
var has_double_dice_power_up: Array[bool] = [false, false, false, false] # Menandai pemain mana yang memiliki power-up
var power_up_instance: Area2D = null # Referensi ke instance power-up yang ada di scene

# --- VARIABEL GAME LAINNYA ---
var player_positions: Array[int] = [1, 1, 1, 1] # Menyimpan posisi setiap pemain
var current_player_index: int = 0 # Indeks pemain saat ini
var game_over: bool = false

# Visual coordinate
var tile_coordinates: Array = [
	null,
	Vector2(318.0, 583.0), Vector2(375.0, 583.0), Vector2(433.0, 583.0), Vector2(491.0, 583.0), Vector2(547.0, 583.0),
	Vector2(605.0, 583.0), Vector2(662.0, 583.0), Vector2(719.0, 583.0), Vector2(777.0, 583.0), Vector2(836.0, 583.0),
	Vector2(836.0, 525.0), Vector2(777.0, 525.0), Vector2(720.0, 525.0), Vector2(662.0, 525.0), Vector2(605.0, 525.0),
	Vector2(546.0, 525.0), Vector2(489.0, 525.0), Vector2(431.0, 525.0), Vector2(373.0, 525.0), Vector2(316.0, 525.0),
	Vector2(316.0, 467.0), Vector2(375.0, 467.0), Vector2(432.0, 467.0), Vector2(489.0, 467.0), Vector2(548.0, 467.0),
	Vector2(605.0, 467.0), Vector2(662.0, 467.0), Vector2(720.0, 467.0), Vector2(777.0, 467.0), Vector2(834.0, 467.0),
	Vector2(834.0, 410.0), Vector2(777.0, 410.0), Vector2(720.0, 410.0), Vector2(662.0, 410.0), Vector2(605.0, 410.0),
	Vector2(547.0, 410.0), Vector2(489.0, 410.0), Vector2(432.0, 410.0), Vector2(375.0, 410.0), Vector2(316.0, 410.0),
	Vector2(316.0, 353.0), Vector2(374.0, 353.0), Vector2(432.0, 353.0), Vector2(489.0, 353.0), Vector2(548.0, 353.0),
	Vector2(605.0, 353.0), Vector2(662.0, 353.0), Vector2(720.0, 353.0), Vector2(778.0, 353.0), Vector2(834.0, 353.0),
	Vector2(834.0, 295.0), Vector2(776.0, 295.0), Vector2(718.0, 295.0), Vector2(661.0, 295.0), Vector2(603.0, 295.0),
	Vector2(546.0, 295.0), Vector2(489.0, 295.0), Vector2(431.0, 295.0), Vector2(374.0, 295.0), Vector2(317.0, 295.0),
	Vector2(317.0, 238.0), Vector2(374.0, 238.0), Vector2(431.0, 238.0), Vector2(489.0, 238.0), Vector2(547.0, 238.0),
	Vector2(604.0, 238.0), Vector2(662.0, 238.0), Vector2(719.0, 238.0), Vector2(777.0, 238.0), Vector2(835.0, 238.0),
	Vector2(835.0, 180.0), Vector2(775.0, 180.0), Vector2(719.0, 180.0), Vector2(660.0, 180.0), Vector2(604.0, 180.0),
	Vector2(546.0, 180.0), Vector2(489.0, 180.0), Vector2(432.0, 180.0), Vector2(373.0, 180.0), Vector2(316.0, 180.0),
	Vector2(316.0, 124.0), Vector2(374.0, 124.0), Vector2(432.0, 124.0), Vector2(489.0, 124.0), Vector2(546.0, 124.0),
	Vector2(604.0, 124.0), Vector2(660.0, 124.0), Vector2(719.0, 124.0), Vector2(775.0, 124.0), Vector2(834.0, 124.0),
	Vector2(834.0, 67.0), Vector2(778.0, 67.0), Vector2(719.0, 67.0), Vector2(660.0, 67.0), Vector2(605.0, 67.0),
	Vector2(546.0, 67.0), Vector2(489.0, 67.0), Vector2(432.0, 67.0), Vector2(374.0, 67.0), Vector2(316.0, 67.0)
]

# References to UI
@onready var turn_info_label = $"/root/Main_game/UI/Turn_info_label"
@onready var roll_dice_button = $"/root/Main_game/UI/Roll_dice_button"

func _ready():
	# Atur posisi semua pemain ke kotak pertama saat game dimulai
	for i in range(player_nodes.size()):
		player_nodes[i].position = tile_coordinates[1]
		player_nodes[i].get_node("AnimatedSprite").play("idle")
		
		# Set semua pemain tidak memiliki power-up saat game dimulai
		has_double_dice_power_up[i] = false

	# Hubungkan sinyal 'pressed' dari tombol dadu ke fungsi _on_roll_dice_button_pressed
	roll_dice_button.pressed.connect(_on_roll_dice_button_pressed)
	
	# Spawn power-up saat game dimulai
	spawn_power_up()
	
	# Mulai giliran pertama
	start_turn()

# Fungsi baru untuk membuat dan menempatkan power-up di papan
func spawn_power_up():
	# Hapus power-up yang lama jika masih ada
	if is_instance_valid(power_up_instance):
		power_up_instance.queue_free()
		power_up_instance = null
		
	if power_up_scene:
		power_up_instance = power_up_scene.instantiate()
		
		# Hubungkan sinyal 'picked_up' dari power-up ke fungsi di skrip ini
		if power_up_instance.has_signal("picked_up"):
			power_up_instance.picked_up.connect(_on_power_up_picked_up)
		
		# Tempatkan power-up di kotak acak yang bukan kotak awal atau akhir
		var random_tile = randi_range(2, BOARD_SIZE - 1)
		power_up_instance.position = tile_coordinates[random_tile]
		add_child(power_up_instance)
		print("Power-up ditempatkan di kotak: ", random_tile)

# Fungsi yang dipanggil saat power-up diambil oleh pemain
func _on_power_up_picked_up():
	# Beri pemain saat ini power-up
	has_double_dice_power_up[current_player_index] = true
	print("Pemain %d mengambil Power-Up 'Double Dice'!" % (current_player_index + 1))
	# Setelah power-up diambil, spawn power-up baru setelah beberapa saat
	await get_tree().create_timer(3.0).timeout
	spawn_power_up()
	

func start_turn():
	# Hentikan fungsi jika game sudah berakhir
	if game_over:
		return

	# Perbarui label informasi giliran
	turn_info_label.text = "Giliran Pemain %d" % (current_player_index + 1)
	
	# Beri tahu pemain jika mereka memiliki power-up
	if has_double_dice_power_up[current_player_index]:
		turn_info_label.text += " (Power-up AKTIF!)"
		
	# Aktifkan tombol dadu
	roll_dice_button.disabled = false

func _on_roll_dice_button_pressed():
	# Hentikan fungsi jika game sudah berakhir
	if game_over:
		return
	
	# Nonaktifkan tombol dadu saat giliran sedang berlangsung
	roll_dice_button.disabled = true
	
	# 1. Lempar dadu
	var dice_result = randi_range(1, 6) # Dadu menghasilkan angka 1 sampai 6
	
	# LOGIKA BARU: Terapkan power-up 'Double Dice' jika dimiliki
	if has_double_dice_power_up[current_player_index]:
		print("POWER-UP AKTIF! Hasil dadu digandakan.")
		dice_result *= 2
		# Reset power-up setelah digunakan
		has_double_dice_power_up[current_player_index] = false
	
	var current_pos = player_positions[current_player_index] # Posisi pemain saat ini
	var target_pos_after_dice = current_pos + dice_result # Posisi tujuan setelah lemparan dadu
	
	print("Pemain %d (di kotak %d) melempar dadu: %d" % [current_player_index + 1, current_pos, dice_result])

	# 2. Aturan Kemenangan: Harus pas di kotak terakhir (BOARD_SIZE)
	if target_pos_after_dice > BOARD_SIZE:
		# Jika lemparan melebihi kotak 100, pemain tetap di tempat.
		print("Terlalu jauh! Pemain %d tetap di kotak %d" % [current_player_index + 1, current_pos])
		# Pindah ke giliran selanjutnya tanpa bergerak
		next_turn()
		return
	
	# Pindahkan pemain selangkah demi selangkah ke posisi setelah dadu dilempar
	# Fungsi ini akan menunggu hingga semua langkah selesai
	await _move_player_step_by_step(current_pos, target_pos_after_dice)

	# Perbarui posisi pemain setelah pergerakan dadu selesai
	player_positions[current_player_index] = target_pos_after_dice

	# 3. Pengecekan Ular dan Tangga (setelah pergerakan dadu selesai)
	var final_pos = target_pos_after_dice
	
	if special_tiles.has(target_pos_after_dice):
		final_pos = special_tiles[target_pos_after_dice] # Dapatkan posisi akhir dari ular/tangga
		
		if final_pos > target_pos_after_dice:
			print("Naik Tangga! Dari %d ke %d" % [target_pos_after_dice, final_pos])
			# Di sini Anda bisa menambahkan SFX atau animasi khusus tangga
		else:
			print("Turun Ular! Dari %d ke %d" % [target_pos_after_dice, final_pos])
			# Di sini Anda bisa menambahkan SFX atau animasi khusus ular
		
		# Pindahkan pemain langsung ke posisi ular/tangga dengan kecepatan cepat
		# Fungsi ini akan menunggu hingga pergerakan cepat selesai
		await _move_player_fast(final_pos)
		# Perbarui posisi pemain ke posisi akhir setelah ular/tangga
		player_positions[current_player_index] = final_pos
	
	# 4. Cek kemenangan setelah semua pergerakan (dadu + ular/tangga)
	if player_positions[current_player_index] == BOARD_SIZE:
		game_over = true # Set status game berakhir
		turn_info_label.text = "Pemain %d MENANG!" % (current_player_index + 1) # Perbarui label kemenangan
		# player_nodes[current_player_index].play("celebrate") # Animasi kemenangan (jika ada)
		print("Pemain %d MENANG!" % (current_player_index + 1))
		return # Hentikan proses karena game sudah berakhir
	
	# 5. Pindah ke giliran selanjutnya
	await get_tree().create_timer(0.5).timeout # Beri jeda sedikit sebelum ganti giliran
	next_turn()

# --- FUNGSI PERGERAKAN BARU ---

# Fungsi untuk pergerakan pemain selangkah demi selangkah (untuk lemparan dadu)
func _move_player_step_by_step(start_tile_number: int, end_tile_number: int):
	# player_node sekarang adalah Area2D
	var player_node = player_nodes[current_player_index]
	# Animasinya masih dari child node
	var player_sprite = player_node.get_node("AnimatedSprite")
	player_sprite.play("walk")

	var step_direction = 1
	if start_tile_number > end_tile_number:
		step_direction = -1

	for i in range(start_tile_number, end_tile_number, step_direction):
		var next_tile_number = i + step_direction
		
		if next_tile_number > BOARD_SIZE:
			next_tile_number = BOARD_SIZE
		
		var target_position = tile_coordinates[next_tile_number]
		
		var tween = create_tween()
		
		# TWEAK DISINI: Tween position dari player_node (Area2D)
		tween.tween_property(player_node, "position", target_position, step_by_step_tween_duration).set_trans(Tween.TRANS_LINEAR)
		await tween.finished
		
		if next_tile_number != end_tile_number:
			await get_tree().create_timer(pause_between_steps_duration).timeout
		
		if next_tile_number == end_tile_number:
			break
	
	player_sprite.play("idle")

# Fungsi untuk pergerakan pemain secara cepat (untuk ular atau tangga)
func _move_player_fast(target_tile_number):
	# player_node adalah Area2D
	var player_node = player_nodes[current_player_index]
	var player_sprite = player_node.get_node("AnimatedSprite")
	var target_position = tile_coordinates[target_tile_number]
	
	player_sprite.play("walk") # atau animasi khusus
	var tween = create_tween()
	
	# TWEAK DISINI: Tween position dari player_node (Area2D)
	tween.tween_property(player_node, "position", target_position, fast_tween_duration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	player_sprite.play("idle")

# --- FUNGSI UTAMA LAINNYA ---

func next_turn():
	# Set animasi pemain saat ini ke idle sebelum ganti giliran
	player_nodes[current_player_index].get_node("AnimatedSprite").play("idle")
	# Pindah ke pemain selanjutnya (menggunakan modulo untuk kembali ke pemain 1 setelah pemain terakhir)
	current_player_index = (current_player_index + 1) % player_nodes.size()
	# Mulai giliran pemain berikutnya
	start_turn()
