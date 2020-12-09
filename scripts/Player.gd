extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.98
export var mouse_sensitivity = 0.3

onready var _head = $Head
onready var _camera = $Head/Camera
onready var _rocket_origin = $Head/Camera/Position3DOrigin
onready var _rocket_direction = $Head/Camera/Position3DDirection

var _velocity = Vector3()
var _camera_x_rotation = 0

signal fire_rocket(rocket)

const Rocket = preload("res://scenes/Rocket.tscn")

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    _head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

    var x_delta = event.relative.y * mouse_sensitivity
    if _camera_x_rotation + x_delta > -90 and _camera_x_rotation + x_delta < 90: 
      _camera.rotate_x(deg2rad(-x_delta))
      _camera_x_rotation += x_delta


func _physics_process(delta: float) -> void:
  var direction = Vector3()

  var head_basis = _head.get_global_transform().basis

  if Input.is_action_pressed("ui_up"):
   direction -= head_basis.z
  elif Input.is_action_pressed("ui_down"):
   direction += head_basis.z
  
  if Input.is_action_pressed("ui_left"):
   direction -= head_basis.x
  elif Input.is_action_pressed("ui_right"):
   direction += head_basis.x

  if Input.is_action_just_pressed("ui_fire"):
    fire_rocket()

  direction = direction.normalized()
  _velocity = _velocity.linear_interpolate(direction * speed, acceleration * delta)
  _velocity.y -= gravity

  _velocity = move_and_slide(_velocity)


func fire_rocket() -> void:
  var rocket = Rocket.instance()
  rocket.launch(_rocket_origin.global_transform, _rocket_direction.global_transform)
  emit_signal("fire_rocket", rocket)
