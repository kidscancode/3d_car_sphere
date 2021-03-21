extends MarginContainer

class Property:
	var num_format = "%4.2f"
	var object
	var property
	var label_ref
	var display
	func _init(o, p, l, d):
		object = o
		property = p
		label_ref = l
		display = d
		
	func set_string():
		var s = object.name + "/" + property + " : "
		var p = object.get_indexed(property)
		match display:
			"":
				s += str(p)
			"length":
				s += num_format % p.length()
			"round":
				match typeof(p):
					TYPE_INT, TYPE_REAL:
						s += num_format % p
					TYPE_VECTOR2, TYPE_VECTOR3:
						s += str(p.round())
		label_ref.text = s
	
var props = []

func add_property(object, property, display):
	var l = Label.new()
	l.set("custom_fonts/font", load("res://debug/roboto_16.tres"))
	$Column.add_child(l)
	props.append(Property.new(object, property, l, display))

func remove_property(object, property):
	for prop in props:
		if prop.object == object and prop.property == property:
			props.erase(prop)
	
func _process(_delta):
	if not visible:
		return
	for prop in props:
		prop.set_string()
