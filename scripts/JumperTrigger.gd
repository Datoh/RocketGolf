extends StaticBody

func _ready() -> void:
  for child in get_children():
    _add_link_child(name, child)
  if get_tree().root.find_node(name + "Destination", true, false) == null:
    printerr("JumperTrigger: Destination missing [" + name + "Destination] for node [" + name + "]")


func _add_link_child(group_name: String, node: Node):
  if node.is_in_group("JumperLink"):
    node.add_to_group(group_name)
  for child in node.get_children():
    _add_link_child(group_name, child)


func enabled_disabled() -> void:
  var jumper = get_tree().root.find_node(name + "Destination", true, false)
  jumper.enabled_disabled()
  get_tree().call_group(name, "enabled_disabled")
