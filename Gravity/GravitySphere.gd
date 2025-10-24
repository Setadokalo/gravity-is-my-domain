@tool
extends GravityRegion

const DEBUG_VISUAL_RESOLUTION: int = 256

var col_shape := CircleShape2D.new()
var surface_debug_shape := Line2D.new()
var falloff_debug_shape := Line2D.new()

@export var surface_radius := 200.0:
	set(r):
		surface_radius = r
		resize_collision()

@export var falloff_length := 20.0:
	set(l):
		falloff_length = l
		resize_collision()

@export var falloff_start := 50.0:
	set(l):
		falloff_start = l
		resize_collision()

func poly_circle(radius: float) -> PackedVector2Array:
	var parr = PackedVector2Array()
	parr.resize(DEBUG_VISUAL_RESOLUTION)
	for i in range(0, DEBUG_VISUAL_RESOLUTION):
		parr[i] = Vector2(radius * sin(i / (DEBUG_VISUAL_RESOLUTION as float) * TAU), radius * cos(i / (DEBUG_VISUAL_RESOLUTION as float) * TAU))
	return parr

func _init() -> void:
	super()
	col_shape.radius = surface_radius + falloff_start + falloff_length
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = col_shape
	gravity_area.add_child(collision_shape)

func _enter_tree() -> void:
	if Engine.is_editor_hint() or get_tree().debug_collisions_hint:
		surface_debug_shape.default_color = Color(1, 0.627, 0.2, 1)
		surface_debug_shape.points = poly_circle(surface_radius)
		surface_debug_shape.width = 1.0
		surface_debug_shape.closed = true
		add_child(surface_debug_shape)

		falloff_debug_shape.default_color = Color(1, 0.294, 0.2, 1)
		falloff_debug_shape.points = poly_circle(surface_radius + falloff_start)
		falloff_debug_shape.width = 1.0
		falloff_debug_shape.closed = true
		add_child(falloff_debug_shape)

func resize_collision() -> void:
	col_shape.radius = surface_radius + falloff_start + falloff_length
	if Engine.is_editor_hint() or (is_inside_tree() and get_tree().debug_collisions_hint):
		surface_debug_shape.points = poly_circle(surface_radius)
		falloff_debug_shape.points = poly_circle(surface_radius + falloff_start)

func get_gravity_at(global_pos: Vector2) -> Vector2:
	var local_pos := to_local(global_pos)
	var gravity_dir = local_pos.normalized()
	if local_pos.length() > surface_radius:
		gravity_dir = -gravity_dir
	return gravity_dir * gravity_strength

func get_gravity_influence(global_pos: Vector2) -> float:
	var local_pos := to_local(global_pos)
	var dist_to_surface = (local_pos.length() - surface_radius)
	if is_zero_approx(falloff_length):
		#print(1.0 if dist_to_surface < falloff_start else 0.0)
		return 1.0 if dist_to_surface < falloff_start else 0.0
	var influence = 1.0 - clampf(
		(dist_to_surface - falloff_start) / falloff_length,
		0.0,
		1.0
	)
	#print(influence)
	return influence
