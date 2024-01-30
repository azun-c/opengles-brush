precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform vec2 PixelTex;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

float my_rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void)
{
//    float a = my_rand(TextureCoordOut);
//    float a = rand() / (float) RAND_MAX;
    float red = texture2D(Sampler0, TextureCoordOut).r; // work
//    float red = texture2D(Sampler0, TextureCoordOut).a; // square
    gl_FragColor = vec4(DestinationColor.x, DestinationColor.y, DestinationColor.z, DestinationColor.w*red);
//    gl_FragColor = vec4(1, 0, 0, DestinationColor.w*red);
//    gl_FragColor = texture2D(Sampler0, TextureCoordOut);
}
