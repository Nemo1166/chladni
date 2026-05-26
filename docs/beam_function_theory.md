# 梁函数法 — 克拉尼板技术原理 v2

## 1. 物理回顾

### 1.1 控制方程

薄板横向自由振动满足双调和方程：

$$
\nabla^4 w + \frac{\rho h}{D} \frac{\partial^2 w}{\partial t^2} = 0, \qquad
D = \frac{E h^3}{12(1 - \nu^2)}
$$

分离变量 $w(x,y,t) = \Psi(x,y) \cdot \sin(\omega t)$ 得到本征值问题：

$$
\nabla^4 \Psi = k^4 \Psi, \qquad k^4 = \frac{\rho h \omega^2}{D}
$$

### 1.2 自由边界条件

板边缘（ $x = \pm L/2$ 或 $y = \pm L/2$）处：

- 弯矩为零: $\displaystyle \frac{\partial^2 \Psi}{\partial n^2} + \nu \frac{\partial^2 \Psi}{\partial s^2} = 0$
- 等效剪力为零: $\displaystyle \frac{\partial^3 \Psi}{\partial n^3} + (2 - \nu) \frac{\partial^3 \Psi}{\partial n \partial s^2} = 0$

其中 $n$ 为法向， $s$ 为切向。

### 1.3 Rayleigh-Ritz 近似

方板的二维本征模由一维梁函数乘积叠加构造：

$$
\Psi_{ij}(x,y) = X_i(x) \cdot X_j(y) \pm X_j(x) \cdot X_i(y)
$$

- $X_i$ 为自由-自由梁的第 $i$ 阶弯曲模（ $i = 1, 2, 3, \dots$ ）
- $+$ 号：对称叠加； $-$ 号：反对称叠加

---

## 2. 梁函数推导

### 2.1 自由-自由梁的弯曲振动

长度为 $L$ 的均匀梁，自由边界条件（两端弯矩和剪力为零）。本征函数的一般形式：

$$
X(x) = A \cos(\lambda x) + B \sin(\lambda x) + C \cosh(\lambda x) + D \sinh(\lambda x)
$$

坐标归一化至 $[-L/2, L/2]$，取 $L = 1$，即 $x \in [-0.5, 0.5]$。

### 2.2 对称模（ $i = 1, 3, 5, \dots$ ，即 k 为偶数索引）

对称模为偶函数，$B = D = 0$：

$$
X_k(x) = A \cos(\lambda_k x) + C \cosh(\lambda_k x)
$$

**边界条件**（在 $x = 0.5$ 处）：

弯矩为零： $X_k''(0.5) = -A\lambda_k^2 \cos(\frac{\lambda_k}{2}) + C\lambda_k^2 \cosh(\frac{\lambda_k}{2}) = 0$

$$
\Rightarrow \quad C = A \cdot \frac{\cos(\lambda_k / 2)}{\cosh(\lambda_k / 2)}
$$

剪力为零： $X_k'''(0.5) = A\lambda_k^3 \sin(\frac{\lambda_k}{2}) + C\lambda_k^3 \sinh(\frac{\lambda_k}{2}) = 0$

代入 $C$ 消去 $A\lambda_k^3$：

$$
\sin\!\left(\frac{\lambda_k}{2}\right) + \frac{\cos(\lambda_k/2)}{\cosh(\lambda_k/2)} \cdot \sinh\!\left(\frac{\lambda_k}{2}\right) = 0
$$

即 **对称本征值方程**：

$$
\tan\!\left(\frac{\lambda}{2}\right) + \tanh\!\left(\frac{\lambda}{2}\right) = 0
$$

取 $A = 1$，得：

$$
\boxed{X_k(x) = \cos(\lambda_k x) + C_k \cdot \cosh(\lambda_k x)}
$$

其中 $\displaystyle C_k = \frac{\cos(\lambda_k / 2)}{\cosh(\lambda_k / 2)}$。

**导数**：

$$
\boxed{X_k'(x) = -\lambda_k \sin(\lambda_k x) + C_k \lambda_k \cdot \sinh(\lambda_k x)}
$$

### 2.3 反对称模（$i = 2, 4, 6, \dots$，即 k 为奇数索引）

反对称模为奇函数， $A = C = 0$ ：

$$
X_k(x) = B \sin(\mu_k x) + D \sinh(\mu_k x)
$$

弯矩为零： $X_k''(0.5) = -B\mu_k^2 \sin(\frac{\mu_k}{2}) + D\mu_k^2 \sinh(\frac{\mu_k}{2}) = 0$

$$
\Rightarrow \quad D = B \cdot \frac{\sin(\mu_k / 2)}{\sinh(\mu_k / 2)}
$$

剪力为零： $X_k'''(0.5) = -B\mu_k^3 \cos(\frac{\mu_k}{2}) + D\mu_k^3 \cosh(\frac{\mu_k}{2}) = 0$

