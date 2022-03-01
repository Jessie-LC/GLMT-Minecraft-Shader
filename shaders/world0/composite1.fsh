#version 150
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader5 : enable

layout(location = 0) out vec4 color;

uniform sampler2D colortex1;
uniform sampler2D colortex4;

uniform vec2 viewSize;

uniform int frameCounter;

in vec2 textureCoordinate;

const bool colortex1Clear = false;

#include "/lib/utility/universal.glsl"
#include "/lib/rng/lowbias32.glsl"

/* DRAWBUFFERS:1 */
void main() {
	uint seed = uint(gl_FragCoord.x * viewSize.y + gl_FragCoord.y);
	     seed = seed * 720720u + uint(frameCounter);

    InitRand(seed);

    float frames = texture(colortex1, textureCoordinate).a;
    vec3 previousColor = texture(colortex1, textureCoordinate).rgb;

    float wl = mix(390.0, 831.0, RandNextF());

    vec3 spectral = SpectrumToXYZ(vec3(texture(colortex4, vec2(acos(-2.0 * textureCoordinate.x + 1.0) / pi, (wl - 390.0) / 441.0)).r), wl) * xyzToRGBMatrix;

    color.rgb = mix(previousColor, spectral, 1.0 / (frames += 1.0));

    color.a = frames;
}