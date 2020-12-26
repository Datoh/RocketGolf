extends RigidBody

onready var ball_position = global_transform
var priority_position := -1
var is_moving := false
var need_init := false

var init_position := Transform.IDENTITY
var init_linear_velocity := Vector3.ZERO
var init_angular_velocity := Vector3.ZERO
var init_impulse := Vector3.ZERO

func _physics_process(_delta: float) -> void:
  if _need_init():
    return
  var was_moving = is_moving
  is_moving = linear_velocity.length_squared() >= 0.3 or angular_velocity.length_squared() >= 0.8
  if was_moving and !is_moving:
    get_tree().call_group("checkpoint", "check", self)


func impulse(jump_force: float) -> void:
  apply_impulse(Vector3.ZERO, Vector3.UP * jump_force)


func init() -> void:
  _set_init(ball_position, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)


func stop() -> void:
  _set_init(global_transform, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)


func stop_and_go(direction: Vector3) -> void:
  _set_init(global_transform, Vector3.ZERO, Vector3.ZERO, direction)


func _set_init(position: Transform, linear_vel: Vector3, angular_vel: Vector3, impulse: Vector3) -> void:
  need_init = true
  init_position = position
  init_linear_velocity = linear_vel
  init_angular_velocity = angular_vel
  init_impulse = impulse


func _need_init() -> bool:
  if need_init:
    is_moving = false
    global_transform = init_position
    linear_velocity = init_linear_velocity
    angular_velocity = init_angular_velocity
    apply_impulse(Vector3.ZERO, init_impulse)
    need_init = false
    return true
  else:
    return false


func checkpoint(position: Vector3, checkpoint_priority) -> void:
  if priority_position < checkpoint_priority:
    priority_position = checkpoint_priority
    ball_position.origin = position
