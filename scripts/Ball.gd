extends RigidBody

onready var ball_position = global_transform

func do_jump(jump_force: float) -> void:
  apply_impulse(Vector3.ZERO, Vector3.UP * jump_force)


func init() -> void:
  global_transform = ball_position
  linear_velocity = Vector3.ZERO
  angular_velocity = Vector3.ZERO
