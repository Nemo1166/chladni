# 导出变量说明

## 粒子参数

| 变量 | 类型 | 默认值 | 范围 | 说明 |
| --- | --- | --- | --- | --- |
| `particle_count` | int | 4096 | — | 粒子总数。越多图案越密集，CPU 负载越高 |
| `step_scale` | float | 0.018 | 0.001 ~ 0.1 | 随机跳跃幅度。调小粒子更快稳定在节线上 |
| `drift_speed` | float | 0.35 | 0.01 ~ 2.0 | 向节线漂移的速度。调大加快聚集 |
| `particle_size` | int | 5 | 1 ~ 12 | 粒子显示像素尺寸 |
| `respawn_rate` | float | 0.025 | 0 ~ 0.2 | 每帧随机重生比例。0 = 稳定后不变 |
| `particle_color` | Color | (0.5, 0.8, 1.0, 0.8) | — | 粒子颜色 (RGBA) |
| `background_color` | Color | (0.02, 0.02, 0.06, 1.0) | — | 背景颜色 (RGBA) |

### 快速收敛设置

| 参数 | 推荐值 |
| --- | --- |
| `drift_speed` | 0.6 ~ 1.0 |
| `step_scale` | 0.005 ~ 0.01 |
| `respawn_rate` | 0 |

---

## 音频参数

| 变量 | 类型 | 默认值 | 范围 | 说明 |
| --- | --- | --- | --- | --- |
| `band_count` | int | 12 | 2 ~ 64 | 频段数量。每个频段对应一个本征模 |
| `freq_min` | float | 20.0 | — | 频谱分析最低频率 (Hz) |
| `freq_max` | float | 2000.0 | — | 频谱分析最高频率 (Hz) |

频段采用对数间隔划分，匹配人耳听觉特性。

---

## 梁模参数

| 变量 | 类型 | 默认值 | 范围 | 说明 |
| --- | --- | --- | --- | --- |
| `mode_max_order` | int | 8 | 1 ~ 12 | 梁模阶数上限。越大可选模式越多，图案越复杂 |
| `zoom` | float | 1.0 | 0.5 ~ 4.0 | 坐标缩放。>1 更多节线，<1 更少 |

梁模表自动生成：枚举所有 $(i,j)$ 对（$0 \le i,j <$ `mode_max_order`，$i \neq j$ 时跳过退化组合），按 $\lambda_i^2 + \lambda_j^2$ 排序，均匀采样 `band_count` 个模式。

---

## 公式

采用自由边界梁函数（beam functions）构造方板本征模：

$$
\Psi_{ij}(x,y) = X_i(x) \cdot X_j(y) + s_{ij} \cdot X_j(x) \cdot X_i(y)
$$

梁函数 $X_k$ 在对称模（k 偶）和反对称模（k 奇）之间交替：

- 对称：$X_k(x) = \cos(\lambda_k x) + C_k \cosh(\lambda_k x)$
- 反对称：$X_k(x) = \sin(\mu_k x) + C_k \sinh(\mu_k x)$

叠加符号 $s_{ij} = +1$ 当 $i+j$ 为偶数，$s_{ij} = -1$ 当 $i+j$ 为奇数。

梁函数物理热循环已通过 C++ GDExtension 加速（详见 `beam_function_theory.md`）。

---

## 实现架构

```
GDScript（控制逻辑）
  ├─ 音频频谱分析
  ├─ 频段 → 本征模表查表
  ├─ C++ solver.update()        ← 热循环（~1.2ms vs 原 15ms）
  └─ Image 渲染粒子

C++ GDExtension（热循环）
  └─ ParticleSolver::update()
       └─ beam_val_deriv() × 4  ← 合并值和导数
```

## UI 元素

| 元素 | 内容 |
| --- | --- |
| `ModeLabel`（左上） | 当前本征模 `i=X  j=Y  sign=±1` |
| `FreqLabel`（左上） | 主导频率、λ_i²+λ_j²、zoom |
| `ComputeCostLabel`（左上） | 每帧总计算耗时 (ms) |
| `AmplitudeContainer`（右侧） | 频段振幅 ProgressBar，金色高亮主导频段 |
