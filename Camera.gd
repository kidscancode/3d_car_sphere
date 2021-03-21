extends Camera

# https://github.com/jocamar/Godot-Post-Process-Outlines

export var lerp_speed = 3.0

export (NodePath) var target_path = null
export (Vector3) var offset = Vector3.ZERO
var target = null

func _ready():
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	if !target:
		return
	var target_pos = target.global_transform.translated(offset)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
#	var target_pos = target.global_transform.origin + offset
#	global_transform.origin = lerp(global_transform.origin, target_pos, lerp_speed * delta)
	look_at(target.global_transform.origin, Vector3.UP)
