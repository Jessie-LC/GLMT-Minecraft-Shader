#version 150
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader5 : enable

layout(location = 0) out vec4 color;

#define POLARIZATION 0 //[0 1 2]
#define RADIUS_UM 1.0 //[0.001 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]
#define MAX_MIE_RESOLUTION 90 //[10 30 90 300 400 500] As particle radius increases this should also increase.

#define DARKENING 10.0 //[10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0 90.0 100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0]

uniform sampler2D colortex1;
uniform sampler2D colortex4;

uniform float viewHeight;

uniform int frameCounter;

in vec2 textureCoordinate;

const bool colortex1Clear = false;

#include "/lib/utility/universal.glsl"
#include "/lib/rng/lowbias32.glsl"

/* DRAWBUFFERS:1 */
void main() {
	uint seed = uint(gl_FragCoord.x * viewHeight + gl_FragCoord.y);
	     seed = seed * 720720u + uint(frameCounter);

    InitRand(seed);

    float frames = texture(colortex1, textureCoordinate).a;
    vec3 previousColor = texture(colortex1, textureCoordinate).rgb;

    float wl = mix(390.0, 831.0, RandNextF());

    vec3 spectral = SpectrumToXYZ(vec3(texture(colortex4, vec2(acos(-2.0 * textureCoordinate.x + 1.0) / pi, (wl - 390.0) / 441.0)).r), wl) * xyzToRGBMatrix;

    color.rgb = mix(previousColor, spectral, 1.0 / (frames += 1.0));

    color.a = frames;
}