extends Node3D

# SETTINGS
@export var chain_length = 1.75  # How far behind it trails
@export var drag_speed = 10.0   # Higher = Stiff chain, Lower = Bouncy/Elastic
@export var lock_y = true       # Keep TRUE if you don't want it floating in the air

# INTERNAL
@onready var parent_node = get_parent()

func _ready():
	# CRITICAL: This tells Godot "Don't move me with my parent automatically."
	# We will handle the movement ourselves in the script.
	top_level = true
	
# 2. Calculate the exact spot BEHIND the unicycle
	# We take the Unicycle's position and add the "Backwards" vector multiplied by distance
	var spawn_pos = parent_node.global_position + (parent_node.transform.basis.x * chain_length)
	spawn_pos.y = -0.1
	# 3. Teleport there instantly
	global_position = spawn_pos
	
	# 4. Rotate to face the unicycle immediately
	look_at(parent_node.global_position, Vector3.UP)
	
func _physics_process(delta):
	# 1. Where is the Unicycle?
	var target = parent_node.global_position
	
	# 2. CALCULATE THE "TOW" POSITION
	# We want to be exactly 'chain_length' away from the parent
	var current_pos = global_position
	var direction = current_pos.direction_to(target) # Vector pointing TO the unicycle
	
	# The "Ideal Spot" is behind the unicycle along that direction vector
	var ideal_pos = target - (direction * chain_length)
	
	# 3. HANDLE HEIGHT (Y)
	# If the unicycle jumps, do we want the carriage to fly up instantly?
	# Usually, it looks better if we keep the Y smooth or grounded.
	if lock_y:
		ideal_pos.y = current_pos.y # Keep current height (or use a raycast to stick to floor)
	else:
		ideal_pos.y = target.y # Follow unicycle height
	
	# 4. MOVE THE CARRIAGE
	# Lerp makes it feel like it has weight/drag
	global_position = global_position.lerp(ideal_pos, drag_speed * delta)
	
	# 5. ROTATE THE HINGE
	# Make the carriage look AT the unicycle (like a trailer hitch)
	look_at(target, Vector3.UP)
	
	# Optional: Fix weird rotation if looking straight up/down
	rotation.x = 0 
	rotation.z = 0
