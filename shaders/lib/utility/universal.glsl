#include "constants.glsl"
#include "macros.glsl"
#include "complex.glsl"
#include "fastMath.glsl"
#include "functions.glsl"
#include "converters.glsl"

#if defined MC_GL_AMD_gpu_shader_half_float
    #extension GL_AMD_gpu_shader_half_float : enable
#elif defined MC_GL_NV_gpu_shader5
    #extension GL_NV_gpu_shader5 : enable
#else
    // No half-precision floating point support
    #define NO_HALF

    #define float16_t float
    #define f16vec2 vec2
    #define f16vec3 vec3
    #define f16vec4 vec4
    #define f16mat2 mat2
    #define f16mat3 mat3
    #define f16mat4 mat4
#endif