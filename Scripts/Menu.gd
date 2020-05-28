extends Node2D



func _on_fishing_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/FishingGame.tscn")
