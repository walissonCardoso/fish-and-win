extends KinematicBody2D

# Add speed for each arm
export (float) var impulse = 25
# Resistence the floor causes to the boat
export (float) var friction = 0.4
# Maximum distance a fish can be caught
export (float) var fishable_distance = 125

# The code below is inspired on a car movement
# Distance from the front and back of the boat
var front_space = 35
# Rotation angle from front axis
var steering_angle = 0.52 # 30º
# Actual turning
var steer_angle = 0
# Direction to turn (-1 for left and +1 for right)
var turn = 0

# Intial velocity is zero
var velocity = Vector2.ZERO
# Amount of time to wait before row again
var waiting_time = 1

# Position of the bait in the water
var bait = Vector2.ZERO

func _ready():
	bait = position

func _input(_event):
	if Input.is_action_just_pressed("place_bait"):
		positionate_bait()
	elif Input.is_action_just_pressed("ui_down") and $standing.visible:
		try_to_fish()
	else:
		# Read user input and update speed
		# No impulsion a priori
		var impulsion = Vector2.ZERO
		
		# If left arm is available, push with it.
		if Input.is_action_just_pressed("ui_left") and $leftRow.time_left <= 0:
			turn -= 1
			impulsion += transform.x * impulse
			# Time to use left arm again
			$leftRow.start(waiting_time)
			
		# If right arm is available, push with it
		if Input.is_action_just_pressed("ui_right") and $rightRow.time_left <= 0:
			turn += 1
			impulsion += transform.x * impulse
			# Time to use right arm again
			$rightRow.start(waiting_time)
		
		# If there's any movement, play rowing animation
		if impulsion != Vector2.ZERO:
			set_sprite("rowing")
		
		# If player is pushing with both arms and did not realease buttons, add an
		# extra small speed. This simulates extra effort being put on the pushing
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right")\
		and $leftRow.time_left > 0 and $rightRow.time_left > 0:
			# Small extra force
			impulsion += transform.x * 2
			# Set direction as foward
			turn = 0
		
		# Set to range [-1,1]
		turn = clamp(turn, -1, 1)
		# update speed
		velocity += impulsion
		# update angle to turn
		steer_angle = turn * steering_angle

func _physics_process(delta):
	# Calculate rotation
	calculate_steering(delta)
	# Move chatacter
	# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)
	# Apply friction, reducing velocity
	velocity *= (1-friction * delta)
	
	update()

func calculate_steering(delta):
	# This code is the same one used for car driving in games.
	# Inspired by the following tutorial:
	# https://kidscancode.org/godot_recipes/2d/car_steering/
	var rear_boat = position - transform.x * front_space / 2.0
	var front_boat = position + transform.x * front_space / 2.0
	rear_boat += velocity * delta
	front_boat += velocity.rotated(steer_angle) * delta
	var new_heading = (front_boat - rear_boat).normalized()
	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()

func _on_rowing_animation_finished():
	# Guaranties The animation is ready for playing again
	$rowing.stop()
	$rowing.frame = 0

func set_sprite(sprite_name):
	if sprite_name == "rowing":
		$rowing.visible = true
		$standing.visible = false
		$bait.visible = false
		$rowing.frame = 0
		$rowing.play("row")
	elif sprite_name == "standing":
		$rowing.visible = false
		$standing.visible = true
		$bait.visible = true
		
		# Check if player clicked on the left or right side of the boat.
		# We can find this information by checking if "y" is positive or negative
		var l = -sign(global_to_local(bait).y)
		$standing.rotation = l * PI / 2
		
	update()

func positionate_bait():
	bait = get_global_mouse_position()
	var reference = $standing/fishingRod.global_position
	var distance = bait.distance_to(reference)
	if distance > fishable_distance:
		var factor = fishable_distance / distance
		bait = reference + (bait-reference) * factor
	set_sprite("standing")

func try_to_fish():
	# Get all elements under the bait
	var areas = $bait.get_overlapping_areas()
	for area in areas:
		# For each colliding area, check if it is a fish
		if area.is_in_group("FISH"):
			# If it is a fish, call the caught routine
			var caught = area.was_caught()
			if caught:
				# If it is available to get caught, tell the game
				get_parent().inc_fish(bait)
				break

func _draw():
	# This function is used to draw a file between the fishing rod and the
	# bait on the water
	if $standing.visible == true:
		# If player is fishing (not moving), draw line
		var rod = global_to_local($standing/fishingRod.global_position)
		draw_line(rod, global_to_local(bait), Color(255),1)
		$bait.position = global_to_local(bait)

func global_to_local(coord):
	# Translates global position to local coordinates, acconting for player
	# rotation
	return (coord - position).rotated(-rotation)


