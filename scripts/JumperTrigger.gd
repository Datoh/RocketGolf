extends StaticBody

func do_jump() -> void:
  var root = get_tree().root.get_child(0)
  var jumper = root.find_node(name + "Destination")
  jumper.do_jump()
