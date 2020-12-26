extends StaticBody

func _ready() -> void:
  for child in get_children():
    _check_child(name, child)


func _check_child(group_name: String, node: Node):
  if node.is_in_group("JumperLink"):
    node.add_to_group(group_name)
  for child in node.get_children():
    _check_child(group_name, child)


func enabled_disabled() -> void:
  var jumper = get_tree().root.find_node(name + "Destination", true, false)
  jumper.enabled_disabled()
  get_tree().call_group(name, "enabled_disabled")
