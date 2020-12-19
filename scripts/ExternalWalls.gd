extends Spatial

export(bool) var enabled_force_field = true
export(float) var height = 60.0
export(float) var inset = 2.0

var min_point = null
var max_point = null

var mdt := MeshDataTool.new()

signal ball_falling(ball)

func _ready() -> void:
  if !enabled_force_field:
    $ForceField.queue_free()
    $ExternalWallsPlayer.queue_free()
    $ExternalWallsBall.queue_free()
    return

  for obj in get_tree().get_nodes_in_group("external_wall"):
    if obj is MeshInstance:
      _add_mesh(obj.mesh, Transform())
    if obj is CSGShape:
      if obj.is_root_shape():
        obj._update_shape()
        var m = obj.get_meshes()
        _add_mesh(m[1], obj.transform * m[0])
  mdt = null
  min_point.x += inset
  min_point.z += inset
  max_point.x -= inset
  max_point.z -= inset
  min_point.y = -height / 2.0
  max_point.y = height / 2.0
  var size = max_point - min_point
  var center = min_point + size / 2.0

  $ForceField.mesh.size = size
  $ExternalWallsPlayer/Forward.scale = Vector3(size.x + inset * 2.0, height, 1.0)
  $ExternalWallsPlayer/Forward.translation = Vector3(0.0, 0.0, size.z / 2.0 + inset + 0.5)
  $ExternalWallsPlayer/Backward.scale = Vector3(size.x + inset * 2.0, height, 1.0)
  $ExternalWallsPlayer/Backward.translation = Vector3(0.0, 0.0, -(size.z / 2.0 + inset + 0.5))
  $ExternalWallsPlayer/Left.scale = Vector3(1.0, height, size.z + inset * 2.0)
  $ExternalWallsPlayer/Left.translation = Vector3(-(size.x / 2.0 + inset + 0.5), 0.0, 0.0)
  $ExternalWallsPlayer/Right.scale = Vector3(1.0, height, size.z + inset * 2.0)
  $ExternalWallsPlayer/Right.translation = Vector3(size.x / 2.0 + inset + 0.5, 0.0, 0.0)
  $ExternalWallsBall/Forward.scale = Vector3(size.x, height, 1.0)
  $ExternalWallsBall/Forward.translation = Vector3(0.0, 0.0, size.z / 2.0 + 0.5)
  $ExternalWallsBall/Backward.scale = Vector3(size.x, height, 1.0)
  $ExternalWallsBall/Backward.translation = Vector3(0.0, 0.0, -(size.z / 2.0 + 0.5))
  $ExternalWallsBall/Left.scale = Vector3(1.0, height, size.z)
  $ExternalWallsBall/Left.translation = Vector3(-(size.x / 2.0 + 0.5), 0.0, 0.0)
  $ExternalWallsBall/Right.scale = Vector3(1.0, height, size.z)
  $ExternalWallsBall/Right.translation = Vector3(size.x / 2.0 + 0.5, 0.0, 0.0)
  $ExternalWallsBall/Top.scale = Vector3(size.x, 1.0, size.z)
  $ExternalWallsBall/Top.translation = Vector3(0.0, height / 2.0, 0.0)
  
  translation = center


func _add_mesh(mesh: Mesh, transform: Transform) -> void:
  mdt.create_from_surface(mesh, 0)
  for i in range(mdt.get_vertex_count()):
    var vertex = transform.xform(mdt.get_vertex(i))
    min_point = vertex if min_point == null else min_point
    max_point = vertex if max_point == null else max_point
    min_point.x = min(vertex.x, min_point.x)
    min_point.y = min(vertex.y, min_point.y)
    min_point.z = min(vertex.z, min_point.z)
    max_point.x = max(vertex.x, max_point.x)
    max_point.y = max(vertex.y, max_point.y)
    max_point.z = max(vertex.z, max_point.z)


func _on_FallingArea_body_entered(body: Node) -> void:
  emit_signal("ball_falling", body)
