class_name PlayerCharacter
extends GravityCharacter

func _ready() -> void:
	GameManager.player = self

func _process(delta: float) -> void:
	$Line2D.points = [global_position, global_position + up_direction * 16.0]

func _physics_process(delta: float) -> void:
	super(delta)
	var indir = input_dir()
	if not is_zero_approx(indir.x):
		$Body.play("run")
		$Body.flip_h = indir.x < 0
	elif velocity.rotated(-global_rotation).x < -0.1:
		$Body.flip_h = true
	elif velocity.rotated(-global_rotation).x > 0.1:
		$Body.flip_h = false
	if is_zero_approx(indir.x):
		$Body.play("idle")

func input_dir() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func desires_jump() -> bool:
	return Input.is_action_just_pressed(&"move_jump")