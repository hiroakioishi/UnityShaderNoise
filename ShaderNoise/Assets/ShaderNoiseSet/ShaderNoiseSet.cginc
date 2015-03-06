// An HLSL various shader noise functions set.

// --- noise functions ---
// noise   (float2 uv)                           : value noise,
// fbm     (float a, float f, float2 uv, int it) : fractal brownian motion 
// rmf     (float a, float f, float2 uv, int it) : ridged multifractal
// voronoi (float2 uv)                           : voronoi
// vfbm    (float a, float f, float2 uv, int it) : voronoi fractal brownian motion
// vrmf    (float a, float f, float2 uv, int it) : voronoi ridged multifractal

float2 rhash(float2 uv) {
    fixed2x2 t = fixed2x2(
    	 0.12121212, 0.13131313,
    	-0.13131313, 0.12121212
    );
    float2 s = float2(1e4, 1e6);
    uv = mul(t, uv);
    uv *= s;
	return frac(frac(uv / s) * uv);
}

float2 smooth(float2 uv)
{
    return uv * uv * (3.0 - 2.0 * uv);
}

//value noise
float noise(float2 uv)
{
    const float k = 257.0;
    float4 l  = float4(floor(uv),frac(uv));
    float  u  = l.x + l.y * k;
    float4 v  = float4(u, u + 1.0, u + k, u + k + 1.0);
    v         = frac(frac(1.23456789 * v) * v / 0.987654321);
    l.zw      = smooth(l.zw);
    l.x       = lerp(v.x, v.y, l.z);
    l.y       = lerp(v.z, v.w, l.z);
    return lerp(l.x, l.y, l.w);
}

//iq's voronoi
float voronoi(float2 uv)
{
    float2 p = floor(uv);
    float2 f = frac (uv);
    float  v = 0.0;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            float2 b = float2(i, j);
            float2 r = b - f + rhash(p + b);
            v += 1.0/pow(dot(r,r),8.);
        }
    return pow(1.0/v, 0.0625);
}

//fractal brownian motion
float fbm(float a, float f, float2 uv, int it)
{
    float n = 0.0;
    for (int i = 0; i < 32; i++) {
        if (i < it) {
            n += noise(uv * f) * a;
            a *= 0.5;
            f *= 2.0;
        }
    }
    return n;
}

//ridged multifractal
float rmf(float a, float f, float2 uv, int it)
{
    float l = 2.0;
    float r = 0.0;
    for(int i = 0; i < 32; i++)
    {
        if(i < it)
        {
            uv = uv.yx * l;
            float n = noise (uv);     
            n = abs(frac(n - 0.5) - 0.5);
            n *= n * a;
            a = clamp(0.0, 1.0, n * 2.0);
            r += n * pow(f, -1.0);
            f *= l;
        }
    }
    return r * 8.0;
}

//voronoi fbm
float vfbm(float a, float f, float2 uv, int it)
{
    float n = 0.0;
    for(int i = 0; i < 32; i++)
    {
        if(i<it)
        {
            n += voronoi(uv * f) * a;
            f *= 2.0;
            a *= 0.5;
        }
    }
    return n;
}

//ridged multifractal
float vrmf(float a, float f, float2 uv, int it)
{
    float l = 2.0;
    float r = 0.0;
    for(int i = 0; i < 32; i++)
    {
        if(i < it)
        {
            uv = uv.yx * l;
            float n = voronoi(uv);     
            n = abs(frac(n - 0.5) - 0.5);
            n *= n * a;
            a = clamp(0.0, 1.0, n * 2.0);
            r += n * pow(f, -1.0);
            f *= l;
        }
    }
    return r * 8.0;
}