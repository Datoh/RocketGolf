extends Area

export(int) var checkpoint_priority = 0

func check(ball: RigidBody) -> void:
  for body in get_overlapping_bodies():
    if body == ball:
      var destination = get_tree().root.find_node(name + "Destination", true, false)
      ball.checkpoint(destination.global_transform.origin, checkpoint_priority)
