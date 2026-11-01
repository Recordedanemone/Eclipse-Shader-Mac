#version 430 compatibility

#define RENDER_SETUP

#include "/lib/settings.glsl"

// Vitrail never runs the setup stage, so the block light table is filled here every frame instead
#ifdef VITRAIL
	#include "/dimensions/setup.csh"
#else
	layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
	const ivec3 workGroups = ivec3(1, 1, 1);
	void main() {}
#endif
