extends CharacterBody3D

# --- Settings ---
@export var speed = 10.0
@export var acceleration = 8.0
@export var friction = 10.0 # Helps it stop when you get off
@export var rotation_speed = 5.0
# --- State ---
var player_on_board = false
var player_ref: Node3D = null
var is_player_nearby = false

# --- Nodes ---
@onready var seat = $SeatPosition
@onready var interaction_area = $Area3D

func _physics_process(delta):
	# 1. Apply Gravity (so it doesn't float)
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. CHECK: Is anyone riding?
	if player_on_board:
		# --- RIDING LOGIC ---
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			
			var target_angle = atan2(-direction.x, -direction.z)
		# Smoothly rotate current Y angle to target angle
		# "rotation_speed" controls how snappy it is. Try 5.0 or 3.0.
			rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
		
		else:
			# Slow down if no keys pressed
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			velocity.z = move_toward(velocity.z, 0, friction * delta)
			
	else:
		# --- EMPTY LOGIC (Parking) ---
		# If no one is on board, apply friction so it stops moving completely
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		
	move_and_slide()

func _input(event):
	# Handle Mounting/Dismounting
	if event.is_action_pressed("interact"):
		if not player_on_board and is_player_nearby:
			mount()
		elif player_on_board:
			dismount()


func mount():
	print("Mounting Unicycle!")
	player_on_board = true
	# Disable Player's own physics so they don't try to walk away
	player_ref.set_physics_process(false)
	
	# Glue player to the seat
	player_ref.reparent(seat)
	player_ref.position = Vector3.ZERO
	player_ref.rotation_degrees = Vector3(0, 180, 0)

func dismount():
	print("Dismounting Unicycle!")
	player_on_board = false
	# Put player back in the main world
	var main_scene = get_tree().current_scene
	player_ref.reparent(main_scene)
	
	# Move them aside
	player_ref.global_position = global_position + (transform.basis.x * 1.5)
	
	# Re-enable Player physics
	player_ref.set_physics_process(true)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		is_player_nearby = true
		player_ref = body
		print("Player is near. Press E to ride.")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_nearby = false
