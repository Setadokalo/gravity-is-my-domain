class_name MathLib

static func create_hollow_circle(radius: float, thickness: float, fill_fraction: float) -> PackedVector2Array:
	var new_polygon := PackedVector2Array()
	new_polygon.resize(128)
	for i in range(0, 64):
		new_polygon[i] = Vector2(
			(radius + thickness) * sin(idx2rds(i, fill_fraction)),
			(radius + thickness) * cos(idx2rds(i, fill_fraction))
		)
	for i in range(0, 64):
		new_polygon[64 + i] = Vector2(
			(radius - thickness) * sin(idx2rds(63-i, fill_fraction)),
			(radius - thickness) * cos(idx2rds(63-i, fill_fraction))
		)
	return new_polygon


static func idx2rds(i: int, fill_fraction: float) -> float:
	return (i as float) / 63.0 * TAU * fill_fraction + (1.0 - fill_fraction) * PI