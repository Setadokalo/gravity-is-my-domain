class_name PlayerCharacter
extends GravityCharacter

func _ready() -> void:
	GameManager.player = self

func _process(delta: float) -> void:
	$Line2D.points = [global_position, global_position + up_direction * 16.0]

func input_dir() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func desires_jump() -> bool:
	return Input.is_action_just_pressed(&"move_jump")