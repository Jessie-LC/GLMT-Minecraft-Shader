#version 150

in vec4 vaPosition;
in vec2 vaUV0;

out vec2 textureCoordinate;

void main() {
    gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);

    textureCoordinate = vaUV0;
}