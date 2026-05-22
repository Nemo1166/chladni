extends PanelContainer

@export var show_panel_bg: bool = true
@export var show_dominant_band: bool = true
@export var band_count: int = 0

@onready var v_box: VBoxContainer = %AmpContainer
@onready var min_freq: Label = %MinFreq
@onready var max_freq: Label = %MaxFreq


func setup_bars(count: int, f_min: float, f_max: float):
	min_freq.text = "%.1f Hz" % f_min
	max_freq.text = "%.1f Hz" % f_max
	band_count = count
	for c in v_box.get_children():
		c.queue_free()
	for i in count:
		var bar := ProgressBar.new()
		bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bar.show_percentage = false
		v_box.add_child(bar)


func update_bars(mags: PackedFloat32Array, max_mag: float, dominant_band: int):
	var bars := v_box.get_children()
	for i in band_count:
		if i >= bars.size():
			break
		var mag := mags[i] if i < mags.size() else 0.0
		var ratio := mag / max_mag if max_mag > 0.001 else 0.0
		var bar := bars[i] as ProgressBar
		bar.value = ratio * 100.0
		if show_dominant_band and i == dominant_band:
			bar.modulate = Color(1.0, 0.8, 0.2, 1.0)
		else:
			bar.modulate = Color(1.0, 1.0, 1.0, 0.55)
