extends MeshInstance

export(bool) var enabled = false

func _ready() -> void:
  get_surface_material(0).emission_enabled = enabled


func enabled_disabled() -> void:
  enabled = !enabled
  get_surface_material(0).emission_enabled = enabled
