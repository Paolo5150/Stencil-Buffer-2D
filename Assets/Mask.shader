Shader "Custom/Mask"
{
	Properties
	{
		 _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		//The stencil buffer is really a simple buffer which can contain a number.

		//The Ref parameter simply indicates the number to be written in the stencil buffer.

		//Comp equal means the shader will always replace the current value of the stencil buffer with the value Ref (1 in this case).
		// Therefore, each pixel on which this shader is operating will have a stencil buffer of 1.	

		Pass
		{

		Stencil
		{

		Ref 1
	
		Pass replace


		}

		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;

			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
	
			};
			
			fixed4 _Color;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
	

				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

				color.a = tex2D (_MainTex, uv).a;
				return color;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
		
				fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
				c.rgb *= c.a;

				//Discard pixels that don't have alpha = 1.
				// The texture i'm using has gradual values of alpha, so the result is not great.
				// Use a texture with alpha 0 for parts where you don't want the pass to be overwritten.
				if(c.a<0.9)
						discard;

				return c;
			}
		ENDCG
		}


	}
}
