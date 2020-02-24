// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_SmokeCartoon"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_Texture1("Texture 1", 2D) = "white" {}
		_ColorIn("_ColorIn", Color) = (1,1,1,0)
		_ColorOutline("_ColorOutline", Color) = (1,0,0.7465525,0)
		_ColorMedium("_ColorMedium", Color) = (0.735849,0.735849,0.735849,0)
		_ColorInValue("ColorInValue", Range( 0 , 1)) = 0.5
		_ColorMediumValue("ColorMediumValue", Range( 0 , 0.5)) = 0.056
		_AlphaAdaptation("AlphaAdaptation", Range( 0.1 , 5)) = 2.85
		_AlphaTreshHold("AlphaTreshHold", Range( 0 , 1)) = 0.01
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
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
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

			sampler2D _Texture1;
			sampler2D _Texture0;
			CBUFFER_START( UnityPerMaterial )
			float _ColorInValue;
			float _AlphaAdaptation;
			float4 _Texture0_ST;
			float4 _ColorIn;
			float _ColorMediumValue;
			float4 _ColorMedium;
			float4 _ColorOutline;
			float _AlphaTreshHold;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_color = v.ase_color;
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

				float2 uv_Texture0 = IN.ase_texcoord1 * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode5 = tex2D( _Texture0, uv_Texture0 );
				float clampResult23 = clamp( ( ( tex2DNode5.b * 1.5 ) - ( IN.ase_texcoord1.z * ( tex2DNode5.r * 1.5 ) ) ) , 0.0 , 1.0 );
				float clampResult39 = clamp( ( _AlphaAdaptation * clampResult23 ) , 0.0 , 1.0 );
				float2 appendResult24 = (float2(clampResult39 , 0.0));
				float4 tex2DNode17 = tex2D( _Texture1, appendResult24 );
				float temp_output_44_0 = step( _ColorInValue , tex2DNode17.r );
				float temp_output_45_0 = step( _ColorMediumValue , tex2DNode17.r );
				float4 clampResult55 = clamp( ( ( temp_output_44_0 * _ColorIn ) + ( ( temp_output_45_0 - temp_output_44_0 ) * _ColorMedium ) + ( ( 1.0 - temp_output_45_0 ) * _ColorOutline ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = (clampResult55).rgb;
				float Alpha = ( IN.ase_color.a * step( _AlphaTreshHold , clampResult23 ) );
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

			sampler2D _Texture0;
			CBUFFER_START( UnityPerMaterial )
			float _ColorInValue;
			float _AlphaAdaptation;
			float4 _Texture0_ST;
			float4 _ColorIn;
			float _ColorMediumValue;
			float4 _ColorMedium;
			float4 _ColorOutline;
			float _AlphaTreshHold;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
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

				float2 uv_Texture0 = IN.ase_texcoord * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode5 = tex2D( _Texture0, uv_Texture0 );
				float clampResult23 = clamp( ( ( tex2DNode5.b * 1.5 ) - ( IN.ase_texcoord.z * ( tex2DNode5.r * 1.5 ) ) ) , 0.0 , 1.0 );
				
				float Alpha = ( IN.ase_color.a * step( _AlphaTreshHold , clampResult23 ) );
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
238;73;947;669;-2741.503;632.4886;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;4;-513.6,-510.9;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;False;0;569ab6ae55394a84aa757eaa9153c487;569ab6ae55394a84aa757eaa9153c487;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;5;-297.5688,-520.3997;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;18;53.34009,-715.0232;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;46.92246,-520.101;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;320.8407,-538.1237;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;51.92246,-301.1009;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;1041.026,-559.8489;Inherit;False;882.6641;505.3285;Opacité;3;36;35;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;529.8155,-297.8705;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;1091.026,-436.0616;Inherit;False;Property;_AlphaTreshHold;AlphaTreshHold;8;0;Create;True;0;0;False;0;0.01;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;23;779.5615,-307.2774;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;432.4966,256.7207;Inherit;False;2767.016;1528.218;Comment;19;39;17;24;44;45;52;46;50;47;53;49;51;48;56;57;54;55;16;61;Gestion de la couleur;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;62;1530.911,-577.066;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;35;1394.616,-308.5204;Inherit;True;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;1715.042,468.1092;Inherit;False;Property;_ColorInValue;ColorInValue;5;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;55;2945.512,530.135;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;39;482.4966,468.8351;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;2394.755,907.4036;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;17;1335.409,490.1419;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;47;2137.241,1331.705;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;49;2150.379,1538.446;Inherit;False;Property;_ColorOutline;_ColorOutline;3;0;Create;True;0;0;False;0;1,0,0.7465525,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;24;745.6751,474.8143;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;46;2114.079,949.0653;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;769.025,-58.0802;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;446.6255,-54.88019;Inherit;False;Property;_AlphaAdaptation;AlphaAdaptation;7;0;Create;True;0;0;False;0;2.85;0;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;16;1335.4,306.7207;Inherit;True;Property;_Texture1;Texture 1;1;0;Create;True;0;0;False;0;10261a354cd704e46b122cb0c77a38e0;10261a354cd704e46b122cb0c77a38e0;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.StepOpNode;44;1783.507,536.2917;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;2394.349,1370.493;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;45;1792.345,930.3744;Inherit;True;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;2143.74,1141.887;Inherit;False;Property;_ColorMedium;_ColorMedium;4;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;2378.551,489.2153;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;48;2119.37,621.623;Inherit;False;Property;_ColorIn;_ColorIn;2;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;61;2940.038,302.4945;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;2641.471,534.8892;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;1727.616,860.7328;Inherit;False;Property;_ColorMediumValue;ColorMediumValue;6;0;Create;True;0;0;False;0;0.056;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1724.945,-349.3564;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;34;1924.241,-285.1158;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;31;3332.874,-284.2144;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;S_SmokeCartoon;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;32;1924.241,-285.1158;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;1924.241,-285.1158;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;5;0;4;0
WireConnection;12;0;5;1
WireConnection;19;0;18;3
WireConnection;19;1;12;0
WireConnection;15;0;5;3
WireConnection;20;0;15;0
WireConnection;20;1;19;0
WireConnection;23;0;20;0
WireConnection;35;0;36;0
WireConnection;35;1;23;0
WireConnection;55;0;54;0
WireConnection;39;0;38;0
WireConnection;52;0;46;0
WireConnection;52;1;50;0
WireConnection;17;0;16;0
WireConnection;17;1;24;0
WireConnection;47;0;45;0
WireConnection;24;0;39;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;38;0;37;0
WireConnection;38;1;23;0
WireConnection;44;0;56;0
WireConnection;44;1;17;1
WireConnection;53;0;47;0
WireConnection;53;1;49;0
WireConnection;45;0;57;0
WireConnection;45;1;17;1
WireConnection;51;0;44;0
WireConnection;51;1;48;0
WireConnection;61;0;55;0
WireConnection;54;0;51;0
WireConnection;54;1;52;0
WireConnection;54;2;53;0
WireConnection;41;0;62;4
WireConnection;41;1;35;0
WireConnection;31;2;61;0
WireConnection;31;3;41;0
ASEEND*/
//CHKSM=544609927689C45D058438B46962E3B00B9A3976