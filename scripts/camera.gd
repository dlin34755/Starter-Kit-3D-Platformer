extends Camera3D

# --- SETTINGS ---
@export var offset = Vector3(0, 10, 6)   # Height and Distance
@export var use_smoothing = false        # FALSE = Instant stick (No floating)
@export var smooth_speed = 10.0          # Only used if use_smoothing is true

# --- MANUAL ASSIGNMENT (The Fix) ---
@export var target_override: Node3D = null 

# --- INTERNAL ---
var active_target: Node3D = null

func _ready():
	# 1. Check if you dragged the player in manually (Best Way)
	if target_override:
		active_target = target_override
		print("✅ Camera using Manual Target: ", active_target.name)
	
	# 2. If not, try to auto-find "Player"
	else:
		active_target = get_tree().current_scene.find_child("Player", true, false)
		if active_target:
			print("✅ Camera found Player automatically")
		else:
			print("❌ ERROR: Camera cannot find Player! Drag Player into 'Target Override' slot.")

func _physics_process(delta):
	# If we have a target, follow it!
	if active_target:
		var goal_position = active_target.global_position + offset
		
		if use_smoothing:
			# Float towards player
			global_position = global_position.lerp(goal_position, smooth_speed * delta)
		else:
			# SNAP to player (Rigid, no lag)
			global_position = goal_position
			
		# Optional: Keep looking at the player
		look_at(active_target.global_position, Vector3.UP)
