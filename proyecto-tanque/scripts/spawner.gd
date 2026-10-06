class_name EnemySpawner
extends Node2D

@export var robot_scene: PackedScene = preload("res://scenes/robot.tscn")
var spawn_interval: float
var spawn_interval_decrease: float
var spawn_interval_time_decrease: float
var minimum_spawn_interval: float
var enemy_speed_interval: float
var enemy_speed_increase: float
var enemy_base_speed: float
var max_enemies: int
var enemies_per_difficulty: int
var enemy_capacity_increase: int
var enemy_capacity_time_increase: int
@export var arena_rect: Rect2 = Rect2(32.0, 32.0, 1216.0, 656.0)

var target: Node2D = null
var spawn_timer: Timer
var random := RandomNumberGenerator.new()
var defeated_enemies: int = 0
var initial_max_enemies: int
var initial_spawn_interval: float
var elapsed_time: float = 0.0
var enemy_speed_level: int = 0
var time_spawn_level: int = 0

func _ready() -> void:
	random.randomize()
	spawn_interval = GameSettings.spawn_interval
	spawn_interval_decrease = GameSettings.DEFAULT_SPAWN_INTERVAL_DECREASE
	spawn_interval_time_decrease = GameSettings.DEFAULT_SPAWN_INTERVAL_TIME_DECREASE
	minimum_spawn_interval = GameSettings.DEFAULT_MINIMUM_SPAWN_INTERVAL
	enemy_speed_interval = GameSettings.DEFAULT_ENEMY_SPEED_INTERVAL
	enemy_speed_increase = GameSettings.DEFAULT_ENEMY_SPEED_INCREASE
	enemy_base_speed = GameSettings.enemy_speed
	max_enemies = GameSettings.DEFAULT_MAX_ENEMIES
	enemies_per_difficulty = GameSettings.DEFAULT_ENEMIES_PER_DIFFICULTY
	enemy_capacity_increase = GameSettings.DEFAULT_ENEMY_CAPACITY_INCREASE
	enemy_capacity_time_increase = GameSettings.DEFAULT_ENEMY_CAPACITY_TIME_INCREASE
	initial_max_enemies = max_enemies
	initial_spawn_interval = spawn_interval
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _process(delta: float) -> void:
	elapsed_time += delta
	var new_speed_level := int(elapsed_time / enemy_speed_interval)
	if new_speed_level > enemy_speed_level:
		enemy_speed_level = new_speed_level
		_apply_enemy_speed_level()
	if new_speed_level > time_spawn_level:
		time_spawn_level = new_speed_level
		_update_spawn_difficulty()

func _on_spawn_timer_timeout() -> void:
	if not robot_scene or not target:
		return
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return

	var robot := robot_scene.instantiate() as Robot
	robot.target = target
	robot.speed = enemy_base_speed
	robot.set_difficulty_level(enemy_speed_level, enemy_speed_increase)
	robot.global_position = _get_spawn_position()
	get_parent().add_child(robot)

func register_enemy_defeated() -> void:
	defeated_enemies += 1
	_update_spawn_difficulty()

func _update_spawn_difficulty() -> void:
	var defeat_level := int(defeated_enemies / enemies_per_difficulty)
	max_enemies = initial_max_enemies + defeat_level * enemy_capacity_increase + time_spawn_level * enemy_capacity_time_increase
	var defeat_interval_reduction := defeat_level * spawn_interval_decrease
	var time_interval_reduction := time_spawn_level * spawn_interval_time_decrease
	spawn_timer.wait_time = maxf(initial_spawn_interval - defeat_interval_reduction - time_interval_reduction, minimum_spawn_interval)

func _apply_enemy_speed_level() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_difficulty_level"):
			enemy.set_difficulty_level(enemy_speed_level, enemy_speed_increase)

func _get_spawn_position() -> Vector2:
	var side := random.randi_range(0, 3)
	match side:
		0:
			return Vector2(random.randf_range(arena_rect.position.x, arena_rect.end.x), arena_rect.position.y)
		1:
			return Vector2(arena_rect.end.x, random.randf_range(arena_rect.position.y, arena_rect.end.y))
		2:
			return Vector2(random.randf_range(arena_rect.position.x, arena_rect.end.x), arena_rect.end.y)
		_:
			return Vector2(arena_rect.position.x, random.randf_range(arena_rect.position.y, arena_rect.end.y))
