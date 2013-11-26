#version 150

in  vec2 texCoord;
out vec4 fColor;

uniform sampler2D texture;
uniform  int effectMode;

vec3 router( vec3 , int );
vec3 LuminanceEffect( vec3 );
vec3 NegativeEffect( vec3 );
vec3 EdgeDetectionEffect( vec3 );

void main() 
{ 
	vec3 color = vec3(texture( texture, texCoord ));
    fColor = vec4(router(color, effectMode), 1.0);

}

vec3 router(vec3 color, int effectMode)
{
	switch(effectMode)
	{
		case 0:
			return color;
		case 1:
			return LuminanceEffect(color);
		
		case 2:
			return NegativeEffect(color);

		case 3:
			//color = LuminanceEffect(color);
			return EdgeDetectionEffect(color);

		default:
			return color;
	}
}

vec3 EdgeDetectionEffect(vec3 color)
{
	const vec3 LUMCOEFFS = vec3(0.2125, 0.7154, 0.0721);
	ivec2 ires = textureSize( texture, 0);
	float ResS = float( ires.s );
	float ResT = float( ires.t );

	vec2 stp0 = vec2(1.0/ResS,  0.0     ); //texel offsets
	vec2 st0p = vec2(0.0 ,      1.0/ResT);
	vec2 stpp = vec2(1.0/ResS,  1.0/ResT);
	vec2 stpm = vec2(1.0/ResS, -1.0/ResT);

	// 3x3 pixel colors next
	float i00   = dot( texture( texture, texCoord      ).rgb , LUMCOEFFS);
	float im1m1 = dot( texture( texture, texCoord-stpp ).rgb , LUMCOEFFS);
	float ip1p1 = dot( texture( texture, texCoord+stpp ).rgb , LUMCOEFFS);
	float im1p1 = dot( texture( texture, texCoord-stpm ).rgb , LUMCOEFFS);
	float ip1m1 = dot( texture( texture, texCoord+stpm ).rgb , LUMCOEFFS);
	float im10  = dot( texture( texture, texCoord-stp0 ).rgb , LUMCOEFFS);
	float ip10  = dot( texture( texture, texCoord+stp0 ).rgb , LUMCOEFFS);
	float i0m1  = dot( texture( texture, texCoord-st0p ).rgb , LUMCOEFFS);
	float i0p1  = dot( texture( texture, texCoord+st0p ).rgb , LUMCOEFFS);

	float h = -1.0 * im1p1 - 2.0 * i0p1 - 1.0 * ip1p1 + 1.0 * im1m1 + 2.0 * i0m1 + 1.0 * ip1m1;
	float v = -1.0 * im1m1 - 2.0 * im10 - 1.0 * im1p1 + 1.0 * ip1m1 + 2.0 * ip10 + 1.0 * ip1p1;

	float mag = sqrt(h*h + v*v);
	vec3 target = vec3(mag, mag, mag);
	return mix(color, target, texCoord.y);
}

vec3 NegativeEffect(vec3 color)
{
	return vec3( 1.0 - color.x, 1.0 - color.y, 1.0 - color.z);
}

vec3 LuminanceEffect(vec3 color)
{
	const vec3 LUMCOEFFS = vec3(0.2125, 0.7154, 0.0721);
	float luminance = dot(color, LUMCOEFFS);
	return vec3( luminance, luminance,luminance);
}

/*
vec3 EmbossingEffect()
{

}

*/

/*
Embossing effect
ToonRendering
TwirlTransformation
RippleTransformation
SphericalTransformation
*/