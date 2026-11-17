class_name GameHUD
extends CanvasLayer

@export var time_system: TimeSystem
@export var chunk_system: ChunkSystem

@onready var day_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DayLabel
@onready var time_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TimeLabel
@onready var chunk_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ChunkLabel
@onready var status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var skip_button: Button = $PanelContainer/MarginContainer/VBoxContainer/SkipDayButton

func _ready() -> void:
	if time_system != null:
		time_system.time_tick.connect(_on_time_tick)
		time_system.day_ended.connect(_on_day_ended)
		time_system.day_started.connect(_on_day_started)

	if chunk_system != null:
		chunk_system.player_chunk_changed.connect(_on_chunk_changed)
		chunk_system.chunk_settlement_executed.connect(_on_chunk_settled)

	if skip_button != null:
		skip_button.pressed.connect(_on_skip_button_pressed)

	_update_ui()

func _update_ui() -> void:
	if time_system != null:
		if day_label != null:
			day_label.text = "📅 第 %d 天" % time_system.current_day
		if time_label != null:
			var period = "☀️ 白天" if time_system.current_hour < 18 else "🌙 黄昏/夜晚"
			time_label.text = "⏰ %s (%s)" % [time_system.get_time_string(), period]

	if chunk_system != null and chunk_label != null:
		var c = chunk_system.current_player_chunk
		if c.x != 999999:
			chunk_label.text = "🧭 当前象限区块: [%d, %d]" % [c.x, c.y]
		else:
			chunk_label.text = "🧭 当前象限区块: [0, 0]"

func _on_time_tick(day: int, _hour: int, _minute: int, time_str: String) -> void:
	if day_label != null:
		day_label.text = "📅 第 %d 天" % day
	if time_label != null:
		var period = "☀️ 白天" if time_system.current_hour < 18 else "🌙 黄昏/夜晚"
		time_label.text = "⏰ %s (%s)" % [time_str, period]

func _on_chunk_changed(_old: Vector2i, new_chunk: Vector2i) -> void:
	if chunk_label != null:
		chunk_label.text = "🧭 当前象限区块: [%d, %d]" % [new_chunk.x, new_chunk.y]

func _on_day_ended(day: int) -> void:
	if status_label != null:
		status_label.text = "💤 第 %d 天已结束，正在进行每日结算..." % day

func _on_day_started(day: int) -> void:
	if status_label != null:
		status_label.text = "✨ 第 %d 天开始 (06:00 清晨)" % day

func _on_chunk_settled(chunk_coord: Vector2i, days_passed: int) -> void:
	print("[HUD] 区块 %s 完成结算，跨越天数: %d" % [chunk_coord, days_passed])

func _on_skip_button_pressed() -> void:
	if time_system != null:
		time_system.skip_to_next_day()
