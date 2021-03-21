tool
extends EditorScenePostImport

func post_import(scene):
  var tmp_parent = scene.get_child(0)
  var child = tmp_parent.get_child(0)
  tmp_parent.remove_child(child)
  scene.remove_child(tmp_parent)
  scene.add_child(child)
  child.set_owner(scene)
  tmp_parent.queue_free()
  child.create_convex_collision ()
  return scene
