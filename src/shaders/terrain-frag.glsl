#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

//from IQ 
vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

// Gradient Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/XdXGW8
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

const vec4 redColor = vec4(255.0, 0.0, 0.0, 255.0) / 255.0; 
const vec4 greenColor = vec4(0.0, 255.0, 0.0, 255.0) / 255.0; 
const vec4 blueColor = vec4(0.0, 0.0, 255.0, 255.0) / 255.0; 

//spiky mountains with rivers between them 
vec4 mountainsColor() {

    //do this based on height (which is fs_Sine)
    vec4 returnColor = vec4(0.0); 
    if (fs_Sine > 0.5) {
        returnColor = redColor; 

    } else {
        returnColor = blueColor; 

    }

    return returnColor; 

}

void main()
{
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    out_Col = vec4(mix(vec3(0.5 * (fs_Sine + 1.0)), vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);

   // out_Col = vec4(0.0, 0.0, 255.0, 255.0) / 255.0;  
}
