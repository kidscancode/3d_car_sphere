extends Spatial

onready var ball = $Ball
onready var car_mesh = $CarMesh
onready var ground_ray = $CarMesh/RayCast
# mesh references
onready var right_wheel = $CarMesh/tmpParent/suv/wheel_frontRight
onready var left_wheel = $CarMesh/tmpParent/suv/wheel_frontLeft
onready var body_mesh = $CarMesh/tmpParent/suv/body


export (bool) var show_debug = false
var sphere_offset = Vector3(0, -1.0, 0)
var acceleration = 50
var steering = 21
var turn_speed = 5
var turn_stop_limit = 0.75
var body_tilt = 35

var speed_input = 0
var rotate_input = 0

func _ready():
	$Ball/DebugMesh.visible = show_debug
	ground_ray.add_exception(ball)
#	DebugOverlay.stats.add_property(ball, "linear_velocity", "length")
#	DebugOverlay.draw.add_vector(ball, "linear_velocity", 1, 4, Color(0, 1, 0, 0.5))
#	DebugOverlay.draw.add_vector(car_mesh, "transform:basis:z", -4, 4, Color(1, 0, 0, 0.5))

func _process(delta):
	# Can't steer/accelerate when in the air
	if not ground_ray.is_colliding():
		return
	# f/b input
	speed_input = 0
	speed_input += Input.get_action_strength("accelerate")
	speed_input -= Input.get_action_strength("brake") 
	speed_input *= acceleration
	# steer input
#	rotate_target = lerp(rotate_target, rotate_input, 5 * delta)
	rotate_input = 0
	rotate_input += Input.get_action_strength("steer_left")
	rotate_input -= Input.get_action_strength("steer_right")
	rotate_input *= deg2rad(steering)
	
	# rotate wheels for effect
	right_wheel.rotation.y = rotate_input
	left_wheel.rotation.y = rotate_input

	# smoke?
	var d = ball.linear_velocity.normalized().dot(-car_mesh.transform.basis.z)
	if ball.linear_velocity.length() > 5.5 and d < 0.9:
		$CarMesh/Smoke.emitting = true
		$CarMesh/Smoke2.emitting = true
	else:
		$CarMesh/Smoke.emitting = false
		$CarMesh/Smoke2.emitting = false
		
	# rotate car mesh
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, rotate_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		
		# tilt body for effect
		var t = -rotate_input * ball.linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 10 * delta)
		
	# align mesh with ground normal
	var n = ground_ray.get_collision_normal()
	var xform = align_with_y(car_mesh.global_transform, n.normalized())
	car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)
	
func _physics_process(delta):
#	car_mesh.transform.origin = ball.transform.origin + sphere_offset
	# just lerp the y due to trimesh bouncing
	car_mesh.transform.origin.x = ball.transform.origin.x + sphere_offset.x
	car_mesh.transform.origin.z = ball.transform.origin.z + sphere_offset.z
	car_mesh.transform.origin.y = lerp(car_mesh.transform.origin.y, ball.transform.origin.y + sphere_offset.y, 10 * delta)
#	car_mesh.transform.origin = lerp(car_mesh.transform.origin, ball.transform.origin + sphere_offset, 0.3)
	ball.add_central_force(-car_mesh.global_transform.basis.z * speed_input)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
		
