extends KinematicBody

class_name PlayerObject

onready var head = $Head
onready var camera = $Head/Camera
onready var rocket_origin = $Head/Camera/Position3DOrigin
onready var rocket_direction = $Head/Camera/Position3DDirection
onready var player_position = global_transform
onready var camera_position = $Head/Camera.global_transform

export(float) var gravity := -30.0
export(float) var max_speed := 8.0
export(float) var jump_speed := 8.0
export(float) var mouse_sensitivity := 0.002  # radians/pixel

var velocity := Vector3()
var jump := false

var network_id := -1
var type
var just_reset_position := false

signal fire_rocket(rocket)

const Rocket = preload("res://scenes/Rocket.tscn")

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
  if Network.is_remote(self):
    return

  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    rotate_y(-event.relative.x * mouse_sensitivity)
    camera.rotate_x(-event.relative.y * mouse_sensitivity)
    camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func init() -> void:
  global_transform = player_position
  if camera != null:
    camera.global_transform = camera_position


func get_input() -> Vector3:
  if Input.is_action_just_pressed("ui_fire"):
    fire_rocket()

  jump = Input.is_action_just_pressed("ui_jump")

  var input_dir = Vector3()
  # desired move in camera direction
  if Input.is_action_pressed("ui_up"):
    input_dir += -camera.global_transform.basis.z
  if Input.is_action_pressed("ui_down"):
    input_dir += camera.global_transform.basis.z
  if Input.is_action_pressed("ui_left"):
    input_dir += -camera.global_transform.basis.x
  if Input.is_action_pressed("ui_right"):
    input_dir += camera.global_transform.basis.x
  input_dir = input_dir.normalized()
  return input_dir


func _physics_process(delta: float) -> void:
  if Network.is_remote(self):
    return

  if true or get_tree().has_network_peer():
    _update_state()

  velocity.y += gravity * delta
  var desired_velocity = get_input() * max_speed

  velocity.x = desired_velocity.x
  velocity.z = desired_velocity.z
  velocity = move_and_slide(velocity, Vector3.UP)
  if jump and is_on_floor():
    velocity.y += jump_speed


static func merge_state(state0, state1):
  if state0.has(Network.RESET_POSITION_KEY):
    state1[Network.RESET_POSITION_KEY] = 1
  return state1


static func clear_state(state):
  if state.has(Network.RESET_POSITION_KEY):
    state.erase(Network.RESET_POSITION_KEY)
  return state


func initial_state():
 return null


func set_initial_state(_state):
  $Head/Camera.current = false
  collision_layer = 0
  collision_mask = 0


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


func teleport(teleport, destination):
  var player_transform_y = global_transform.origin.y - teleport.global_transform.origin.y
  global_transform.origin = destination.global_transform.origin
  global_transform.origin.y += player_transform_y
  look_at(global_transform.origin + destination.direction(), Vector3.UP)
  just_reset_position = true


func fire_rocket() -> void:
  var rocket = Rocket.instance()
  rocket.launch(rocket_origin.global_transform, rocket_direction.global_transform)
  emit_signal("fire_rocket", rocket)
