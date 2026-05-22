#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include "particle_solver.h"

namespace chladni {

void initialize_particle_solver(godot::ModuleInitializationLevel p_level) {
	if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	godot::ClassDB::register_class<ParticleSolver>();
}

void uninitialize_particle_solver(godot::ModuleInitializationLevel p_level) {}

extern "C" {
GDExtensionBool GDE_EXPORT chladni_init(
	GDExtensionInterfaceGetProcAddress p_get_proc_address,
	GDExtensionClassLibraryPtr p_library,
	GDExtensionInitialization* r_initialization
) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
	init_obj.register_initializer(initialize_particle_solver);
	init_obj.register_terminator(uninitialize_particle_solver);
	init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);
	return init_obj.init();
}
}

} // namespace chladni
