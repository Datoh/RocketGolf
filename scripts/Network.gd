extends Node

const DEFAULT_IP := "127.0.0.1"
const DEFAULT_PORT := 31412
const MAX_PLAYERS := 100
const LATENCY_SIZE := 9
const MAX_OBJECT_BY_PLAYER = 10000

var players_data = {}
var player_info = { name = "name", level_complete = false, time = 0, score = 0 }

var client_time_latency = -1
var client_times_latency = []

const TIMESTAMP_KEY = "T"
const POSITION_KEY = "P"
const RESET_POSITION_KEY = "RP"
const STATE_KEY = "S"
const DATA_KEY = "D"

# signals for clients
signal client_player_connected(player_data, player_id)
signal client_world_state_updated(world_state)
signal client_objects_removed(network_ids)

# signals for servers
signal server_object_removed(network_id)
signal server_object_state(network_id, object_state)

# signals for clients and servers
signal object_added(player_id, network_id, type, state)
signal player_disconnected(player_id)

signal level_complete(player_id, score, time)
signal all_level_complete()
signal next_level(level)


func _ready() -> void:
  get_tree().connect('server_disconnected', self, '_on_server_disconnected')


func create_server(port):
  get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
  get_tree().connect("network_peer_connected", self, "_on_player_connected")
  get_tree().connect("connection_failed", self, "_on_connection_failed")

  var peer := NetworkedMultiplayerENet.new()
  var result := peer.create_server(port, MAX_PLAYERS - 1)
  if result == OK:
    print("Create server on port ", port)
    get_tree().set_network_peer(peer)
    players_data.clear()
    Client.queue_free()
    assert(get_tree().is_network_server())
  return result


func connect_to_server(ip, port):
  get_tree().connect("network_peer_connected", self, "_on_connected_to_server")
  print("Connect to server: ", ip, ":", port)
  var peer := NetworkedMultiplayerENet.new()
  var result := peer.create_client(ip, port)
  if result == OK:
    get_tree().set_network_peer(peer)
  return result


func ping():
  assert(!get_tree().is_network_server())
  rpc_id(1, "_ping", OS.get_system_time_msecs())


sync func _ping(time):
  assert(get_tree().is_network_server())
  rpc_id(get_tree().get_rpc_sender_id(), "_pong", OS.get_system_time_msecs(), time)


sync func _pong(_server_time, time):
  assert(!get_tree().is_network_server())
  var current_time = OS.get_system_time_msecs()
  var latency = (current_time - time) / 2
  client_times_latency.append(latency)
  if client_time_latency == -1:
    client_time_latency = latency
  if client_times_latency.size() == LATENCY_SIZE:
    client_times_latency.sort()
    var total_latency = 0
    var mid_delta = client_times_latency[(LATENCY_SIZE - 1) / 2.0]
    for index in range(1 + (LATENCY_SIZE - 1) / 2.0, LATENCY_SIZE):
      var temp_latency = client_times_latency[index]
      if temp_latency > 2 * mid_delta and temp_latency > 20:
        client_times_latency.remove(index)
      else:
        total_latency += temp_latency
    client_time_latency = total_latency / client_times_latency.size()
    client_times_latency.clear()

func current_time():
  var current_time = OS.get_system_time_msecs()
  if !get_tree().is_network_server():
    current_time += client_time_latency
  return current_time


func level_complete(time, score):
  rpc("_level_complete", time, score)


func next_level(level):
  assert(get_tree().is_network_server())
  rpc("_next_level", level)


remote func _next_level(level):
  assert(!get_tree().is_network_server())
  emit_signal("client_next_level", level)


remotesync func _level_complete(time, score):
  var player_data = players_data[get_tree().get_rpc_sender_id()]
  player_data.level_complete = true
  player_data.time = time
  player_data.score = score
  emit_signal("level_complete", get_tree().get_rpc_sender_id(), time, score)
  if get_tree().is_network_server():
    var all_complete = true
    for data in players_data:
      all_complete &= data.level_complete
    if all_complete:
      emit_signal("all_level_complete")


func add_object(network_id, type, state):
  assert(!get_tree().is_network_server())
  rpc("_add_object", network_id, type, state)


