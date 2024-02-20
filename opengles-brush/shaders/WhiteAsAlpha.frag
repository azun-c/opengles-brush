precision mediump float;

varying lowp vec4 DestinationColor;
varying mediump vec2 TextureCoordOut;

uniform sampler2D Sampler0;

void main(void)
{
    // the texture has 2 colors (white in center, black at corners)
    // white part's color in vector vec4(1, 1, 1, 1)
    // black part's color in vector vec4(0, 0, 0, 1)
    float redComponent = texture2D(Sampler0, TextureCoordOut).r; // 1 or 0
    // the `red` component of texture's sample is `1` for white pixel and `0` for black pixel
    
    // by multiplying the `red` component with the drawing color's alpha
    // to mark a pixel as visible or hidden according to the texture: white => visible; black => hidden;
    gl_FragColor = vec4(DestinationColor.x, DestinationColor.y, DestinationColor.z,
                        DestinationColor.w * redComponent);
}
