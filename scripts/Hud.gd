extends MarginContainer

onready var hud_time := find_node("TimeLabel")
onready var hud_rockets := find_node("RocketsLabel")

var player_stats = null

func _ready() -> void:
  find_node("KeyLabel").text = Global.keys[Global.key_value]


func set_title(title: String) -> void:
  find_node("TitleLabel").text = str(Global.level_index + 1) + ". " + title


func set_help() -> void:
  find_node("KeyLabel").text = Global.keys[Global.key_value]


func draw_victory() -> void:
  $Timer.stop()
  var seconds = player_stats.time % 60
  var minutes = (player_stats.time - seconds) / 60
  find_node("VictoryTimeLabel").text = "Time: " + str(minutes) + ":" + str(seconds).pad_zeros(2)
  find_node("VictoryRocketLabel").text = "Rockets: " + str(player_stats.rocket_count)
  find_node("VictoryScoreLabel").text = "Score: " + str(player_stats.score) + "%"
  find_node("InGame").visible = false
  find_node("Victory").visible = true


func _on_Timer_timeout() -> void:
  player_stats.time += 1
  var seconds = player_stats.time % 60
  var minutes = (player_stats.time - seconds) / 60
  hud_time.text = str(minutes) + ":" + str(seconds).pad_zeros(2)


func _on_Player_fire_rocket(_rocket) -> void:
  hud_rockets.text = str(player_stats.rocket_count)
