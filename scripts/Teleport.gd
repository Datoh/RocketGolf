extends CSGBox

func _on_Area_body_entered(body: Node) -> void:
  var root = get_tree().root.get_child(0)
  var destination = root.find_node(name + "Destination")
  var player := body as KinematicBody
  var player_transform_y = player.global_transform.origin.y - global_transform.origin.y
  player.global_transform.origin = destination.global_transform.origin
  player.global_transform.origin.y += player_transform_y
  player.look_at(player.global_transform.origin + destination.cast_to, Vector3.UP)
  emit_signal("teleport", body, destination)
