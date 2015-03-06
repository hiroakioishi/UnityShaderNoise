﻿// This is a HLSL translated code of
// http://glslsandbox.com/e#20793.0
// Translated by Hiroaki Oishi

Shader "ShaderNoise/RenderNoise" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "ShaderNoiseSet.cginc"
	
	uniform sampler2D _MainTex;
	uniform fixed4    _MainTex_Texelsize;
	
	struct appdata_t {
		float4 vertex   : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 vertex   : SV_POSITION;
		half2  texcoord : TEXCOORD0;
	};
	
	v2f vert (appdata_t v) {
		v2f o = (v2f)0;
		o.vertex   = mul(UNITY_MATRIX_MVP, v.vertex);
		o.texcoord = v.texcoord;
		return o;
	}
	
	fixed4 frag (v2f i) : COLOR
	{
		float2 uv = i.texcoord.xy;
	    
	    float a = 0.5;
	    float f = 5.0;
	    const int it = 8;
	    
	    //noise functions
		//top    row : value noise => fractal brownian motion         => ridged multifractal
		//bottom row : voronoi     => voronoi fractal brownian motion => voronoi ridged multifractal
		float n = uv.x > 0.33 ? uv.x > 0.66 ?  rmf(a, f, uv, it) :  fbm(a, f, uv, it) : noise  (uv * 8.0);
  		float v = uv.x > 0.33 ? uv.x > 0.66 ? vrmf(a, f, uv, it) : vfbm(a, f, uv, it) : voronoi(uv * 8.0);
    	float r = uv.y < 0.50 ? v : n;
	
		return fixed4 (r);
	}
	ENDCG
	
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
			#pragma target   3.0
			#pragma vertex   vert
			#pragma fragment frag
			
			ENDCG
		}
	
	} 
	FallBack Off
}
