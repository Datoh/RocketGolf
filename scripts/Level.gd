extends Spatial

class_name LevelState

export(String) var title = "Level test1"

const Explosion = preload("res://scenes/Explosion.tscn")
const Player = preload("res://scenes/Player.tscn")
const Ball = preload("res://scenes/Ball.tscn")
const Rocket = preload("res://scenes/Rocket.tscn")

onready var ball := $Ball
onready var player := $Player
var debug_overlay = null

var win = false
var last_collider_rocket: Spatial = null
var player_stats = PlayerStats.new()

enum ObjectType { Player, Ball, Rocket }


func _ready() -> void:
  $Hud.set_title(title)
  $Hud.player_stats = player_stats
  Global.player_stats.append(player_stats)
  if Global.debug_overlay:
    _debug_overlay()

  Network.connect("object_added", self, "_on_object_added")
  var is_connected := get_tree().has_network_peer()
  if is_connected:
    Client.add_object(ObjectType.Player, player)
    Client.add_object(ObjectType.Ball, ball)

  $ExternalWalls.connect("rocket_out", self, "_on_rocket_out")
  $ExternalWalls.connect("ball_falling", self, "_on_ball_falling")
  $Ball.connect("body_entered", self, "_on_Ball_body_entered")
  $Ball.connect("body_exited", self, "_on_Ball_body_exited")
  $Player.connect("fire_rocket", self, "_on_Player_fire_rocket")
  $Player.connect("fire_rocket", $Hud, "_on_Player_fire_rocket")
  $Content/Ground/Hole.connect("win", self, "_on_Hole_win")

  $Player.add_to_group("player")

func _on_object_added(player_id, network_id, type, state):
  var local_player_id = get_tree().get_network_unique_id()
  if local_player_id == player_id:
    return
  var object
  if type == ObjectType.Player:
    object = Player.instance()
  elif type == ObjectType.Ball:
    object = Ball.instance()
  elif type == ObjectType.Rocket:
    object = Rocket.instance()
  object.name = "Object_" + str(network_id)
  $Objects.add_child(object)
  Client.add_remote_object(network_id, type, object)
  object.set_initial_state(state)


static func merge_state(type, state0, state1):
  if type == ObjectType.Player:
    return PlayerObject.merge_state(state0, state1)
  elif type == ObjectType.Ball:
    return BallObject.merge_state(state0, state1)
  elif type == ObjectType.Rocket:
    return RocketObject.merge_state(state0, state1)
  return state1


static func clear_state(type, state):
  if type == ObjectType.Player:
    return PlayerObject.clear_state(state)
  elif type == ObjectType.Ball:
    return BallObject.clear_state(state)
  elif type == ObjectType.Rocket:
    return RocketObject.clear_state(state)
  return state


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
  player.init()
  $Ball.init()
  for rocket in $Rockets.get_children():
    $Rockets.remove_child(rocket)
    rocket.queue_free()


func _on_Hole_win() -> void:
  AudioManager.play("res://assets/audio/jingles_STEEL15.ogg", player.global_transform.origin)

  win = true
  player.enabled = false

  player_stats.score = 100
  player_stats.score -= int(float(player_stats.time - (player_stats.time % 10)) / 10)
  player_stats.score -= player_stats.rocket_count * 5
  player_stats.score = int(max(0, player_stats.score))

  var _total = PlayerStats.merge(Global.player_stats)

  $Hud.draw_victory()


func _on_Player_fire_rocket(rocket: Spatial) -> void:
  Client.add_object(ObjectType.Rocket, rocket)
  $Rockets.add_child(rocket)
  player_stats.rocket_count += 1
  rocket.connect("rocket_blow", self, "_on_rocket_blow")


func _on_rocket_blow(rocket: Spatial, collider: Spatial) -> void:
  var explosion = Explosion.instance()
  $Rockets.add_child(explosion)
  explosion.global_transform.origin = rocket.global_transform.origin
  AudioManager.play("res://assets/audio/lowFrequency_explosion_001.ogg", rocket.global_transform.origin)

  if Network.is_remote(rocket):
    return

  last_collider_rocket = collider
  # 0: hit ball directly, 1: hit ball indirectly, 2: hit but not the ball
  var hit = rocket.hit(ball, ball.global_transform.origin)

  AudioManager.play("res://assets/audio/lowFrequency_explosion_001.ogg", rocket.global_transform.origin)
  if hit == 0:
    AudioManager.play("res://assets/audio/impactMetal_000.ogg", rocket.global_transform.origin)

  var is_air_shot = hit == 0 and not ball.is_on_floor
  var distance = rocket.global_transform.origin.distance_squared_to(rocket.origin) if hit != 2 else 0.0
  player_stats.air_shot_count += 1 if is_air_shot else 0
  player_stats.hit_count += 1 if hit != 2 else 0
  player_stats.longuest_air_shot = distance if is_air_shot and distance > player_stats.longuest_air_shot else player_stats.longuest_air_shot
  player_stats.longuest_shot = distance if distance > player_stats.longuest_shot else player_stats.longuest_shot
  player_stats.longuest_shot_serie = 0 if hit == 2 else player_stats.longuest_shot_serie + 1


func _on_ball_falling(falling_ball: RigidBody) -> void:
  falling_ball.init()


func _on_rocket_out(rocket) -> void:
  player_stats.longuest_shot_serie = 0
  rocket.level_out()


func _dbg_last_colllider_rocket() -> String:
  return last_collider_rocket.name if last_collider_rocket != null else "Null"
