@tool
extends PhysicsBody2D

@export
var size := Vector2(200, 400):
	set(r):
		size = r
		remake()

@export
var thickness := 5:
	set(r):
		thickness = r
		remake()

var color := Color(0.631, 0.243, 0.122):
	set(r):
		color = r
		_polygon.color = r

@export_range(0.02, 1.0)
var fill_fraction := 1.0:
	set(r):
		fill_fraction = r
		remake()

var _collision_shape := CollisionPolygon2D.new()
var _polygon := Polygon2D.new()

func _init() -> void:
	add_child(_collision_shape)
	_polygon.color = color
	add_child(_polygon)
	remake()

func remake() -> void:
	var circle = MathLib.create_rounded_box(size, thickness)
	_polygon.polygon = circle
	_collision_shape.polygon = circle
