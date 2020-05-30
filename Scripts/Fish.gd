extends Area2D

# get the size of the screen
onready var screen_size = get_viewport().get_visible_rect().size
# Amount of air the fish has. If zero, forces the fish to go to the surface
onready var air = randf()

# Max velocity on x and y
var MAX_VELOCITY = 20
# Although the game is 2D, we will simulate z axis
var velocity = Vector3.ZERO
var location = Vector3.ZERO
var breathing_factor = 0.005
# Best position on PSO algorithm
var best_position = Vector3.ZERO
# Controls if this fish was never caught
var its_alive = true

func _ready():
	# Random locations on x and y
	position.x = rand_range(0, screen_size.x)
	position.y = rand_range(0, screen_size.y)
	# Z-axis varies on [0,1]
	location = Vector3(position.x, position.y, 0.1)
	velocity = Vector3(rand_range(-1, 1) * MAX_VELOCITY,\
					   rand_range(-1, 1) * MAX_VELOCITY,\
					   rand_range(-0.2, 0.1))
	# Best position ever found for this fish
	best_position = Vector3.ZERO + location
	
	update_fish_sprite()

func _process(delta):
	update_position(delta)
	check_margin()
	
	if location[2] >= 0.99:
		# Fish is in the surface breathing
		air += delta
	elif air > 0:
		# Fish is under water
		air -= delta * breathing_factor

func update_velocity(best_global_position):
	var distance = to_zero_one(best_global_position - location)
	
	velocity = 0.9 * velocity +\
			   0.3 * distance * MAX_VELOCITY +\
			   0.01 * Vector3(randf(), randf(), randf()) * MAX_VELOCITY
	
	# Forces fish to go up
	if air <= 0.05:
		velocity[2] = 0.05
	
	# Limit speed on all axis
	velocity[0] = clamp(velocity[0], -MAX_VELOCITY, MAX_VELOCITY)
	velocity[1] = clamp(velocity[1], -MAX_VELOCITY, MAX_VELOCITY)
	velocity[2] = clamp(velocity[2], -0.05, 0.05)
	
	update_fish_sprite()

func update_position(delta):
	# Just update according to our location variable
	location += velocity * delta
	position = Vector2(location[0], location[1])

func update_fish_sprite():
	# Rotation according to x/y
	rotation = Vector2(velocity[0], velocity[1]).angle()
	# scale according to z to give the impression of proximity
	scale = Vector2.ONE * (location[2] / 2 + 0.5)
	# Change visibility of the fish as it goes down
	modulate.a = pow(location[2], 2) - 0.2
	
func check_margin():
	# If the fish is going outside on x, set velocity to zero
	if location[0] <= 0 and velocity[0] < 0 or\
	   location[0] >= screen_size.x and velocity[0] > 0:
			velocity[0] = 0
	# If the fish is going outside on y, set velocity to zero
	if location[1] <= 0 and velocity[1] < 0 or\
	   location[1] >= screen_size.y and velocity[1] > 0:
			velocity[1] = 0
	# If the fish is going outside on z, set velocity to zero
	if location[2] <= 0 and velocity[2] < 0 or\
	   location[2] >= 1 and velocity[2] > 0:
			velocity[2] = 0

func to_zero_one(position):
	return Vector3(position[0] / screen_size.x,
				   position[1] / screen_size.y,
				   position[2])

func was_caught():
	if its_alive and modulate.a > 0.05:
		its_alive = false
		visible = false
		return true
	return false
