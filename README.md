# Chladni Plate

Real-time Chladni pattern visualization driven by audio spectrum analysis. Built with Godot 4.6 (Mobile renderer) + C++ GDExtension.

基于音频频谱驱动的实时克拉尼图形可视化。使用 Godot 4.6 (Mobile 渲染器) + C++ GDExtension。

## Quick Start / 快速开始

```bash
# Build C++ extension / 构建 C++ 扩展
scons platform=windows target=template_debug -j8

# Open in Godot / 在 Godot 中打开
# project/project.godot
```

## Structure / 项目结构

```
src/          — C++ GDExtension (particle solver hot loop)
project/      — Godot project
  addons/chladni_pattern/  — ChladniView + ComputeComponent + ParticleView
  scripts/                 — demo_controller.gd
  scenes/                  — UI components (audio_ctrl, amplitude, params)
docs/         — beam function theory & parameter reference
```

## Physics / 物理原理

Uses free-edge beam eigenfunctions (Rayleigh-Ritz) to model square plate vibration modes. Particles drift toward nodal lines via gradient descent on the amplitude field.

使用自由边界梁本征函数（Rayleigh-Ritz 法）对方板振动建模。粒子通过振幅场梯度下降向节线漂移。

[Read more](docs/beam_function_theory.md)

## Limitations / 已知限制

- Mobile renderer only (you can change to GLES3/Forward+ on your own)
- AudioEffect (e.g. AudioEffectSpectrumAnalyzer) not supported in Web export
- No audio input / microphone support yet
- Particles reset on mode switch (no smooth transition)

- Mobile 渲染器专用（你可以自行切换到 GLES3/Forward+）
- Web 导出部分音频格式不可用（AudioEffect 不受支持）
- 尚未支持麦克风实时输入
- 模式切换时粒子重置（无平滑过渡）

## Build Requirements / 构建依赖

- Godot 4.6+
- [godot-cpp](https://github.com/godotengine/godot-cpp) (git submodule)
- SCons
