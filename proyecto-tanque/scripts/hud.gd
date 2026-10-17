class_name HUD
extends CanvasLayer

var tank: Node2D = null
var arena: Node2D = null

@onready var zone_colors: Dictionary = {
	"chassis_front": $Interface/StatsPanel/Margin/VBox/TankDiagram/FrontColor,
	"chassis_rear": $Interface/StatsPanel/Margin/VBox/TankDiagram/RearColor,
	"chassis_left": $Interface/StatsPanel/Margin/VBox/TankDiagram/LeftColor,
	"chassis_right": $Interface/StatsPanel/Margin/VBox/TankDiagram/RightColor,
	"turret": $Interface/StatsPanel/Margin/VBox/TankDiagram/TurretColor,
}
@onready var attack_value: Label = $Interface/StatsPanel/Margin/VBox/AttackValue
@onready var movement_value: Label = $Interface/StatsPanel/Margin/VBox/MovementValue
@onready var time_value: Label = $Interface/RunPanel/Margin/VBox/TimeValue
@onready var enemies_value: Label = $Interface/RunPanel/Margin/VBox/EnemiesValue
@onready var defeated_value: Label = $Interface/RunPanel/Margin/VBox/DefeatedValue
@onready var difficulty_value: Label = $Interface/RunPanel/Margin/VBox/DifficultyValue
@onready var credits_value: Label = $Interface/ShopPanel/Margin/VBox/CreditsValue
@onready var shop_panel: PanelContainer = $Interface/ShopPanel
@onready var shop_opaque: ColorRect = $Interface/ShopOpaque
@onready var shop_grid: GridContainer = $Interface/ShopPanel/Margin/VBox/ShopGrid
@onready var shop_store_icon: TextureRect = $Interface/ShopPanel/Margin/VBox/ShopHeader/StoreIcon
@onready var shop_toggle_button: Button = $Interface/ShopPanel/Margin/VBox/ShopHeader/ShopToggleButton

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
var shop_key_labels: Dictionary = {
	"repair_chassis_front": "1",
	"repair_chassis_rear": "2",
	"repair_chassis_left": "3",
	"repair_chassis_right": "4",
	"repair_turret": "Q",
	"upgrade_armor": "W",
	"upgrade_fire_rate": "E",
	"upgrade_turret_rotation": "R",
}

const INTACT_COLOR := Color("4bd37b")
const DAMAGED_COLOR := Color("ef5b52")
const MUTED_TEXT_COLOR := Color("aab8ba")
const PIXEL_FONT: Font = preload("res://art/ui/pixel_font.ttf")
const WINDOW_FRAME: Texture2D = preload("res://art/ui/windows_frame.png")
const BUTTON_NORMAL: Texture2D = preload("res://art/ui/button_normal.png")
const BUTTON_HOVER: Texture2D = preload("res://art/ui/button_hover.png")
const BUTTON_PRESSED: Texture2D = preload("res://art/ui/button_pressed.png")
const BUTTON_DISABLED: Texture2D = preload("res://art/ui/button_disabled.png")
const KEY_BADGE_NORMAL: Texture2D = preload("res://art/ui/key_badge_normal.png")
const KEY_BADGE_DISABLED: Texture2D = preload("res://art/ui/key_badge_disabled.png")
const REPAIR_ICON: Texture2D = preload("res://art/ui/repair_icon.png")
const ARMOR_ICON: Texture2D = preload("res://art/ui/armor_icon.png")
const FIRE_ICON: Texture2D = preload("res://art/ui/fire_icon.png")
const TURRET_ICON: Texture2D = preload("res://art/ui/config_icon.png")
const SHOP_ICON_SIZE := 14
const SHOP_MIN_ICON_SIZE := 16
const SHOP_MAX_BUTTON_SIZE := Vector2(205, 32)
const SHOP_MIN_BUTTON_SIZE := Vector2(52, 40)
# Rect2(X, Y, Ancho, Alto)
const SHOP_MAX_RECT := Rect2(801, 435, 452, 270)
const SHOP_MIN_RECT := Rect2(990, 535, 271, 150)
const KEY_LABEL_COLOR := Color("24313a")
const SHOP_MIN_KEY_SIZE := Vector2(24, 24)

