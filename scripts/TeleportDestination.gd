extends Spatial

func _ready() -> void:
  $MeshInstance.queue_free()

func direction() -> Vector3:
  return $Position3D.global_transform.origin - global_transform.origin
