extends CharacterBody3D

# --- Settings ---
@export var paddle_force = 0.3   # Speed per SINGLE tap
@export var turn_angle = 10.0    # Turn degrees per SINGLE tap
@export var friction = 2.0       # Deceleration
@export var max_speed = 15.0     # Speed limit

# --- State ---
var current_speed = 0.0

# Player 1 State
var p1_on_board = false
var p1_ref: Node3D = null

# Player 2 State
var p2_on_board = false
var p2_ref: Node3D = null

# --- Nodes ---
@onready var seat_p1 = $Seat1   # Make sure you created this!
@onready var seat_p2 = $Seat2  # Make sure you created this!
@onready var interaction_area = $Area3D

func _physics_process(delta):
	# 1. Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Handle Movement if ANYONE is on board
	if p1_on_board or p2_on_board:
		handle_team_paddle(delta)
	else:
		# Stop quickly if empty
		current_speed = move_toward(current_speed, 0, friction * delta)
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func handle_team_paddle(delta):
	# We start with 0 force every frame
	var total_turn_strength = 0.0  # + is Left, - is Right
	var total_kick_force = 0.0     # How many kicks are happening

	# --- PLAYER 1 INPUTS (WASD) ---
	if p1_on_board:
		if Input.is_action_just_pressed("p1_left"):
			total_turn_strength += 1.0
			total_kick_force += 1.0
		if Input.is_action_just_pressed("p1_right"):
			total_turn_strength -= 1.0
			total_kick_force += 1.0

	# --- PLAYER 2 INPUTS (Arrows) ---
	if p2_on_board:
		if Input.is_action_just_pressed("p2_left"):
			total_turn_strength += 1.0 # Adds to P1's turn!
			total_kick_force += 1.0
		if Input.is_action_just_pressed("p2_right"):
			total_turn_strength -= 1.0 # Subtracts from turn
			total_kick_force += 1.0

	# --- APPLY PHYSICS ---

	# A. ROTATION
	# If both press Left: 1 + 1 = 2 (Double Turn)
	# If P1 Left, P2 Right: 1 - 1 = 0 (No Turn / Straight)
	if total_turn_strength != 0:
		rotate_y(deg_to_rad(turn_angle) * total_turn_strength)

	# B. SPEED
	# If both press a key: 1 + 1 = 2 (Double Speed Impulse)
	if total_kick_force > 0:
		current_speed += paddle_force * total_kick_force

	# C. LIMITS & FRICTION
	current_speed = clamp(current_speed, 0, max_speed)
	current_speed = move_toward(current_speed, 0, friction * delta)

	# D. MOVE FORWARD
	var forward_dir = -transform.basis.x
	velocity.x = forward_dir.x * current_speed
	velocity.z = forward_dir.z * current_speed

# --- INPUT HANDLING (Mounting) ---
func _input(event):
	# Player 1 Mount
	if event.is_action_pressed("p1_interact"):
		if not p1_on_board and p1_ref: mount_p1()
		elif p1_on_board: dismount_p1()

	# Player 2 Mount
	if event.is_action_pressed("p2_interact"):
		if not p2_on_board and p2_ref: mount_p2()
		elif p2_on_board: dismount_p2()

# --- MOUNTING HELPERS ---
func mount_p1():
	p1_on_board = true
	p1_ref.set_physics_process(false)
	p1_ref.reparent(seat_p1)
	p1_ref.position = Vector3.ZERO
	p1_ref.rotation_degrees = Vector3(0, -90, 0) # Face forward

func dismount_p1():
	p1_on_board = false
	var main_scene = get_tree().current_scene
	p1_ref.reparent(main_scene)
	p1_ref.global_position = global_position + (-transform.basis.x * 1.5) # Eject Left
	p1_ref.set_physics_process(true)

func mount_p2():
	p2_on_board = true
	p2_ref.set_physics_process(false)
	p2_ref.reparent(seat_p2)
	p2_ref.position = Vector3.ZERO
	p2_ref.rotation_degrees = Vector3(0, -90, 0) # Face forward

func dismount_p2():
	p2_on_board = false
	var main_scene = get_tree().current_scene
	p2_ref.reparent(main_scene)
	p2_ref.global_position = global_position + (transform.basis.x * 1.5) # Eject Right
	p2_ref.set_physics_process(true)

# --- DETECTION ---
# We use naming to know who is who. Name your nodes "Player1" and "Player2"!
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player1": p1_ref = body
	elif body.name == "Player2": p2_ref = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player1": p1_ref = null
	elif body.name == "Player2": p2_ref = null
