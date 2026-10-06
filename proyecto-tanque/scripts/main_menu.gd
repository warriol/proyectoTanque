extends Control

@onready var play_button: Button = $Center/Panel/Margin/VBox/PlayButton
@onready var settings_button: Button = $Center/Panel/Margin/VBox/SettingsButton
@onready var records_button: Button = $Center/Panel/Margin/VBox/RecordsButton
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var records_panel: PanelContainer = $RecordsPanel
@onready var records_list: VBoxContainer = $RecordsPanel/Margin/VBox/RecordsList
@onready var records_close_button: Button = $RecordsPanel/Margin/VBox/CloseButton
@onready var spawn_slider: HSlider = $SettingsPanel/Margin/VBox/SpawnSlider
@onready var speed_slider: HSlider = $SettingsPanel/Margin/VBox/SpeedSlider
@onready var detection_slider: HSlider = $SettingsPanel/Margin/VBox/DetectionSlider
@onready var spawn_value: Label = $SettingsPanel/Margin/VBox/SpawnValue
@onready var speed_value: Label = $SettingsPanel/Margin/VBox/SpeedValue
@onready var detection_value: Label = $SettingsPanel/Margin/VBox/DetectionValue
@onready var sfx_slider: HSlider = $SettingsPanel/Margin/VBox/SfxSlider
@onready var music_slider: HSlider = $SettingsPanel/Margin/VBox/MusicSlider
@onready var sfx_value: Label = $SettingsPanel/Margin/VBox/SfxValue
@onready var music_value: Label = $SettingsPanel/Margin/VBox/MusicValue
@onready var apply_button: Button = $SettingsPanel/Margin/VBox/ApplyButton
@onready var back_button: Button = $SettingsPanel/Margin/VBox/BackButton
@onready var reset_button: Button = $SettingsPanel/Margin/VBox/ResetButton

func _ready() -> void:
	_apply_localized_text()
	play_button.grab_focus()
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_show_settings)
	records_button.pressed.connect(_show_records)
	apply_button.pressed.connect(_apply_settings)
	back_button.pressed.connect(_hide_settings)
	records_close_button.pressed.connect(_hide_records)
	reset_button.pressed.connect(_reset_settings)
	spawn_slider.value_changed.connect(_update_setting_labels)
	speed_slider.value_changed.connect(_update_setting_labels)
	detection_slider.value_changed.connect(_update_setting_labels)
	sfx_slider.value_changed.connect(_update_setting_labels)
	music_slider.value_changed.connect(_update_setting_labels)
	_load_settings()
	_update_setting_labels()

func _apply_localized_text() -> void:
	$Center/Panel/Margin/VBox/Title.text = Localization.text("game_title")
	$Center/Panel/Margin/VBox/Subtitle.text = Localization.text("game_subtitle")
	play_button.text = Localization.text("play")
	settings_button.text = Localization.text("settings")
	records_button.text = Localization.text("records")
	$SettingsPanel/Margin/VBox/Title.text = Localization.text("settings_title")
	$SettingsPanel/Margin/VBox/SpawnTitle.text = Localization.text("spawn_interval_title")
	$SettingsPanel/Margin/VBox/SpawnSlider.tooltip_text = Localization.text("spawn_interval_tooltip")
	$SettingsPanel/Margin/VBox/SpeedTitle.text = Localization.text("enemy_speed_title")
	$SettingsPanel/Margin/VBox/DetectionTitle.text = Localization.text("detection_title")
	$SettingsPanel/Margin/VBox/SfxTitle.text = Localization.text("sfx_title")
	$SettingsPanel/Margin/VBox/MusicTitle.text = Localization.text("music_title")
	apply_button.text = Localization.text("apply")
	reset_button.text = Localization.text("reset_defaults")
	back_button.text = Localization.text("back")
	$RecordsPanel/Margin/VBox/Title.text = Localization.text("records_title")
	records_close_button.text = Localization.text("back")

func _on_play_pressed() -> void:
	_apply_settings()
	get_tree().change_scene_to_file("res://scenes/main_arena.tscn")

