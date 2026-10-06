extends Node

const RECORDS_PATH := "user://records.json"
const MAX_RECORDS := 10

var records: Array[Dictionary] = []

func _ready() -> void:
	_load_records()

func is_record(score: int) -> bool:
	return records.size() < MAX_RECORDS or score > int(records.back().get("score", 0))

func add_record(record: Dictionary) -> void:
	records.append(record)
	records.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		return int(first.get("score", 0)) > int(second.get("score", 0))
	)
	if records.size() > MAX_RECORDS:
		records.resize(MAX_RECORDS)
	_save_records()

func get_records() -> Array[Dictionary]:
	return records.duplicate(true)

func _load_records() -> void:
	if not FileAccess.file_exists(RECORDS_PATH):
		return
	var file := FileAccess.open(RECORDS_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		for record in parsed:
			if record is Dictionary:
				records.append(record)
		records.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
			return int(first.get("score", 0)) > int(second.get("score", 0))
		)
		if records.size() > MAX_RECORDS:
			records.resize(MAX_RECORDS)

func _save_records() -> void:
	var file := FileAccess.open(RECORDS_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(records))

func submit_to_steam(_record: Dictionary) -> void:
	pass
