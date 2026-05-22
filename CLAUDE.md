# Chladni Plate Visualization

Godot 4.6 (Mobile renderer) project — real-time Chladni pattern visualization driven by audio spectrum analysis.

## Architecture

```
project/demo.tscn (Control root, script=control.gd)
├── ComputeComponent (Node, script=compute_component.gd)
│     — all compute: audio analysis, beam/mode tables, C++ solver
├── AudioStreamPlayer          — audio source
├── FileDialog                 — audio file picker
├── ParticleView (TextureRect) — particle rendering, script=particle_view.gd
└── UI (Control overlay)
    ├── ModeLabel / FreqLabel / ComputeCostLabel
    ├── AudioCtrl (PanelContainer, script=audio_ctrl.gd)
    ├── AmplitudeViewer (PanelContainer, script=amplitude_container.gd)
    │     — spectrum ProgressBar bands
    └── ParamPanel (ScrollContainer)
          └── ParamList → ParamCtrl rows (runtime-adjustable params)
```

## Key Files

| File | Purpose |
|------|---------|
| `project/scripts/control.gd` | Thin orchestrator: calls compute.update(), renders particles, refreshes UI labels |
| `project/scripts/compute_component.gd` | Compute pipeline: spectrum → mode selection → C++ solver (class_name ComputeComponent) |
| `project/scripts/particle_view.gd` | Renders particle positions to Image → ImageTexture, fill modes |
| `project/scenes/audio_ctrl.gd` | Play/pause, seek, time display |
| `project/scenes/amplitude_container.gd` | Creates/updates ProgressBar bands from spectrum |
| `project/scenes/param_controller.gd` | Reusable Label+HSlider+SpinBox widget (class_name ParamCtrl) |
| `src/particle_solver.cpp/.h` | C++ GDExtension: per-particle physics hot loop |
| `project/doc_classes/ParticleSolver.xml` | Editor class reference docs for ParticleSolver |

## Data Flow

```
AudioStreamPlayer → SpectrumAnalyzer (Master bus)
  → ComputeComponent polls band_count log-spaced bands via get_magnitude_for_frequency_range()
  → finds dominant band
  → looks up in _mode_table (beam eigenmode triplets sorted by λ_i²+λ_j²)
  → solver.update(delta, beam_i, beam_j, beam_sign, step_scale, drift_speed, respawn_rate)
  → control.gd reads compute.get_positions()
  → particle_view.render(positions, particle_count)
```

## Exported Variables (ComputeComponent)

- **Physics**: `particle_count`, `step_scale`, `drift_speed`, `respawn_rate`
- **Audio**: `band_count`, `freq_min`, `freq_max`, `mode_max_order`, `zoom`
- `band_count/freq_min/freq_max` setters auto-rebuild bands and emit `bands_changed` signal
- `mode_max_order` setter rebuilds beam/mode tables and emits `bands_changed`
- `zoom` setter syncs to C++ solver

## Exported Variables (particle_view.gd)

- `fill_mode`: STRETCH (0), FIT (1), COVER (2)
- `particle_size`, `particle_color`

## ParamCtrl Convention

- `target`: node to control (compute params target ComputeComponent, visual params target ParticleView)
- `variable`: property name on target
- `label`: display name (Chinese labels used in demo scene)
- Self-contained: slider changes → `target.set(variable, value)`

## Audio Loading

`_on_file_dialog_file_selected()` in control.gd: uses `AudioStreamOggVorbis.load_from_file()` etc. (static methods, cross-platform including Web).
