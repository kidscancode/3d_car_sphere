extends Control

class Vector:
	var object
	var value
	var scale
	var width
	var color
	func _init(o, v, s, w, c):
		object = o
		value = v
		scale = s
		width = w
		color = c
	func draw(node, cam):
		if cam.is_position_behind(object.global_transform.origin):
			return
		var start = cam.unproject_position(object.global_transform.origin)
		var end = cam.unproject_position(object.global_transform.origin + object.get_indexed(value) * scale)
		node.draw_line(start, end, color, width)
		node.draw_triangle(end, start.direction_to(end), width*2, color)


var vectors = []

func _process(_delta):
	if not visible:
		return
	update()


func _draw():
	var camera = get_viewport().get_camera()
	for vector in vectors:
		vector.draw(self, camera)


func add_vector(object, value, size, width, color):
	vectors.append(Vector.new(object, value, size, width, color))
	print("registered %s of %s." % [value, object.name])


func remove_vector(object, property):
	for v in vectors:
		if v.object == object and v.value == property:
			vectors.erase(v)
			print("removed %s of %s." % [property, object.name])
			break


func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
