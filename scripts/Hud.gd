extends MarginContainer

onready var hud_time := find_node("TimeLabel")
onready var hud_rockets := find_node("RocketsLabel")

func set_title(title: String) -> void:
  find_node("TitleLabel").text = title


func _on_Timer_timeout() -> void:
  Global.level_time += 1
  var seconds = Global.level_time % 60
  var minutes = Global.level_time - seconds
  hud_time.text = str(minutes) + ":" + str(seconds).pad_zeros(2)


func _on_Player_fire_rocket(_rocket) -> void:
  Global.level_rockets_count += 1
  hud_rockets.text = str(Global.level_rockets_count)
