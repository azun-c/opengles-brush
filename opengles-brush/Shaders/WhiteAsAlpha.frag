precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform vec2 PixelTex;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

void main(void)
{
    float alpha = texture2D(Sampler0, TextureCoordOut).r;
    gl_FragColor = vec4(DestinationColor.x, DestinationColor.y, DestinationColor.z, DestinationColor.w*alpha);
}
