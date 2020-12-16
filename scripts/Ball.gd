extends RigidBody

onready var ball_position = global_transform
var priority_position := -1
var is_moving := false
var need_init := false

func _physics_process(_delta: float) -> void:
  if _need_init():
    return
  var was_moving = is_moving
  is_moving = linear_velocity.length_squared() < 0.1 and angular_velocity.length_squared() < 0.5
  if was_moving and !is_moving:
    get_tree().call_group("checkpoint", "check", self)


func do_jump(jump_force: float) -> void:
  apply_impulse(Vector3.ZERO, Vector3.UP * jump_force)


func init() -> void:
  need_init = true


func _need_init() -> bool:
  if need_init:
    is_moving = false
    global_transform = ball_position
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
    need_init = false
    return true
  else:
    return false
    

func checkpoint(position: Vector3, checkpoint_priority) -> void:
  if priority_position < checkpoint_priority:
    priority_position = checkpoint_priority
    ball_position.origin = position
