#version 150
#extension GL_ARB_compute_shader : enable
#extension GL_ARB_shader_image_load_store : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader5 : enable

#define POLARIZATION 0 //[0 1 2]
#define RADIUS_UM 1.0 //[0.001 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]
#define MAX_MIE_RESOLUTION 50 //[10 20 30 40 50 60 70 80 90 100 200 300 400 500] As particle radius increases this should also increase.

#define DARKENING 10.0 //[10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0 90.0 100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0]

layout (local_size_x = 16, local_size_y = 16) in;
const ivec3 workGroups = ivec3(16, 16, 1);

layout (rgba32f) uniform image2D colorimg4;

uniform sampler2D colortex5;

uniform vec2 viewSize;

uniform int frameCounter;

#include "/lib/utility/universal.glsl"

float ComputeGeneralizedMieTheory(in float theta, in float lambda, in float radius, in complexFloat iorHost, in complexFloat iorParticle, out float Csca) {
    const int M = MAX_MIE_RESOLUTION;

    complexFloat hostZ = complexDiv(complexMul(2.0 * pi * radius, iorHost), complexFloat(lambda, 0.0));
    complexFloat particleZ = complexDiv(complexMul(2.0 * pi * radius, iorParticle), complexFloat(lambda, 0.0));

    complexFloat hostA[M + 2];
    complexFloat particleA[M + 2];
    hostA[M + 1] = complexFloat(1.0, 0.0);
    particleA[M + 1] = complexFloat(1.0, 0.0);
    for(int n = M; n >= 0; --n) {
        complexFloat tmpHost = complexDiv(complexFloat(float(n) + 1.0, 0.0), hostZ);
        complexFloat tmpParticle = complexDiv(complexFloat(float(n) + 1.0, 0.0), particleZ);

        hostA[n] = complexSub(tmpHost, complexDiv(complexFloat(1.0, 0.0), complexAdd(tmpHost, hostA[n + 1])));
        particleA[n] = complexSub(tmpParticle, complexDiv(complexFloat(1.0, 0.0), complexAdd(tmpParticle, particleA[n + 1])));
    }

    complexFloat B       = complexFloat(0.0, 1.0);
    complexFloat psiZeta = complexMul(complexFloat(0.5, 0.0), complexSub(1.0, complexExp(complexFloat(-2.0 * hostZ.i, 2.0 * hostZ.r))));
    complexFloat ratio   = complexMul(complexFloat(0.5, 0.0), complexSub(1.0, complexExp(complexFloat(2.0 * hostZ.i, -2.0 * hostZ.r))));
    complexFloat a[M];
    complexFloat b[M];
    for(int n = 1; n < M; ++n) {
        complexFloat n_z = complexDiv(complexFloat(float(n), 0.0), hostZ);
        psiZeta = complexMul(psiZeta, complexMul(complexSub(n_z, hostA[n - 1]), complexSub(n_z, B)));
        B = complexAdd(hostA[n], complexDiv(complexFloat(0.0, 1.0), psiZeta));
        ratio = complexMul(ratio, complexDiv(complexAdd(B, n_z), complexAdd(hostA[n], n_z)));

        a[n] = complexMul(
            ratio,
            complexDiv(
                complexSub(
                    complexMul(
                        iorHost,
                        particleA[n]
                    ),
                    complexMul(
                        iorParticle,
                        hostA[n]
                    )
                ),
                complexSub(
                    complexMul(
                        iorHost,
                        particleA[n]
                    ),
                    complexMul(
                        iorParticle,
                        B
                    )
                )
            )
        );
        b[n] = complexMul(
            ratio,
            complexDiv(
                complexSub(
                    complexMul(
                        iorParticle,
                        particleA[n]
                    ),
                    complexMul(
                        iorHost,
                        hostA[n]
                    )
                ),
                complexSub(
                    complexMul(
                        iorParticle,
                        particleA[n]
                    ),
                    complexMul(
                        iorHost,
                        B
                    )
                )
            )
        );
    }

    float cosTheta = cos(theta);

    complexFloat SSenkrecht;
    complexFloat SParallel;
    float sum = 0.0;
    for(int n = 1; n < M; ++n) {
        float PiN = texelFetch(colortex5, ivec2(degrees(theta) - 0.5, n), 0).r;//ComputePi(cosTheta, n);
        float TauN = texelFetch(colortex5, ivec2(degrees(theta) - 0.5, n), 0).g;//ComputeTau(cosTheta, n);

        float tmp = (2.0 * n + 1.0) / (n * (n + 1.0));
        SSenkrecht = complexAdd(
            SSenkrecht,
            complexAdd(
                complexMul(a[n], PiN),
                complexMul(b[n], TauN)
            )
        );
        SParallel = complexAdd(
            SParallel,
            complexAdd(
                complexMul(a[n], TauN),
                complexMul(b[n], PiN)
            )
        );
        sum += (2.0 * n + 1.0) * (square(complexAbs(a[n])) + square(complexAbs(b[n])));
    }
    complexFloat k = complexDiv(complexMul(2.0 * pi, iorHost), complexFloat(lambda, 0.0));

	float alpha = 4.0 * pi * radius * iorHost.i / lambda;
	float y = alpha < 10e-6 ? 1.0 : (2.0 * (1.0 + (alpha - 1.0) * exp(alpha))) / pow(alpha, 2.0);
	float term1 = pow(lambda, 2.0) * exp(-alpha);
	float term2 = 2.0 * pi * y * square(complexAbs(iorHost));

    Csca = term1 / term2 * sum;

    #if POLARIZATION == 0
        return (square(complexAbs(SSenkrecht)) + square(complexAbs(SParallel))) / (2.0 * square(complexAbs(k)) * Csca);
    #elif POLARIZATION == 1
        return square(complexAbs(SSenkrecht)) / (1.0 * square(complexAbs(k)) * Csca);
    #elif POLARIZATION == 2
        return square(complexAbs(SParallel)) / (1.0 * square(complexAbs(k)) * Csca);
    #endif
}

void main() {
    ivec2 fragCoord = ivec2(gl_GlobalInvocationID.xy);

    float lambda = mix(3.9e-7, 8.31e-7, fragCoord.y / 441.0);
    float radius = RADIUS_UM * 1e-6;
    float theta = fragCoord.x * (pi / 179.0);

    complexFloat iorHost = complexFloat(1.00028, 0.0);
    complexFloat iorParticle = complexFloat(mix(1.320, 1.350, fragCoord.y / 441.0), mix(1e-9, 4e-8, fragCoord.y / 441.0));

    float Csca = 0.0;
    float phase = ComputeGeneralizedMieTheory(theta, lambda, radius, iorHost, iorParticle, Csca);

    imageStore(colorimg4, ivec2(fragCoord), vec4(phase / DARKENING));
}