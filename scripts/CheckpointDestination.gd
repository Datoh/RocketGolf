extends Spatial

func _ready() -> void:
  $MeshInstance.visible = false
  var checkpoint_name = name.left(name.length() - "Destination".length())
  if get_tree().root.find_node(checkpoint_name, true, false) == null:
    printerr("Checkpoint: area missing [" + checkpoint_name + "] for node [" + name + "]")
