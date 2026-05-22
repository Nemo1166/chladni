extends MarginContainer
class_name ParamCtrl

signal value_changed(value: float)

@export var label: String = ""
@export var variable: StringName = &""
@export var target: Node
@export_group("Value", "value")
@export var value_min: float = 0.0
@export var value_max: float = 1.0
@export var value_step: float = 0.01
@export var value_value: float = 0.5
@export var use_integer: bool = false

@onready var _label: Label = %Label
@onready var _slider: HSlider = %HSlider
@onready var _spinbox: SpinBox = %SpinBox

var _updating := false


func _ready():
	_label.text = label
	_slider.min_value = value_min
	_slider.max_value = value_max
	_slider.step = value_step
	_spinbox.min_value = value_min
	_spinbox.max_value = value_max
	_spinbox.step = 1.0 if use_integer else value_step

	if target and not variable.is_empty():
		value_value = target.get(variable)
	_slider.value = value_value
	_spinbox.value = value_value

	if not _slider.value_changed.is_connected(_on_slider_changed):
		_slider.value_changed.connect(_on_slider_changed)
	if not _spinbox.value_changed.is_connected(_on_spinbox_changed):
		_spinbox.value_changed.connect(_on_spinbox_changed)


func set_value(v: float) -> void:
	_updating = true
	_slider.value = v
	_spinbox.value = v
	_updating = false


func get_value() -> float:
	return _slider.value


func _apply_value(v: float) -> void:
	if use_integer:
		v = round(v)
	if target and not variable.is_empty():
		target.set(variable, v)


func _on_slider_changed(v: float) -> void:
	if _updating:
		return
	_updating = true
	_spinbox.value = v
	_updating = false
	_apply_value(v)
	value_changed.emit(v)


func _on_spinbox_changed(v: float) -> void:
	if _updating:
		return
	_updating = true
	_slider.value = v
	_updating = false
	_apply_value(v)
	value_changed.emit(v)
