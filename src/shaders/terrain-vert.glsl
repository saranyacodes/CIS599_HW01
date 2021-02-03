#version 300 es


uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out float fs_Sine;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

//noise example from slides (Slide 5)
vec3 random1(vec3 p) {
  float a = dot(p, vec3(127.1, 311.7, 191.999));
  float b = dot(p, vec3(269.5, 183.3, 765.54));
  float c = dot(p, vec3(420.69, 631.2, 109.21)); 
  vec3 d = vec3(a, b, c); 

  vec3 e = fract(sin(d) * 43758.5453);
  return e; 

}

//noise example from slides
float random1(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); 
}

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                 dot(p, vec2(269.5,183.3))))
                 * 43758.5453);
}

//interpNoise2D from the slides (slide 11)
float interpNoise2D_1(vec2 p) {
  float x = p.x; 
  float y = p.y; 

  vec2 seed = vec2(vs_Pos.x, vs_Pos.z); //I added this as a seed (using the position x z)
  //  float x_pos = vs_Pos.x + u_PlanePos.x; 
  //  float z_pos = vs_Pos.z + u_PlanePos.y;
  seed = vec2(1.0, 1.0) * 0.5; //using this as the seed

  float intX = floor(x); 
  float fractX = fract(x); 
  float intY = floor(y); 
  float fractY = fract(y); 

  float v1 = random1(vec2(intX, intY), seed); 
  float v2 = random1(vec2(intX + 1.0, intY), seed); 
  float v3 = random1(vec2(intX, intY + 1.0), seed); 
  float v4 = random1(vec2(intX + 1.0, intY + 1.0), seed); 

  float i1 = mix(v1, v2, fractX); 
  float i2 = mix(v3, v4, fractX); 
  return mix(i1, i2, fractY); 

}

//same as interpNoise2D_1 but the random1 function is different
float interpNoise2D_2(vec2 p) {
  float x = p.x; 
  float y = p.y; 

  float intX = floor(x); 
  float fractX = fract(x); 
  float intY = floor(y); 
  float fractY = fract(y); 

   float v1 = random1(vec2(intX, intY)); 
   float v2 = random1(vec2(intX + 1.0, intY)); 
   float v3 = random1(vec2(intX, intY + 1.0)); 
   float v4 = random1(vec2(intX + 1.0, intY + 1.0)); 

  float i1 = mix(v1, v2, fractX); 
  float i2 = mix(v3, v4, fractX); 
  return mix(i1, i2, fractY); 

  return 1.0; 

}

//noised function from IQ: https://iquilezles.org/www/articles/morenoise/morenoise.htm (goes with the terrain noise function below)
vec4 noised (vec3 x) {
  vec3 p = floor(x);
    vec3 w = fract(x);
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    vec3 du = 30.0*w*w*(w*(w-2.0)+1.0);

    vec3 seed = vec3(1.0, 1.0, 1.0) * 0.5; //using this as the seed

  //random1 takes in vec3 and returns float 
    float a = random1( p+vec3(0,0,0), seed );
    float b = random1( p+vec3(1,0,0), seed );
    float c = random1( p+vec3(0,1,0), seed );
    float d = random1( p+vec3(1,1,0), seed );
    float e = random1( p+vec3(0,0,1), seed );
    float f = random1( p+vec3(1,0,1), seed );
    float g = random1( p+vec3(0,1,1), seed );
    float h = random1( p+vec3(1,1,1), seed );

     float k0 =   a;
    float k1 =   b - a;
    float k2 =   c - a;
    float k3 =   e - a;
    float k4 =   a - b - c + d;
    float k5 =   a - c - e + g;
    float k6 =   a - b - e + f;
    float k7 = - a + b + c - d + e - f - g + h;

    return vec4( -1.0+2.0*(k0 + k1*u.x + k2*u.y + k3*u.z + k4*u.x*u.y + k5*u.y*u.z + k6*u.z*u.x + k7*u.x*u.y*u.z),
                 2.0* du * vec3( k1 + k4*u.y + k6*u.z + k7*u.y*u.z,
                                 k2 + k5*u.z + k4*u.x + k7*u.z*u.x,
                                 k3 + k6*u.x + k5*u.y + k7*u.x*u.y ) );
}

