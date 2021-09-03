extends CSGBox

func _ready() -> void:
  if get_tree().root.find_node(name + "Destination", true, false) == null:
    printerr("Teleport: destination missing [" + name + "Destination] for node [" + name + "]")


func _on_TeleportArea_body_entered(body: Node) -> void:
  var destination = get_tree().root.find_node(name + "Destination", true, false)
  var player := body as KinematicBody
  player.teleport(self, destination)
