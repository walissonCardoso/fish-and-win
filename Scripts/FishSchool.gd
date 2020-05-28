extends Node2D

# The fish moviment is controlled by PSO algorithm. We distribute some "food
# sources" in the water randomly to make them move

# Number of fishes shown on screen
export (int) var initial_n_fish = 21
var n_fish = initial_n_fish

# Variable to keep the screen size
var screen_size = Vector2.ZERO

# We gonna create those fishes dinammically
const fish_factory = preload("res://Scenes/Fish.tscn")
var fish_list = []

# List of food 3d-position in the space and their quantity.
var food_position = []
var food_quantity = []
var food_decay_factor = 0.01

# Variables for Particle Swarm Optimization algorithm
var gamma = 0.9
var phi1 = 0.6
var phi2 = 0.4

func _ready():
	# Get the size of the screen
	screen_size = get_viewport().get_visible_rect().size
	
	# Create the fishes
	for _i in range(n_fish):
		fish_list.append(fish_factory.instance())
	
	# Add them to the screen
	for fish in fish_list:
		self.add_child(fish)
	
	# Add 10 food sources
	for i in range(10):
		food(i)

func _process(delta):
	# Reduce food amount
	food_decay(delta)
	
	# We will only update one single fish velocity every iteration
	# I did this to waste fewer resources
	var i = randi() % n_fish
	
	# If fish was caught.clean from memory
	if !fish_list[i].its_alive:
		n_fish -= 1
		fish_list[i].queue_free()
		fish_list.remove(i)
		return
	
	# Update fish velocity
	fish_list[i].update_velocity(get_best_global(i), gamma, phi1, phi2)
	
	# Check if the new location of the fish is better than its old best
	# found. This information is basically the same for each fish, since the
	# evaluation won't change
	if evaluate(fish_list[i].best_position) > evaluate(fish_list[i].location):
		fish_list[i].best_position = copy3(fish_list[i].location)

func evaluate(eval_position):
	# The evaluation is the distances multiplied by the food quantities.
	# This could be anything, just tried to get something to work
	var normal_position = to_zero_one(eval_position)
	var penality = 0
	for i in range(len(food_position)):
		var distance = normal_position.distance_to(to_zero_one(food_position[i]))
		penality += distance * food_quantity[i]
	
	var last_capture = Vector2.ZERO
	if get_parent().get_name() == "FishingGame":
		last_capture = get_parent().capture_position
	if last_capture != Vector2.ZERO:
		var distance = copy2(eval_position).distance_to(last_capture)
		if distance < 200:
			penality += pow(2-distance/200, 2)
	return penality

func get_best_global(i):
	# The best global is global for a set of fishes. The best global for the
	# first part is the first food, source, the second and so on.
	var index = i % len(food_position)
	return copy3(food_position[index])

func copy2(vector):
	return Vector2(vector[0], vector[1])
	
func copy3(vector):
	# Make a copy by value of a 3-dimentional vector
	return Vector3.ZERO + vector

func to_zero_one(position):
	return Vector3(position[0] / screen_size[0],
				   position[1] / screen_size[1],
				   position[2])

func food_decay(delta):
	# Make the food quantity reduce and deposit on the bottom of the lake
	for i in range(len(food_quantity)):
		food_quantity[i] -= delta * food_decay_factor
		food_position[i][2] -= delta * food_decay_factor / 2
	
	# If the quantity of food reached the value of zero, reinitiate in another
	# place
	for i in range(len(food_quantity)):
		if food_quantity[i] <= 0:
			food(i)

func food(i):
	# Place food on random location. Index "i" refers to the food source number
	var food_pos = Vector3(rand_range(0, screen_size[0]),
						   rand_range(0, screen_size[1]),
						   rand_range(0.0, 1.0))
	# If the array is still being create, append
	if len(food_position) <= i:
		food_position.append(food_pos)
		food_quantity.append(rand_range(0, 1))
	# If not, change in the position
	else:
		# Tries to make fish go up during gameplay according
		# to a quadratic distribution
		var max_depth = pow(1 - n_fish / initial_n_fish, 2)
		food_position[i] = copy3(food_pos)
		food_quantity[i] = rand_range(max_depth, 1)

func _on_foodDeposity_timeout():
	# Every five seconds, change randomly a food source 
	var i = randi() % len(food_position)
	food(i)

# Uncomment below to see food sources and add "update()" to _process()
#func _draw():
#	for pos in food_position:
#		draw_circle(Vector2(pos[0], pos[1]), 3, Color(1,0,0))
