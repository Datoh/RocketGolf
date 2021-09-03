extends Spatial

const DELAY = 100 # in ms

var objects := {} # dictionnary of object by player id
var world_state_buffer := []
var last_world_state_time = 0
var ping_timer = null

var object_next_id = 0

func _ready():
  Network.connect("player_disconnected", self, "_on_player_disconnected")
  Network.connect("client_player_connected", self, "_on_player_connected")
  Network.connect("client_world_state_updated", self, "_on_world_state_updated")
  Network.connect("client_objects_removed", self, "_on_objects_removed")


func _exit_tree():
  if !get_tree().is_network_server():
    Network.disconnect_network()


func _physics_process(_delta):
  var is_connected := get_tree().has_network_peer()
  if not is_connected or get_tree().is_network_server():
    return

  if world_state_buffer.size() > 1:
    var render_time = Network.current_time() - DELAY
    while world_state_buffer.size() > 2 and render_time > world_state_buffer[2][Network.TIMESTAMP_KEY]:
      world_state_buffer.remove(0)

    if world_state_buffer.size() > 1:
      var state1 = world_state_buffer[-2]
      var state2 = world_state_buffer[-1]
      var state1_timestamp = state1[Network.TIMESTAMP_KEY]
      var state2_timestamp = state2[Network.TIMESTAMP_KEY]
      var interpolation_factor
      if render_time <= state2[Network.TIMESTAMP_KEY]: # We have a future state => interpolation
        interpolation_factor = float(render_time - state1_timestamp) / float(state2_timestamp - state1_timestamp)
      else: # We have two pasts states => extrapolation
        interpolation_factor = 1.0 + (float(render_time - state1_timestamp) / float(state2_timestamp - state1_timestamp))
      # TODO: fix negative interpolation_factor

      var local_player_id = get_tree().get_network_unique_id()
      for network_id in state1[Network.DATA_KEY].keys():
        if not objects.has(network_id) or not state2[Network.DATA_KEY].has(network_id):
          continue
        var object = objects[network_id]
        if object.get_network_master() == local_player_id:
          continue
        object.visible = true
        object.set_state(state1[Network.DATA_KEY][network_id][Network.STATE_KEY], state2[Network.DATA_KEY][network_id][Network.STATE_KEY], interpolation_factor)


func _on_player_connected(_players_data, new_player_id):
  var local_player_id = get_tree().get_network_unique_id()
  if new_player_id == local_player_id:
    Network.ping()
    ping_timer = Timer.new()
    ping_timer.autostart = true
    ping_timer.wait_time = 0.5
    ping_timer.connect("timeout", self, "_on_ping_timer_timeout")
    self.add_child(ping_timer)
    get_tree().change_scene("res://scenes/LevelTest.tscn")
  else:
    for network_id in objects.keys():
      var object = objects[network_id]
      if object.get_network_master() == local_player_id:
        Network.add_object_for_client(new_player_id, network_id, object.type, object.initial_state())


func _on_ping_timer_timeout():
  Network.ping()


func _on_player_disconnected(player_id):
  ping_timer.stop()
  ping_timer = null
  var local_player_id = get_tree().get_network_unique_id()
  var to_remove = []
  for network_id in objects.keys():
    if player_id == local_player_id or objects[network_id].get_network_master() == player_id:
      to_remove.append(network_id)

  for network_id in to_remove:
    objects[network_id].queue_free()
    objects.erase(network_id)

  if player_id == local_player_id:
    Network.disconnect_network()


func _on_world_state_updated(world_state):
  var world_state_timestamp = world_state[Network.TIMESTAMP_KEY]
  if last_world_state_time < world_state_timestamp:
    last_world_state_time = world_state_timestamp
    world_state_buffer.append(world_state)


# Locally added object
func add_object(type, object):
  object_next_id += 1
  var local_player_id = get_tree().get_network_unique_id()
  var network_id = Network.get_network_id(local_player_id, object_next_id)
  add_remote_object(network_id, type, object)
  Network.add_object(network_id, type, object.initial_state())


# Remotly added object
func add_remote_object(network_id, type, object):
  var local_player_id = get_tree().get_network_unique_id()
  var player_id = Network.get_player_id(network_id)
  if player_id != local_player_id:
    object.visible = false
  object.network_id = network_id
  object.type = type
  object.set_network_master(player_id)
  objects[network_id] = object


func remove_object(object, network_id):
  if !Network.is_remote(object):
    Network.remove_object(network_id)
  objects.erase(network_id)


func _on_objects_removed(network_ids):
  for network_id in network_ids:
    if objects.has(network_id):
      var object = objects[network_id]
      if Network.is_remote(object):
        object.queue_free()
      objects.erase(network_id)


static func set_object_state(network_id, object_state):
  Network.set_object_state(network_id, { Network.TIMESTAMP_KEY: Network.current_time(), Network.STATE_KEY: object_state })


static func set_object_state_unreliable(network_id, object_state):
  Network.set_object_state_unreliable(network_id, { Network.TIMESTAMP_KEY: Network.current_time(), Network.STATE_KEY: object_state })
