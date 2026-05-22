#include "particle_solver.h"
#include <godot_cpp/core/class_db.hpp>
#include <cmath>

namespace chladni {

void ParticleSolver::resize(int count) {
	m_particle_count = count;
	m_positions.resize(count);
	if (m_rng.is_null()) {
		m_rng.instantiate();
		m_rng->randomize();
	}
	godot::Vector2* ptr = m_positions.ptrw();
	for (int i = 0; i < count; ++i) {
		ptr[i] = godot::Vector2(m_rng->randf(), m_rng->randf());
	}
}

void ParticleSolver::set_beam_lam(const godot::PackedFloat32Array& arr) {
	m_beam_lam = arr;
}

void ParticleSolver::set_beam_coeff(const godot::PackedFloat32Array& arr) {
	m_beam_coeff = arr;
}

void ParticleSolver::set_zoom(float z) {
	m_zoom = z;
}

float ParticleSolver::get_zoom() const {
	return m_zoom;
}

godot::PackedVector2Array ParticleSolver::get_positions() const {
	return m_positions;
}

godot::PackedVector2Array ParticleSolver::update(
	float delta,
	int b_i, int b_j, int b_sign,
	float step_scale, float drift_speed, float respawn_rate
) {
	const int N = m_particle_count;
	if (N == 0) return m_positions;

	const float* lam   = m_beam_lam.ptr();
	const float* coeff = m_beam_coeff.ptr();
	godot::Vector2* pos = m_positions.ptrw();

	const float z = m_zoom;
	const float z_half_offset = 0.5f * z;

	for (int i = 0; i < N; ++i) {
		float px = pos[i].x;
		float py = pos[i].y;

		const float cx = px * z - z_half_offset;
		const float cy = py * z - z_half_offset;

		auto v1 = beam_val_deriv(b_i, cx, lam, coeff);
		auto v2 = beam_val_deriv(b_j, cy, lam, coeff);
		auto v3 = beam_val_deriv(b_j, cx, lam, coeff);
		auto v4 = beam_val_deriv(b_i, cy, lam, coeff);

		const float psi = v1.val * v2.val + static_cast<float>(b_sign) * v3.val * v4.val;
		const float vib = std::fabs(psi);

		px += (m_rng->randf() - 0.5f) * vib * step_scale;
		py += (m_rng->randf() - 0.5f) * vib * step_scale;

		if (vib > 0.001f) {
			const float dx = (v1.deriv * v2.val + static_cast<float>(b_sign) * v3.deriv * v4.val) * z;
			const float dy = (v1.val   * v2.deriv + static_cast<float>(b_sign) * v3.val   * v4.deriv) * z;

			const float sign_psi = (psi >= 0.0f) ? 1.0f : -1.0f;
			px += -sign_psi * dx * drift_speed * delta * vib;
			py += -sign_psi * dy * drift_speed * delta * vib;
		}

		pos[i].x = reflect(px);
		pos[i].y = reflect(py);
	}

	const int respawn_count = static_cast<int>(N * respawn_rate);
	for (int j = 0; j < respawn_count; ++j) {
		int idx = m_rng->randi() % N;
		pos[idx].x = m_rng->randf();
		pos[idx].y = m_rng->randf();
	}

	return m_positions;
}

void ParticleSolver::_bind_methods() {
	using namespace godot;
	ClassDB::bind_method(D_METHOD("resize", "count"), &ParticleSolver::resize);
	ClassDB::bind_method(D_METHOD("set_beam_lam", "arr"), &ParticleSolver::set_beam_lam);
	ClassDB::bind_method(D_METHOD("set_beam_coeff", "arr"), &ParticleSolver::set_beam_coeff);
	ClassDB::bind_method(D_METHOD("set_zoom", "z"), &ParticleSolver::set_zoom);
	ClassDB::bind_method(D_METHOD("get_zoom"), &ParticleSolver::get_zoom);
	ClassDB::bind_method(D_METHOD("get_positions"), &ParticleSolver::get_positions);
	ClassDB::bind_method(D_METHOD("update", "delta", "b_i", "b_j", "b_sign",
		"step_scale", "drift_speed", "respawn_rate"), &ParticleSolver::update);
}

} // namespace chladni
