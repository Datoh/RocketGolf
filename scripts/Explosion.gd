extends Spatial

func _ready() -> void:
  $Flames.emitting = true
  $Smoke.emitting = true


func _on_Timer_timeout() -> void:
  queue_free()
