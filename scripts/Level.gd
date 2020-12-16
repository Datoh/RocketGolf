extends Spatial

export(String) var title = "Level test"

const Explosion = preload("res://scenes/Explosion.tscn")

onready var ball := $Ball

var win = false

func _ready() -> void:
  $Hud.set_title(title)
  Global.level_rockets_count = 0
  Global.level_time = 0


func _physics_process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_switch_control"):
    Global.switch_keys()
    $Hud.set_help()
  if Input.is_action_just_pressed("ui_restart"):
    restart()
  if Input.is_action_just_pressed("ui_cancel"):
    get_tree().change_scene("res://scenes/TitleScreen.tscn")
  if Input.is_action_just_pressed("ui_next_level"):
    Global.next_level()
  if Input.is_action_just_pressed("ui_previous_level"):
    Global.previous_level()
  if Input.is_action_just_pressed("ui_level_test"):
    get_tree().change_scene("res://scenes/LevelTest.tscn")
  if win and Input.is_action_just_pressed("ui_accept"):
    Global.next_level()


func restart() -> void:
  $Player.init()
  $Ball.init()
  for rocket in $Rockets.get_children():
    $Rockets.remove_child(rocket)
    rocket.queue_free()


func _on_Hole_win() -> void:
  win = true
  $Player.enabled = false

  Global.level_score = 100
  Global.level_score -= (Global.level_time - (Global.level_time % 10)) / 10
  Global.level_score -= Global.level_rockets_count * 5
  Global.level_score = max(0, Global.level_score)

  Global.total_time += Global.level_time
  Global.total_rockets_count += Global.level_rockets_count
  Global.total_score += Global.level_score

  $Hud.draw_victory()
 

func _on_Player_fire_rocket(rocket: Spatial) -> void:
  $Rockets.add_child(rocket)
  Global.total_rockets_count += 1
  rocket.connect("rocket_blow", self, "_on_rocket_blow")


func _on_rocket_blow(rocket: Spatial) -> void:
  var explosion = Explosion.instance()  
  $Rockets.add_child(explosion)
  explosion.global_transform.origin = rocket.global_transform.origin
  explosion.launch()
  var hit = rocket.hit(ball, ball.global_transform.origin)
  # 0: hit ball directly, 1: hit ball indrectly, 2: hit but not the ball
  if hit == 0:
    pass
