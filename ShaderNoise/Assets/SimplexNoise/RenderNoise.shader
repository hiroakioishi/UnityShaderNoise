
Shader "WebGLNoise/RenderNoise" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	//#include "noise2D.cginc"
	//#include "noise3D.cginc"
	//#include "noise4D.cginc"
	#include "snoise.cginc"
	
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
	    
	    // noise2D
	    //float r = snoise (float2(uv * 1.0));
	    // noise3D
	    float r = snoise (float3(uv * 1.0, _Time.y));
	    // noise4D
	    //float r = snoise (float4(uv * 5.0, 1.0, _Time.y * 0.5));
	    
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
