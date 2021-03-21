extends StaticBody

export(float) var jump_force = 25.0
export(bool) var enabled = false

func _ready() -> void:
  var spatial_material := $MeshInstance.get_surface_material(1) as SpatialMaterial
  spatial_material.emission_enabled = enabled


func enabled_disabled() -> void:
  enabled = !enabled
  var spatial_material := $MeshInstance.get_surface_material(1) as SpatialMaterial
  spatial_material.emission_enabled = enabled
  if not enabled:
    return
    
  var balls = $Hole.get_overlapping_bodies()
  if balls.empty():
    return;
  balls[0].impulse(jump_force)


func _on_Area_body_entered(body: Node) -> void:
  if enabled:
    body.impulse(jump_force)
