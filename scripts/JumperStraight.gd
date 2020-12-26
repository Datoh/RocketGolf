extends MeshInstance

export(float) var jump_force = 25.0

func _ready() -> void:
  get_surface_material(0).emission_enabled = false


func _on_Collision1_body_entered(ball: Node) -> void:
  ball.stop_and_go(($Collision1/Position3D.global_transform.origin - ball.global_transform.origin).normalized() * jump_force)


func _on_Collision2_body_entered(ball: Node) -> void:
  ball.stop_and_go(($Collision2/Position3D.global_transform.origin - ball.global_transform.origin).normalized() * jump_force)
