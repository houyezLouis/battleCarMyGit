// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_OutlineParticle"
{
	Properties
	{
		_Main("Main", 2D) = "white" {}
		_Pattern("Pattern", 2D) = "white" {}
		_colorIn("colorIn", Color) = (0.8113208,0.6526773,0.1722143,0)
		_PatternColor("PatternColor", Color) = (0.8113208,0.6526773,0.1722143,0)
		_colorOut("colorOut", Color) = (1,0.2196366,0,0)
		_InValue("InValue", Range( 0.01 , 1)) = 0.3205248
		_OutValue("OutValue", Range( 0.01 , 1)) = 0.5896263
		_EmissiveIn("EmissiveIn", Range( 0.2 , 10)) = 1.345882
		_EmissiveOut("EmissiveOut", Range( 0.2 , 10)) = 1.345882
		[IntRange]_Motif1Value("Motif1Value", Range( 0 , 1)) = 1
		[IntRange]_Motif2Value("Motif2Value", Range( 0 , 1)) = 1
		[IntRange]_Motif3Value("Motif3Value", Range( 0 , 1)) = 1
		_MotifEmissive("MotifEmissive", Range( 0 , 4)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha One , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Main;
			sampler2D _Pattern;
			CBUFFER_START( UnityPerMaterial )
			float4 _colorIn;
			float _EmissiveIn;
			float _InValue;
			float4 _Main_ST;
			float _EmissiveOut;
			float _OutValue;
			float4 _colorOut;
			float4 _PatternColor;
			float4 _Pattern_ST;
			float _Motif1Value;
			float _Motif2Value;
			float _Motif3Value;
			float _MotifEmissive;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				o.clipPos = TransformObjectToHClip( v.vertex.xyz );
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( o.clipPos.z );
				#endif
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_Main = IN.ase_texcoord1.xy * _Main_ST.xy + _Main_ST.zw;
				float4 tex2DNode4 = tex2D( _Main, uv_Main );
				float temp_output_19_0 = step( _InValue , tex2DNode4.r );
				float temp_output_20_0 = step( _OutValue , ( tex2DNode4.b - tex2DNode4.r ) );
				float2 uv_Pattern = IN.ase_texcoord1.xy * _Pattern_ST.xy + _Pattern_ST.zw;
				float4 tex2DNode26 = tex2D( _Pattern, uv_Pattern );
				float clampResult54 = clamp( ( ( tex2DNode26.r * _Motif1Value ) + ( tex2DNode26.g * _Motif2Value ) + ( tex2DNode26.b * _Motif3Value ) ) , 0.0 , 1.0 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( _colorIn * ( _EmissiveIn * temp_output_19_0 ) ) + ( ( _EmissiveOut * temp_output_20_0 ) * _colorOut ) ) + ( _PatternColor * ( tex2DNode4.g * ( clampResult54 * _MotifEmissive ) ) ) ).rgb;
				float Alpha = ( IN.ase_color.a * ( temp_output_19_0 + temp_output_20_0 ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Main;
			CBUFFER_START( UnityPerMaterial )
			float4 _colorIn;
			float _EmissiveIn;
			float _InValue;
			float4 _Main_ST;
			float _EmissiveOut;
			float _OutValue;
			float4 _colorOut;
			float4 _PatternColor;
			float4 _Pattern_ST;
			float _Motif1Value;
			float _Motif2Value;
			float _Motif3Value;
			float _MotifEmissive;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_Main = IN.ase_texcoord.xy * _Main_ST.xy + _Main_ST.zw;
				float4 tex2DNode4 = tex2D( _Main, uv_Main );
				float temp_output_19_0 = step( _InValue , tex2DNode4.r );
				float temp_output_20_0 = step( _OutValue , ( tex2DNode4.b - tex2DNode4.r ) );
				
				float Alpha = ( IN.ase_color.a * ( temp_output_19_0 + temp_output_20_0 ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=17700
-1708;1;1478;1029;2736.424;2286.975;3.48661;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;5;-1239.537,-379.5134;Inherit;True;Property;_Main;Main;0;0;Create;True;0;0;False;0;64ade541dc419974c9fe34fea0bb23bc;d4d7514522c86bd448a06958d2b53b08;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;42;-372.1768,-1580.362;Inherit;False;1769.661;1274.62;Main Color + alpha;18;39;37;9;8;15;31;19;24;38;20;41;40;25;16;17;35;23;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-972.8461,-371.1042;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-322.1768,-853.3624;Inherit;False;Property;_OutValue;OutValue;6;0;Create;True;0;0;False;0;0.5896263;0.68;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-304.9148,-756.3837;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-282.2569,-1015.833;Inherit;False;Property;_InValue;InValue;5;0;Create;True;0;0;False;0;0.3205248;0.34;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;19;186.4974,-1039.049;Inherit;True;2;0;FLOAT;0.19;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;20;-10.84686,-771.8281;Inherit;True;2;0;FLOAT;0.05;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;860.4912,-775.9261;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;34;932.9351,-943.8756;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;43;-355.6819,-279.0905;Inherit;False;1379.445;782.9661;Motif;10;30;29;3;2;1;28;53;54;55;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-40.20786,-1243.581;Inherit;False;Property;_EmissiveIn;EmissiveIn;7;0;Create;True;0;0;False;0;1.345882;1;0.2;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-122.6776,-1530.362;Inherit;False;Property;_colorIn;colorIn;2;0;Create;True;0;0;False;0;0.8113208,0.6526773,0.1722143,0;0,0.2745098,0.08235291,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;391.042,-1526.779;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-301.5171,57.35551;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;101.3134,121.0562;Inherit;False;Property;_MotifEmissive;MotifEmissive;12;0;Create;True;0;0;False;0;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;247.1475,-695.6878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;281.6956,-517.7422;Inherit;False;Property;_colorOut;colorOut;4;0;Create;True;0;0;False;0;1,0.2196366,0,0;0.8105844,1,0.4669811,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;486.1104,-706.6145;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-736,-96;Inherit;False;Property;_Motif1Value;Motif1Value;9;1;[IntRange];Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-31.29392,-528.4348;Inherit;False;Property;_EmissiveOut;EmissiveOut;8;0;Create;True;0;0;False;0;1.345882;1;0.2;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;775.7757,-1503.613;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;1162.484,-1484.044;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;460.2614,-1276.512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-1248.883,-121.9852;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;27;-1515.574,-130.3944;Inherit;True;Property;_Pattern;Pattern;1;0;Create;True;0;0;False;0;b18160458199d2a40b5893faad40cabe;b18160458199d2a40b5893faad40cabe;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-487.9861,104.7499;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;1153.547,-749.5881;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;317.177,-195.4645;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;30;-12.86028,201.9439;Inherit;False;Property;_PatternColor;PatternColor;3;0;Create;True;0;0;False;0;0.8113208,0.6526773,0.1722143,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;657.977,-223.644;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-474.9861,-139.2501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-474.9861,-33.25006;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;134.5771,-9.636992;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-736,16;Inherit;False;Property;_Motif2Value;Motif2Value;10;1;[IntRange];Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;54;-74.2085,37.66187;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-742.9861,152.7499;Inherit;False;Property;_Motif3Value;Motif3Value;11;1;[IntRange];Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1783.869,-773.934;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;S_OutlineParticle;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;8;5;False;-1;1;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-1500.881,86.84784;Inherit;False;570.9137;100;R = In / B= Out / G = Motif;0;;1,1,1,1;0;0
WireConnection;4;0;5;0
WireConnection;38;0;4;3
WireConnection;38;1;4;1
WireConnection;19;0;24;0
WireConnection;19;1;4;1
WireConnection;20;0;25;0
WireConnection;20;1;38;0
WireConnection;23;0;19;0
WireConnection;23;1;20;0
WireConnection;8;0;9;0
WireConnection;8;1;39;0
WireConnection;53;0;47;0
WireConnection;53;1;48;0
WireConnection;53;2;49;0
WireConnection;41;0;40;0
WireConnection;41;1;20;0
WireConnection;17;0;41;0
WireConnection;17;1;16;0
WireConnection;15;0;8;0
WireConnection;15;1;17;0
WireConnection;31;0;15;0
WireConnection;31;1;29;0
WireConnection;39;0;37;0
WireConnection;39;1;19;0
WireConnection;26;0;27;0
WireConnection;49;0;26;3
WireConnection;49;1;52;0
WireConnection;35;0;34;4
WireConnection;35;1;23;0
WireConnection;28;0;4;2
WireConnection;28;1;55;0
WireConnection;29;0;30;0
WireConnection;29;1;28;0
WireConnection;47;0;26;1
WireConnection;47;1;50;0
WireConnection;48;0;26;2
WireConnection;48;1;51;0
WireConnection;55;0;54;0
WireConnection;55;1;56;0
WireConnection;54;0;53;0
WireConnection;0;2;31;0
WireConnection;0;3;35;0
ASEEND*/
//CHKSM=33A23D5C5E27B2A60DD9481DAB47220662414DEB