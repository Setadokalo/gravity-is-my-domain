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
	return (i as float) / (CIRCLE_RESOLUTION as float - 1.0) * TAU * fill_fraction + (1.0 - fill_fraction) * PI

static func create_circle(radius: float) -> PackedVector2Array:
	var parr = PackedVector2Array()
	parr.resize(CIRCLE_RESOLUTION - 1)
	for i in range(0, CIRCLE_RESOLUTION - 1):
		parr[i] = Vector2(radius * sin(idx2rds(i, 1.0)), radius * cos(idx2rds(i, 1.0)))
	return parr