extends Spatial

onready var _ball := $Ball

func _physics_process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_cancel"):
    get_tree().reload_current_scene()


func _on_Hole_win() -> void:
  print("win")


func _on_Player_fire_rocket(rocket: Spatial) -> void:
  $Rockets.add_child(rocket)
  rocket.connect("rocket_blow", self, "_on_rocket_blow")


func _on_rocket_blow(rocket: Spatial) -> void:
  rocket.hit(_ball, _ball.global_transform.origin)
