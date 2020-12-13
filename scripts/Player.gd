extends KinematicBody

onready var head = $Head
onready var camera = $Head/Camera
onready var rocket_origin = $Head/Camera/Position3DOrigin
onready var rocket_direction = $Head/Camera/Position3DDirection
onready var player_position = global_transform
onready var camera_position = $Head/Camera.global_transform

export(float) var gravity = -30.0
export(float) var max_speed = 8.0
export(float) var jump_speed = 8.0
export(float) var mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3()
var jump = false

signal fire_rocket(rocket)

const Rocket = preload("res://scenes/Rocket.tscn")

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    rotate_y(-event.relative.x * mouse_sensitivity)
    camera.rotate_x(-event.relative.y * mouse_sensitivity)
    camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func init() -> void:
  global_transform = player_position
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
  velocity.y += gravity * delta
  var desired_velocity = get_input() * max_speed

  velocity.x = desired_velocity.x
  velocity.z = desired_velocity.z
  velocity = move_and_slide(velocity, Vector3.UP, true)
  if jump and is_on_floor():
    velocity.y += jump_speed


func fire_rocket() -> void:
  var rocket = Rocket.instance()
  emit_signal("fire_rocket", rocket)
  rocket.launch(rocket_origin.global_transform, rocket_direction.global_transform)