func _show_settings() -> void:
	records_panel.visible = false
	settings_panel.visible = true
	$SettingsBackdrop.visible = true
	apply_button.grab_focus()

func _hide_settings() -> void:
	settings_panel.visible = false
	$SettingsBackdrop.visible = false
	settings_button.grab_focus()

func _show_records() -> void:
	settings_panel.visible = false
	$SettingsBackdrop.visible = true
	records_panel.visible = true
	_refresh_records()
	records_close_button.grab_focus()

func _hide_records() -> void:
	records_panel.visible = false
	$SettingsBackdrop.visible = false
	records_button.grab_focus()

func _refresh_records() -> void:
	for child in records_list.get_children():
		child.queue_free()

	records_list.add_child(_create_record_row([Localization.text("records_position"), Localization.text("records_name"), Localization.text("records_score"), Localization.text("records_time"), Localization.text("records_defeated"), Localization.text("records_credits"), Localization.text("records_level")], true))
	var saved_records := RecordManager.get_records()
	if saved_records.is_empty():
		var empty_label := Label.new()
		empty_label.text = Localization.text("no_records")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		records_list.add_child(empty_label)
	else:
		for index in saved_records.size():
			var record: Dictionary = saved_records[index]
			var values: Array[String] = [
				"%02d" % (index + 1),
				str(record.get("name", "Jugador")),
				str(int(record.get("score", 0))),
				_format_record_time(int(record.get("time", 0))),
				str(int(record.get("defeated", 0))),
				str(int(record.get("credits", 0))),
				str(record.get("difficulty", "CUSTOM")),
			]
			records_list.add_child(_create_record_row(values, false))

func _create_record_row(values: Array[String], is_header: bool) -> GridContainer:
	var row := GridContainer.new()
	row.columns = 7
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 4)
	var column_widths: Array[float] = [36.0, 145.0, 85.0, 65.0, 55.0, 65.0, 75.0]
	for index in values.size():
		var cell := Label.new()
		cell.text = values[index]
		cell.custom_minimum_size = Vector2(column_widths[index], 28)
		cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cell.clip_text = true
		cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if index != 1 else HORIZONTAL_ALIGNMENT_LEFT
		if is_header:
			cell.add_theme_color_override("font_color", Color("6ed3cf"))
			cell.add_theme_font_size_override("font_size", 12)
		row.add_child(cell)
	return row

func _format_record_time(total_seconds: int) -> String:
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]

func _load_settings() -> void:
	spawn_slider.value = GameSettings.spawn_interval
	speed_slider.value = GameSettings.enemy_speed
	detection_slider.value = GameSettings.detection_radius
	sfx_slider.value = GameSettings.sfx_volume
	music_slider.value = GameSettings.music_volume
	AudioManager.set_sfx_volume(GameSettings.sfx_volume)
	AudioManager.set_music_volume(GameSettings.music_volume)
	_update_setting_labels()

func _apply_settings() -> void:
	GameSettings.spawn_interval = spawn_slider.value
	GameSettings.enemy_speed = speed_slider.value
	GameSettings.detection_radius = detection_slider.value
	GameSettings.sfx_volume = sfx_slider.value
	GameSettings.music_volume = music_slider.value
	AudioManager.set_sfx_volume(GameSettings.sfx_volume)
	AudioManager.set_music_volume(GameSettings.music_volume)
	settings_panel.visible = false
	$SettingsBackdrop.visible = false

func _reset_settings() -> void:
	GameSettings.reset_defaults()
	_load_settings()

func _update_setting_labels(_value: float = 0.0) -> void:
	spawn_value.text = Localization.text("spawn_value") % spawn_slider.value
	speed_value.text = Localization.text("speed_value") % speed_slider.value
	detection_value.text = Localization.text("detection_value") % detection_slider.value
	sfx_value.text = Localization.text("volume_value") % int(sfx_slider.value * 100.0)
	music_value.text = Localization.text("volume_value") % int(music_slider.value * 100.0)
