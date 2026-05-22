extends PanelContainer

@export var target: AudioStreamPlayer

@onready var progress: ProgressBar = %ProgressBar
@onready var play_time: Label = %PlayTime


func _process(_delta: float) -> void:
	if not target or not target.stream:
		return

	var total := target.stream.get_length()
	var pos := target.get_playback_position() + AudioServer.get_time_since_last_mix()
	pos -= AudioServer.get_output_latency()
	pos = clampf(pos, 0.0, total)

	progress.value = (pos / total) * 100.0 if total > 0 else 0.0
	play_time.text = "%s / %s" % [_fmt(pos), _fmt(total)]


func _on_play_pulse_pressed() -> void:
	if not target:
		return

	if target.playing:
		target.stream_paused = not target.stream_paused
	else:
		target.play(target.get_playback_position())


func _on_reset_pressed() -> void:
	if not target:
		return
	target.stop()


func _fmt(sec: float) -> String:
	var m := int(sec / 60)
	var s := int(sec) % 60
	return "%d:%02d" % [m, s]
