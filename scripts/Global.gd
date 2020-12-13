extends Node

var levels = [ "Level1", "Level2", "Level3", "Level4", "Level5" ]
var level_index = 0

var level_rockets_count := 0
var level_time := 0
var total_rockets_count := 0
var total_time := 0

func previous_level() -> void:
  if level_index <= 0:
    return
  level_index -= 1
  get_tree().change_scene("res://scenes/levels/" + levels[level_index] + ".tscn")


func next_level() -> void:
  if level_index >= levels.size() - 1:
    return
  level_index += 1
  get_tree().change_scene("res://scenes/levels/" + levels[level_index] + ".tscn")


func restart() -> void:
  level_index = 0
  get_tree().change_scene("res://scenes/levels/" + levels[level_index] + ".tscn")
