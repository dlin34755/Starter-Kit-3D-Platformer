extends Camera3D

# --- TARGETS ---
# Assign these in the Inspector!
@export var player1_path: NodePath
@export var player2_path: NodePath

# --- SETTINGS ---
@export var offset = Vector3(0, 0, 3)  # Normal height/distance
@export var smooth_speed = 10.0
@export var lock_x_axis = false         # Set TRUE if you want the camera to stay centered on the lane

# --- ZOOM SETTINGS ---
@export var use_dynamic_zoom = true
@export var min_zoom = 10.0              # Closest distance (Z)
@export var max_zoom = 18.0             # Furthest distance (Z)
@export var zoom_factor = 0.5           # How much to zoom out per unit of distance

# --- NODES ---
var p1: Node3D = null
var p2: Node3D = null

func _ready():
	if player1_path: p1 = get_node(player1_path)
	if player2_path: p2 = get_node(player2_path)

func _physics_process(delta):
	# 1. FAIL-SAFE: Re-find players if they were reparented to the unicycle
	if !p1: p1 = get_tree().current_scene.find_child("Player1", true, false)
	if !p2: p2 = get_tree().current_scene.find_child("Player2", true, false)
	if !p1 or !p2: return 

	# 2. GET WORLD POSITIONS
	var p1_pos = p1.global_position
	var p2_pos = p2.global_position

	# 3. CALCULATE MIDPOINT
	var center_pos = (p1_pos + p2_pos) / 2.0

	# 4. CALCULATE DYNAMIC ZOOM
	# Start with your base setting from the Inspector
	var total_z_distance = offset.z 
	
	if use_dynamic_zoom:
		var distance_apart = p1_pos.distance_to(p2_pos)
		
		# Calculate ONLY the extra distance based on how far apart they are
		# We start at 0 extra zoom (min_zoom should probably be 0 in Inspector now)
		var extra_zoom = clamp(min_zoom + (distance_apart * zoom_factor), min_zoom, max_zoom)
		
		# ADD the extra zoom to the base offset
		total_z_distance += extra_zoom	# 5. DETERMINE TARGET POSITION
#DETERMINE TARGET CAMERA POSITION
	var target_cam_pos = Vector3.ZERO
	target_cam_pos.x = 0 if lock_x_axis else center_pos.x
	target_cam_pos.y = center_pos.y + offset.y
	
	# Use the TOTAL calculated distance
	target_cam_pos.z = center_pos.z + total_z_distance

	# 6. APPLY MOVEMENT
	# We LERP (smooth) the X and Y so it's not jittery
	# But we move Z faster or instantly if they are "driving away"
	var new_pos = global_position.lerp(target_cam_pos, smooth_speed * delta)
	
	# UNCOMMENT THE LINE BELOW if they still outrun the camera:
	new_pos.z = target_cam_pos.z 
	
	global_position = new_pos
	
	# 7. LOOK AT TARGET
	var look_target = center_pos
	if lock_x_axis: look_target.x = 0
	look_at(look_target, Vector3.UP)
