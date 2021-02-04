#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;
in float fbm_val; 

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

//mapping function to map something from min max to another min max 
//reference: https://gamedev.stackexchange.com/questions/147890/is-there-an-hlsl-equivalent-to-glsls-map-function 
float map_range(float v, float min1, float max1, float min2, float max2) {
        // Convert the current value to a percentage
    // 0% - min1, 100% - max1
    float perc = (v - min1) / (max1 - min1);

    // Do the same operation backwards with min2 and max2
    float newV = perc * (max2 - min2) + min2;

    return newV; 
}

//returns a color mapped to white and black 
//given your current color in greyscale and the colors you want to interpolate between returns a color 
vec4 whiteBlackMap(vec4 currColor, vec4 newBlack, vec4 newWhite, float lowerBound, float upperBound) {
    float val1 = map_range(currColor.x, lowerBound, upperBound, newBlack.x, newWhite.x); // 0, 1 is black, white
    float val2 = map_range(currColor.y, lowerBound, upperBound, newBlack.y, newWhite.y); 
    float val3 = map_range(currColor.z, lowerBound, upperBound, newBlack.z, newWhite.z); 

    vec4 returnValue = vec4(val1, val2, val3, 1.0); 

    return returnValue; 


}

//color for demonic mountains 
vec4 demonicMountainColor() {
    vec4 returnColor = vec4(0.0); 
    float t = 0.0; 
    if (fbm_val > -0.5) {
        t = smoothstep(0.75, 1.0, fbm_val / 0.2); 
        returnColor = mix(redColor, greenColor, t); 

    } else {
        t = fbm_val / 0.5; 
        float noiseVal = t + noise((fs_Pos.xz + u_PlanePos) * 0.25); 
        returnColor = mix(greenColor, blueColor, noiseVal); 
       // returnColor = blueColor; 

    }

    return returnColor; 

}

vec4 test() {
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog

   // vec3 exampleVec = vec3(164.0 / 255.0, 233.0 / 255.0, 1.0); 
    vec3 exampleVec = vec3(0.0 / 255.0, 0.0 / 255.0, 1.0); 


    vec4 returnColor = vec4(mix(vec3(0.5 * (fbm_val + 1.0)), exampleVec, t), 1.0); //REPLACE fs_Sine with fbm_val for some funky coloring'

    vec4 greyColor = vec4(64.0, 64.0, 64.0, 255.0) / 255.0; 
    vec4 redColor = vec4(204.0, 0.0, 0.0, 255.0) / 255.0; 
    returnColor = whiteBlackMap(returnColor, redColor, greyColor, 0.3, 1.0); 

    if (fbm_val < 0.1) {
        //returnColor *= 3.0; 
        returnColor.w = 1.0; 

    } else {
        t = fbm_val / 0.5; 
        float noiseVal = t + noise((fs_Pos.xz + u_PlanePos) * 0.25); 
        //returnColor = mix(greenColor, blueColor, noiseVal); 
       // returnColor = blueColor; 

    }


    return returnColor; 
}

void main()
{
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    out_Col = vec4(mix(vec3(0.5 * (fs_Sine + 1.0)), vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);

  // out_Col = demonicMountainColor(); 
 // out_Col = test(); 
}
