extends Spatial

const FPS = 20
const NEXT = 1.0 / FPS
var current = 0
var current_level = 0

var world_state = {}
var object_type = {}
var to_remove = []

export(int) var port := Network.DEFAULT_PORT


func _ready():
  Network.connect("object_added", self, "_on_object_added")
  Network.connect("server_object_removed", self, "_on_object_removed")
  Network.connect("server_object_state", self, "_on_object_state")
  Network.connect("all_level_complete", self, "_on_all_level_complete")
  Network.create_server(port)


func _exit_tree():
  Network.disconnect_network()


func _physics_process(delta):
  current += delta
  if current > NEXT:
    # update world state
    current -= NEXT
    var temp_world_state = world_state.duplicate(true)
    for network_id in temp_world_state.keys():
      temp_world_state[network_id].erase(Network.TIMESTAMP_KEY)
    if not temp_world_state.empty():
      Network.update_world_state({ Network.TIMESTAMP_KEY: Network.current_time(), Network.DATA_KEY: temp_world_state })

    for network_id in to_remove:
      world_state.erase(network_id)
    Network.remove_objects(to_remove)
    to_remove.clear()

    for network_id in world_state.keys():
      world_state[network_id][Network.STATE_KEY] = LevelState.clear_state(object_type[network_id], world_state[network_id][Network.STATE_KEY])


func _on_object_added(_player_id, network_id, type, state):
  object_type[network_id] = type


func _on_object_removed(network_id):
  to_remove.append(network_id)


func _on_object_state(network_id, object_state):
  if not world_state.has(network_id):
    world_state[network_id] = object_state
  elif world_state[network_id][Network.TIMESTAMP_KEY] < object_state[Network.TIMESTAMP_KEY]:
    object_state[Network.STATE_KEY] = LevelState.merge_state(object_type[network_id], world_state[network_id][Network.STATE_KEY], object_state[Network.STATE_KEY])
    world_state[network_id] = object_state


func _on_all_level_complete():
  $Timer.start()


func _on_level_complete_timeout():
  current_level += 1
  Network.next_level(current_level)
