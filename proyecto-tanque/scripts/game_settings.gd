extends Node

const DEFAULT_SPAWN_INTERVAL: float = 1.0
const DEFAULT_ENEMY_SPEED: float = 100.0
const DEFAULT_DETECTION_RADIUS: float = 280.0
const DEFAULT_SFX_VOLUME: float = 0.8
const DEFAULT_MUSIC_VOLUME: float = 0.6
const MIN_SPAWN_INTERVAL: float = 0.5
const MAX_SPAWN_INTERVAL: float = 1.5
const MIN_ENEMY_SPEED: float = 50.0
const MAX_ENEMY_SPEED: float = 150.0
const MIN_DETECTION_RADIUS: float = 150.0
const MAX_DETECTION_RADIUS: float = 410.0
const DEFAULT_MOVE_SPEED: float = 35.0
const DEFAULT_TURRET_ROTATION_SPEED: float = 5.0
const DEFAULT_AIM_TOLERANCE_DEGREES: float = 12.0
const DEFAULT_FIRE_RATE: float = 0.5
const DEFAULT_MAX_IMPACTS: int = 2
const DEFAULT_SPAWN_INTERVAL_DECREASE: float = 0.08
const DEFAULT_SPAWN_INTERVAL_TIME_DECREASE: float = 0.05
const DEFAULT_MINIMUM_SPAWN_INTERVAL: float = 0.5
const DEFAULT_ENEMY_SPEED_INTERVAL: float = 180.0
const DEFAULT_ENEMY_SPEED_INCREASE: float = 0.15
const DEFAULT_MAX_ENEMIES: int = 8
const DEFAULT_ENEMIES_PER_DIFFICULTY: int = 8
const DEFAULT_ENEMY_CAPACITY_INCREASE: int = 1
const DEFAULT_ENEMY_CAPACITY_TIME_INCREASE: int = 2
const MAX_UPGRADE_LEVEL: int = 15
const ENEMY_REWARD: int = 10
const SHOP_BASE_PRICES: Dictionary = {
	"repair_chassis_front": 10,
	"repair_chassis_rear": 10,
	"repair_chassis_left": 10,
	"repair_chassis_right": 10,
	"repair_turret": 15,
	"upgrade_armor": 25,
	"upgrade_fire_rate": 25,
	"upgrade_turret_rotation": 25,
}

var spawn_interval: float = DEFAULT_SPAWN_INTERVAL
var enemy_speed: float = DEFAULT_ENEMY_SPEED
var detection_radius: float = DEFAULT_DETECTION_RADIUS
var sfx_volume: float = DEFAULT_SFX_VOLUME
var music_volume: float = DEFAULT_MUSIC_VOLUME

func reset_defaults() -> void:
	spawn_interval = DEFAULT_SPAWN_INTERVAL
	enemy_speed = DEFAULT_ENEMY_SPEED
	detection_radius = DEFAULT_DETECTION_RADIUS
	sfx_volume = DEFAULT_SFX_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME

func get_difficulty_name() -> String:
	var is_default := is_equal_approx(spawn_interval, DEFAULT_SPAWN_INTERVAL) and is_equal_approx(enemy_speed, DEFAULT_ENEMY_SPEED) and is_equal_approx(detection_radius, DEFAULT_DETECTION_RADIUS)
	var is_minimum := is_equal_approx(spawn_interval, MIN_SPAWN_INTERVAL) and is_equal_approx(enemy_speed, MIN_ENEMY_SPEED) and is_equal_approx(detection_radius, MIN_DETECTION_RADIUS)
	var is_maximum := is_equal_approx(spawn_interval, MAX_SPAWN_INTERVAL) and is_equal_approx(enemy_speed, MAX_ENEMY_SPEED) and is_equal_approx(detection_radius, MAX_DETECTION_RADIUS)
	if is_default:
		return "NORMAL"
	if is_minimum:
		return "DIFICIL"
	if is_maximum:
		return "FACIL"
	return "CUSTOM"
