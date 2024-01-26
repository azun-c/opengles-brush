precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform vec2 PixelTex;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

void main(void)
{
    gl_FragColor = texture2D(Sampler0, TextureCoordOut);
//    gl_FragColor = DestinationColor;
}
