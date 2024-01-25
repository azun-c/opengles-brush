precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform vec2 PixelTex;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

void main(void)
{
    vec4 dstColor = texture2D(Sampler0, TextureCoordOut);
    vec4 srcColor = texture2D(Sampler1, TextureCoordOut);
    
    if(dstColor.a == 0.0 && srcColor.a == 0.0) discard;
    
    float newAlpha = dstColor.a + srcColor.a - dstColor.a*srcColor.a;
    float blendAlpha = srcColor.a/newAlpha;
    vec3 resultColor = (1.0 - blendAlpha)*dstColor.rgb + blendAlpha*srcColor.rgb;
    
    gl_FragColor = vec4(resultColor, newAlpha);
}
