extends StaticBody

func do_jump() -> void:
  var jumper = get_tree().root.find_node(name + "Destination", true, false)
  jumper.do_jump()
