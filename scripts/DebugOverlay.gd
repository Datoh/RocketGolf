extends CanvasLayer

# Debug overlay by Gonkee - full tutorial https://youtu.be/8Us2cteHbbo

var stats = []

func add_stat(stat_name: String, object: Object, stat_ref: String, is_method: bool) -> void:
  stats.append([stat_name, object, stat_ref, is_method])


func _process(delta: float) -> void:
  var label_text := ""

  label_text += str("FPS: ", Engine.get_frames_per_second()) + "\n"

  label_text += str("Static Memory: ", String.humanize_size(OS.get_static_memory_usage())) + "\n"

  for s in stats:
    var value = null

    if s[1] and weakref(s[1]).get_ref():
      if s[3]:
        value = s[1].call(s[2])
      else:
        value = s[1].get(s[2])
    label_text += str(s[0], ": ", value)
    label_text += "\n"

  $Label.text = label_text
