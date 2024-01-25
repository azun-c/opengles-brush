attribute vec4 Position;
attribute vec2 TextureCoord;

varying vec4 DestinationColor;
varying vec2 TextureCoordOut;

uniform vec4 DrawColor;
uniform mat4 Projection;
uniform mat4 Modelview;

void main(void)
{
    DestinationColor = DrawColor;
    gl_Position = Projection * Modelview * Position;
    TextureCoordOut = TextureCoord;
}
