precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform vec2 PixelTex;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

void main(void)
{
    vec4 texColor = texture2D(Sampler0, TextureCoordOut);

    vec2 texCodU = vec2(TextureCoordOut.x, TextureCoordOut.y - PixelTex.y);
    vec4 texColorU = texture2D(Sampler0, texCodU);
    
    vec2 texCodD = vec2(TextureCoordOut.x, TextureCoordOut.y + PixelTex.y);
    vec4 texColorD = texture2D(Sampler0, texCodD);

    vec2 texCodL = vec2(TextureCoordOut.x - PixelTex.x, TextureCoordOut.y);
    vec4 texColorL = texture2D(Sampler0, texCodL);

    vec2 texCodR = vec2(TextureCoordOut.x + PixelTex.x, TextureCoordOut.y);
    vec4 texColorR = texture2D(Sampler0, texCodR);

//    gl_FragColor = (texColor + texColorU + texColorD + texColorL + texColorR)/5.0;

    vec2 texCodUL = vec2(TextureCoordOut.x - PixelTex.x, TextureCoordOut.y - PixelTex.y);
    vec4 texColorUL = texture2D(Sampler0, texCodUL);

    vec2 texCodUR = vec2(TextureCoordOut.x + PixelTex.x, TextureCoordOut.y - PixelTex.y);
    vec4 texColorUR = texture2D(Sampler0, texCodUR);

    vec2 texCodDL = vec2(TextureCoordOut.x - PixelTex.x, TextureCoordOut.y + PixelTex.y);
    vec4 texColorDL = texture2D(Sampler0, texCodDL);

    vec2 texCodDR = vec2(TextureCoordOut.x + PixelTex.x, TextureCoordOut.y + PixelTex.y);
    vec4 texColorDR = texture2D(Sampler0, texCodDR);

    // 3x3 ガウスフィルタ
    gl_FragColor = (texColorUL + 2.0*texColorU + texColorUR + 2.0*texColorL + 4.0*texColor + 2.0*texColorR + texColorDL + 2.0*texColorD + texColorDR)/16.0;
}