extends Camera3D

# Settings for your Overcooked angle
@export var offset = Vector3(0, 10, 6) # Adjust height(Y) and distance(Z)
@export var smooth_speed = 5.0

var player_target: Node3D = null

func _ready():
	# 1. Find the Player automatically, no matter where they are in the tree
	# "true" means it searches recursively inside other nodes (like the house or bike)
	player_target = get_tree().current_scene.find_child("Player", true, false)
	
	if player_target:
		print("Camera locked onto: ", player_target.name)
	else:
		print("ERROR: Camera cannot find a node named 'Player'!")

func _physics_process(delta):
	if player_target:
		# 2. ALWAYS follow the player's world position
		# global_position works even if the player is riding the unicycle
		var target_pos = player_target.global_position + offset
		
		# 3. Smoothly float there
		global_position = global_position.lerp(target_pos, smooth_speed * delta)
