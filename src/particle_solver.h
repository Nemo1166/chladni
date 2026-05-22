#ifndef PARTICLE_SOLVER_H
#define PARTICLE_SOLVER_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>

namespace chladni {

class ParticleSolver : public godot::RefCounted {
	GDCLASS(ParticleSolver, godot::RefCounted)

private:
	godot::PackedVector2Array m_positions;
	godot::PackedFloat32Array m_beam_lam;
	godot::PackedFloat32Array m_beam_coeff;
	godot::Ref<godot::RandomNumberGenerator> m_rng;
	float m_zoom = 1.0f;
	int m_particle_count = 0;

	struct BeamValDeriv { float val; float deriv; };

	static inline BeamValDeriv beam_val_deriv(
		int k, float x,
		const float* lam_table, const float* coeff_table
	) noexcept {
		const float lam = lam_table[k];
		const float C   = coeff_table[k];
		const float lx  = lam * x;

		if (k & 1) {
			const float s  = sinf(lx);
			const float sh = sinhf(lx);
			const float c  = cosf(lx);
			const float ch = coshf(lx);
			return { s + C * sh, lam * (c + C * ch) };
		} else {
			const float c  = cosf(lx);
			const float ch = coshf(lx);
			const float s  = sinf(lx);
			const float sh = sinhf(lx);
			return { c + C * ch, lam * (-s + C * sh) };
		}
	}

	static inline float reflect(float v) noexcept {
		if (v < 0.0f)  return -v;
		if (v > 1.0f)  return 2.0f - v;
		return v;
	}

public:
	void resize(int count);
	void set_beam_lam(const godot::PackedFloat32Array& arr);
	void set_beam_coeff(const godot::PackedFloat32Array& arr);
	void set_zoom(float z);
	float get_zoom() const;
	godot::PackedVector2Array get_positions() const;

	godot::PackedVector2Array update(
		float delta,
		int b_i, int b_j, int b_sign,
		float step_scale, float drift_speed, float respawn_rate
	);

protected:
	static void _bind_methods();
};

} // namespace chladni
#endif
