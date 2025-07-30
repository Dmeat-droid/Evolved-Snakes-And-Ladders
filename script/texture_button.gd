extends TextureButton

@onready var dice_animation = $DiceAnimation

signal number_generated(number: int) # Sinyal untuk mengirim angka acak
var random_number: int = 0 # Angka acak yang dihasilkan (1-6)

## Menghubungkan sinyal pressed saat tombol dimuat
func _ready():
	pressed.connect(_on_button_pressed)
	dice_animation.animation_finished.connect(_on_dice_animation_finished)

## Menghasilkan angka acak 1-6 saat tombol ditekan
func _on_button_pressed():
	random_number = randi_range(1, 6)
	dice_animation.play("rolling")
	

func _on_dice_animation_finished():
	dice_animation.play("dice_face")
	dice_animation.frame = random_number - 1
	number_generated.emit(random_number)
	
	
## Mengembalikan angka acak yang dihasilkan
## @return: Angka acak dari 1 hingga 6
func get_random_number() -> int:
	return random_number
