extends CSGCylinder

export(float) var jump_force = 25.0
export(bool) var enabled = false

func _ready() -> void:
  var spatial_material := material as SpatialMaterial
  spatial_material.emission_enabled = enabled


func enabled_disabled() -> void:
  enabled = !enabled
  var spatial_material := material as SpatialMaterial
  spatial_material.emission_enabled = enabled
  if not enabled:
    return
    
  var balls = $Area.get_overlapping_bodies()
  if balls.empty():
    return;
  balls[0].do_jump(jump_force)


func _on_Area_body_entered(body: Node) -> void:
  if enabled:
    body.do_jump(jump_force)
