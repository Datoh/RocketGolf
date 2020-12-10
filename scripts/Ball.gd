extends RigidBody

func do_jump(jump_force: float) -> void:
  apply_impulse(Vector3.ZERO, Vector3.UP * jump_force)
