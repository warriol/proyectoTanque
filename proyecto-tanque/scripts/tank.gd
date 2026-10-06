class_name Tank
extends CharacterBody2D

# --- ESTADÍSTICAS DEL TANQUE ---
var move_speed: float
var turret_rotation_speed: float
var aim_tolerance_degrees: float
var fire_rate: float
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var armor_level: int = 0
var fire_rate_level: int = 0
var turret_rotation_level: int = 0
var max_impacts: int

# --- BANDERAS DE DAÑO (Para conectar con la tienda/daño localizado) ---
var is_chasis_damaged: bool = false
var is_turret_damaged: bool = false

# --- REFERENCIAS A NODOS ---
@onready var turret: Node2D = $Turret
@onready var muzzle: Node2D = $Turret/Muzzle
@onready var shoot_timer: Timer = $ShootTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var damage_zones: Node2D = $DamageZones
@onready var turret_zone: Area2D = $Turret/TurretZone
@onready var engine_sound: AudioStreamPlayer2D = $EngineSound

@export var bullet_sound: AudioStream = preload("res://audio/sfx/bullet_shoot.wav")

var target_enemy: Node2D = null
var impact_count: int = 0
var damaged_zones: Dictionary = {}
var handled_robot_ids: Dictionary = {}

func set_detection_radius(radius: float) -> void:
	var detection_shape := $DetectionArea/CollisionShape2D.shape as CircleShape2D
	if detection_shape:
		detection_shape.radius = radius

func _ready() -> void:
	move_speed = GameSettings.DEFAULT_MOVE_SPEED
	turret_rotation_speed = GameSettings.DEFAULT_TURRET_ROTATION_SPEED
	aim_tolerance_degrees = GameSettings.DEFAULT_AIM_TOLERANCE_DEGREES
	fire_rate = GameSettings.DEFAULT_FIRE_RATE
	max_impacts = GameSettings.DEFAULT_MAX_IMPACTS
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

	for zone in damage_zones.get_children():
		if zone is Area2D:
			zone.body_entered.connect(_on_damage_zone_body_entered.bind(zone))
	turret_zone.body_entered.connect(_on_damage_zone_body_entered.bind(turret_zone))

func _physics_process(delta: float) -> void:
	_update_target()
	_aim_turret(delta)
	_move_autonomously()

	if velocity.length_squared() > 0.0:
		if not engine_sound.playing:
			engine_sound.play()
	else:
		if engine_sound.playing:
			engine_sound.stop()

func _on_engine_sound_finished() -> void:
	if velocity.length_squared() > 0.0:
		engine_sound.play()

# --- LOGICA DE SONIDO ---
func _fire_bullet() -> void:
	var bullet_instance = bullet_scene.instantiate() as Bullet
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.direction = Vector2.RIGHT.rotated(turret.global_rotation)
	get_tree().current_scene.add_child(bullet_instance)

	AudioManager.play_sound(bullet_sound)

# --- LÓGICA DE MOVIMIENTO AUTÓNOMO ---
func _move_autonomously() -> void:
	var current_speed = move_speed * (0.5 if is_chasis_damaged else 1.0)
	if not is_instance_valid(target_enemy):
		velocity = Vector2.ZERO
		return
	if not _is_turret_aimed():
		velocity = Vector2.ZERO
		return

	var local_direction = global_position.direction_to(target_enemy.global_position).rotated(-global_rotation)
	if damaged_zones.get("chassis_front", false) and local_direction.x > 0.0:
		local_direction.x = 0.0
	if damaged_zones.get("chassis_rear", false) and local_direction.x < 0.0:
		local_direction.x = 0.0
	if damaged_zones.get("chassis_left", false) and local_direction.y < 0.0:
		local_direction.y = 0.0
	if damaged_zones.get("chassis_right", false) and local_direction.y > 0.0:
		local_direction.y = 0.0

	if local_direction.length_squared() == 0.0:
		velocity = Vector2.ZERO
		return

	velocity = local_direction.rotated(global_rotation).normalized() * current_speed
	move_and_slide()

func _is_turret_aimed() -> bool:
	var target_angle := turret.global_position.direction_to(target_enemy.global_position).angle()
	var angle_error := absf(angle_difference(turret.global_rotation, target_angle))
	return angle_error <= deg_to_rad(aim_tolerance_degrees)

# --- LÓGICA DE DETECCIÓN Y APUNTADO ---
func _update_target() -> void:
	var bodies = detection_area.get_overlapping_bodies()
	var closest_enemy: Node2D = null
	var min_distance: float = INF
	
	for body in bodies:
		if is_instance_valid(body) and body.is_in_group("enemies"):
			var dist = global_position.distance_to(body.global_position)
			if dist < min_distance:
				min_distance = dist
				closest_enemy = body
	
	target_enemy = closest_enemy

func _aim_turret(delta: float) -> void:
	if target_enemy:
		var target_dir = (target_enemy.global_position - turret.global_position).angle() - global_rotation
		var current_rot_speed = turret_rotation_speed * (0.4 if is_turret_damaged else 1.0)
		
		# Rotación suave hacia la posición del enemigo
		turret.rotation = lerp_angle(turret.rotation, target_dir, current_rot_speed * delta)

# --- LÓGICA DE DISPARO ---
func _on_shoot_timer_timeout() -> void:
	if is_instance_valid(target_enemy) and bullet_scene:
		_fire_bullet()

func _on_damage_zone_body_entered(body: Node2D, zone: Area2D) -> void:
	if not body.is_in_group("enemies"):
		return

	var robot_id := body.get_instance_id()
	if handled_robot_ids.has(robot_id):
		return
	handled_robot_ids[robot_id] = true
	body.queue_free()

	var zone_id: String = zone.get_meta("damage_zone", "")
	if impact_count >= max_impacts or damaged_zones.has(zone_id):
		_trigger_game_over()
		return

	impact_count += 1
	damaged_zones[zone_id] = true
	if zone_id == "turret":
		is_turret_damaged = true
		shoot_timer.wait_time = fire_rate * 2.0
	else:
		is_chasis_damaged = true

	if damaged_zones.size() == 5:
		_trigger_game_over()

func repair_zone(zone_id: String) -> bool:
	if not damaged_zones.has(zone_id):
		return false

	damaged_zones.erase(zone_id)
	impact_count = maxi(impact_count - 1, 0)
	if zone_id == "turret":
		is_turret_damaged = false
	else:
		is_chasis_damaged = false
		for damaged_zone in damaged_zones:
			if damaged_zone.begins_with("chassis_"):
				is_chasis_damaged = true
				break
	_refresh_shoot_timer()
	return true

func upgrade_armor() -> bool:
	if armor_level >= GameSettings.MAX_UPGRADE_LEVEL:
		return false
	armor_level += 1
	max_impacts += 1
	return true

func upgrade_fire_rate() -> bool:
	if fire_rate_level >= GameSettings.MAX_UPGRADE_LEVEL:
		return false
	fire_rate_level += 1
	fire_rate = maxf(fire_rate * 0.85, 0.1)
	_refresh_shoot_timer()
	return true

func upgrade_turret_rotation() -> bool:
	if turret_rotation_level >= GameSettings.MAX_UPGRADE_LEVEL:
		return false
	turret_rotation_level += 1
	turret_rotation_speed *= 1.2
	return true

func _refresh_shoot_timer() -> void:
	shoot_timer.wait_time = fire_rate * (2.0 if is_turret_damaged else 1.0)

func _trigger_game_over() -> void:
	var current_scene := get_tree().current_scene
	if current_scene.has_method("trigger_game_over"):
		current_scene.trigger_game_over()
	queue_free()

