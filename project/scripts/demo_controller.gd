extends Control

@onready var chladni_view: ChladniView = %ChladniView
@onready var compute: ComputeComponent = chladni_view.compute
@onready var mode_label := %ModeLabel
@onready var freq_label := %FreqLabel
@onready var cost_label := %ComputeCostLabel
@onready var bar_container := $UI/AmplitudeViewer
@onready var audio_player := $AudioStreamPlayer


func _ready():
	bar_container.setup_bars(compute.band_count, compute.freq_min, compute.freq_max)
	chladni_view.bands_changed.connect(func(count, f_min, f_max):
		bar_container.setup_bars(count, f_min, f_max)
	)


func _process(delta):
	var start: float = Time.get_ticks_usec()
	chladni_view.tick(delta)

	mode_label.text = "i=%d j=%d sign=%+d" % [compute.beam_i + 1, compute.beam_j + 1, compute.beam_sign]
	freq_label.text = "zoom=%.1f  lam=%.0f\n%.0f Hz" % [
		compute.zoom, compute.freq_proxy, compute.mid_freq
	]
	cost_label.text = "Compute: %.2f ms\nRender: %.2f ms" % [
		compute.compute_time_ms, (Time.get_ticks_usec() - start) * 0.001
	]
	bar_container.update_bars(compute.band_mags, compute.max_mag, compute.dominant_band)


func _on_file_dialog_file_selected(path: String) -> void:
	var ext := path.to_lower().get_extension()
	var stream: AudioStream

	if ext == "ogg":
		stream = AudioStreamOggVorbis.load_from_file(path)
	elif ext == "mp3":
		stream = AudioStreamMP3.load_from_file(path)
	elif ext == "wav":
		stream = AudioStreamWAV.load_from_file(path)

	if stream:
		audio_player.stop()
		audio_player.stream = stream
		audio_player.play()
	else:
		push_error("Failed to load audio: %s" % path)