func remove_object(network_id):
  assert(!get_tree().is_network_server())
  rpc_id(1, "_remove_object", network_id)


func remove_objects(network_ids):
  assert(get_tree().is_network_server())
  rpc("_remove_objects", network_ids)


func add_object_for_client(client_id, network_id, type, state):
  assert(!get_tree().is_network_server())
  rpc_id(client_id, "_add_object", network_id, type, state)


remotesync func _add_object(network_id, type, state):
  assert(get_tree().get_rpc_sender_id() == get_player_id(network_id))
  emit_signal("object_added", get_tree().get_rpc_sender_id(), network_id, type, state)


remotesync func _remove_object(network_id):
  assert(get_tree().is_network_server())
  emit_signal("server_object_removed", network_id)


remote func _remove_objects(network_ids):
  assert(!get_tree().is_network_server())
  emit_signal("client_objects_removed", network_ids)


func _on_player_connected(connected_player_id: int):
  assert(get_tree().is_network_server())
  print("Player ", connected_player_id, " connected")
  rpc_id(connected_player_id, '_request_player_info')


func _on_connected_to_server(connected_player_id: int):
  if connected_player_id == 1:
    print("Connection successed with id ", get_tree().get_network_unique_id())
  else:
    print("Player ", connected_player_id, " connected")

func _on_connection_failed():
  print("Connection failed ", DEFAULT_IP, ":", DEFAULT_PORT)


func _on_server_disconnected():
  print("Server disconnected")
  disconnect_network()
  # TODO get_tree().change_scene("res://common/TitleServerDisconnect.tscn")


func _on_player_disconnected(id: int):
  assert(get_tree().is_network_server())
  print("Player ", id, " disconnected")
  players_data.erase(id)
  rpc("_remove_player", id)


func disconnect_network():
  var network_peer := get_tree().network_peer
  if network_peer == null:
    return
  if get_tree().is_network_server():
    for player_id in players_data.keys():
      rpc_id(player_id, "_remove_player", player_id)
      network_peer.disconnect_peer(players_data[player_id])
  else:
    network_peer.close_connection()
  get_tree().set_network_peer(null)
  players_data.clear()


func set_object_state(network_id, object_state):
  assert(!get_tree().is_network_server())
  rpc_id(1, '_object_state', network_id, object_state)


func set_object_state_unreliable(network_id, object_state):
  assert(!get_tree().is_network_server())
  rpc_unreliable_id(1, '_object_state', network_id, object_state)


func update_world_state(world_state):
  assert(get_tree().is_network_server())
  rpc_unreliable('_update_world_state', world_state)


remote func _update_world_state(remote_world_state):
  assert(!get_tree().is_network_server())
  emit_signal("client_world_state_updated", remote_world_state)


remote func _object_state(network_id, object_state):
  assert(get_tree().is_network_server())
  emit_signal("server_object_state", network_id, object_state)


remote func _request_player_info():
  assert(!get_tree().is_network_server())
  assert(get_tree().get_rpc_sender_id() == 1)
  rpc_id(1, '_player_info', player_info)


remote func _player_info(remote_player_info):
  assert(get_tree().is_network_server())
  var player_id = get_tree().get_rpc_sender_id()
  players_data[player_id] = remote_player_info
  rpc("_add_player", players_data, player_id)


remote func _add_player(remote_players_data, player_id):
  assert(!get_tree().is_network_server())
  players_data = remote_players_data
  emit_signal("client_player_connected", players_data, player_id)


remotesync func _remove_player(player_id):
  emit_signal("player_disconnected", player_id)


func is_remote(node) -> bool:
  return get_tree().has_network_peer() and !node.is_network_master()


static func get_network_id(player_id, object_id):
  assert(object_id < MAX_OBJECT_BY_PLAYER)
  return MAX_OBJECT_BY_PLAYER * player_id + object_id


static func get_player_id(network_id):
  return (network_id - (network_id % MAX_OBJECT_BY_PLAYER)) / MAX_OBJECT_BY_PLAYER


static func get_object_id(network_id):
  return network_id % MAX_OBJECT_BY_PLAYER
