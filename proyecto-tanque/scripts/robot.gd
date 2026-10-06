class_name Robot
extends CharacterBody2D

@export var explosion_sound: AudioStream = preload("res://audio/sfx/robot_explosion.wav")
@export var speed: float = 100.0
var target: Node2D = null
var base_speed: float
var difficulty_level: int = 0

const DIFFICULTY_COLORS := [
	Color("ffffff"),
	Color("ffd166"),
	Color("ef8354"),
	Color("d1495b"),
	Color("8f2d56"),
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
	difficulty_level = level
	if base_speed == 0.0:
		base_speed = speed
	speed = base_speed * pow(1.0 + speed_increase, difficulty_level)
	modulate = DIFFICULTY_COLORS[mini(difficulty_level, DIFFICULTY_COLORS.size() - 1)]