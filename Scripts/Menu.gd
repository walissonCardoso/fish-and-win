extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _on_fishing_pressed():
	var _r = get_tree().change_scene("res://Scenes/FishingGame.tscn")

func _on_competition_pressed():
	var _r = get_tree().change_scene("res://Scenes/RowingGame.tscn")
