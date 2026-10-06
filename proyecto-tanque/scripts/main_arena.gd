extends Node2D

@onready var tank: Node2D = $Tank
@onready var spawner: Node2D = $Spawner
@onready var hud: CanvasLayer = $HUD

@export var game_over_sound: AudioStream = preload("res://audio/sfx/game_over.wav")
@export var upgrade_purchase_sound: AudioStream = preload("res://audio/sfx/compra_tienda_mejora.wav")

var game_over: bool = false
var survival_time: float = 0.0
var credits: int = 0
var enemy_reward: int = GameSettings.ENEMY_REWARD

var shop_levels: Dictionary = {
	"repair_chassis_front": 0,
	"repair_chassis_rear": 0,
	"repair_chassis_left": 0,
	"repair_chassis_right": 0,
	"repair_turret": 0,
	"upgrade_armor": 0,
	"upgrade_fire_rate": 0,
	"upgrade_turret_rotation": 0,
}
var shop_base_prices: Dictionary = GameSettings.SHOP_BASE_PRICES

func _ready() -> void:
	tank.set_detection_radius(GameSettings.detection_radius)
	spawner.target = tank
	hud.tank = tank
	hud.arena = self
	queue_redraw()

func _process(delta: float) -> void:
	if not game_over:
		survival_time += delta

func register_enemy_defeated() -> void:
	credits += enemy_reward
	spawner.register_enemy_defeated()

func get_shop_item_state(item_id: String) -> Dictionary:
	var price := get_shop_price(item_id)
	var can_buy := credits >= price
	var is_upgrade := item_id.begins_with("upgrade_")
	var level: int = shop_levels.get(item_id, 0)
	if game_over or not is_instance_valid(tank):
		return {"price": price, "can_buy": false, "level": level, "max_level": GameSettings.MAX_UPGRADE_LEVEL}
	if is_upgrade and level >= GameSettings.MAX_UPGRADE_LEVEL:
		can_buy = false
	if item_id.begins_with("repair_"):
		var zone_id := item_id.trim_prefix("repair_")
		var current_damaged_zones: Dictionary = tank.get("damaged_zones")
		can_buy = can_buy and current_damaged_zones.has(zone_id)
	return {"price": price, "can_buy": can_buy, "level": level, "max_level": GameSettings.MAX_UPGRADE_LEVEL}

func get_shop_price(item_id: String) -> int:
	return shop_base_prices.get(item_id, 0) * (shop_levels.get(item_id, 0) + 1)

func try_purchase(item_id: String) -> bool:
	if game_over or not is_instance_valid(tank):
		return false
	var state := get_shop_item_state(item_id)
	if not state.can_buy:
		return false

	var purchased := false
	if item_id.begins_with("repair_"):
		purchased = tank.repair_zone(item_id.trim_prefix("repair_"))
	else:
		purchased = tank.call(item_id)
	if not purchased:
		return false

	credits -= state.price
	shop_levels[item_id] += 1
	if item_id.begins_with("upgrade_"):
		AudioManager.play_sound(upgrade_purchase_sound)
	return true

func trigger_game_over() -> void:
	if game_over:
		return
	game_over = true
	AudioManager.play_sound(game_over_sound)

	var game_over_layer := CanvasLayer.new()
	game_over_layer.layer = 20
	game_over_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(game_over_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.03, 0.05, 0.82)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_layer.add_child(overlay)

	var panel := VBoxContainer.new()
	panel.position = Vector2(390, 230)
	panel.size = Vector2(500, 360)
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 14)
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_layer.add_child(panel)

	var game_over_label := Label.new()
	game_over_label.text = Localization.text("game_over")
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 52)
	game_over_label.add_theme_color_override("font_color", Color("f05a47"))
	panel.add_child(game_over_label)

	var score := _calculate_score()
	var score_label := Label.new()
	score_label.text = "%s: %d" % [Localization.text("score"), score]
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 24)
	panel.add_child(score_label)

	var breakdown_label := Label.new()
	breakdown_label.text = "%s: %d  |  %s: %d  |  %s: %d" % [Localization.text("score_time"), int(survival_time * 10.0), Localization.text("score_enemies"), spawner.defeated_enemies * 100, Localization.text("score_credits"), credits * 5]
	breakdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	breakdown_label.add_theme_color_override("font_color", Color("aab8ba"))
	panel.add_child(breakdown_label)

	var difficulty_label := Label.new()
	difficulty_label.text = "%s: %s" % [Localization.text("difficulty"), GameSettings.get_difficulty_name()]
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(difficulty_label)

	if RecordManager.is_record(score):
		var record_label := Label.new()
		record_label.text = Localization.text("new_record")
		record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		record_label.add_theme_color_override("font_color", Color("ffd166"))
		panel.add_child(record_label)

		var name_edit := LineEdit.new()
		name_edit.placeholder_text = Localization.text("player_name_placeholder")
		name_edit.max_length = 20
		name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_edit.process_mode = Node.PROCESS_MODE_ALWAYS
		panel.add_child(name_edit)

		var save_record_button := Button.new()
		save_record_button.text = Localization.text("save_record")
		save_record_button.process_mode = Node.PROCESS_MODE_ALWAYS
		save_record_button.pressed.connect(_save_current_record.bind(name_edit, save_record_button, score))
		panel.add_child(save_record_button)
		name_edit.grab_focus()

	var return_button := Button.new()
	return_button.text = Localization.text("return_home")
	return_button.custom_minimum_size = Vector2(0, 48)
	return_button.process_mode = Node.PROCESS_MODE_ALWAYS
	return_button.pressed.connect(_return_to_menu)
	panel.add_child(return_button)
	return_button.grab_focus()
	get_tree().paused = true

func _calculate_score() -> int:
	var time_score: int = int(survival_time * 10.0)
	var defeated_score: int = spawner.defeated_enemies * 100
	var unspent_credits_score: int = credits * 5
	return time_score + defeated_score + unspent_credits_score

func _save_current_record(name_edit: LineEdit, save_button: Button, score: int) -> void:
	var player_name := name_edit.text.strip_edges()
	if player_name.is_empty():
		player_name = "Jugador"
	var record := {
		"name": player_name,
		"score": score,
		"time": int(survival_time),
		"defeated": spawner.defeated_enemies,
		"credits": credits,
		"difficulty": GameSettings.get_difficulty_name(),
		"date": Time.get_datetime_string_from_system(false, true),
	}
	RecordManager.add_record(record)
	RecordManager.submit_to_steam(record)
	save_button.disabled = true
	save_button.text = Localization.text("record_saved")

func _return_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _draw() -> void:
	var arena_rect := Rect2(32.0, 32.0, 1216.0, 656.0)
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color("101820"), true)
	draw_rect(arena_rect, Color("1d3035"), true)
	draw_rect(arena_rect, Color("6ed3cf"), false, 4.0)

	for x in range(64, 1248, 64):
		draw_line(Vector2(x, 32.0), Vector2(x, 688.0), Color(0.16, 0.27, 0.29, 0.35), 1.0)
	for y in range(64, 688, 64):
		draw_line(Vector2(32.0, y), Vector2(1248.0, y), Color(0.16, 0.27, 0.29, 0.35), 1.0)
