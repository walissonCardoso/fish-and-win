extends Node2D

onready var screen_size = get_viewport().get_visible_rect().size
# Number the player has to achieve in order to win
export (int) var fish_to_win = 20
# Fish currently caught by the player
var caught_fish = 0
var capture_position = Vector2.ZERO
var elipsed_time = 0

func _ready():
	$HUD/timer/growAnim.play("grow")
	$HUD/tutorial.rect_position = $Player.position - Vector2(120, 120)
	get_tree().paused = true

func _input(_event):
	if Input.is_action_just_released("ui_accept"):
		$HUD/pauseMenu.rect_position = $Player.position - Vector2(64, 88)
		$HUD/pauseMenu.show()
		get_tree().paused = true

func _process(delta):
	elipsed_time += delta
	# Convert to format mm:ss
	var time_str = str(int(elipsed_time / 60)) + ":" + str(int(elipsed_time) % 60).pad_zeros(2)
	$HUD/timer.set_text(time_str)
	# The timer follows the player
	$HUD/timer.rect_position = $Player.position - Vector2(14, screen_size.y * 0.4)
	# As well as the camera
	$Camera2D.position = $Player.position

func inc_fish(position):
	# Save capture
	capture_position = Vector2(position[0], position[1])
	# This function should only be called when a new fish is caught. It updates
	# the player score
	caught_fish += 1
	# score in string format
	var score_str = str(caught_fish).pad_zeros(2)
	# Set text on number label
	$HUD/scorer/number.set_text(score_str)
	# Set position of the scorer right above the player's bait
	$HUD/scorer.rect_position = $Player/standing.global_position - Vector2(28, 0)
	# Set scorer visible
	$HUD/scorer.visible = true
	# Start timer to set scorer invisible again after 2 seconds
	$HUD/scorer/scoreVisible.start(1)
	# Check if player has won
	if caught_fish >= fish_to_win:
		game_over()

func game_over():
	# Display resutl according to time taken by the player
	$HUD/gameOver.rect_position = $Player.position - Vector2(120, 120)
	if elipsed_time < 80:
		# I don't know if it's actually possible to reach fishing god
		$HUD/gameOver/result.set_text("Result: fishing god")
	elif elipsed_time < 105:
		$HUD/gameOver/result.set_text("Result: fishing master")
	elif elipsed_time < 125:
		$HUD/gameOver/result.set_text("Result: fishing pro")
	elif elipsed_time < 180:
		$HUD/gameOver/result.set_text("Result: good fisherman")
	elif elipsed_time < 260:
		$HUD/gameOver/result.set_text("Result: need to improve")
	else:
		$HUD/gameOver/result.set_text("Result: rookie")
	
	# Display time and pause everything else.
	# Game over menu won't pause
	var time_str = str(int(elipsed_time / 60)) + ":" + str(int(elipsed_time) % 60).pad_zeros(2)
	$HUD/gameOver/time.set_text('Time: ' + time_str)
	$HUD/gameOver.show()
	get_tree().paused = true

# Signal functions

func _on_scoreVisible_timeout():
	# Set scorer back to invisible
	$HUD/scorer.visible = false

func _on_continue_pressed():
	# Player pressed continue on pause menu
	get_tree().paused = false
	$HUD/pauseMenu.hide()

func _on_menu_pressed():
	# Player pressed "menu" on pause menu
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Menu.tscn")

func _on_tutorial_ok_pressed():
	# Player pressed ok on tutorial menu
	get_tree().paused = false
	$HUD/tutorial.hide()

func _on_gameover_ok_pressed():
	# Player pressed ok on game over menu
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Menu.tscn")
