extends Camera3D

# --- SETTINGS ---
@export var follow_distance = 6.0  # Increased for a better view of the road
@export var follow_height = 4.0    # Slightly higher to see over the cargo
@export var smooth_speed = 5.0    # Higher speed feels more like Easy Delivery Co

# --- INTERNAL ---
@onready var target_vehicle = get_parent()

func _ready():
	# Keeps the camera from spinning wildly if the truck flips
	top_level = true

func _physics_process(delta):
	if !target_vehicle: return

	# 1. GET TRUCK DATA
	var truck_pos = target_vehicle.global_position
	# This gets the vector pointing out the BACK of the truck
	var back_vector = target_vehicle.global_transform.basis.z 

	# 2. CALCULATE GOAL POSITION
	# We start at the truck, go UP, then go BACK

	var target_pos = truck_pos + (Vector3.UP * follow_height) - (back_vector * follow_distance)
	#target_pos.x += 5
	# 3. APPLY SMOOTH MOVEMENT
	# We use a higher smooth_speed so it follows the "lane" accurately
	global_position = global_position.lerp(target_pos, smooth_speed * delta)
	
	# 4. LOOK AT THE ROAD AHEAD
	# Instead of looking at the center of the truck, we look slightly above 
	# and IN FRONT of it so the player can see where they are going.
	var look_at_pos = truck_pos + (Vector3.UP * 1.5)
	look_at(look_at_pos, Vector3.UP)
