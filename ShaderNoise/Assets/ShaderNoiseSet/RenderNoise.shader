Shader "ShaderNoisePattern/Render"
{
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "ShaderNoisePattern.cginc"
	
	uniform sampler2D _MainTex;
	uniform fixed4    _MainTex_Texelsize;
	
	fixed4 frag (v2f_img i) : COLOR
	{
		float2 uv = i.uv.xy;
		float2 noiseUv = uv * 4.0;
		float  time = _Time.y * 1.0;
	    
	    float a = 0.5;
	    float f = 5.0;
	    const int it = 8;
	    
	    //noise functions
		//top    row : value noise => fractal brownian motion         => ridged multifractal
		//bottom row : voronoi     => voronoi fractal brownian motion => voronoi ridged multifractal
		float n = uv.x > 0.33 ? uv.x > 0.66 ?  noise_rmf(a, f, float3(noiseUv, time), it) :  noise_fbm(a, f, float3(noiseUv, time), it) :   noise_value(float3(noiseUv * 2.0, time));
  		float v = uv.x > 0.33 ? uv.x > 0.66 ? noise_vrmf(a, f, float3(noiseUv, time), it) : noise_vfbm(a, f, float3(noiseUv, time), it) : noise_voronoi(float3(noiseUv * 2.0, time));
    	float r = uv.y < 0.50 ? v : n;
	
		return fixed4 (r, r, r, r);
	}
	ENDCG
	
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
			#pragma target   3.0
			#pragma vertex   vert_img
			#pragma fragment frag
			ENDCG
		}
	
	} 
	FallBack Off
}
