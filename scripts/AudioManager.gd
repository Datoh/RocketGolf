extends Node

var num_players := 8
var bus := "master"

var available = []  # The available players.

var queue = []  # The queue of sounds to play.

func _ready() -> void:
  for i in num_players:
    var p = AudioStreamPlayer3D.new()
    add_child(p)
    available.append(p)
    p.connect("finished", self, "_on_stream_finished", [p])
    p.bus = bus


func _on_stream_finished(stream: AudioStreamPlayer3D) -> void:
  available.append(stream)


func play(sound_path: String, position: Vector3) -> void:
  queue.append([sound_path, position])


func _process(_delta: float) -> void:
  if not queue.empty() and not available.empty():
    var sound = queue.pop_front()
    available[0].stream = load(sound[0])
    available[0].global_transform.origin = sound[1]
    available[0].play()
    available.pop_front()
