precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform vec2 PixelTex;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

void main(void)
{
    if (texture2D(Sampler0, TextureCoordOut).a == 0.0) discard;// アルファ値が0のものは破棄
    gl_FragColor = vec4(DestinationColor.r, DestinationColor.g, DestinationColor.b, 1.0);
}
