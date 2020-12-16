extends Control

onready var answers = [ find_node("Answer1"), find_node("Answer2") ]
onready var selected_answer: Label = find_node("Answer1")

var question_index = 0
var questions = [
  "Pick your weapons ?",
  "Are you sure ?",
  "Did you read the title ?",
  "Last try ?!",
 ]

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  find_node("Question").text = questions[question_index]
  find_node("Key").text = Global.keys[Global.key_value]


func _physics_process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"):
    _previous_answer()
  if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_right"):
    _next_answer()
  if Input.is_action_just_pressed("ui_switch_control"):
    Global.switch_keys()
    find_node("Key").text = Global.keys[Global.key_value]
  if Input.is_action_just_pressed("ui_accept"):
    _accept(selected_answer)


func _on_Answer1_mouse_entered() -> void:
  _set_answer(find_node("Answer1"))


func _on_Answer2_mouse_entered() -> void:
  _set_answer(find_node("Answer2"))


func _on_Answer1_gui_input(event: InputEvent) -> void:
  if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
      _accept(find_node("Answer1"))


func _on_Answer2_gui_input(event: InputEvent) -> void:
  if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
    _accept(find_node("Answer2"))


func _accept(answer: Label) -> void:
  if answer == find_node("Answer1"):
    Global.restart()
  else:
    question_index = (question_index + 1) % questions.size()
    find_node("Question").text = questions[question_index]
    _set_answer(find_node("Answer1"))


func _next_answer() -> void:
  var id = answers.find(selected_answer)
  _set_answer(answers[(id + 1) % answers.size()])


func _previous_answer() -> void:
  var id = answers.find(selected_answer)
  _set_answer(answers[id - 1 if id > 0 else answers.size() - 1])


func _set_answer(answer: Label) -> void:
  for label in answers:
    label.text = label.text.replace(">", "")
  answer.text = ">" + answer.text
  selected_answer = answer
