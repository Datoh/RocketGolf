extends Object
class_name PlayerStats

var longuest_shot: float = 0.0
var longuest_air_shot: float = 0.0
var longuest_shot_serie: int = 0
var rocket_count: int = 0
var hit_count: int = 0
var air_shot_count: int = 0
var score: int = 0
var time: int = 0


static func merge(player_stats) -> PlayerStats:
  if player_stats.empty():
    return null

  var total_stats = load("res://scripts/PlayerStats.gd").new()
  for stats in player_stats:
    total_stats.longuest_shot = max(total_stats.longuest_shot, stats.longuest_shot)
    total_stats.longuest_air_shot = max(total_stats.longuest_air_shot, stats.longuest_air_shot)
    total_stats.longuest_shot_serie = max(total_stats.longuest_shot_serie, stats.longuest_shot_serie)
    total_stats.rocket_count += stats.rocket_count
    total_stats.hit_count += stats.hit_count
    total_stats.air_shot_count += stats.air_shot_count
    total_stats.score += stats.score
    total_stats.time += stats.time
  return total_stats
