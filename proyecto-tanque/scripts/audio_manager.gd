extends Node

const MUSIC_STREAM: AudioStream = preload("res://audio/sfx/Target_Acquired.mp3")
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

var music_player: AudioStreamPlayer

func _ready() -> void:
    _ensure_bus(SFX_BUS)
    _ensure_bus(MUSIC_BUS)
    set_sfx_volume(GameSettings.sfx_volume)
    set_music_volume(GameSettings.music_volume)
    music_player = AudioStreamPlayer.new()
    music_player.stream = MUSIC_STREAM
    music_player.bus = MUSIC_BUS
    add_child(music_player)
    music_player.finished.connect(_on_music_finished)
    music_player.play()

func play_sound(sound: AudioStream) -> void:
    if not sound or AudioServer.get_bus_index(SFX_BUS) < 0:
        return

    var player := AudioStreamPlayer.new()
    player.stream = sound
    player.bus = SFX_BUS
    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()

func set_sfx_volume(value: float) -> void:
    _set_bus_volume(SFX_BUS, value)

func set_music_volume(value: float) -> void:
    _set_bus_volume(MUSIC_BUS, value)

func _ensure_bus(bus_name: String) -> void:
    if AudioServer.get_bus_index(bus_name) < 0:
        AudioServer.add_bus()
        AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _set_bus_volume(bus_name: String, value: float) -> void:
    var bus_index := AudioServer.get_bus_index(bus_name)
    if bus_index < 0:
        return
    var volume_db := -80.0 if value <= 0.0 else linear_to_db(value)
    AudioServer.set_bus_volume_db(bus_index, volume_db)

func _on_music_finished() -> void:
    music_player.play()

func _exit_tree() -> void:
    for child in get_children():
        child.free()