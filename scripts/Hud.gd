extends MarginContainer

onready var hud_time := find_node("TimeLabel")
onready var hud_rockets := find_node("RocketsLabel")

func _ready() -> void:
  find_node("KeyLabel").text = Global.keys[Global.key_value]
  
  
func set_title(title: String) -> void:
  find_node("TitleLabel").text = title


func set_help() -> void:
  find_node("KeyLabel").text = Global.keys[Global.key_value]


func draw_victory() -> void:
  $Timer.stop()
  var seconds = Global.level_time % 60
  var minutes = (Global.level_time - seconds) / 60
  find_node("VictoryTimeLabel").text = "Time: " + str(minutes) + ":" + str(seconds).pad_zeros(2)
  find_node("VictoryRocketLabel").text = "Rockets: " + str(Global.level_rockets_count)
  find_node("VictoryScoreLabel").text = "Score: " + str(Global.level_score) + "%"
  find_node("InGame").visible = false
  find_node("Victory").visible = true


func _on_Timer_timeout() -> void:
  Global.level_time += 1
  var seconds = Global.level_time % 60
  var minutes = (Global.level_time - seconds) / 60
  hud_time.text = str(minutes) + ":" + str(seconds).pad_zeros(2)


func _on_Player_fire_rocket(_rocket) -> void:
  Global.level_rockets_count += 1
  hud_rockets.text = str(Global.level_rockets_count)
