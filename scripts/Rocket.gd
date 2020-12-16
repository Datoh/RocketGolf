extends KinematicBody

export(float) var speed := 25.0
export(float) var blow_radius := 3.0
export(float) var blow_force_direct := 20.0
export(float) var blow_force_indirect := 20.0
export(float) var factor_add_velocity_hit_directly := 0.5
export(float) var factor_add_up_hit_indirectly := 1.0

var velocity := Vector3.ZERO
var colliding_body: Spatial = null
var colliding_position := Vector3.ZERO

signal rocket_blow(rocket)


func launch(origin: Transform, direction: Transform) -> void:
  global_transform = origin
  transform = direction
  velocity = -transform.basis.z * speed


# 0: hit ball directly, 1: hit ball indrectly, 2: hit but not the ball
func hit(body: Spatial, position: Vector3) -> int:
  var hit_directly := colliding_body == body
  var hit := hit_directly

  var distance := 0.0
  
  # else check if near 
  if !hit:
    var raycast := $RayCast
    raycast.look_at(position, Vector3.UP)
    raycast.cast_to = Vector3(0.0, 0.0, -blow_radius)
    raycast.force_raycast_update()
    var colliding_ball = raycast.get_collider()
    hit = colliding_ball != null && body == colliding_ball.get_parent()
    if hit:
      colliding_position = raycast.get_collision_point()
      distance = colliding_position.distance_to(global_transform.origin)
      hit = distance < blow_radius

    raycast.global_transform.origin = global_transform.origin  

  if hit:
    var impulse_direction := global_transform.origin.direction_to(position).normalized()
    if !hit_directly:
      impulse_direction += Vector3.UP * factor_add_up_hit_indirectly
    else:
      impulse_direction += velocity.normalized() * factor_add_velocity_hit_directly

    var impulse_force := (blow_radius - distance) / blow_radius
    # farest is the explosion, lower is the impulse
    impulse_force = ease(impulse_force, 2.6) # see https://godotengine.org/qa/59172/how-do-i-properly-use-the-ease-function
    var blow_force := blow_force_direct if hit_directly else blow_force_indirect
    body.apply_central_impulse(impulse_direction.normalized() * impulse_force * blow_force)
  
  if hit_directly:
    return 0
  elif hit:
    return 1
  else:
    return 2


func _on_Timer_timeout() -> void:
  queue_free()


func _physics_process(delta: float) -> void:
  var colliding_info = move_and_collide(velocity * delta)
  if colliding_info != null:
    colliding_body = colliding_info.collider
    if colliding_body.is_in_group("ball"):
      colliding_body = colliding_body.get_parent()
    print(colliding_body.name)
    colliding_position = colliding_info.position
    if colliding_body.is_in_group("jumper_trigger"):
      colliding_body.do_jump()
    emit_signal("rocket_blow", self)
    queue_free()
