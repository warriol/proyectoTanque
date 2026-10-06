class_name Bullet
extends Area2D

@export var speed: float = 600.0
@export var push_force: float = 300.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("apply_knockback"):
			body.apply_knockback(direction * push_force)
		var current_scene := get_tree().current_scene
		if current_scene.has_method("register_enemy_defeated"):
			current_scene.register_enemy_defeated()
		queue_free()