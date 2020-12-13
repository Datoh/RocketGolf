extends Spatial

export(String) var title = "Level test"

onready var ball := $Ball

func _ready() -> void:
  $Hud.set_title(title)

func _physics_process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_restart"):
    restart()
  if Input.is_action_just_pressed("ui_cancel"):
    Global.restart()
  if Input.is_action_just_pressed("ui_next_level"):
    Global.next_level()
  if Input.is_action_just_pressed("ui_previous_level"):
    Global.previous_level()
  if Input.is_action_just_pressed("ui_level_test"):
    get_tree().change_scene("res://scenes/LevelTest.tscn")


func restart() -> void:
  $Player.init()
  $Ball.init()
  for rocket in $Rockets.get_children():
    $Rockets.remove_child(rocket)
    rocket.queue_free()

func _on_Hole_win() -> void:
  Global.level_rockets_count = 0
  Global.level_time = 0
  Global.next_level()


func _on_Player_fire_rocket(rocket: Spatial) -> void:
  $Rockets.add_child(rocket)
  Global.total_rockets_count += 1
  rocket.connect("rocket_blow", self, "_on_rocket_blow")


func _on_rocket_blow(rocket: Spatial) -> void:
  rocket.hit(ball, ball.global_transform.origin)
