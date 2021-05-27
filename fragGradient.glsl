#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

uniform float u_speed;
uniform float u_scale1;
uniform float u_scale2;
uniform float u_dimensions;
uniform float u_base_color;
uniform float u_simplex_coefficient;
uniform float u_noise_strength;
uniform float u_mouse_impact;
uniform float u_bleed_only;



vec3 random3(vec3 c){
	float j=4096.*sin(dot(c,vec3(17.,59.4,15.)));
	vec3 r;
	r.z=fract(512.*j);
	j*=.125;
	r.x=fract(512.*j);
	j*=.125;
	r.y=fract(512.*j);
	return r-.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) {
	/* 1. find current tetrahedron T and it's four vertices */
	/* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	/* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	
	/* calculate s and x */
	vec3 s = floor(p + dot(p, vec3(F3)));
	vec3 x = p - s + dot(s, vec3(G3));
	
	/* calculate i1 and i2 */
	vec3 e = step(vec3(0.0), x - x.yzx);
	vec3 i1 = e*(1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	
	/* x1, x2, x3 */
	vec3 x1 = x - i1 + G3;
	vec3 x2 = x - i2 + 2.0*G3;
	vec3 x3 = x - 1.0 + 3.0*G3;
	
	/* 2. find four surflets and store them in d */
	vec4 w, d;
	
	/* calculate surflet weights */
	w.x = dot(x, x);
	w.y = dot(x1, x1);
	w.z = dot(x2, x2);
	w.w = dot(x3, x3);
	
	/* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	w = max(0.6 - w, 0.0);
	
	/* calculate surflet components */
	d.x = dot(random3(s), x);
	d.y = dot(random3(s + i1), x1);
	d.z = dot(random3(s + i2), x2);
	d.w = dot(random3(s + 1.0), x3);
	
	/* multiply d by w^4 */
	w *= w;
	w *= w;
	d *= w;
	
	/* 3. return the sum of the four surflets */
	return dot(d, vec4(52.0));
}

/* const matrices for 3d rotation */
const mat3 rot1 = mat3(-0.37, 0.36, 0.85,-0.14,-0.93, 0.34,0.92, 0.01,0.4);
const mat3 rot2 = mat3(-0.55,-0.39, 0.74, 0.33,-0.91,-0.24,0.77, 0.12,0.63);
const mat3 rot3 = mat3(-0.71, 0.52,-0.47,-0.08,-0.72,-0.68,-0.7,-0.45,0.56);

/* directional artifacts can be reduced by rotating each octave */
float simplex3d_fractal(vec3 m){
	return .5333333*simplex3d(m*rot1);
	
}

float random(vec2 st,float seed){
	return fract(sin(dot(st.xy,vec2(seed,.233)))*43761.777);
}

// blue secondary
vec3 colorA=vec3(.486,.69,.996);
// red, primary
vec3 colorB=vec3(.909,.258,0.);

// yellow, tertiary
vec3 colorC=vec3(1.,.83,.356);

float quadraticInOut(float t){
	float p=2.*t*t;
	return t<.5?p:-p+(4.*t)-1.;
}

void main(){
	vec2 mousePos=u_mouse.xy/u_resolution.x;
	vec2 p=gl_FragCoord.xy/u_resolution.x;
	vec3 p3=vec3(p,u_time*u_speed);
	
	float value;
    float topBleed;
    // we can set a color for the top gradient
    vec3 topBleedColor = vec3(1.0, 1.0, 1.0);
	
	// increase the amount of circles here
	value=simplex3d_fractal(p3*u_scale1+u_scale2);	
	// mess around with what colors you want most
	value=u_base_color+u_simplex_coefficient*value;
	// if px position is near mousepos
	// increase value
	float dist=pow(distance(mousePos,p),1.);
	dist=1.-quadraticInOut(dist+.3);
    // add mouse movement
	value+=dist*u_mouse_impact;
	
	vec3 color=vec3(0.);
	
	if(value<=.5){
		color=mix(colorA,colorB,value*2.);
	}else{
		color=mix(colorB,colorC,(value-.5)*2.);
	}
	
	// added a bit of grain on top
	color+=random(p,sin(u_time)*100.)*u_noise_strength;

    // add the top gradient 
	
	// meaning of each number :
	// how low the bar is (0-1) ; how strong the noise affects it (0 -inf) ; scale of noise (how many "eyes") ; another way to edit scale
	topBleed = 0.45 + 0.3*simplex3d_fractal(p3*0.7+3.);
	// first pass to remove all bottom white values
	topBleed=smoothstep(0.20,  1. - (p.y) ,topBleed);
	// second pass to remove more values, edit first value to change the length of the blend between top and bottom
    topBleed=smoothstep(0.2, 1., topBleed );
	// match it with the color ( set as white for now, so not seeable)
    topBleedColor = vec3(topBleedColor.r * topBleed, topBleedColor.g * topBleed, topBleedColor.b * topBleed );
    color+= topBleedColor;
	

    // gl_FragColor = vec4(vec3(value), 1.);
	if(u_bleed_only == 1. ){
		color = vec3(topBleed);
	}

	
	gl_FragColor=vec4(
		color,
	1.);
	return;
}
