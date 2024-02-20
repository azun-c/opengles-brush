precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform sampler2D Sampler0;

void main(void)
{
    gl_FragColor = texture2D(Sampler0, TextureCoordOut);
}
