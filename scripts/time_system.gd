class_name TimeSystem
extends Node

signal time_tick(day: int, hour: int, minute: int, time_str: String)
signal day_ended(day: int)     # Triggered at 22:00 or when skipping day (Daily Settlement)
signal day_started(day: int)   # Triggered at 06:00 next day

@export var day_start_hour: int = 6
@export var forced_sleep_hour: int = 22

# 1 real second = 1 in-game minute (16 real minutes = 16 in-game hours)
@export var seconds_per_game_minute: float = 1.0
@export var is_paused: bool = false

var current_day: int = 1
var current_hour: int = 6
var current_minute: int = 0

var _timer: float = 0.0

func _ready() -> void:
	current_hour = day_start_hour
	current_minute = 0
	_emit_time_update()

func _process(delta: float) -> void:
	if is_paused:
		return

	_timer += delta
	if _timer >= seconds_per_game_minute:
		_timer -= seconds_per_game_minute
		_advance_one_minute()

func _advance_one_minute() -> void:
	current_minute += 1
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1

	_emit_time_update()

	# Check for 22:00 bedtime
	if current_hour >= forced_sleep_hour:
		print("[TimeSystem] Reached %d:00! Forced bedtime triggered." % forced_sleep_hour)
		skip_to_next_day()

func skip_to_next_day() -> void:
	print("[TimeSystem] === Starting Daily Settlement for Day %d ===" % current_day)
	# 1. Trigger daily settlement for all loaded chunks and systems
	day_ended.emit(current_day)

	# 2. Advance to next day 06:00
	current_day += 1
	current_hour = day_start_hour
	current_minute = 0
	_timer = 0.0

	_emit_time_update()
	day_started.emit(current_day)
	print("[TimeSystem] === Woke up on Day %d at %02d:00 ===" % [current_day, day_start_hour])

func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

func _emit_time_update() -> void:
	time_tick.emit(current_day, current_hour, current_minute, get_time_string())
