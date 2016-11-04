
// --- noise functions ---
// noise   (float2 uv)                           : Value Noise
// fbm     (float a, float f, float2 uv, int it) : Fractal Brownian Motion (Fractional Brownian Motion)
// rmf     (float a, float f, float2 uv, int it) : Ridged Multifractal
// voronoi (float2 uv)                           : Voronoi
// vfbm    (float a, float f, float2 uv, int it) : Voronoi Fractal Brownian Motion
// vrmf    (float a, float f, float2 uv, int it) : Voronoi Ridged Multifractal

// ----------------------------------------------------------------------------
// Value Noise
// ----------------------------------------------------------------------------
// Generic 1,2,3 Noise 
// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
//  By Morgan McGuire @morgan3d, http://graphicscodex.com

float _noise_pattern_set_hash(float n)
{
	return frac(sin(n) * 1e4);
}

float _noise_pattern_set_hash(float2 p)
{
	return frac(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

// for voronoi
float2 _noise_pattern_set_hash2(float2 p)
{
	return float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3))); return frac(sin(p) * 43758.5453);
}

// 1D
float noise_value(float x)
{
	float i = floor(x);
	float f = frac(x);
	float u = f * f * (3.0 - 2.0 * f);
	return lerp(_noise_pattern_set_hash(i), _noise_pattern_set_hash(i + 1.0), u);
}
// 2D
float noise_value(float2 x)
{
	float2 i = floor(x);
	float2 f = frac(x);

	// Four corners in 2D of a tile
	float a = _noise_pattern_set_hash(i);
	float b = _noise_pattern_set_hash(i + float2(1.0, 0.0));
	float c = _noise_pattern_set_hash(i + float2(0.0, 1.0));
	float d = _noise_pattern_set_hash(i + float2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//          mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//          smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	float2 u = f * f * (3.0 - 2.0 * f);
	return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// 3D
// This one has non-ideal tiling properties that I'm still tuning
float noise_value(float3 x)
{
	const float3 step = float3(110, 241, 171);

	float3 i = floor(x);
	float3 f = frac(x);

	// For performance, compute the base input to a 1D _noise_pattern_set_hash from the integer part of the argument and the 
	// incremental change to the 1D based on the 3D -> 1D wrapping
	float n = dot(i, step);

	float3 u = f * f * (3.0 - 2.0 * f);
	return lerp(lerp(lerp(_noise_pattern_set_hash(n + dot(step, float3(0, 0, 0))), _noise_pattern_set_hash(n + dot(step, float3(1, 0, 0))), u.x), lerp(_noise_pattern_set_hash(n + dot(step, float3(0, 1, 0))), _noise_pattern_set_hash(n + dot(step, float3(1, 1, 0))), u.x), u.y), lerp(lerp(_noise_pattern_set_hash(n + dot(step, float3(0, 0, 1))), _noise_pattern_set_hash(n + dot(step, float3(1, 0, 1))), u.x), lerp(_noise_pattern_set_hash(n + dot(step, float3(0, 1, 1))), _noise_pattern_set_hash(n + dot(step, float3(1, 1, 1))), u.x), u.y), u.z);
}

// ----------------------------------------------------------------------------
// iq's Voronoi
// ----------------------------------------------------------------------------
// http://glslsandbox.com/e#20793.0
// 2D
float noise_voronoi(float2 uv)
{
	float2 p = floor(uv);
	float2 f = frac(uv);
	float  v = 0.0;
	for (int j = -1; j <= 1; j++)
		for (int i = -1; i <= 1; i++)
		{
			float2 b = float2(i, j);
			float2 r = b - f + _noise_pattern_set_hash(p + b);
			v += 1.0 / pow(dot(r, r), 8.);
		}
	return pow(1.0 / v, 0.0625);
}

// 3D
float noise_voronoi(float3 uv)
{
	float2 p = floor(uv);
	float2 f = frac(uv);
	float  v = 0.0;
	for (int j = -1; j <= 1; j++)
		for (int i = -1; i <= 1; i++)
		{
			float2 b = float2(i, j);
			float2 o = _noise_pattern_set_hash2(p + b);

			o = 0.5 + 0.5 * sin(uv.z + 6.2831 * o); // animate
			float2 r = b - f + o;

			v += 1.0 / pow(dot(r, r), 8.);
		}
	return pow(1.0 / v, 0.0625);
}

// ----------------------------------------------------------------------------
// Fractal Brownian Motion
// ----------------------------------------------------------------------------
// http://glslsandbox.com/e#20793.0
// 2D
float noise_fbm(float a, float f, float2 uv, int it)
{
	float n = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i < it) {
			n += noise_value(uv * f) * a;
			a *= 0.5;
			f *= 2.0;
		}
	}
	return n;
}

