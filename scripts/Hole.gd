extends StaticBody

export(int) var time_ball_in_hole = 3

signal win()

func _on_Area_body_entered(_body: Node) -> void:
  $Timer.stop()
  $Timer.wait_time = time_ball_in_hole
  $Timer.start()


func _on_Area_body_exited(_body: Node) -> void:
  $Timer.stop()


func _on_Timer_timeout() -> void:
  emit_signal("win")
