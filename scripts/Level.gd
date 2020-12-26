extends Spatial

export(String) var title = "Level test"

const Explosion = preload("res://scenes/Explosion.tscn")

onready var ball := $Ball
var debug_overlay = null

var win = false
var last_collider_rocket: Spatial = null

func _ready() -> void:
  $Hud.set_title(title)
  Global.level_rockets_count = 0
  Global.level_time = 0
  if Global.debug_overlay:
    _debug_overlay()


func _debug_overlay() -> void:
  if debug_overlay != null:
    remove_child(debug_overlay)
    debug_overlay = null
  else:
    debug_overlay = load("res://scenes/DebugOverlay.tscn").instance()
    debug_overlay.add_stat("Rocket hit", self, "_dbg_last_colllider_rocket", true)
    debug_overlay.add_stat("Checkpoint", ball, "priority_position", false)
    debug_overlay.add_stat("Ball linear_velocity", ball, "linear_velocity", false)
    debug_overlay.add_stat("Ball angular_velocity", ball, "angular_velocity", false)
    add_child(debug_overlay)
  Global.debug_overlay = debug_overlay != null


func _physics_process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_switch_control"):
    Global.switch_keys()
    $Hud.set_help()
  if Input.is_action_just_pressed("ui_debug"):
    _debug_overlay()
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
  if win and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_accept_mouse")):
    Global.next_level()


func restart() -> void:
  $Player.init()
  $Ball.init()
  for rocket in $Rockets.get_children():
    $Rockets.remove_child(rocket)
    rocket.queue_free()


func _on_Hole_win() -> void:
  AudioManager.play("res://assets/audio/jingles_STEEL15.ogg", $Player.global_transform.origin)
  
  win = true
  $Player.enabled = false

  Global.level_score = 100
  Global.level_score -= int(float(Global.level_time - (Global.level_time % 10)) / 10)
  Global.level_score -= Global.level_rockets_count * 5
  Global.level_score = int(max(0, Global.level_score))

  Global.total_time += Global.level_time
  Global.total_rockets_count += Global.level_rockets_count
  Global.total_score += Global.level_score

  $Hud.draw_victory()
 

func _on_Player_fire_rocket(rocket: Spatial) -> void:
  $Rockets.add_child(rocket)
  Global.total_rockets_count += 1
  rocket.connect("rocket_blow", self, "_on_rocket_blow")


func _on_rocket_blow(rocket: Spatial, collider: Spatial) -> void:
  last_collider_rocket = collider
  var explosion = Explosion.instance()  
  $Rockets.add_child(explosion)
  explosion.global_transform.origin = rocket.global_transform.origin
  explosion.launch()
  var hit = rocket.hit(ball, ball.global_transform.origin)
  # 0: hit ball directly, 1: hit ball indrectly, 2: hit but not the ball
  AudioManager.play("res://assets/audio/lowFrequency_explosion_001.ogg", rocket.global_transform.origin)
  if hit == 0:
    AudioManager.play("res://assets/audio/impactMetal_000.ogg", rocket.global_transform.origin)


func _on_ball_falling(falling_ball: RigidBody) -> void:
  falling_ball.init()


func _dbg_last_colllider_rocket() -> String:
  return last_collider_rocket.name if last_collider_rocket != null else "Null"