// 3D
float noise_fbm(float a, float f, float3 uv, int it)
{
	float n = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i < it) {
			n += noise_value(float3(uv.xy * f, uv.z)) * a;
			a *= 0.5;
			f *= 2.0;
		}
	}
	return n;
}

// ----------------------------------------------------------------------------
// Ridged MultiFractal
// ----------------------------------------------------------------------------
// http://glslsandbox.com/e#20793.0
// 2D
float noise_rmf(float a, float f, float2 uv, int it)
{
	float l = 2.0;
	float r = 0.0;
	for (int i = 0; i < 32; i++)
	{
		if (i < it)
		{
			uv = uv.yx * l;
			float n = noise_value(uv);
			n = abs(frac(n - 0.5) - 0.5);
			n *= n * a;
			a = clamp(0.0, 1.0, n * 2.0);
			r += n * pow(f, -1.0);
			f *= l;
		}
	}
	return r * 8.0;
}

// 3D
float noise_rmf(float a, float f, float3 uv, int it)
{
	float l = 2.0;
	float r = 0.0;
	for (int i = 0; i < 32; i++)
	{
		if (i < it)
		{
			uv.xy = uv.yx * l;
			float n = noise_value(uv);
			n = abs(frac(n - 0.5) - 0.5);
			n *= n * a;
			a = clamp(0.0, 1.0, n * 2.0);
			r += n * pow(f, -1.0);
			f *= l;
		}
	}
	return r * 8.0;
}

// ----------------------------------------------------------------------------
// Voronoi Fbm
// ----------------------------------------------------------------------------
// http://glslsandbox.com/e#20793.0
// 2D
float noise_vfbm(float a, float f, float2 uv, int it)
{
	float n = 0.0;
	for (int i = 0; i < 32; i++)
	{
		if (i<it)
		{
			n += noise_voronoi(uv * f) * a;
			f *= 2.0;
			a *= 0.5;
		}
	}
	return n;
}

// 3D
float noise_vfbm(float a, float f, float3 uv, int it)
{
	float n = 0.0;
	for (int i = 0; i < 32; i++)
	{
		if (i<it)
		{
			n += noise_voronoi(float3(uv.xy * f, uv.z)) * a;
			f *= 2.0;
			a *= 0.5;
		}
	}
	return n;
}

// ----------------------------------------------------------------------------
// Ridged MultiFractal
// ----------------------------------------------------------------------------
// http://glslsandbox.com/e#20793.0
// 2D
float noise_vrmf(float a, float f, float2 uv, int it)
{
	float l = 2.0;
	float r = 0.0;
	for (int i = 0; i < 32; i++)
	{
		if (i < it)
		{
			uv = uv.yx * l;
			float n = noise_voronoi(uv);
			n = abs(frac(n - 0.5) - 0.5);
			n *= n * a;
			a = clamp(0.0, 1.0, n * 2.0);
			r += n * pow(f, -1.0);
			f *= l;
		}
	}
	return r * 8.0;
}

// 3D
float noise_vrmf(float a, float f, float3 uv, int it)
{
	float l = 2.0;
	float r = 0.0;
	for (int i = 0; i < 32; i++)
	{
		if (i < it)
		{
			uv.xy = uv.yx * l;
			float n = noise_voronoi(uv);
			n = abs(frac(n - 0.5) - 0.5);
			n *= n * a;
			a = clamp(0.0, 1.0, n * 2.0);
			r += n * pow(f, -1.0);
			f *= l;
		}
	}
	return r * 8.0;
}

