extends Area

export(float) var speed := 25.0
export(float) var blow_radius := 5.0
export(float) var blow_force := 20.0
var velocity := Vector3()

var colliding_body: Spatial = null

signal rocket_blow(rocket)

func launch(origin: Transform, direction: Transform) -> void:
  global_transform = origin
  transform = direction
  velocity = -transform.basis.z * speed


func hit(body: Spatial, position: Vector3) -> bool:
  var hit := colliding_body == body
  var distance := 0.0
  var collider_point := global_transform.origin
  
  # first check if body is overlapping rocket
  if !hit:
    for overlapping_body in get_overlapping_bodies():
      hit = hit || overlapping_body == body
  
  # else check if near 
  if !hit:
    var raycast = $RayCast
    raycast.cast_to = Vector3.ZERO
    raycast.cast_to.z = blow_radius
    raycast.force_raycast_update()
    if colliding_body == raycast.get_collider():
      raycast.global_transform.origin = raycast.get_collision_point()
      raycast.transform.origin -= velocity.normalized() * 0.1
     
    raycast.look_at(position, Vector3.UP)
    raycast.cast_to.z = -blow_radius
    raycast.force_raycast_update()
    hit = body == raycast.get_collider()
    if hit:
      collider_point = raycast.get_collision_point()
      distance = collider_point.distance_to(global_transform.origin)
      hit = distance < blow_radius

    raycast.global_transform.origin = global_transform.origin  

  if hit:
    var impulse_direction = global_transform.origin.direction_to(position)
    var impulse_force = (blow_radius - distance) / blow_radius * blow_force
    impulse_direction = impulse_direction.normalized() + Vector3.UP
    body.apply_central_impulse(impulse_direction.normalized() * impulse_force)
    
  return hit


func _process(delta: float) -> void:
  transform.origin += velocity * delta


func _on_Timer_timeout() -> void:
  queue_free()


func _on_Rocket_body_entered(body: Node) -> void:
  if body.is_in_group("jumper_trigger"):
    body.do_jump()
  colliding_body = body
  emit_signal("rocket_blow", self)
  queue_free()


func _on_Rocket_area_entered(_area: Area) -> void:
  emit_signal("rocket_blow", self)
  queue_free()

