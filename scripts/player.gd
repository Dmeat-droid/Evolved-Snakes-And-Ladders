extends CharacterBody2D

# Save player's powerup status
var has_double_dice: bool = false

# If player touch the power up
func gain_double_dice_power_up():
	print(name + " sekarang punya power-up Double Dice!")
	has_double_dice = true

func apply_and_consume_power_up(dice_result: int) -> int:
	if has_double_dice:
		print("POWER-UP " + name + " DIGUNAKAN! Hasil dadu digandakan.")
		has_double_dice = false # Empty the power up
		return dice_result * 2
	else:
		return dice_result
