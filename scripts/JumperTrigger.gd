extends StaticBody

func do_jump() -> void:
  var jumper = get_tree().root.find_node(name + "Destination", true, false)
  jumper.enabled_disabled()
  get_tree().call_group(name, "enabled_disabled")

