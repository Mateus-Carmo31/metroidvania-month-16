class_name MathUtils

# Gets transform forward (-z)
static func get_forward(t : Transform) -> Vector3:
	return -t.basis.z

# Gets transform left (-x)
static func get_left(t : Transform) -> Vector3:
	return -t.basis.x

# Gets transform up (y)
static func get_up(t : Transform) -> Vector3:
	return t.basis.y

# Rotates `t` so that it points towards `new_dir`.
# If `align` is `true`, will make `new_dir` perpendicular to `t`'s up direction (putting it on the same plane as its forward and left vectors)
static func point_towards(t : Transform, new_dir : Vector3, align = false) -> Transform:
	if align:
		new_dir = Plane(t.basis.y, 0).project(new_dir).normalized()

	return t.looking_at(t.origin + new_dir, t.basis.y)

# Obtains the projection of `v` on the plane defined by `normal` along the line defined by `dir`.
# Note: make sure the normal and dir aren't perpendicular!
static func project_along(v : Vector3, normal : Vector3, dir : Vector3, plane_origin = Vector3.ZERO) -> Vector3:

	var dot = normal.dot(dir)

	if not normal.is_normalized() or not dir.is_normalized():
		push_error("Error in project_along: plane normal or line direction aren't normalized!")

	if dot == 0:
		push_error("Error in project_along: plane and line are parallel!")
		return Vector3.ZERO

	var d = normal.dot(plane_origin - v) / dot

	return v + dir * d

# kinda cringe, don't use
# Rotates `t` around its y-axis using Basis
# static func rotate_on_y_towards(t : Transform, new_dir : Vector3, align = false):
# 	# New basis:
# 	# Z = -new_dir (since Z is backwards)
# 	# Y is Y
# 	# X is new_dir x Y (right hand rule, ends up pointing right)
# 	# if something goes wrong check the transform
# 	if align:
# 		new_dir = Plane(t.basis.y, 0).project(new_dir).normalized()
# 	t.basis = Basis(new_dir.cross(t.basis.y).normalized(), t.basis.y, -new_dir)
# 	return t


# Takes a value in range (iMin, iMax) and gets its correspondent in range (oMin, oMax).
static func remap(iMin, iMax, oMin, oMax, v):
	var t = inverse_lerp(iMin, iMax, v)
	return lerp(oMin, oMax, t)
