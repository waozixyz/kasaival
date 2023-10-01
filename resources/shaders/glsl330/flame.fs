#version 330 core

#define PI 3.141592
#define OFF 0.03

uniform sampler2D iChannel0;
uniform float iTime;
uniform vec2 iResolution;


float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.99, 78.233))) * 43758.545);
}

float shift(float r) {
    return sin(r * 2. * PI + iTime * 7.) * 0.5 + 0.5;
}

float noise(vec2 p) {   
    vec2 f = fract(p);
    vec2 i = floor(p);
    return mix(mix(shift(rand(i + vec2(0, 0))), 
                   shift(rand(i + vec2(1, 0))), f.x),
               mix(shift(rand(i + vec2(0, 1))), 
                   shift(rand(i + vec2(1, 1))), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.;
    float a = 1.;
    for (int i = 0; i < 4; ++i) {
        vec2 p1 = p * 4. / a;
        a *= 0.5;
        v += a * noise(p1);
    }
    return v;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 p = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    
	vec2 r = vec2(fbm(p + vec2(0,  OFF)) - fbm(p + vec2( 0, -OFF)), 
                 -fbm(p + vec2(OFF,  0)) + fbm(p + vec2(-OFF,  0))) * 0.01;	
  r += vec2(0.002, 0.0045);

  vec2 uv = fragCoord / iResolution.xy;
	float dCircle = sdCircle(p, 0.1); 
	vec3 col = pow(texture(iChannel0, uv - r).rgb, vec3(1.15))
             + vec3(smoothstep(0.01, -0.01, abs(dCircle) - 0.007)) * vec3(1., 0.6, 0.25);
	col = clamp(col, 0., 1.);
  fragColor = vec4(col, 1.);
}


void main()
{
    mainImage(gl_FragColor, gl_FragCoord.xy);
}