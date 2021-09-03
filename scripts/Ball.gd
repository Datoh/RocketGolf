extends RigidBody

class_name BallObject

onready var ball_position = global_transform
var priority_position := -1
var is_moving := false
var need_init := false

var init_position := Transform.IDENTITY
var init_linear_velocity := Vector3.ZERO
var init_angular_velocity := Vector3.ZERO
var init_impulse := Vector3.ZERO

var is_on_floor = false

var network_id = -1
var type
var just_reset_position = false

func _physics_process(_delta: float) -> void:
  if Network.is_remote(self):
    return
  if _need_init():
    return
  if get_tree().has_network_peer():
    _update_state()

  var was_moving = is_moving
  is_moving = linear_velocity.length_squared() >= 0.3 or angular_velocity.length_squared() >= 0.8
  if was_moving and !is_moving:
    get_tree().call_group("checkpoint", "check", self)


func initial_state():
 return null


func set_initial_state(_state):
  remove_child($StaticBodyBall)
  collision_layer = 0
  collision_mask = 0


static func merge_state(state0, state1):
  if state0.has(Network.RESET_POSITION_KEY):
    state1[Network.RESET_POSITION_KEY] = 1
  return state1


static func clear_state(state):
  if state.has(Network.RESET_POSITION_KEY):
    state.erase(Network.RESET_POSITION_KEY)
  return state


func _update_state():
  if just_reset_position:
    Client.set_object_state(network_id, { Network.POSITION_KEY: translation, Network.RESET_POSITION_KEY: 1 })
    just_reset_position = false
  else:
    Client.set_object_state_unreliable(network_id, { Network.POSITION_KEY: translation })


func set_state(previous_state, next_state, interpolation_factor):
  if previous_state[Network.POSITION_KEY] == next_state[Network.POSITION_KEY]:
    translation = next_state[Network.POSITION_KEY]
  elif next_state.has(Network.RESET_POSITION_KEY):
    # TODO should be extrapolation, but missing previous_previous_state
    translation = previous_state[Network.POSITION_KEY]
  elif interpolation_factor <= 1.0: # Manage extrapolation
    translation = lerp(previous_state[Network.POSITION_KEY], next_state[Network.POSITION_KEY], interpolation_factor)
  else: # Manage interpolation
    var times = floor(interpolation_factor)
    var translation1 = next_state[Network.POSITION_KEY]
    var translation2 = translation1 + (times * (translation1 - previous_state[Network.POSITION_KEY]))
    translation = lerp(translation1, translation2, interpolation_factor - times)


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
    just_reset_position = true
    return true
  else:
    return false


func checkpoint(position: Vector3, checkpoint_priority) -> void:
  if priority_position < checkpoint_priority:
    priority_position = checkpoint_priority
    ball_position.origin = position


func _on_Ball_body_entered(body: Node) -> void:
  if not body.is_in_group("player") and not body.is_in_group("rocket"):
    is_on_floor = true


func _on_Ball_body_exited(body: Node) -> void:
  if not body.is_in_group("player") and not body.is_in_group("rocket"):
    is_on_floor = false
