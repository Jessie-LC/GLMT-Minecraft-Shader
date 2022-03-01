#version 150
#extension GL_ARB_compute_shader : enable
#extension GL_ARB_shader_image_load_store : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader5 : enable

layout (local_size_x = 16, local_size_y = 16) in;
const ivec3 workGroups = ivec3(16, 16, 1);

layout (rgba32f) uniform image2D colorimg5;

uniform vec2 viewSize;

uniform int frameCounter;

#include "/lib/utility/universal.glsl"

float Pn(float x, int n) {
	if (n == 0) {
		return 1.0;
	}
	else {
		float currentR2 = 1.0;
		float currentR1 = x;
		for (int currentN = 2; currentN <= n; currentN++) {
			float currentR = ((2 * currentN - 1) * x * currentR1 - (currentN - 1) * currentR2) / currentN;
			currentR2 = currentR1;
			currentR1 = currentR;
		}
		return currentR1;
	}
}

float DerivativeLegendre(int n, float x) {
	if (n == 0) {
		return 0.0;
	}
	else {
		float currentR2 = 1.0;
		float dcurrentR2dx = 0.0;
		float currentR1 = x;
		float dcurrentR1dx = 1.0;
		for (int currentN = 2; currentN <= n; currentN++) {
			float currentR = ((2 * currentN - 1) * x * currentR1 - (currentN - 1) * currentR2) / currentN;
			float dcurrentRdx = ((2 * currentN - 1) * (currentR1 + x * dcurrentR1dx) - (currentN - 1) * dcurrentR2dx) / currentN;
			currentR2 = currentR1;
			dcurrentR2dx = dcurrentR1dx;
			currentR1 = currentR;
			dcurrentR1dx = dcurrentRdx;
		}
		return dcurrentR1dx;
	}
}

float ComputePi(float mu, int n) {
	return DerivativeLegendre(n, mu);
}

float DerivativePi(float x, int n) {
	if (n == 0) {
		return 0.0;
	}
	else {
		float currentR2 = 1.0;
		float dcurrentR2dx = 0.0;
		float d2currentR2dx = 0.0;
		float currentR1 = x;
		float dcurrentR1dx = 1.0;
		float d2currentR1dx = 0.0;
		for (int currentN = 2; currentN <= n; currentN++) {
			float currentR = ((2 * currentN - 1) * x * currentR1 - (currentN - 1) * currentR2) / currentN;
			float dcurrentRdx = ((2 * currentN - 1) * (currentR1 + x * dcurrentR1dx) - (currentN - 1) * dcurrentR2dx) / currentN;
			float d2currentRdx = ((2 * currentN - 1) * (dcurrentR1dx + (dcurrentR1dx + x * d2currentR1dx)) - (currentN - 1) * d2currentR2dx) / currentN;
			currentR2 = currentR1;
			dcurrentR2dx = dcurrentR1dx;
			d2currentR2dx = d2currentR1dx;
			currentR1 = currentR;
			dcurrentR1dx = dcurrentRdx;
			d2currentR1dx = d2currentRdx;
		}
		return d2currentR1dx;
	}
}

float ComputeTau(float mu, int n) {
	float mu_sin = sin(acos(mu));
	return mu * ComputePi(mu, n) - pow(mu_sin, 2.0) * DerivativePi(mu, n);
}

void main() {
    ivec2 fragCoord = ivec2(gl_GlobalInvocationID.xy);

    float theta = fragCoord.x * (pi / 179.0);

    float PiN = ComputePi(cos(theta), fragCoord.y);
    float TauN = ComputeTau(cos(theta), fragCoord.y);

    imageStore(colorimg5, ivec2(fragCoord), vec4(PiN, TauN, 1.0, 0.0));
}