代入 $D$ 消去 $B\mu_k^3$ ：

$$
-\cos\!\left(\frac{\mu_k}{2}\right) + \frac{\sin(\mu_k/2)}{\sinh(\mu_k/2)} \cdot \cosh\!\left(\frac{\mu_k}{2}\right) = 0
$$

即 **反对称本征值方程**：

$$
\tan\!\left(\frac{\mu}{2}\right) - \tanh\!\left(\frac{\mu}{2}\right) = 0
$$

取 $B = 1$ ，得：

$$
\boxed{X_k(x) = \sin(\mu_k x) + C_k \cdot \sinh(\mu_k x)}
$$

其中 $\displaystyle C_k = \frac{\sin(\mu_k / 2)}{\sinh(\mu_k / 2)}$ 。

**导数**：

$$
\boxed{X_k'(x) = \mu_k \cos(\mu_k x) + C_k \mu_k \cdot \cosh(\mu_k x)}
$$

### 2.4 本征值表（前 12 阶）

| 阶数 k | 类型 | 本征值 $\lambda_k$ 或 $\mu_k$ | 系数 $C_k$ |
|--------|------|-------------------------------|-----------|
| 1 | 对称 | 4.73004 | −0.98250 |
| 2 | 反对称 | 7.85320 | −1.00078 |
| 3 | 对称 | 10.99561 | −0.99997 |
| 4 | 反对称 | 14.13717 | −1.00000 |
| 5 | 对称 | 17.27876 | −1.00000 |
| 6 | 反对称 | 20.42035 | −1.00000 |
| 7 | 对称 | 23.56194 | −1.00000 |
| 8 | 反对称 | 26.70354 | −1.00000 |
| 9 | 对称 | 29.84513 | −1.00000 |
| 10 | 反对称 | 32.98672 | −1.00000 |
| 11 | 对称 | 36.12832 | −1.00000 |
| 12 | 反对称 | 39.26991 | −1.00000 |

高阶近似： $\lambda_k \approx (2k+1)\pi/2$ （对称）， $\mu_k \approx (2k+3)\pi/2$ （反对称）， $C_k \approx -1$ 。

### 2.5 牛顿迭代

本征值无闭式解，使用牛顿法数值求解。

**对称**： $f(\lambda) = \tan(\lambda/2) + \tanh(\lambda/2)$

$$
f'(\lambda) = \frac{1}{2}\left[ \sec^2\!\left(\frac{\lambda}{2}\right) + \text{sech}^2\!\left(\frac{\lambda}{2}\right) \right]
$$

初值 $\lambda^{(0)} = (4k-1)\pi/2$（$k = 1, 2, \dots$） ，迭代：

$$
\lambda^{(n+1)} = \lambda^{(n)} - \frac{f(\lambda^{(n)})}{f'(\lambda^{(n)})}
$$

**反对称**： $f(\mu) = \tan(\mu/2) - \tanh(\mu/2)$

$$
f'(\mu) = \frac{1}{2}\left[ \sec^2\!\left(\frac{\mu}{2}\right) - \text{sech}^2\!\left(\frac{\mu}{2}\right) \right]
$$

初值 $\mu^{(0)} = (4k-3)\pi/2 (k = 1, 2, \dots)$ ，迭代同上。

5 次迭代即可收敛至机器精度。

---

## 3. 方板本征模

### 3.1 构造

$$
\Psi_{ij}(x, y) = X_i(x) \cdot X_j(y) + s_{ij} \cdot X_j(x) \cdot X_i(y)
$$

叠加符号 $s_{ij}$ 由梁模对称性决定：

$$
s_{ij} = \begin{cases}
+1 & i + j \text{ 为偶数（同奇偶 → 对称组合）} \\
-1 & i + j \text{ 为奇数（异奇偶 → 反对称组合）}
\end{cases}
$$

### 3.2 共振频率

薄板的共振频率近似满足：

$$
f_{ij} \propto \lambda_i^2 + \lambda_j^2
$$

其中 $\lambda_i$ 为第 $i$ 阶梁模的本征值（对称模和反对称模统一记为 $\lambda$ ）。

本实现按此关系对本征模排序，低 $f$ 对应低阶简单图案，高 $f$ 对应高阶复杂图案。

### 3.3 与纯余弦近似的对比

| 特性 | 纯余弦 | 梁函数 |
|------|--------|--------|
| 公式 | $\cos(n\pi x)\cos(m\pi y) \pm \cos(m\pi x)\cos(n\pi y)$ | $X_i(x)X_j(y) \pm X_j(x)X_i(y)$ |
| 自由边界 | 不满足 | **满足** |
| 边缘振幅 | 强制为零或很大（取决于相位） | 物理正确 |
| 节线形状 | 直线 | **弯曲** |
| $n=m$ 退化 | 差分模式退化 | **无退化**（全有效） |
| X 形对角线 artifact | 差分模式恒存 | **不存在** |
| 高阶模 | cosh 爆炸需归一化 | 自然有界 |

---

## 4. 梯度推导

### 4.1 梁函数梯度

对称模 $(k$ 偶 $)$ ：

$$
\begin{aligned}
X_k(x) &= \cos(\lambda_k x) + C_k \cosh(\lambda_k x) \\
X_k'(x) &= -\lambda_k \sin(\lambda_k x) + C_k \lambda_k \sinh(\lambda_k x)
\end{aligned}
$$

反对称模 $(k$ 奇 $)$ ：

$$
\begin{aligned}
X_k(x) &= \sin(\mu_k x) + C_k \sinh(\mu_k x) \\
X_k'(x) &= \mu_k \cos(\mu_k x) + C_k \mu_k \cosh(\mu_k x)
\end{aligned}
$$

### 4.2 方板本征模梯度

$$
\Psi(x,y) = X_i(x) X_j(y) + s \cdot X_j(x) X_i(y)
$$

偏导数：

$$
\begin{aligned}
\frac{\partial\Psi}{\partial x} &= X_i'(x) X_j(y) + s \cdot X_j'(x) X_i(y) \\[6pt]
\frac{\partial\Psi}{\partial y} &= X_i(x) X_j'(y) + s \cdot X_j(x) X_i'(y)
\end{aligned}
$$

带缩放 $z$ （zoom），坐标变换 $cx = (u_x - 0.5) \cdot z$ ：

$$
\frac{\partial\Psi}{\partial u_x} = z \cdot \frac{\partial\Psi}{\partial(cx)}
$$

---

## 5. 粒子物理模型

粒子在板上的运动模拟沙粒在振动板上的行为：

**每帧更新的物理规则**：

1. 计算局部振动幅度： $\text{vib} = |\Psi(p_x, p_y)|$
2. 随机跳跃： $\Delta p_{\text{rand}} = \xi \cdot \text{vib} \cdot S$（$\xi$ 为单位随机向量，$S$ = `step_scale`）
3. 梯度漂移： $\Delta p_{\text{drift}} = -\text{sgn}(\Psi) \cdot \nabla\Psi \cdot D \cdot \Delta t \cdot \text{vib}$ （ $D$ = `drift_speed`）
4. 边界反射： $p \leftarrow \text{reflect}(p)$

**漂移方向原理**：节线在 $\Psi = 0$ 处，梯度 $\nabla\Psi$ 指向 $\Psi$ 增大的方向。

- $\Psi > 0$ 的区域：粒子需向 $\Psi$ 减小方向移动 → $-\nabla\Psi$
- $\Psi < 0$ 的区域：粒子需向 $\Psi$ 增大方向移动 → $+\nabla\Psi$
- 统一表达式：$-\text{sgn}(\Psi) \cdot \nabla\Psi$

---

## 6. 实现架构

### 6.1 项目结构

```text
chladni/
├── SConstruct                  # C++ 构建脚本
├── godot-cpp/                  # Godot C++ 绑定（git submodule）
├── src/                        # C++ GDExtension 源码
│   ├── particle_solver.h
│   ├── particle_solver.cpp
│   └── register_types.cpp
├── docs/                       # 文档
├── tmp/                        # 临时文件
└── project/                    # Godot 项目
    ├── project.godot
    ├── demo.tscn               # 主场景
    ├── scripts/
    │   └── demo_controller.gd  # 场景控制脚本
    ├── scenes/                 # UI 组件场景
    │   ├── audio_ctrl.gd / .tscn
    │   ├── amplitude_container.gd / .tscn
    │   └── param_controller.gd / .tscn
    ├── addons/
    │   └── chladni_pattern/    # GDExtension 插件
    │       ├── chladni.gdextension
    │       ├── plugin.cfg / plugin.gd
    │       ├── bin/            # 编译产物 (.dll / .wasm)
    │       ├── scenes/
    │       │   └── chladni_view.tscn
    │       └── scripts/
    │           ├── chladni_view.gd       # ChladniView 外观类
    │           ├── compute_component.gd  # ComputeComponent
    │           └── particle_view.gd      # ParticleView
    ├── ogg/
    └── img/
```

### 6.2 系统流程

```text
AudioStreamPlayer → SpectrumAnalyzer → band_mags[]
    → 找到主导频段 → 查 beam 模表 → (i, j, sign) 当前模式
    → GDScript 调用 solver.update() → C++ 粒子物理热循环
    → solver.get_positions() → Image 渲染 → TextureRect 显示
```

### 6.3 预计算（GDScript，`_ready()`）

1. `_compute_beam_table()`：牛顿法求解 `mode_max_order` 个本征值及系数
2. `_build_mode_table()`：枚举所有 $(i,j)$ 对，按 $\lambda_i^2 + \lambda_j^2$ 排序，均匀采样 `band_count` 个模式
3. 梁系数表通过 `solver.set_beam_lam()` / `solver.set_beam_coeff()` 同步到 C++ 侧

### 6.4 热路径（C++ GDExtension）

每帧 GDScript 调用 `solver.update(delta, i, j, sign, ...)` → C++ 侧 `ParticleSolver::update()`：

- `beam_val_deriv()` 单次调用同时返回值和导数（合并 cos/sin/cosh/sinh）
- 4 次 `beam_val_deriv` 覆盖 $X_i(cx), X_j(cy), X_j(cx), X_i(cy)$ 的全部值和导数
- $\psi$ 和 $\nabla\psi$ 从已计算的值/导数组合得到，无需额外超越函数调用
- 每粒子 **16 次超越函数**（vs GDScript 原版的 24 次）

### 6.5 构建

```bash
cd chladni
scons platform=windows target=template_debug -j8   # 编辑器调试
scons platform=windows target=template_release -j8  # 发布
```

产物输出至 `project/addons/chladni_pattern/bin/`。

### 6.6 性能

| 指标 | GDScript（旧） | C++ GDExtension（新） |
|------|---------------|---------------------|
| 物理更新 (4096 粒子) | ~15 ms | ~1.2 ms |
| 帧预算占比 (60 FPS) | ~90% | ~7% |
| 加速比 | 1× | **~12×** |

---

## 7. 与真实实验的对应

| 实验操作 | 软件对应 |
|----------|----------|
| 调节信号发生器频率 | 音频频谱分析 → 主导频段选择 |
| 板子在某频率共振 | 频段 → 查表 → 离散 $(i,j)$ 本征模 |
| 扫频时模式跳变 | 频段切换 → 离散本征模跳变 |
| 沙子聚集到节线 | 粒子漂移 + 随机跳跃 → 涌现节线图案 |
| 边缘自由振动 | 梁函数满足自由边界，边缘 $\Psi \neq 0$ |
| 节线弯曲 | 梁函数 cosh 项 → 非正弦振动形态 |