//terrain noise function from IQ: https://iquilezles.org/www/articles/morenoise/morenoise.htm
float interpNoise2D_3(vec2 p) {
  mat2 m = mat2(0.8, -0.6, 0.6, 0.8); 
  float a = 0.0; 
  float b = 1.0; 
  vec2 d = vec2(0.0); 

  for (int i = 0; i < 15; i++) {
    vec3 n = vec3(noised(vec3(p, 1.0))); //noised takes in a 3d vector, so i extend this to 3d and then truncate it 
    d +=n.yz;
    a +=b*n.x/(1.0+dot(d,d));
    b *=0.5;
    p=m*p*2.0;

  }

  return a; 


}

//Worley Noise function from ShaderFun
float WorleyNoise(vec2 uv) {
    uv *= 15.0; // Now the space is 10x10 instead of 1x1. Change this to any number you want.
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);
    float minDist = 1.0; // Minimum distance initialized to max.
    int y_range = 5; 
    int x_range = 1; 
    for(int y = -y_range; y <= y_range; ++y) {
         for(int x = -x_range; x <= x_range; ++x) {
             vec2 neighbor = vec2(float(x), float(y)); // Direction in which neighbor cell lies
             vec2 point = random2(uvInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
             vec2 diff = neighbor + point - uvFract; // Distance between fragment coord and neighbor’s Voronoi point
             float dist = length(diff);
             minDist = min(minDist, dist);
         }
    }
    return minDist;
}

//voronoi function from IQ: https://iquilezles.org/www/articles/smoothvoronoi/smoothvoronoi.htm

float voronoi( vec2 x )
{
    // ivec2 p = floor( x );
     ivec2 p = ivec2(floor(x.x), floor(x.y));
     vec2  f = fract( x );

    float res = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
         ivec2 b = ivec2( i, j );
        vec2  r = vec2( b ) - f + random2( vec2(p + b) );
         float d = dot( r, r );

         res = min( res, d );
    }
    return sqrt( res );
}

//inspired by redblobgames "redistribution" https://www.redblobgames.com/maps/terrain-from-noise/#noise 
float basicNoise (vec2 p) {

  float noise1 = random1(p); 
  float noise2 = random1(vec2(p.x * 2.0, p.y * 2.0)) * 0.5; 
  float noise3 = random1(vec2(p.x * 4.0, p.y * 4.0)) * 0.25; 
  float e = noise1 + noise2 + noise3; 

  return pow(e, 1.33); 

}

//fbm noise from lecture slides 
float fbm (vec2 p) {
  float total = 0.0; 
  float persistence = 0.5f; 
  int octaves = 8; 

  for (int i = 0; i < octaves; i++) {
    float power = 2.0; 
    float freq = pow(power, float(i)); 
    float amp = pow(persistence, float(i)); 

    total += interpNoise2D_3(p * freq) * amp; //can replace interpNoise2D with any noise function that takes in a vec2 and returns a float (TODO)

    // total += interpNoise2D_2(p * freq) * amp; 

    //total += interpNoise2D_1(p * freq) * amp; 

   // total += WorleyNoise(p * freq) * amp; 

   //total += voronoi(p * freq) * amp; 

   //total += basicNoise(p * freq) * amp; 

  }

   return total; 
  
}





void main()
{
   fs_Pos = vs_Pos.xyz;

  //based on the x and z position, we want to get a y position 
   float x_pos = vs_Pos.x + u_PlanePos.x; 
   float z_pos = vs_Pos.z + u_PlanePos.y;
   vec2 input_pos = vec2(x_pos, z_pos); 


  fs_Sine = (sin((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1));
 
  fs_Sine = fs_Sine * 0.5 * fbm (input_pos); //trying something 

  //trying something 2
  float sineTerm = (sin((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) * 2.0 - 0.5 + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1) * 1.5);
  fs_Sine = sineTerm * fbm (input_pos); //2a
  
  fs_Sine = fbm (input_pos * 0.3) ; //2c
    fs_Sine = fbm (input_pos * 0.3) + sineTerm * 0.2; //2d


 // fs_Sine = pow(smoothstep(0.0, 0.9, fs_Sine), 3.0); //2b

 // fs_Sine = basicNoise(input_pos); 


// //trying 3 
// float height = fbm(vec2(1000.101, -1000.101));
// height = pow(smoothstep(0.2, 0.8, height), 3.0) * 33.0; 
// fs_Sine = height; 

  vec4 modelposition = vec4(vs_Pos.x, fs_Sine, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  gl_Position = u_ViewProj * modelposition;

  /*
  fs_Pos = vs_Pos.xyz;
  fs_Sine = (sin((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1));
  vec4 modelposition = vec4(vs_Pos.x, fs_Sine * 2.0, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  gl_Position = u_ViewProj * modelposition;
  */
}
