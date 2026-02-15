extends VehicleBody3D

# --- SETTINGS ---
@export var engine_power = 3000.0
@export var brake_power = 100.0
@export var max_steering = 0.4

# --- NODES ---
@onready var truck_cam = $Camera3D
@onready var exit_point = $ExitPoint
@onready var interaction_zone = $InteractionZone

# --- STATE ---
var is_driving = false
var player_node: Node3D = null
var can_enter = false

func _ready():

	truck_cam.current = false

func _physics_process(delta):
	if is_driving:
		handle_driving()
		
		# Exit if Interact is pressed
		if Input.is_action_just_pressed("p1_interact"):
			exit_truck()
			
	elif can_enter and Input.is_action_just_pressed("p1_interact"):
		enter_truck()

func handle_driving():
	# 1. Steering (Left/Right)
	# Note: We swap left/right because VehicleBody steering is inverted sometimes
	var steer_val = Input.get_axis("p1_right", "p1_left")
	steering = move_toward(steering, steer_val * max_steering, 0.1)

	# 2. Gas/Brake
	var gas_val = Input.get_axis("p1_down", "p1_up")
	
	if abs(gas_val) > 0.05: # Deadzone to prevent creeping
		engine_force = gas_val * engine_power
		brake = 0.0
	else:
		engine_force = 0.0
		# This "engine braking" makes the truck feel heavy and stable
		brake = 2.0

# --- TRANSITIONS ---

func enter_truck():
	if !player_node: return
	
	print("🚛 Driving Mode: ON")
	is_driving = true
	
	# 1. Hide/Disable Player
	player_node.process_mode = Node.PROCESS_MODE_DISABLED
	player_node.visible = false
	
	# 2. Switch Camera
	truck_cam.make_current()

func exit_truck():
	if !player_node: return

	print("🚶 Walking Mode: ON")
	is_driving = false
	
	# 1. Stop Truck
	engine_force = 0
	steering = 0
	brake = 100
	
	# 2. Re-enable Player
	player_node.visible = true
	player_node.process_mode = Node.PROCESS_MODE_INHERIT
	
	# 3. Teleport Player to Exit Point
	player_node.global_position = exit_point.global_position
	player_node.rotation = Vector3.ZERO
	
	# 4. Switch Camera Back to Player
	# We assume the player has a camera named "Camera3D" inside them
	var player_cam = player_node.find_child("Camera3D", true, false)
	if player_cam:
		player_cam.make_current()

func _on_interaction_zone_body_entered(body: Node3D) -> void:
			# Since there is only 1 player, we just check if it's a CharacterBody3D
	if body is CharacterBody3D:
		can_enter = true
		player_node = body # Remember who the player is
		print("Player can enter")

func _on_interaction_zone_body_exited(body: Node3D) -> void:
	if body == player_node:
		can_enter = false
