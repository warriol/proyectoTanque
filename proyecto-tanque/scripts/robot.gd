class_name Robot
extends CharacterBody2D

@export var explosion_sound: AudioStream = preload("res://audio/sfx/robot_explosion.wav")
@export var speed: float = 100.0
var target: Node2D = null
var base_speed: float
var difficulty_level: int = 0
@onready var body_sprite: Sprite2D = $Body

const DIFFICULTY_TEXTURES: Array[Texture2D] = [
	preload("res://art/enemies/robot_magnet_1.png"),
	preload("res://art/enemies/robot_magnet_2.png"),
	preload("res://art/enemies/robot_magnet_3.png"),
	preload("res://art/enemies/robot_magnet_4.png"),
	preload("res://art/enemies/robot_magnet_5.png"),
]

func _ready() -> void:
	add_to_group("enemies")
	base_speed = speed

func _physics_process(delta: float) -> void:
	if target:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func apply_knockback(_impact_vector: Vector2) -> void:
	AudioManager.play_sound(explosion_sound)
	queue_free()

func set_difficulty_level(level: int, speed_increase: float) -> void:
	difficulty_level = clampi(level, 0, DIFFICULTY_TEXTURES.size() - 1)
	if base_speed == 0.0:
		base_speed = speed
	speed = base_speed * pow(1.0 + speed_increase, difficulty_level)
	body_sprite.texture = DIFFICULTY_TEXTURES[difficulty_level]