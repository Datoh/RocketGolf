extends Spatial

func _ready() -> void:
  yield(get_tree().create_timer(2.0), "timeout")
  queue_free()


func launch() -> void:
  $Flames.emitting = true
  $Smoke.emitting = true
