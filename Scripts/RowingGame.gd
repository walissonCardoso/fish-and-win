extends Node

# references to all cameras
onready var main_camera = $singleScreen/Viewport/Camera
onready var left_camera = $splitScreen/left/Viewport/Camera
onready var right_camera = $splitScreen/right/Viewport/Camera

# World is the game we made in raceTrack
onready var world = $singleScreen/Viewport/raceTrack

# Get size of the screen
onready var screen_size = get_viewport().get_visible_rect().size

# The game starts if no split screen
var n_screens = 1
var game_is_over = false

func _ready():
	var viewport_main = $singleScreen/Viewport
	var viewport_left = $splitScreen/left/Viewport
	var viewport_right = $splitScreen/right/Viewport
	
	# Share world between cameras
	viewport_left.world_2d = viewport_main.world_2d
	viewport_right.world_2d = viewport_main.world_2d
	
	# Set the y coordinate the same for all cameras
	main_camera.position.y = 120
	left_camera.position.y = 120
	right_camera.position.y = 120

func _process(_delta):
	# Get positions of the players
	var x1 = world.get_node("Player1").position.x
	var x2 = world.get_node("Player2").position.x
	
	# Verify if the players are too far apart to fit in the screen.
	# In this case, we split the screen
	verify_split(x1, x2)
	# Update cameras' positions
	update_camera(x1, x2)
	
	# Check if someone won
	var winner = $singleScreen/Viewport/raceTrack.winner()
	if winner:
		game_over(winner)

func update_camera(x1, x2):
	# Update cameras' positions
	if n_screens == 1:
		# If game is over, show only the winner.
		# If not, if players fit in the screen, show both
		if game_is_over:
			main_camera.position.x = max(x1, x2)
		else:
			main_camera.position.x = (x1 + x2) / 2
	else:
		# If we can't show both players on same screen, we split the screen
		# and position each camera above the players
		var x_min = min(x1, x2)
		var x_max = max(x1, x2)
		# Here we offset in relation to the main camera
		left_camera.position.x = x_min + 60
		right_camera.position.x = x_max - 60

func verify_split(x1, x2):
	# This function verifies if both players fit in the screen
	var distance = abs(x1 - x2)
	# We give 160 px extra so we see the whole boat
	var screen_range = (screen_size[0] - 160) * main_camera.zoom.x
	
	# If distance is too big, split screen.
	# If game is over, don't allow the split
	if distance > screen_range and n_screens == 1 and !game_is_over:
		split_screen(true)
	elif distance < screen_range and n_screens == 2:
		split_screen(false)

func split_screen(split):
	# We actually keep three view ports. One for left, one for right, and one
	# main one that can see the whole window. When we change between screens, we
	# simply hide one of the viewport containers. This causes flickering, but
	# I could not solve this issue.
	if split:
		n_screens = 2
		$splitScreen.show()
		$singleScreen.hide()
	else:
		n_screens = 1
		$singleScreen.show()
		$splitScreen.hide()

func game_over(winner):
	# If game is over, execute this function
	game_is_over = true
	# Disable player command
	$singleScreen/Viewport/raceTrack/Player1.ignore_input = true
	$singleScreen/Viewport/raceTrack/Player2.ignore_input = true
	
	# Get winner and size of the game_over panel
	var winner_str = 'Player ' + str(winner)
	var panel_size = $singleScreen/Viewport/gameOver.rect_size.x
	
	# x coordinate of the players
	var x1 = $singleScreen/Viewport/raceTrack/Player1.position.x
	var x2 = $singleScreen/Viewport/raceTrack/Player2.position.x
	
	# gameOver panel appears in the center of the main camera
	$singleScreen/Viewport/gameOver.rect_position.x = main_camera.position.x - panel_size / 2
	
	# Check if gameOver is visible. If not, turn visible.
	# This avoid multiple calls to show()
	if !$singleScreen/Viewport/gameOver.visible:
		# Disable split
		split_screen(false)
		$singleScreen/Viewport/gameOver.show()
		$singleScreen/Viewport/gameOver/playerWin.set_text(winner_str)

func _on_gameover_playAgain_pressed():
	var _r = get_tree().change_scene("res://Scenes/RowingGame.tscn")

func _on_gameover_menu_pressed():
	var _r = get_tree().change_scene("res://Scenes/Menu.tscn")
