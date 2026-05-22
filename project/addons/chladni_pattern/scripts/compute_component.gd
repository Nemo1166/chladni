extends Node
class_name ComputeComponent

signal bands_changed(count: int, f_min: float, f_max: float)

# ——— Particle parameters ———
var particle_count: int = 4096:
	set(v):
		particle_count = v
		if solver: solver.resize(v)
var step_scale: float = 0.018
var drift_speed: float = 0.35
var respawn_rate: float = 0.025

# ——— Audio / mode parameters ———
var band_count: int = 12:
	set(v):
		band_count = v
		if is_node_ready() and _bands.size() > 0:
			_rebuild_bands_and_modes()
var freq_min: float = 20.0:
	set(v):
		freq_min = v
		if is_node_ready() and _bands.size() > 0:
			_rebuild_bands_and_modes()
var freq_max: float = 2000.0:
	set(v):
		freq_max = v
		if is_node_ready() and _bands.size() > 0:
			_rebuild_bands_and_modes()
var mode_max_order: int = 8:
	set(v):
		mode_max_order = v
		if is_node_ready() and _bands.size() > 0:
			_compute_beam_table()
			if solver: solver.set_beam_lam(_beam_lam)
			if solver: solver.set_beam_coeff(_beam_coeff)
			_build_mode_table()
			bands_changed.emit(band_count, freq_min, freq_max)
var zoom: float = 1.0:
	set(v):
		zoom = v
		if solver: solver.set_zoom(zoom)

# ——— Public read-only state ———
var beam_i: int = 0
var beam_j: int = 1
var beam_sign: int = -1
var freq_proxy: float = 0.0
var mid_freq: float = 0.0
var max_mag: float = 0.0
var dominant_band: int = 0
var band_mags: PackedFloat32Array
var compute_time_ms: float = 0.0

var solver
var spectrum: AudioEffectSpectrumAnalyzerInstance

# ——— Internal ———
var _bands: Array = []
var _beam_lam: PackedFloat32Array
var _beam_coeff: PackedFloat32Array
var _mode_i: PackedInt32Array
var _mode_j: PackedInt32Array
var _mode_sign: PackedInt32Array


func _ready():
	_build_bands()
	_compute_beam_table()
	_build_mode_table()

	solver = ParticleSolver.new()
	solver.resize(particle_count)
	solver.set_beam_lam(_beam_lam)
	solver.set_beam_coeff(_beam_coeff)
	solver.set_zoom(zoom)

	if _mode_i.size() > 0:
		beam_i = _mode_i[0]
		beam_j = _mode_j[0]
		beam_sign = _mode_sign[0]

	var bus_idx = AudioServer.get_bus_index("Master")
	spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0)


func update(delta: float) -> void:
	var t0 := Time.get_ticks_usec()
	_update_audio()
	solver.set_zoom(zoom)
	solver.update(delta, beam_i, beam_j, beam_sign,
				  step_scale, drift_speed, respawn_rate)
	compute_time_ms = (Time.get_ticks_usec() - t0) * 0.001


func get_positions() -> PackedVector2Array:
	return solver.get_positions() if solver else PackedVector2Array()


func _build_bands():
	_bands.clear()
	var log_min := log(freq_min)
	var log_max := log(freq_max)
	for i in band_count:
		var t0 := float(i) / float(band_count)
		var t1 := float(i + 1) / float(band_count)
		var from := exp(log_min + t0 * (log_max - log_min))
		var to := exp(log_min + t1 * (log_max - log_min))
		_bands.append({"from": from, "to": to, "index": i})


func _compute_beam_table():
	_beam_lam.clear()
	_beam_coeff.clear()
	for k in range(1, mode_max_order + 1):
		var is_sym := (k % 2 == 1)
		var lam: float
		if is_sym:
			lam = (4.0 * k - 1.0) * PI / 2.0
			for _iter in 5:
				var half := lam * 0.5
				var tan_h := tan(half)
				var tanh_h := tanh(half)
				var f := tan_h + tanh_h
				var sec2 := 1.0 / (cos(half) * cos(half))
				var sech2 := 1.0 / (cosh(half) * cosh(half))
				var fp := 0.5 * (sec2 + sech2)
				lam -= f / fp
			_beam_coeff.append(cos(lam * 0.5) / cosh(lam * 0.5))
		else:
			lam = (4.0 * k - 3.0) * PI / 2.0
			for _iter in 5:
				var half := lam * 0.5
				var tan_h := tan(half)
				var tanh_h := tanh(half)
				var f := tan_h - tanh_h
				var sec2 := 1.0 / (cos(half) * cos(half))
				var sech2 := 1.0 / (cosh(half) * cosh(half))
				var fp := 0.5 * (sec2 - sech2)
				lam -= f / fp
			_beam_coeff.append(sin(lam * 0.5) / sinh(lam * 0.5))
		_beam_lam.append(lam)


func _build_mode_table():
	var entries: Array = []
	for i in range(mode_max_order):
		var fi := _beam_lam[i] * _beam_lam[i]
		for j in range(mode_max_order):
			var fj := _beam_lam[j] * _beam_lam[j]
			var s := 1 if (i + j) % 2 == 0 else -1
			entries.append({
				"i": i, "j": j, "sign": s,
				"freq": fi + fj,
			})
	entries.sort_custom(func(a, b): return a["freq"] < b["freq"])

	_mode_i.clear()
	_mode_j.clear()
	_mode_sign.clear()
	var total := entries.size()
	if total <= band_count:
		for e in entries:
			_mode_i.append(e["i"]); _mode_j.append(e["j"]); _mode_sign.append(e["sign"])
	else:
		for b in band_count:
			var idx := int(round(float(b) / float(band_count - 1) * float(total - 1)))
			_mode_i.append(entries[idx]["i"])
			_mode_j.append(entries[idx]["j"])
			_mode_sign.append(entries[idx]["sign"])


func _rebuild_bands_and_modes():
	_build_bands()
	_build_mode_table()
	bands_changed.emit(band_count, freq_min, freq_max)


func _update_audio():
	if spectrum == null or _bands.is_empty():
		return

	band_mags.resize(band_count)
	max_mag = 0.0
	dominant_band = 0
	var best_from := 0.0
	var best_to := 0.0

	for band in _bands:
		var idx: int = band["index"]
		var vec := spectrum.get_magnitude_for_frequency_range(band["from"], band["to"])
		var mag := (vec.x + vec.y) * 0.5
		band_mags[idx] = mag
		if mag > max_mag:
			max_mag = mag
			dominant_band = idx
			best_from = band["from"]
			best_to = band["to"]

	if _mode_i.size() > 0:
		var table_idx := clampi(
			int(round(float(dominant_band) / float(band_count - 1) * float(_mode_i.size() - 1))),
			0, _mode_i.size() - 1
		) if band_count > 1 else 0
		beam_i = _mode_i[table_idx]
		beam_j = _mode_j[table_idx]
		beam_sign = _mode_sign[table_idx]

	freq_proxy = _beam_lam[beam_i] * _beam_lam[beam_i] + _beam_lam[beam_j] * _beam_lam[beam_j]
	mid_freq = (best_from + best_to) * 0.5