var key_badges: Dictionary = {}
var shop_minimized := false
var shop_item_icons: Dictionary = {
	"repair_chassis_front": REPAIR_ICON,
	"repair_chassis_rear": REPAIR_ICON,
	"repair_chassis_left": REPAIR_ICON,
	"repair_chassis_right": REPAIR_ICON,
	"repair_turret": REPAIR_ICON,
	"upgrade_armor": ARMOR_ICON,
	"upgrade_fire_rate": FIRE_ICON,
	"upgrade_turret_rotation": TURRET_ICON,
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_localized_text()
	for item_id in shop_item_labels:
		var button: Button = $Interface/ShopPanel/Margin/VBox/ShopGrid.get_node(item_id)
		shop_buttons[item_id] = button
		button.pressed.connect(_on_shop_button_pressed.bind(item_id))
	_configure_visual_theme()
	_update_display()

func _configure_visual_theme() -> void:
	for control in $Interface.find_children("*", "Control", true, false):
		control.add_theme_font_override("font", PIXEL_FONT)
	var panel_style := _create_panel_style()
	$Interface/StatsPanel.add_theme_stylebox_override("panel", panel_style)
	$Interface/RunPanel.add_theme_stylebox_override("panel", _create_panel_style())
	$Interface/ShopPanel.add_theme_stylebox_override("panel", _create_panel_style())

	for button in shop_buttons.values():
		button.add_theme_stylebox_override("normal", _create_button_style(BUTTON_NORMAL))
		button.add_theme_stylebox_override("hover", _create_button_style(BUTTON_HOVER))
		button.add_theme_stylebox_override("pressed", _create_button_style(BUTTON_PRESSED))
		button.add_theme_stylebox_override("disabled", _create_button_style(BUTTON_DISABLED))
		button.icon = shop_item_icons[shop_buttons.find_key(button)]
		button.add_theme_constant_override("icon_max_width", SHOP_ICON_SIZE)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var item_id: String = shop_buttons.find_key(button)
		var badge := TextureRect.new()
		badge.position = Vector2(4, 5)
		badge.size = Vector2(22, 22)
		badge.texture = KEY_BADGE_NORMAL
		badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(badge)
		var key_label := Label.new()
		key_label.position = Vector2(4, 5)
		key_label.size = Vector2(22, 22)
		key_label.text = shop_key_labels[item_id]
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key_label.add_theme_color_override("font_color", KEY_LABEL_COLOR)
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(key_label)
		key_badges[item_id] = {"badge": badge, "label": key_label}
	shop_toggle_button.pressed.connect(_toggle_shop)
	shop_toggle_button.add_theme_stylebox_override("normal", _create_button_style(BUTTON_NORMAL))
	shop_toggle_button.add_theme_stylebox_override("hover", _create_button_style(BUTTON_HOVER))
	shop_toggle_button.add_theme_stylebox_override("pressed", _create_button_style(BUTTON_PRESSED))
	shop_toggle_button.add_theme_stylebox_override("disabled", _create_button_style(BUTTON_DISABLED))
	_set_shop_mode(false)

func _create_panel_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = WINDOW_FRAME
	style.texture_margin_left = 8.0
	style.texture_margin_top = 8.0
	style.texture_margin_right = 8.0
	style.texture_margin_bottom = 8.0
	return style

func _create_button_style(texture: Texture2D) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 6.0
	style.texture_margin_top = 6.0
	style.texture_margin_right = 6.0
	style.texture_margin_bottom = 6.0
	return style

func _apply_localized_text() -> void:
	$Interface/StatsPanel/Margin/VBox/TitleBar/Title.text = Localization.text("tank_status")
	$Interface/RunPanel/Margin/VBox/TitleBar/Title.text = Localization.text("run")
	$Interface/ShopPanel/Margin/VBox/Title.text = Localization.text("shop")
	shop_toggle_button.text = Localization.text("shop_minimize")

func _process(_delta: float) -> void:
	_update_display()
	_sync_shop_opaque()

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
				if not shop_minimized:
					shop_buttons[item_id].text = "    %s [%s] $%d" % [item_label, level_text, state.price]
			else:
				if not shop_minimized:
					shop_buttons[item_id].text = "    %s $%d" % [item_label, state.price]
			shop_buttons[item_id].disabled = not state.can_buy
			key_badges[item_id].badge.texture = KEY_BADGE_DISABLED if shop_buttons[item_id].disabled else KEY_BADGE_NORMAL
			if shop_minimized:
				key_badges[item_id].label.modulate = Color(0.55, 0.62, 0.64, 1) if shop_buttons[item_id].disabled else Color.WHITE

	var damaged_zones: Dictionary = tank.get("damaged_zones")
	for zone_id in zone_colors:
		var damaged: bool = damaged_zones.get(zone_id, false)
		zone_colors[zone_id].color = DAMAGED_COLOR if damaged else INTACT_COLOR

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

func _toggle_shop() -> void:
	_set_shop_mode(not shop_minimized)

func _set_shop_mode(minimized: bool) -> void:
	shop_minimized = minimized
	var panel_rect := SHOP_MIN_RECT if minimized else SHOP_MAX_RECT

	# Panel de la tienda
	shop_panel.custom_minimum_size = panel_rect.size
	shop_panel.offset_left = panel_rect.position.x
	shop_panel.offset_top = panel_rect.position.y
	shop_panel.offset_right = panel_rect.position.x + panel_rect.size.x
	shop_panel.offset_bottom = panel_rect.position.y + panel_rect.size.y

	# Fondo opaco
	shop_opaque.custom_minimum_size = panel_rect.size
	shop_opaque.offset_left = panel_rect.position.x
	shop_opaque.offset_top = panel_rect.position.y
	shop_opaque.offset_right = panel_rect.position.x + panel_rect.size.x
	shop_opaque.offset_bottom = panel_rect.position.y + panel_rect.size.y

	# shop_store_icon.visible = not minimized
	credits_value.visible = not minimized
	shop_grid.columns = 4 if minimized else 2
	shop_toggle_button.text = Localization.text("shop_maximize" if minimized else "shop_minimize")
	for item_id in shop_buttons:
		var button: Button = shop_buttons[item_id]
		button.custom_minimum_size = SHOP_MIN_BUTTON_SIZE if minimized else SHOP_MAX_BUTTON_SIZE
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER if minimized else HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", SHOP_MIN_ICON_SIZE if minimized else SHOP_ICON_SIZE)
		var badge: TextureRect = key_badges[item_id].badge
		var key_label: Label = key_badges[item_id].label
		badge.visible = minimized
		key_label.visible = minimized
		badge.position = Vector2(14, 8) if minimized else Vector2(4, 5)
		badge.size = SHOP_MIN_KEY_SIZE if minimized else Vector2(22, 22)
		key_label.position = badge.position
		key_label.size = badge.size
		if minimized:
			button.text = ""

func _sync_shop_opaque() -> void:
	if not is_instance_valid(shop_panel) or not is_instance_valid(shop_opaque):
		return
	shop_opaque.position = shop_panel.position
	shop_opaque.size = shop_panel.size

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo or not is_instance_valid(arena):
		return
	var key_to_item := {
		KEY_1: "repair_chassis_front",
		KEY_2: "repair_chassis_rear",
		KEY_3: "repair_chassis_left",
		KEY_4: "repair_chassis_right",
		KEY_Q: "repair_turret",
		KEY_W: "upgrade_armor",
		KEY_E: "upgrade_fire_rate",
		KEY_R: "upgrade_turret_rotation",
	}
	if key_to_item.has(event.keycode):
		_on_shop_button_pressed(key_to_item[event.keycode])
