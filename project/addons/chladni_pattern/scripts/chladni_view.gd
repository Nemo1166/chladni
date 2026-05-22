extends Control
class_name ChladniView

signal bands_changed(count: int, f_min: float, f_max: float)

# ── Particle parameters ──
var _particle_count: int = 4096
@export var particle_count: int = 4096:
	get: return compute.particle_count if compute else _particle_count
	set(v):
		_particle_count = v
		if compute: compute.particle_count = v

var _step_scale: float = 0.018
@export_range(0.001, 0.1, 0.001) var step_scale: float = 0.018:
	get: return compute.step_scale if compute else _step_scale
	set(v):
		_step_scale = v
		if compute: compute.step_scale = v

var _drift_speed: float = 0.05
@export_range(0.01, 1.0, 0.01) var drift_speed: float = 0.05:
	get: return compute.drift_speed if compute else _drift_speed
	set(v):
		_drift_speed = v
		if compute: compute.drift_speed = v

var _respawn_rate: float = 0.005
@export_range(0.0, 0.2, 0.005) var respawn_rate: float = 0.005:
	get: return compute.respawn_rate if compute else _respawn_rate
	set(v):
		_respawn_rate = v
		if compute: compute.respawn_rate = v

# ── Audio / mode parameters ──
var _band_count: int = 48
@export_range(4, 64, 4) var band_count: int = 48:
	get: return compute.band_count if compute else _band_count
	set(v):
		_band_count = v
		if compute: compute.band_count = v

var _freq_min: float = 20.0
@export var freq_min: float = 20.0:
	get: return compute.freq_min if compute else _freq_min
	set(v):
		_freq_min = v
		if compute: compute.freq_min = v

var _freq_max: float = 8000.0
@export var freq_max: float = 8000.0:
	get: return compute.freq_max if compute else _freq_max
	set(v):
		_freq_max = v
		if compute: compute.freq_max = v

var _mode_max_order: int = 9
@export_range(1, 12) var mode_max_order: int = 9:
	get: return compute.mode_max_order if compute else _mode_max_order
	set(v):
		_mode_max_order = v
		if compute: compute.mode_max_order = v

var _zoom: float = 0.5
@export_range(0.5, 2.0, 0.1) var zoom: float = 0.5:
	get: return compute.zoom if compute else _zoom
	set(v):
		_zoom = v
		if compute: compute.zoom = v

# ── Visual parameters ──
var _particle_size: int = 5
@export_range(1, 12, 1) var particle_size: int = 5:
	get: return particle_view.particle_size if particle_view else _particle_size
	set(v):
		_particle_size = v
		if particle_view: particle_view.particle_size = v

var _particle_color: Color = Color(0.5, 0.8, 1.0, 0.8)
@export var particle_color: Color = Color(0.5, 0.8, 1.0, 0.8):
	get: return particle_view.particle_color if particle_view else _particle_color
	set(v):
		_particle_color = v
		if particle_view: particle_view.particle_color = v

@onready var compute: ComputeComponent = %ComputeComponent
@onready var particle_view := %ParticleView


func _ready():
	_sync_to_children()
	compute.bands_changed.connect(
		func(count, f_min, f_max): bands_changed.emit(count, f_min, f_max)
	)


func tick(delta: float) -> void:
	compute.update(delta)
	particle_view.render(compute.get_positions(), compute.particle_count)


func _sync_to_children():
	if not compute: return
	compute.particle_count = _particle_count
	compute.step_scale = _step_scale
	compute.drift_speed = _drift_speed
	compute.respawn_rate = _respawn_rate
	compute.band_count = _band_count
	compute.freq_min = _freq_min
	compute.freq_max = _freq_max
	compute.mode_max_order = _mode_max_order
	compute.zoom = _zoom
	if particle_view:
		particle_view.particle_size = _particle_size
		particle_view.particle_color = _particle_color
