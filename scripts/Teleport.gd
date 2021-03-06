extends CSGBox

func _ready() -> void:
  if get_tree().root.find_node(name + "Destination", true, false) == null:
    printerr("Teleport: destination missing [" + name + "Destination] for node [" + name + "]")


func _on_TeleportArea_body_entered(body: Node) -> void:
  var destination = get_tree().root.find_node(name + "Destination", true, false)
  var player := body as KinematicBody
  var player_transform_y = player.global_transform.origin.y - global_transform.origin.y
  player.global_transform.origin = destination.global_transform.origin
  player.global_transform.origin.y += player_transform_y
  player.look_at(player.global_transform.origin + destination.direction(), Vector3.UP)
