extends Node2D

@onready var sprite = $Path2D/PathFollow2D/CharacterBody2D/AnimatedSprite2D
@export var random_button: Node # Node RandomButton
@export var player: Node # Node Player
@export var bot1: Node # Node Bot (pertama)
@export var bot2: Node # Node Bot (kedua)
@export var bot3: Node # Node Bot (ketiga)

var current_turn = 0 # 0: Player, 1: Bot1, 2: Bot2, 3: Bot3
var turn_order = [] # Array untuk menyimpan urutan node

## Menghubungkan sinyal dari RandomButton, Player, dan semua Bot
func _ready():
	turn_order = [player, bot1, bot2, bot3]
	if random_button and random_button.has_signal("number_generated"): # cek sinyal dari button.gd
		random_button.number_generated.connect(_on_number_generated) # connect value ke func _on_number_generated
	for i in range(turn_order.size()): # cek index array
		if turn_order[i] and turn_order[i].has_signal("movement_finished"): # cek jika ada sinyal
			turn_order[i].movement_finished.connect(_on_movement_finished.bind(i))

## Menangani angka acak dari RandomButton untuk pemain
## @param number: Angka acak dari RandomButton
func _on_number_generated(number: int):
	if current_turn == 0 and player and player.has_method("start_movement"): # jika player 
		player.start_movement(number) # player melangkah sesuai value number

## Menangani selesainya pergerakan dan mengalihkan giliran
## @param turn_index: Indeks giliran yang selesai
func _on_movement_finished(turn_index: int):
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_advance_turn.bind(turn_index))
	timer.start()

## Memajukan giliran ke entitas berikutnya
## @param prev_turn_index: Indeks giliran sebelumnya
func _advance_turn(prev_turn_index: int):
	current_turn = (prev_turn_index + 1) % turn_order.size() # Giliran berikutnya
	if current_turn == 0:
		return # Menunggu tombol ditekan untuk giliran pemain
	var next_entity = turn_order[current_turn]
	if next_entity and next_entity.has_method("start_movement"):
		var bot_number = randi_range(1, 6) # Angka acak baru untuk bot
		next_entity.start_movement(bot_number)
