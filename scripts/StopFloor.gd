extends MeshInstance


func _on_Area_body_entered(body: Node) -> void:
  body.stop()
