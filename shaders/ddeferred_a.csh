#version 150
#extension GL_ARB_compute_shader : enable
#extension GL_ARB_shader_image_load_store : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader5 : enable

layout (local_size_x = 16, local_size_y = 16) in;
const ivec3 workGroups = ivec3(16, 16, 1);

layout (rgba32f) uniform image2D colorimg2;

uniform vec2 viewSize;

uniform int frameCounter;

#include "/lib/utility/universal.glsl"

#define POLARIZATION 0 //[0 1 2]
#define RADIUS_UM 1.0 //[0.001 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]
#define MAX_MIE_RESOLUTION 90 //[10 30 90 300 400 500] As particle radius increases this should also increase.

#define DARKENING 10.0 //[10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0 90.0 100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0]

void main() {
    ivec2 fragCoord = ivec2(gl_GlobalInvocationID.xy);

    float lambda = mix(3.9e-7, 8.31e-7, fragCoord.y / 441.0);
    float radius = RADIUS_UM * 1e-6;

    complexFloat iorHost = complexFloat(1.00028, 0.0);
    complexFloat iorParticle = complexFloat(mix(1.320, 1.350, fragCoord.y / 441.0), mix(1e-9, 4e-8, fragCoord.y / 441.0));

    complexFloat hostZ = complexDiv(complexMul(2.0 * pi * radius, iorHost), complexFloat(lambda, 0.0));
    complexFloat particleZ = complexDiv(complexMul(2.0 * pi * radius, iorParticle), complexFloat(lambda, 0.0));

    complexFloat hostA[1000 + 2];
    complexFloat particleA[1000 + 2];
    hostA[1000 + 1] = complexFloat(1.0, 0.0);
    particleA[M + 1] = complexFloat(1.0, 0.0);
    for(int n = M; n >= 0; --n) {
        complexFloat tmpHost = complexDiv(complexFloat(float(n) + 1.0, 0.0), hostZ);
        complexFloat tmpParticle = complexDiv(complexFloat(float(n) + 1.0, 0.0), particleZ);

        hostA[n] = complexSub(tmpHost, complexDiv(complexFloat(1.0, 0.0), complexAdd(tmpHost, hostA[n + 1])));
        particleA[n] = complexSub(tmpParticle, complexDiv(complexFloat(1.0, 0.0), complexAdd(tmpParticle, particleA[n + 1])));
    }

    imageStore(colorimg2, ivec2(fragCoord), vec4(PiN, TauN, 1.0, 0.0));
}