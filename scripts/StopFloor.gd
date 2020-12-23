extends CSGBox

func _ready() -> void:
  $Area/CollisionShape.scale = Vector3(width / 2.0, height, depth / 2.0)


func _on_Area_body_entered(body: Node) -> void:
  body.stop()
