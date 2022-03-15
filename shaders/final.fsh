#version 150
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader5 : enable

layout(location = 0) out vec3 color;

uniform sampler2D colortex1;
uniform sampler2D colortex5;

uniform vec2 viewSize;

uniform int frameCounter;

in vec2 textureCoordinate;

/*
    const int colortex1Format = RGBA32F;
    const int colortex3Format = RGBA32F;
    const int colortex4Format = RGBA32F;
    const int colortex5Format = RGBA32F;
*/

#include "/lib/utility/universal.glsl"
#include "/lib/rng/bayer.glsl"

const mat3x3 ACESInputMat = mat3(
    0.59719, 0.35458, 0.04823,
    0.07600, 0.90834, 0.01566,
    0.02840, 0.13383, 0.83777
);

const mat3x3 ACESOutputMat = mat3(
     1.60475, -0.53108, -0.07367,
    -0.10208,  1.10813, -0.00605,
    -0.00327, -0.07276,  1.07602
);

vec3 RRTAndODTFit(vec3 v) {
    vec3 a = v * (v + 0.0245786f) - 0.000090537f;
    vec3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
    return a / b;
}

vec3 ACESFitted(vec3 color) {
    color = color * ACESInputMat;
    color = RRTAndODTFit(color);
    color = color * ACESOutputMat;
    color = saturate(color);

    return color;
}

void main() {
    color = texture(colortex1, textureCoordinate).rgb;
    color = ACESFitted(color);
    color = LinearToSrgb(color);
    color += Bayer32(gl_FragCoord.st) / 64.0;
}