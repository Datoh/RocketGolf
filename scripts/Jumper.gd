extends CSGCylinder

export(float) var jump_force = 25.0

func do_jump() -> void:
  var balls = $Area.get_overlapping_bodies()
  if balls.empty():
    return;
  balls[0].do_jump(jump_force)
