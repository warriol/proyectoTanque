class_name HUD
extends CanvasLayer

var tank: Node2D = null
var arena: Node2D = null

@onready var zone_colors: Dictionary = {
	"chassis_front": $Interface/StatsPanel/Margin/VBox/DamageGrid/FrontColor,
	"chassis_rear": $Interface/StatsPanel/Margin/VBox/DamageGrid/RearColor,
	"chassis_left": $Interface/StatsPanel/Margin/VBox/DamageGrid/LeftColor,
	"chassis_right": $Interface/StatsPanel/Margin/VBox/DamageGrid/RightColor,
	"turret": $Interface/StatsPanel/Margin/VBox/DamageGrid/TurretColor,
}
@onready var zone_states: Dictionary = {
	"chassis_front": $Interface/StatsPanel/Margin/VBox/DamageGrid/FrontState,
	"chassis_rear": $Interface/StatsPanel/Margin/VBox/DamageGrid/RearState,
	"chassis_left": $Interface/StatsPanel/Margin/VBox/DamageGrid/LeftState,
	"chassis_right": $Interface/StatsPanel/Margin/VBox/DamageGrid/RightState,
	"turret": $Interface/StatsPanel/Margin/VBox/DamageGrid/TurretState,
}
@onready var attack_value: Label = $Interface/StatsPanel/Margin/VBox/AttackValue
@onready var movement_value: Label = $Interface/StatsPanel/Margin/VBox/MovementValue
@onready var time_value: Label = $Interface/RunPanel/Margin/VBox/TimeValue
@onready var enemies_value: Label = $Interface/RunPanel/Margin/VBox/EnemiesValue
@onready var defeated_value: Label = $Interface/RunPanel/Margin/VBox/DefeatedValue
@onready var difficulty_value: Label = $Interface/RunPanel/Margin/VBox/DifficultyValue
@onready var credits_value: Label = $Interface/ShopPanel/Margin/VBox/CreditsValue

var shop_buttons: Dictionary = {}
var shop_item_labels: Dictionary = {
	"repair_chassis_front": "repair_front",
	"repair_chassis_rear": "repair_rear",
	"repair_chassis_left": "repair_left",
	"repair_chassis_right": "repair_right",
	"repair_turret": "repair_turret",
	"upgrade_armor": "upgrade_armor",
	"upgrade_fire_rate": "upgrade_fire_rate",
	"upgrade_turret_rotation": "upgrade_turret_rotation",
}

const INTACT_COLOR := Color("4bd37b")
const DAMAGED_COLOR := Color("ef5b52")
const MUTED_TEXT_COLOR := Color("aab8ba")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_localized_text()
	for item_id in shop_item_labels:
		var button: Button = $Interface/ShopPanel/Margin/VBox/ShopGrid.get_node(item_id)
		shop_buttons[item_id] = button
		button.pressed.connect(_on_shop_button_pressed.bind(item_id))
	_update_display()

func _apply_localized_text() -> void:
	$Interface/StatsPanel/Margin/VBox/Title.text = Localization.text("tank_status")
	$Interface/StatsPanel/Margin/VBox/DamageTitle.text = Localization.text("damage_zones")
	$Interface/StatsPanel/Margin/VBox/DamageGrid/FrontName.text = Localization.text("front")
	$Interface/StatsPanel/Margin/VBox/DamageGrid/RearName.text = Localization.text("rear")
	$Interface/StatsPanel/Margin/VBox/DamageGrid/LeftName.text = Localization.text("left")
	$Interface/StatsPanel/Margin/VBox/DamageGrid/RightName.text = Localization.text("right")
	$Interface/StatsPanel/Margin/VBox/DamageGrid/TurretName.text = Localization.text("turret")
	$Interface/RunPanel/Margin/VBox/Title.text = Localization.text("run")
	$Interface/ShopPanel/Margin/VBox/Title.text = Localization.text("shop")

func _process(_delta: float) -> void:
	_update_display()

func _update_display() -> void:
	if not is_instance_valid(tank):
		for button in shop_buttons.values():
			button.disabled = true
		return
	if is_instance_valid(arena):
		credits_value.text = Localization.text("credits") % arena.get("credits")
		for item_id in shop_buttons:
			var state: Dictionary = arena.call("get_shop_item_state", item_id)
			var item_label: String = Localization.text(shop_item_labels[item_id])
			if item_id.begins_with("upgrade_"):
				var level: int = state.level
				var max_level: int = state.max_level
				var level_text := "MAX" if level >= max_level else "N. %d/%d" % [level, max_level]
				shop_buttons[item_id].text = "%s [%s] $%d" % [item_label, level_text, state.price]
			else:
				shop_buttons[item_id].text = "%s $%d" % [item_label, state.price]
			shop_buttons[item_id].disabled = not state.can_buy

	var damaged_zones: Dictionary = tank.get("damaged_zones")
	for zone_id in zone_colors:
		var damaged: bool = damaged_zones.get(zone_id, false)
		zone_colors[zone_id].color = DAMAGED_COLOR if damaged else INTACT_COLOR
		zone_states[zone_id].text = Localization.text("damaged") if damaged else Localization.text("ok")
		zone_states[zone_id].modulate = DAMAGED_COLOR if damaged else MUTED_TEXT_COLOR

	var shoot_timer: Timer = tank.get("shoot_timer")
	var attack_interval: float = shoot_timer.wait_time if shoot_timer else 0.0
	var attacks_per_second: float = 1.0 / attack_interval if attack_interval > 0.0 else 0.0
	attack_value.text = Localization.text("cadence") % [attack_interval, attacks_per_second]

	var base_speed: float = tank.get("move_speed")
	var current_speed: float = base_speed * (0.5 if tank.get("is_chasis_damaged") else 1.0)
	movement_value.text = Localization.text("movement") % current_speed

	if is_instance_valid(arena):
		var spawner: Node2D = arena.get("spawner")
		var elapsed: float = arena.get("survival_time")
		var minutes := int(elapsed) / 60
		var seconds := int(elapsed) % 60
		time_value.text = Localization.text("time") % [minutes, seconds]
		var active_enemies := get_tree().get_nodes_in_group("enemies").size()
		enemies_value.text = Localization.text("enemies") % [active_enemies, spawner.get("max_enemies")]
		defeated_value.text = Localization.text("defeated") % spawner.get("defeated_enemies")
		var difficulty_step: int = int(spawner.get("defeated_enemies") / spawner.get("enemies_per_difficulty"))
		var speed_step: int = spawner.get("enemy_speed_level")
		difficulty_value.text = Localization.text("difficulty_levels") % [difficulty_step + 1, speed_step + 1]

func _on_shop_button_pressed(item_id: String) -> void:
	if is_instance_valid(arena):
		arena.call("try_purchase", item_id)
