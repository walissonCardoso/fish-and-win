extends Node2D

# Get size of the screen
onready var screen_size = get_viewport().get_visible_rect().size
# This variable is set when someone wins
var winning_player = null

func _ready():
	# Set players to competition mode
	$Player1.set_competition_mode(1)
	$Player2.set_competition_mode(2)

func _process(_delta):
	# Display velocity on screen
	$Player1/velocity.value = $Player1.velocity.x
	$Player2/velocity.value = $Player2.velocity.x

func _on_Area2D_body_entered(player):
	# Someone is above the finishing line
	if !winning_player:
		winning_player = player.player_number

func winner():
	# Returns the value of winner
	return winning_player

func _on_tutorial_ok_pressed():
	# Player pressed ok on tutorial menu
	get_tree().paused = false
	$HUD/tutorial.hide()
	$HUD/counter.show()
	$HUD/counter/animation.play("countdown")
	$HUD/counter/bip.play()

# warning-ignore:unused_argument
func _on_counter_animation_finished(anim_name):
	# The animation finishes at every three seconds. So we change between
	# sprites in those moments. When frame reaches frame zero, the counting ends
	if $HUD/counter/numbers.frame > 0:
		$HUD/counter/numbers.frame -= 1
		$HUD/counter/animation.play("countdown")
		$HUD/counter/bip.play()
	else:
		# Let players move on countdown ending
		$HUD/counter.hide()
		$Player1.ignore_input = false
		$Player2.ignore_input = false
		$HUD/counter/horn.play(0.2)
