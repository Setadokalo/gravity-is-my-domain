class_name MathLib

const CIRCLE_RESOLUTION: int = 64

static func create_hollow_circle(radius: float, thickness: float, fill_fraction: float) -> PackedVector2Array:
	var new_polygon := PackedVector2Array()
	new_polygon.resize(CIRCLE_RESOLUTION * 2)
	for i in range(0, CIRCLE_RESOLUTION):
		new_polygon[i] = Vector2(
			(radius + thickness) * sin(idx2rds(i, fill_fraction)),
			(radius + thickness) * cos(idx2rds(i, fill_fraction))
		)
	for i in range(0, CIRCLE_RESOLUTION):
		new_polygon[CIRCLE_RESOLUTION + i] = Vector2(
			(radius - thickness) * sin(idx2rds((CIRCLE_RESOLUTION - 1)-i, fill_fraction)),
			(radius - thickness) * cos(idx2rds((CIRCLE_RESOLUTION - 1)-i, fill_fraction))
		)
	return new_polygon


static func idx2rds(i: int, fill_fraction: float) -> float:
	return (i as float) / (CIRCLE_RESOLUTION as float) * TAU * fill_fraction + (1.0 - fill_fraction) * PI

static func create_circle(radius: float) -> PackedVector2Array:
	var parr = PackedVector2Array()
	parr.resize(CIRCLE_RESOLUTION)
	for i in range(0, CIRCLE_RESOLUTION):
		parr[i] = Vector2(radius * sin(idx2rds(i, 1.0)), radius * cos(idx2rds(i, 1.0)))
	return parr

static func create_box(size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
			Vector2(-size.x / 2.0, -size.y / 2.0),
			Vector2( size.x / 2.0, -size.y / 2.0),
			Vector2( size.x / 2.0,  size.y / 2.0),
			Vector2(-size.x / 2.0,  size.y / 2.0)
	])

static func create_rounded_box(size: Vector2, rounding_radius: float) -> PackedVector2Array:
	if rounding_radius < 0 or is_zero_approx(rounding_radius):
		return create_box(size)
	if rounding_radius > min(size.x, size.y) * 0.5:
		return create_circle(rounding_radius)
	const CORNER_RESOLUTION: int = CIRCLE_RESOLUTION / 4
	assert(CORNER_RESOLUTION * 4 == CIRCLE_RESOLUTION, "Circle resolution does not allow clean rounded edge behaviour")

	var half := size * 0.5
	var points := create_circle(rounding_radius)
	print(points.size())
	# lower right
	for p_idx in range(0, CORNER_RESOLUTION):
		points[p_idx] = points[p_idx] + Vector2(1, 1) * (half - Vector2(rounding_radius, rounding_radius))
	# Duplicate point between two arcs
	points.insert(CORNER_RESOLUTION, points[CORNER_RESOLUTION] + Vector2(1, 1) * (half - Vector2(rounding_radius, rounding_radius)))
	# upper right
	for p_idx in range(CORNER_RESOLUTION + 1, CORNER_RESOLUTION * 2 + 1):
		points[p_idx] = points[p_idx] + Vector2(1, -1) * (half - Vector2(rounding_radius, rounding_radius))
	# Duplicate point between two arcs
	points.insert(CORNER_RESOLUTION * 2 + 1, points[CORNER_RESOLUTION * 2 + 1] + Vector2(1, -1) * (half - Vector2(rounding_radius, rounding_radius)))
	# upper left
	for p_idx in range(CORNER_RESOLUTION * 2 + 2, CORNER_RESOLUTION * 3 + 2):
		points[p_idx] = points[p_idx] + Vector2(-1, -1) * (half - Vector2(rounding_radius, rounding_radius))
	# Duplicate point between two arcs
	points.insert(CORNER_RESOLUTION * 3 + 2, points[CORNER_RESOLUTION * 3 + 2] + Vector2(-1, -1) * (half - Vector2(rounding_radius, rounding_radius)))
	# lower left
	for p_idx in range(CORNER_RESOLUTION * 3 + 3, CORNER_RESOLUTION * 4 + 3):
		points[p_idx] = points[p_idx] + Vector2(-1, 1) * (half - Vector2(rounding_radius, rounding_radius))
	points.insert(CORNER_RESOLUTION * 4 + 3, points[0] * Vector2(-1, 1))

	return points


static func move_towards_angle(from: float, to: float, by: float) -> float:
	return clamp(lerp_angle(from, to, 1.0), from-by, from+by)