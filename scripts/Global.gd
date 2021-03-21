extends Node

const SAVEGAME = "user://savegame.save"

var levels = [
  "LevelFirstShot",
  "LevelKingOfTheHill",
  "LevelBridge",
  "LevelSnail",
  "LevelHighJump",
  "LevelSniper",
  "LevelDoubleShot",
  "LevelJumper",
  "LevelPlatform",
]
var level_index = 0

var level_rockets_count := 0
var level_time := 0
var level_score := 0
var total_rockets_count := 0
var total_time := 0
var total_score := 0

var debug_overlay := true

var key_value := 0
var keys = [
  "wasd (F1) - R to restart",
  "zqsd (F1) - R to restart",
 ]

func _ready() -> void:
  var save_game = File.new()
  if save_game.file_exists(SAVEGAME):
    save_game.open(SAVEGAME, File.READ)
    key_value = int(save_game.get_line())
    save_game.close()
    set_keys(0, key_value)


func previous_level() -> void:
  if level_index <= 0:
    return
  level_index -= 1
  get_tree().change_scene("res://scenes/levels/" + levels[level_index] + ".tscn")


func next_level() -> void:
  if level_index >= levels.size() - 1:
    get_tree().change_scene("res://scenes/TitleScreen.tscn")
  else:
    level_index += 1
    get_tree().change_scene("res://scenes/levels/" + levels[level_index] + ".tscn")


func restart() -> void:
  level_index = 0
  get_tree().change_scene("res://scenes/levels/" + levels[level_index] + ".tscn")


func switch_keys() -> void:
  var old_key_value = key_value
  key_value = (key_value + 1) % 2
  set_keys(old_key_value, key_value)
  
  var save_game = File.new()
  save_game.open(SAVEGAME, File.WRITE)
  save_game.store_line(str(key_value))
  save_game.close()


func set_keys(from: int, to: int) -> void:
  _remove_event_input_map("ui_left", from)
  _remove_event_input_map("ui_up", from)
  _add_event_input_map("ui_left", to)
  _add_event_input_map("ui_up", to)

  
func _remove_event_input_map(action: String, key: int):
  var ev = InputEventKey.new()
  ev.scancode = _get_key(action, key)
  InputMap.action_erase_event(action, ev)

  
func _add_event_input_map(action: String, key: int):
  var ev = InputEventKey.new()
  ev.scancode = _get_key(action, key)
  InputMap.action_add_event(action, ev)


func _get_key(action: String, key: int) -> int:
  if action == "ui_up":
    if key == 0:
      return KEY_W
    elif key == 1:
      return KEY_Z
  elif action == "ui_left":
    if key == 0:
      return KEY_A
    elif key == 1:
      return KEY_Q
  return 0
  
  
  
