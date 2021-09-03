extends Control


func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_switch_control"):
    Global.switch_keys()
    find_node("Key").text = Global.keys[Global.key_value]
  if Input.is_action_just_pressed("ui_accept"):
    Network.connect_to_server(Network.DEFAULT_IP, Network.DEFAULT_PORT)
