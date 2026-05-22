# Chladni Plate Visualization

Godot 4.6 (Mobile renderer) project — real-time Chladni pattern visualization driven by audio spectrum analysis.

## Architecture

```
project/demo.tscn (Control root, script=demo_controller.gd)
├── AudioStreamPlayer          — audio source
├── FileDialog                 — audio file picker
├── ChladniView (MarginContainer, script=chladni_view.gd)
│     — facade: exports all params, delegates to children
│   ├── ComputeComponent (Node, script=compute_component.gd)
│   │     — all compute: audio analysis, beam/mode tables, C++ solver
│   └── ParticleView (TextureRect, script=particle_view.gd)
│         — particle rendering to Image → ImageTexture
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
| `project/scripts/demo_controller.gd` | Thin orchestrator: updates labels, amplitude bars, loads audio files |
| `project/addons/chladni_pattern/scripts/chladni_view.gd` | Facade: exports all params, delegates get/set to ComputeComponent and ParticleView (class_name ChladniView) |
| `project/addons/chladni_pattern/scripts/compute_component.gd` | Compute pipeline: spectrum → mode selection → C++ solver (class_name ComputeComponent) |
| `project/addons/chladni_pattern/scripts/particle_view.gd` | Renders particle positions to Image → ImageTexture, fill modes |
| `project/scenes/audio_ctrl.gd` | Play/pause, seek, time display |
| `project/scenes/amplitude_container.gd` | Creates/updates ProgressBar bands from spectrum |
| `project/scenes/param_controller.gd` | Reusable Label+HSlider+SpinBox widget (class_name ParamCtrl) |
| `src/particle_solver.cpp/.h` | C++ GDExtension: per-particle physics hot loop |
| `src/register_types.cpp` | GDExtension entry point: registers ParticleSolver class |
| `SConstruct` | SCons build script for C++ extension |
| `project/doc_classes/ParticleSolver.xml` | Editor class reference docs for ParticleSolver |

## Data Flow

```
AudioStreamPlayer → SpectrumAnalyzer (Master bus)
  → ComputeComponent polls band_count log-spaced bands via get_magnitude_for_frequency_range()
  → finds dominant band
  → looks up in _mode_table (beam eigenmode triplets sorted by λ_i²+λ_j²)
  → solver.update(delta, beam_i, beam_j, beam_sign, step_scale, drift_speed, respawn_rate)
  → ChladniView.tick() reads compute.get_positions()
  → particle_view.render(positions, particle_count)
```

## Exported Variables (ChladniView)

ChladniView is the public facade. It mirrors all ComputeComponent and ParticleView properties; setters propagate to children automatically.

- **Physics**: `particle_count` (4096), `step_scale` (0.018), `drift_speed` (0.05), `respawn_rate` (0.005)
- **Audio**: `band_count` (48), `freq_min` (20.0), `freq_max` (8000.0)
- **Mode**: `mode_max_order` (9), `zoom` (0.5)
- **Visual**: `particle_size` (5), `particle_color` (0.5, 0.8, 1.0, 0.8)
- `band_count/freq_min/freq_max` setters rebuild bands and emit `bands_changed` signal
- `mode_max_order` setter rebuilds beam/mode tables and emits `bands_changed`
- `zoom` setter syncs to C++ solver

## Exported Variables (ComputeComponent, internal)

ComputeComponent has its own internal defaults (overridden by ChladniView at `_ready()`):

- **Physics**: `particle_count` (4096), `step_scale` (0.018), `drift_speed` (0.35), `respawn_rate` (0.025)
- **Audio**: `band_count` (12), `freq_min` (20.0), `freq_max` (2000.0)
- **Mode**: `mode_max_order` (8), `zoom` (1.0)

## Exported Variables (particle_view.gd)

- `fill_mode`: STRETCH (0), FIT (1), COVER (2)
- `particle_size` (5), `particle_color` (0.5, 0.8, 1.0, 0.8)

## ParamCtrl Convention

- `target`: node to control (compute params target ComputeComponent, visual params target ParticleView)
- `variable`: property name on target
- `label`: display name (Chinese labels used in demo scene)
- Self-contained: slider changes → `target.set(variable, value)`

## Audio Loading

`_on_file_dialog_file_selected()` in demo_controller.gd: uses `AudioStreamOggVorbis.load_from_file()` etc. (static methods, cross-platform including Web).

## Build (C++ GDExtension)

```bash
scons platform=windows target=template_debug -j8    # editor debug
scons platform=windows target=template_release -j8   # release
scons platform=web target=template_debug -j8         # web debug
```

Output at `project/addons/chladni_pattern/bin/libchladni.<platform><suffix>`. Platform library entries configured in `project/addons/chladni_pattern/chladni.gdextension`.
