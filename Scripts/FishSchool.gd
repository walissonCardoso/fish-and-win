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
var food_decay_factor = 0.02

func _ready():
	# Get the size of the screen
	screen_size = get_viewport().get_visible_rect().size
	
	# Create the fishes
	for _i in range(n_fish):
		fish_list.append(fish_factory.instance())
	
	# Add them to the screen
	for fish in fish_list:
		self.add_child(fish)
	
	# Add n_fish food sources
	for i in range(n_fish):
		food(i)

func _process(delta):
	#update()
	
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
	fish_list[i].update_velocity(get_best_global(i))

func get_best_global(i):
	# The best global is a food source
	return copy3(food_position[i])

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
	# Tries to make fish go up during gameplay according
	# to a quadratic distribution
	var progress = 1 - float(n_fish) / initial_n_fish
	var max_depth = pow(progress, 2)
	# Place food on random location. Index "i" refers to the food source number
	var food_pos = Vector3(rand_range(0, screen_size.x),
						   rand_range(0, screen_size.y),
						   rand_range(max_depth, max_depth+0.5))
	# If the array is still being create, append
	if len(food_position) <= i:
		food_position.append(food_pos)
		food_quantity.append(rand_range(0, 1))
	# If not, change in the position
	else:
		food_position[i] = copy3(food_pos)
		food_quantity[i] = rand_range(0, 1)

func _on_foodDeposity_timeout():
	# Every five seconds, change randomly a food source 
	var i = randi() % len(food_position)
	food(i)

func copy2(vector):
	return Vector2(vector[0], vector[1])
	
func copy3(vector):
	# Make a copy by value of a 3-dimentional vector
	return Vector3.ZERO + vector

# Uncomment below to see food sources and add "update()" to _process()
#func _draw():
#	for pos in food_position:
#		draw_circle(Vector2(pos[0], pos[1]), 3, Color(1,0,0))
