extends Spatial

func _ready() -> void:
  $MeshInstance.queue_free()
  var teleport_name = name.left(name.length() - "Destination".length())
  if get_tree().root.find_node(teleport_name, true, false) == null:
    printerr("Teleport: Teleport missing [" + teleport_name + "] for node [" + name + "]")


func direction() -> Vector3:
  return $Position3D.global_transform.origin - global_transform.origin
