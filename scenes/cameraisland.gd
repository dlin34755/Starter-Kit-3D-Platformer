extends Camera3D

# --- 1. DRAG YOUR PLAYER HERE IN INSPECTOR ---
@export var target_path: NodePath

# --- 2. ADJUST VIEW HERE ---
# (0, 15, 10) = Angled Top-Down
# (0, 20, 0)  = Perfect Top-Down
@export var offset = Vector3(0, 15, 10) 

var target: Node3D

func _ready():
	# Detach from parent so we don't spin with the player
	top_level = true
	
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	if !target: return

	# 1. CALCULATE POSITION
	# We take the player's exact position + our fixed offset
	var desired_position = target.global_position + offset
	
	# 2. TELEPORT THERE (NO SMOOTHING)
	# By setting this directly, the player is locked to the center of the screen.
	global_position = desired_position
	
	# 3. LOOK AT PLAYER
	# Ensure the camera always points at the player
	look_at(target.global_position, Vector3.UP)
