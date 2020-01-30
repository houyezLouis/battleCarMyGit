// This is a copy of the source shader. Modifying this file will not affect the original shader.
Shader "Hidden/VFX/VFX_SmokeDrift/System 1/Output Particle Quad"
{
	SubShader
	{	
		Cull Off
		
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		Blend SrcAlpha OneMinusSrcAlpha
		ZTest LEqual
		ZWrite Off
		Cull Off
		
	
			
		HLSLINCLUDE
		
		#define NB_THREADS_PER_GROUP 64
		#define HAS_ATTRIBUTES 1
		#define VFX_PASSDEPTH_ACTUAL (0)
		#define VFX_PASSDEPTH_MOTION_VECTOR (1)
		#define VFX_PASSDEPTH_SELECTION (2)
		#define VFX_USE_LIFETIME_CURRENT 1
		#define VFX_USE_POSITION_CURRENT 1
		#define VFX_USE_COLOR_CURRENT 1
		#define VFX_USE_ALPHA_CURRENT 1
		#define VFX_USE_ALIVE_CURRENT 1
		#define VFX_USE_AXISX_CURRENT 1
		#define VFX_USE_AXISY_CURRENT 1
		#define VFX_USE_AXISZ_CURRENT 1
		#define VFX_USE_ANGLEX_CURRENT 1
		#define VFX_USE_ANGLEY_CURRENT 1
		#define VFX_USE_ANGLEZ_CURRENT 1
		#define VFX_USE_PIVOTX_CURRENT 1
		#define VFX_USE_PIVOTY_CURRENT 1
		#define VFX_USE_PIVOTZ_CURRENT 1
		#define VFX_USE_SIZE_CURRENT 1
		#define VFX_USE_SCALEX_CURRENT 1
		#define VFX_USE_SCALEY_CURRENT 1
		#define VFX_USE_SCALEZ_CURRENT 1
		#define VFX_USE_AGE_CURRENT 1
		#define VFX_COLORMAPPING_DEFAULT 1
		#define IS_TRANSPARENT_PARTICLE 1
		#define VFX_BLENDMODE_ALPHA 1
		#define VFX_HAS_INDIRECT_DRAW 1
		#define USE_DEAD_LIST_COUNT 1
		#define VFX_PRIMITIVE_QUAD 1
		
		
		
		
		
		
		#define VFX_LOCAL_SPACE 1
		#include "Packages/com.unity.visualeffectgraph/Shaders/RenderPipeline/Universal/VFXDefines.hlsl"
		

		CBUFFER_START(parameters)
		    float4 Size_b;
		    float Color_c;
		    uint3 PADDING_0;
		CBUFFER_END
		
		struct Attributes
		{
		    float lifetime;
		    float3 position;
		    float3 color;
		    float alpha;
		    bool alive;
		    float3 axisX;
		    float3 axisY;
		    float3 axisZ;
		    float angleX;
		    float angleY;
		    float angleZ;
		    float pivotX;
		    float pivotY;
		    float pivotZ;
		    float size;
		    float scaleX;
		    float scaleY;
		    float scaleZ;
		    float age;
		};
		
		struct SourceAttributes
		{
		};
		
		Texture2D mainTexture;
		SamplerState samplermainTexture;
		float4 mainTexture_TexelSize;
		

		
		#define VFX_NEEDS_COLOR_INTERPOLATOR (VFX_USE_COLOR_CURRENT || VFX_USE_ALPHA_CURRENT)
		#if HAS_STRIPS
		#define VFX_OPTIONAL_INTERPOLATION 
		#else
		#define VFX_OPTIONAL_INTERPOLATION nointerpolation
		#endif
		
		ByteAddressBuffer attributeBuffer;	
		
		#if VFX_HAS_INDIRECT_DRAW
		StructuredBuffer<uint> indirectBuffer;	
		#endif	
		
		#if USE_DEAD_LIST_COUNT
		ByteAddressBuffer deadListCount;
		#endif
		
		#if HAS_STRIPS
		Buffer<uint> stripDataBuffer;
		#endif
		
		#if WRITE_MOTION_VECTOR_IN_FORWARD || USE_MOTION_VECTORS_PASS
		ByteAddressBuffer elementToVFXBufferPrevious;
		#endif
		
		CBUFFER_START(outputParams)
			float nbMax;
			float systemSeed;
		CBUFFER_END
		
		// Helper macros to always use a valid instanceID
		#if defined(UNITY_STEREO_INSTANCING_ENABLED)
			#define VFX_DECLARE_INSTANCE_ID     UNITY_VERTEX_INPUT_INSTANCE_ID
			#define VFX_GET_INSTANCE_ID(i)      unity_InstanceID
		#else
			#define VFX_DECLARE_INSTANCE_ID     uint instanceID : SV_InstanceID;
			#define VFX_GET_INSTANCE_ID(i)      i.instanceID
		#endif
		
		ENDHLSL
		

		Pass
		{		
			Tags { "LightMode"="SceneSelectionPass" }
		
			ZWrite On
			Blend Off
			
			HLSLPROGRAM
			#define VFX_PASSDEPTH VFX_PASSDEPTH_SELECTION
			#pragma target 4.5
			
			struct ps_input
			{
				float4 pos : SV_POSITION;
				#if USE_FLIPBOOK_INTERPOLATION
				float4 uv : TEXCOORD0;
				#else
				float2 uv : TEXCOORD0;	
				#endif
				#if USE_ALPHA_TEST || USE_FLIPBOOK_INTERPOLATION || VFX_USE_ALPHA_CURRENT
				// x: alpha threshold
				// y: frame blending factor
				// z: alpha
				VFX_OPTIONAL_INTERPOLATION float3 builtInInterpolants : TEXCOORD1;
				#endif
				
				#if USE_FLIPBOOK_MOTIONVECTORS
				// x: motion vectors scale X
				// y: motion vectors scale Y
				VFX_OPTIONAL_INTERPOLATION float2 builtInInterpolants2 : TEXCOORD2;
				#endif
				
				#if VFX_PASSDEPTH == VFX_PASSDEPTH_MOTION_VECTOR
				float4 cPosPrevious : TEXCOORD3;
				float4 cPosNonJiterred : TEXCOORD4;
				#endif
			    
			    #if VFX_NEEDS_POSWS_INTERPOLATOR
			    float3 posWS : TEXCOORD5;
			    #endif
			    
				
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			#define VFX_VARYING_PS_INPUTS ps_input
			#define VFX_VARYING_POSCS pos
			#define VFX_VARYING_ALPHA builtInInterpolants.z
			#define VFX_VARYING_ALPHATHRESHOLD builtInInterpolants.x
			#define VFX_VARYING_FRAMEBLEND builtInInterpolants.y
			#define VFX_VARYING_MOTIONVECTORSCALE builtInInterpolants2.xy
			#define VFX_VARYING_UV uv
			
			#if VFX_NEEDS_POSWS_INTERPOLATOR
			#define VFX_VARYING_POSWS posWS
			#endif
			
			#if VFX_PASSDEPTH == VFX_PASSDEPTH_MOTION_VECTOR
			#define VFX_VARYING_VELOCITY_CPOS cPosNonJiterred
			#define VFX_VARYING_VELOCITY_CPOS_PREVIOUS cPosPrevious
			#endif
			
			#if VFX_PASSDEPTH == VFX_PASSDEPTH_MOTION_VECTOR
			
			#else
			
			#endif
			#if !(defined(VFX_VARYING_PS_INPUTS) && defined(VFX_VARYING_POSCS))
			#error VFX_VARYING_PS_INPUTS, VFX_VARYING_POSCS and VFX_VARYING_UV must be defined.
			#endif
			
			#include "Packages/com.unity.visualeffectgraph/Shaders/RenderPipeline/Universal/VFXCommon.hlsl"
			#include "Packages/com.unity.visualeffectgraph/Shaders/VFXCommon.hlsl"
			

			void Orient_4(inout float3 axisX, inout float3 axisY, inout float3 axisZ) /*mode:FaceCameraPlane axes:ZY */
			{
			    
			    float3x3 viewRot = GetVFXToViewRotMatrix();
			    axisX = viewRot[0].xyz;
			    axisY = viewRot[1].xyz;
			    #if VFX_LOCAL_SPACE // Need to remove potential scale in local transform
			    axisX = normalize(axisX);
			    axisY = normalize(axisY);
			    axisZ = cross(axisX,axisY);
			    #else
			    axisZ = -viewRot[2].xyz;
			    #endif
			    
			}
			void AttributeFromCurve_45ABB90F(inout float size, float age, float lifetime, float4 Size) /*attribute:size Composition:Overwrite AlphaComposition:Overwrite SampleMode:OverLife Mode:PerComponent ColorMode:ColorAndAlpha channels:X */
			{
			    float t = age / lifetime;
			    float value = 0.0f;
			    value = SampleCurve(Size, t);
			    size = value;
			}
			void AttributeFromCurve_48A86161(inout float3 color, inout float alpha, float age, float lifetime, float Color) /*attribute:color Composition:Overwrite AlphaComposition:Overwrite SampleMode:OverLife Mode:PerComponent ColorMode:ColorAndAlpha channels:XYZ */
			{
			    float t = age / lifetime;
			    float4 value = 0.0f;
			    value = SampleGradient(Color, t);
			    color = value.rgb;
			    alpha = value.a;
			}
			

			
			#if defined(HAS_STRIPS) && !defined(VFX_PRIMITIVE_QUAD)
			#error VFX_PRIMITIVE_QUAD must be defined when HAS_STRIPS is.
			#endif
			
			struct vs_input
			{
				VFX_DECLARE_INSTANCE_ID
			};
			
			#if HAS_STRIPS
			#define PARTICLE_IN_EDGE (id & 1)
			
			float3 GetParticlePosition(uint index)
			{
				struct Attributes attributes = (Attributes)0;
				attributes.position = asfloat(attributeBuffer.Load3((index * 0x4 + 0xA0) << 2));
				

				return attributes.position;
			}
			
			float3 GetStripTangent(float3 currentPos, uint relativeIndex, const StripData stripData)
			{
				float3 prevTangent = (float3)0.0f;
				if (relativeIndex > 0)
				{
					uint prevIndex = GetParticleIndex(relativeIndex - 1,stripData);
					prevTangent = normalize(currentPos - GetParticlePosition(prevIndex));
				}
				
				float3 nextTangent = (float3)0.0f;
				if (relativeIndex < stripData.nextIndex - 1)
				{
					uint nextIndex = GetParticleIndex(relativeIndex + 1,stripData);
					nextTangent = normalize(GetParticlePosition(nextIndex) - currentPos);
				}
				
				return normalize(prevTangent + nextTangent);
			}
			#endif
			
			#pragma vertex vert
			VFX_VARYING_PS_INPUTS vert(uint id : SV_VertexID, vs_input i)
			{
				VFX_VARYING_PS_INPUTS o = (VFX_VARYING_PS_INPUTS)0;
			
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			
			#if VFX_PRIMITIVE_TRIANGLE
				uint index = id / 3;
			#elif VFX_PRIMITIVE_QUAD
			#if HAS_STRIPS
				id += VFX_GET_INSTANCE_ID(i) * 8192;
				const uint vertexPerStripCount = (PARTICLE_PER_STRIP_COUNT - 1) << 2;
				const StripData stripData = GetStripDataFromStripIndex(id / vertexPerStripCount, PARTICLE_PER_STRIP_COUNT);
				uint currentIndex = ((id % vertexPerStripCount) >> 2) + (id & 1); // relative index of particle
				
				uint maxEdgeIndex = currentIndex - PARTICLE_IN_EDGE + 1;
				if (maxEdgeIndex >= stripData.nextIndex)
					return o;
				
				uint index = GetParticleIndex(currentIndex, stripData);
			#else
				uint index = (id >> 2) + VFX_GET_INSTANCE_ID(i) * 2048;
			#endif
			#elif VFX_PRIMITIVE_OCTAGON
				uint index = (id >> 3) + VFX_GET_INSTANCE_ID(i) * 1024;
			#endif
			
				
						uint deadCount = 0;
						#if USE_DEAD_LIST_COUNT
						deadCount = deadListCount.Load(0);
						#endif	
						if (index >= asuint(nbMax) - deadCount)
						#if USE_GEOMETRY_SHADER
							return; // cull
						#else
							return o; // cull
						#endif
						
						Attributes attributes = (Attributes)0;
						SourceAttributes sourceAttributes = (SourceAttributes)0;
						
						#if VFX_HAS_INDIRECT_DRAW
						index = indirectBuffer[index];
						attributes.lifetime = asfloat(attributeBuffer.Load((index * 0x1 + 0x80) << 2));
						attributes.position = asfloat(attributeBuffer.Load3((index * 0x4 + 0xA0) << 2));
						attributes.color = float3(1, 1, 1);
						attributes.alpha = (float)1;
						attributes.alive = (attributeBuffer.Load((index * 0x2 + 0x120) << 2));
						attributes.axisX = float3(1, 0, 0);
						attributes.axisY = float3(0, 1, 0);
						attributes.axisZ = float3(0, 0, 1);
						attributes.angleX = (float)0;
						attributes.angleY = (float)0;
						attributes.angleZ = (float)0;
						attributes.pivotX = (float)0;
						attributes.pivotY = (float)0;
						attributes.pivotZ = (float)0;
						attributes.size = (float)0.100000001;
						attributes.scaleX = (float)1;
						attributes.scaleY = (float)1;
						attributes.scaleZ = (float)1;
						attributes.age = asfloat(attributeBuffer.Load((index * 0x2 + 0x121) << 2));
						
				
						#else
						attributes.alive = (attributeBuffer.Load((index * 0x2 + 0x120) << 2));
						
				
						#if !HAS_STRIPS
						if (!attributes.alive)
							return o;
						#endif
							
						attributes.lifetime = asfloat(attributeBuffer.Load((index * 0x1 + 0x80) << 2));
						attributes.position = asfloat(attributeBuffer.Load3((index * 0x4 + 0xA0) << 2));
						attributes.color = float3(1, 1, 1);
						attributes.alpha = (float)1;
						attributes.axisX = float3(1, 0, 0);
						attributes.axisY = float3(0, 1, 0);
						attributes.axisZ = float3(0, 0, 1);
						attributes.angleX = (float)0;
						attributes.angleY = (float)0;
						attributes.angleZ = (float)0;
						attributes.pivotX = (float)0;
						attributes.pivotY = (float)0;
						attributes.pivotZ = (float)0;
						attributes.size = (float)0.100000001;
						attributes.scaleX = (float)1;
						attributes.scaleY = (float)1;
						attributes.scaleZ = (float)1;
						attributes.age = asfloat(attributeBuffer.Load((index * 0x2 + 0x121) << 2));
						
				
						#endif
						
						// Initialize built-in needed attributes
						#if HAS_STRIPS
						InitStripAttributes(index, attributes, stripData);
						#endif
							
				Orient_4( /*inout */attributes.axisX,  /*inout */attributes.axisY,  /*inout */attributes.axisZ);
				AttributeFromCurve_45ABB90F( /*inout */attributes.size, attributes.age, attributes.lifetime, Size_b);
				AttributeFromCurve_48A86161( /*inout */attributes.color,  /*inout */attributes.alpha, attributes.age, attributes.lifetime, Color_c);
				

				
			#if !HAS_STRIPS
				if (!attributes.alive)
					return o;
			#endif
				
			#if VFX_PRIMITIVE_QUAD
			
			#if HAS_STRIPS
			#if VFX_STRIPS_UV_STRECHED
				o.VFX_VARYING_UV.x = (float)(currentIndex) / (stripData.nextIndex - 1);
			#elif VFX_STRIPS_UV_PER_SEGMENT
				o.VFX_VARYING_UV.x = PARTICLE_IN_EDGE;
			#else
				
			    o.VFX_VARYING_UV.x = texCoord;
			#endif
			
				o.VFX_VARYING_UV.y = float((id & 2) >> 1);
				const float2 vOffsets = float2(0.0f,o.VFX_VARYING_UV.y - 0.5f);
				
			#if VFX_STRIPS_SWAP_UV
				o.VFX_VARYING_UV.xy = float2(1.0f - o.VFX_VARYING_UV.y, o.VFX_VARYING_UV.x);
			#endif
				
				// Orient strips along their tangents
				attributes.axisX = GetStripTangent(attributes.position, currentIndex, stripData);
			#if !VFX_STRIPS_ORIENT_CUSTOM
				attributes.axisZ = attributes.position - GetViewVFXPosition();
			#endif
				attributes.axisY = normalize(cross(attributes.axisZ, attributes.axisX));
				attributes.axisZ = normalize(cross(attributes.axisX, attributes.axisY));
				
			#else
				o.VFX_VARYING_UV.x = float(id & 1);
				o.VFX_VARYING_UV.y = float((id & 2) >> 1);
				const float2 vOffsets = o.VFX_VARYING_UV.xy - 0.5f;
			#endif
				
			#elif VFX_PRIMITIVE_TRIANGLE
			
				const float2 kOffsets[] = {
					float2(-0.5f, 	-0.288675129413604736328125f),
					float2(0.0f, 	0.57735025882720947265625f),
					float2(0.5f,	-0.288675129413604736328125f),
				};
				
				const float kUVScale = 0.866025388240814208984375f;
				
				const float2 vOffsets = kOffsets[id % 3];
				o.VFX_VARYING_UV.xy = (vOffsets * kUVScale) + 0.5f;
				
			#elif VFX_PRIMITIVE_OCTAGON	
				
				const float2 kUvs[8] = 
				{
					float2(-0.5f,	0.0f),
					float2(-0.5f,	0.5f),
					float2(0.0f,	0.5f),
					float2(0.5f,	0.5f),
					float2(0.5f,	0.0f),
					float2(0.5f,	-0.5f),
					float2(0.0f,	-0.5f),
					float2(-0.5f,	-0.5f),
				};
				
				
				cropFactor = id & 1 ? 1.0f - cropFactor : 1.0f;
				const float2 vOffsets = kUvs[id & 7] * cropFactor;
				o.VFX_VARYING_UV.xy = vOffsets + 0.5f;
				
			#endif
				
				
						float3 size3 = float3(attributes.size,attributes.size,attributes.size);
						#if VFX_USE_SCALEX_CURRENT
						size3.x *= attributes.scaleX;
						#endif
						#if VFX_USE_SCALEY_CURRENT
						size3.y *= attributes.scaleY;
						#endif
						#if VFX_USE_SCALEZ_CURRENT
						size3.z *= attributes.scaleZ;
						#endif
						
			#if HAS_STRIPS
				size3 += size3 < 0.0f ? -VFX_EPSILON : VFX_EPSILON; // Add an epsilon so that size is never 0 for strips
			#endif
				
				const float4x4 elementToVFX = GetElementToVFXMatrix(
					attributes.axisX,
					attributes.axisY,
					attributes.axisZ,
					float3(attributes.angleX,attributes.angleY,attributes.angleZ),
					float3(attributes.pivotX,attributes.pivotY,attributes.pivotZ),
					size3,
					attributes.position);
					
				float3 inputVertexPosition = float3(vOffsets, 0.0f);
				float3 vPos = mul(elementToVFX,float4(inputVertexPosition, 1.0f)).xyz;
			
				o.VFX_VARYING_POSCS = TransformPositionVFXToClip(vPos);
			    
			    float3 vPosWS = TransformPositionVFXToWorld(vPos);
				
			    #ifdef VFX_VARYING_POSWS
			        o.VFX_VARYING_POSWS = vPosWS;
			    #endif
			
				float3 normalWS = normalize(TransformDirectionVFXToWorld(normalize(-transpose(elementToVFX)[2].xyz)));
				#ifdef VFX_VARYING_NORMAL
				float normalFlip = (size3.x * size3.y * size3.z) < 0 ? -1 : 1;
				o.VFX_VARYING_NORMAL = normalFlip * normalWS;
				#endif
				#ifdef VFX_VARYING_TANGENT
				o.VFX_VARYING_TANGENT = normalize(TransformDirectionVFXToWorld(normalize(transpose(elementToVFX)[0].xyz)));
				#endif
				#ifdef VFX_VARYING_BENTFACTORS
				
				#if HAS_STRIPS
				#define BENT_FACTOR_MULTIPLIER 2.0f
				#else
				#define BENT_FACTOR_MULTIPLIER 1.41421353816986083984375f
				#endif
				o.VFX_VARYING_BENTFACTORS = vOffsets * normalBendingFactor * BENT_FACTOR_MULTIPLIER;
				#endif
				
				
						#if defined(VFX_VARYING_VELOCITY_CPOS) && defined(VFX_VARYING_VELOCITY_CPOS_PREVIOUS)
						float4x4 previousElementToVFX = (float4x4)0;
						previousElementToVFX[3] = float4(0,0,0,1);
						
						UNITY_UNROLL
						for (int itIndexMatrixRow = 0; itIndexMatrixRow < 3; ++itIndexMatrixRow)
						{
							UNITY_UNROLL
							for (int itIndexMatrixCol = 0; itIndexMatrixCol < 4; ++itIndexMatrixCol)
							{
								uint itIndexMatrix = itIndexMatrixCol * 4 + itIndexMatrixRow;
								uint read = elementToVFXBufferPrevious.Load((index * 16 + itIndexMatrix) << 2);
								previousElementToVFX[itIndexMatrixRow][itIndexMatrixCol] = asfloat(read);
							}
						}
						
						uint previousFrameIndex = elementToVFXBufferPrevious.Load((index * 16 + 15) << 2);
						o.VFX_VARYING_VELOCITY_CPOS = o.VFX_VARYING_VELOCITY_CPOS_PREVIOUS = float4(0.0f, 0.0f, 0.0f, 1.0f);
						if (asuint(currentFrameIndex) - previousFrameIndex == 1u)
						{
							float3 oldvPos = mul(previousElementToVFX,float4(inputVertexPosition, 1.0f)).xyz;
							o.VFX_VARYING_VELOCITY_CPOS_PREVIOUS = TransformPositionVFXToPreviousClip(oldvPos);
							o.VFX_VARYING_VELOCITY_CPOS = TransformPositionVFXToNonJitteredClip(vPos);
						}
						#endif
						
			
				
						#if VFX_USE_COLOR_CURRENT && defined(VFX_VARYING_COLOR)
						o.VFX_VARYING_COLOR = attributes.color;
						#endif
						#if VFX_USE_ALPHA_CURRENT && defined(VFX_VARYING_ALPHA) 
						o.VFX_VARYING_ALPHA = attributes.alpha;
						#endif
						
						#ifdef VFX_VARYING_EXPOSUREWEIGHT
						
						o.VFX_VARYING_EXPOSUREWEIGHT = exposureWeight;
						#endif
						
						#if USE_SOFT_PARTICLE && defined(VFX_VARYING_INVSOFTPARTICLEFADEDISTANCE)
						
						o.VFX_VARYING_INVSOFTPARTICLEFADEDISTANCE = invSoftParticlesFadeDistance;
						#endif
						
						#if (USE_ALPHA_TEST || WRITE_MOTION_VECTOR_IN_FORWARD) && (!VFX_SHADERGRAPH || !HAS_SHADERGRAPH_PARAM_ALPHATHRESHOLD) && defined(VFX_VARYING_ALPHATHRESHOLD)
						
						o.VFX_VARYING_ALPHATHRESHOLD = alphaThreshold;
						#endif
						
						#if USE_UV_SCALE_BIAS
						
						
						#if defined (VFX_VARYING_UV)
						o.VFX_VARYING_UV.xy = o.VFX_VARYING_UV.xy * uvScale + uvBias;
						#endif
						#endif
						
						#if defined(VFX_VARYING_POSWS)
						o.VFX_VARYING_POSWS = TransformPositionVFXToWorld(vPos);
						#endif
						
				
				
						#if USE_FLIPBOOK && defined(VFX_VARYING_UV)
						
						
						VFXUVData uvData = GetUVData(flipBookSize, invFlipBookSize, o.VFX_VARYING_UV.xy, attributes.texIndex);
						o.VFX_VARYING_UV.xy = uvData.uvs.xy;
						#if USE_FLIPBOOK_INTERPOLATION && defined(VFX_VARYING_UV) && defined (VFX_VARYING_FRAMEBLEND)
						o.VFX_VARYING_UV.zw = uvData.uvs.zw;
						o.VFX_VARYING_FRAMEBLEND = uvData.blend;
						#if USE_FLIPBOOK_MOTIONVECTORS && defined(VFX_VARYING_MOTIONVECTORSCALE)
						
						o.VFX_VARYING_MOTIONVECTORSCALE = motionVectorScale * invFlipBookSize;
						#endif
						#endif
						#endif
						
			
				
			    
			    
			
				return o;
			}
			
			
			
			
			
			
			#include "Packages/com.unity.visualeffectgraph/Shaders/VFXCommonOutput.hlsl"
			
			
			
			
			#if VFX_PASSDEPTH == VFX_PASSDEPTH_SELECTION
			int _ObjectId;
			int _PassValue;
			#endif
			
			
			
			#pragma fragment frag
			float4 frag(ps_input i) : SV_TARGET
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				VFXTransformPSInputs(i);
			    #ifdef VFX_SHADERGRAPH
			        
			        
			        
			        
			        float alpha = OUTSG.;
			    #else
			        float alpha = VFXGetFragmentColor(i).a;
			        alpha *= VFXGetTextureColor(VFX_SAMPLER(mainTexture),i).a;
			    #endif
				VFXClipFragmentColor(alpha,i);
				
				#if VFX_PASSDEPTH == VFX_PASSDEPTH_MOTION_VECTOR
					
							float2 velocity = (i.VFX_VARYING_VELOCITY_CPOS.xy/i.VFX_VARYING_VELOCITY_CPOS.w) - (i.VFX_VARYING_VELOCITY_CPOS_PREVIOUS.xy/i.VFX_VARYING_VELOCITY_CPOS_PREVIOUS.w);
							#if UNITY_UV_STARTS_AT_TOP
								velocity.y = -velocity.y;
							#endif
							float4 encodedMotionVector = 0.0f;
							VFXEncodeMotionVector(velocity * 0.5f, encodedMotionVector);
							
					return encodedMotionVector;
				#elif VFX_PASSDEPTH == VFX_PASSDEPTH_SELECTION
					return float4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif VFX_PASSDEPTH == VFX_PASSDEPTH_ACTUAL
					return (float4)0;
				#else
					#error VFX_PASSDEPTH undefined 
				#endif
			}
			
			
		
			ENDHLSL
		}
		

		// Forward pass
		Pass
		{		
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			#pragma target 4.5
			#pragma multi_compile_fog
		
			struct ps_input
			{
				float4 pos : SV_POSITION;
				#if USE_FLIPBOOK_INTERPOLATION
				float4 uv : TEXCOORD0;
				#else
				float2 uv : TEXCOORD0;	
				#endif
				#if VFX_NEEDS_COLOR_INTERPOLATOR
				VFX_OPTIONAL_INTERPOLATION float4 color : COLOR0;
				#endif
				#if USE_SOFT_PARTICLE || USE_ALPHA_TEST || USE_FLIPBOOK_INTERPOLATION || USE_EXPOSURE_WEIGHT || WRITE_MOTION_VECTOR_IN_FORWARD
				// x: inverse soft particles fade distance
				// y: alpha threshold
				// z: frame blending factor
				// w: exposure weight
				VFX_OPTIONAL_INTERPOLATION float4 builtInInterpolants : TEXCOORD1;
				#endif
				#if USE_FLIPBOOK_MOTIONVECTORS
				// x: motion vectors scale X
				// y: motion vectors scale Y
				VFX_OPTIONAL_INTERPOLATION float2 builtInInterpolants2 : TEXCOORD2;
				#endif
				#if VFX_NEEDS_POSWS_INTERPOLATOR
				float3 posWS : TEXCOORD3;
				#endif
				
				#if WRITE_MOTION_VECTOR_IN_FORWARD
				float4 cPosPrevious : TEXCOORD4;
				float4 cPosNonJiterred : TEXCOORD5;
				#endif
				
				#if SHADERGRAPH_NEEDS_NORMAL_FORWARD
				float3 normal : TEXCOORD6;
				#endif
				#if SHADERGRAPH_NEEDS_TANGENT_FORWARD
				float3 tangent : TEXCOORD7;
				#endif
				
		        
				
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			struct ps_output
			{
				float4 color : SV_Target0;
		#if WRITE_MOTION_VECTOR_IN_FORWARD
				float4 outMotionVector : SV_Target1;
		#endif
			};
		
		#define VFX_VARYING_PS_INPUTS ps_input
		#define VFX_VARYING_POSCS pos
		#define VFX_VARYING_COLOR color.rgb
		#define VFX_VARYING_ALPHA color.a
		#define VFX_VARYING_INVSOFTPARTICLEFADEDISTANCE builtInInterpolants.x
		#define VFX_VARYING_ALPHATHRESHOLD builtInInterpolants.y
		#define VFX_VARYING_FRAMEBLEND builtInInterpolants.z
		#define VFX_VARYING_MOTIONVECTORSCALE builtInInterpolants2.xy
		#define VFX_VARYING_UV uv
		#if VFX_NEEDS_POSWS_INTERPOLATOR
		#define VFX_VARYING_POSWS posWS
		#endif
		#if USE_EXPOSURE_WEIGHT
		#define VFX_VARYING_EXPOSUREWEIGHT builtInInterpolants.w
		#endif
		#if WRITE_MOTION_VECTOR_IN_FORWARD
		#define VFX_VARYING_VELOCITY_CPOS cPosNonJiterred
		#define VFX_VARYING_VELOCITY_CPOS_PREVIOUS cPosPrevious
		#endif
		
		
			
		#if SHADERGRAPH_NEEDS_NORMAL_FORWARD
		#define VFX_VARYING_NORMAL normal
		#endif
		#if SHADERGRAPH_NEEDS_TANGENT_FORWARD
		#define VFX_VARYING_TANGENT tangent
		#endif
				
			#if !(defined(VFX_VARYING_PS_INPUTS) && defined(VFX_VARYING_POSCS))
			#error VFX_VARYING_PS_INPUTS, VFX_VARYING_POSCS and VFX_VARYING_UV must be defined.
			#endif
			
			#include "Packages/com.unity.visualeffectgraph/Shaders/RenderPipeline/Universal/VFXCommon.hlsl"
			#include "Packages/com.unity.visualeffectgraph/Shaders/VFXCommon.hlsl"
			

			void Orient_4(inout float3 axisX, inout float3 axisY, inout float3 axisZ) /*mode:FaceCameraPlane axes:ZY */
			{
			    
			    float3x3 viewRot = GetVFXToViewRotMatrix();
			    axisX = viewRot[0].xyz;
			    axisY = viewRot[1].xyz;
			    #if VFX_LOCAL_SPACE // Need to remove potential scale in local transform
			    axisX = normalize(axisX);
			    axisY = normalize(axisY);
			    axisZ = cross(axisX,axisY);
			    #else
			    axisZ = -viewRot[2].xyz;
			    #endif
			    
			}
			void AttributeFromCurve_45ABB90F(inout float size, float age, float lifetime, float4 Size) /*attribute:size Composition:Overwrite AlphaComposition:Overwrite SampleMode:OverLife Mode:PerComponent ColorMode:ColorAndAlpha channels:X */
			{
			    float t = age / lifetime;
			    float value = 0.0f;
			    value = SampleCurve(Size, t);
			    size = value;
			}
			void AttributeFromCurve_48A86161(inout float3 color, inout float alpha, float age, float lifetime, float Color) /*attribute:color Composition:Overwrite AlphaComposition:Overwrite SampleMode:OverLife Mode:PerComponent ColorMode:ColorAndAlpha channels:XYZ */
			{
			    float t = age / lifetime;
			    float4 value = 0.0f;
			    value = SampleGradient(Color, t);
			    color = value.rgb;
			    alpha = value.a;
			}
			

			
			#if defined(HAS_STRIPS) && !defined(VFX_PRIMITIVE_QUAD)
			#error VFX_PRIMITIVE_QUAD must be defined when HAS_STRIPS is.
			#endif
			
			struct vs_input
			{
				VFX_DECLARE_INSTANCE_ID
			};
			
			#if HAS_STRIPS
			#define PARTICLE_IN_EDGE (id & 1)
			
			float3 GetParticlePosition(uint index)
			{
				struct Attributes attributes = (Attributes)0;
				attributes.position = asfloat(attributeBuffer.Load3((index * 0x4 + 0xA0) << 2));
				

				return attributes.position;
			}
			
			float3 GetStripTangent(float3 currentPos, uint relativeIndex, const StripData stripData)
			{
				float3 prevTangent = (float3)0.0f;
				if (relativeIndex > 0)
				{
					uint prevIndex = GetParticleIndex(relativeIndex - 1,stripData);
					prevTangent = normalize(currentPos - GetParticlePosition(prevIndex));
				}
				
				float3 nextTangent = (float3)0.0f;
				if (relativeIndex < stripData.nextIndex - 1)
				{
					uint nextIndex = GetParticleIndex(relativeIndex + 1,stripData);
					nextTangent = normalize(GetParticlePosition(nextIndex) - currentPos);
				}
				
				return normalize(prevTangent + nextTangent);
			}
			#endif
			
			#pragma vertex vert
			VFX_VARYING_PS_INPUTS vert(uint id : SV_VertexID, vs_input i)
			{
				VFX_VARYING_PS_INPUTS o = (VFX_VARYING_PS_INPUTS)0;
			
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			
			#if VFX_PRIMITIVE_TRIANGLE
				uint index = id / 3;
			#elif VFX_PRIMITIVE_QUAD
			#if HAS_STRIPS
				id += VFX_GET_INSTANCE_ID(i) * 8192;
				const uint vertexPerStripCount = (PARTICLE_PER_STRIP_COUNT - 1) << 2;
				const StripData stripData = GetStripDataFromStripIndex(id / vertexPerStripCount, PARTICLE_PER_STRIP_COUNT);
				uint currentIndex = ((id % vertexPerStripCount) >> 2) + (id & 1); // relative index of particle
				
				uint maxEdgeIndex = currentIndex - PARTICLE_IN_EDGE + 1;
				if (maxEdgeIndex >= stripData.nextIndex)
					return o;
				
				uint index = GetParticleIndex(currentIndex, stripData);
			#else
				uint index = (id >> 2) + VFX_GET_INSTANCE_ID(i) * 2048;
			#endif
			#elif VFX_PRIMITIVE_OCTAGON
				uint index = (id >> 3) + VFX_GET_INSTANCE_ID(i) * 1024;
			#endif
			
				
						uint deadCount = 0;
						#if USE_DEAD_LIST_COUNT
						deadCount = deadListCount.Load(0);
						#endif	
						if (index >= asuint(nbMax) - deadCount)
						#if USE_GEOMETRY_SHADER
							return; // cull
						#else
							return o; // cull
						#endif
						
						Attributes attributes = (Attributes)0;
						SourceAttributes sourceAttributes = (SourceAttributes)0;
						
						#if VFX_HAS_INDIRECT_DRAW
						index = indirectBuffer[index];
						attributes.lifetime = asfloat(attributeBuffer.Load((index * 0x1 + 0x80) << 2));
						attributes.position = asfloat(attributeBuffer.Load3((index * 0x4 + 0xA0) << 2));
						attributes.color = float3(1, 1, 1);
						attributes.alpha = (float)1;
						attributes.alive = (attributeBuffer.Load((index * 0x2 + 0x120) << 2));
						attributes.axisX = float3(1, 0, 0);
						attributes.axisY = float3(0, 1, 0);
						attributes.axisZ = float3(0, 0, 1);
						attributes.angleX = (float)0;
						attributes.angleY = (float)0;
						attributes.angleZ = (float)0;
						attributes.pivotX = (float)0;
						attributes.pivotY = (float)0;
						attributes.pivotZ = (float)0;
						attributes.size = (float)0.100000001;
						attributes.scaleX = (float)1;
						attributes.scaleY = (float)1;
						attributes.scaleZ = (float)1;
						attributes.age = asfloat(attributeBuffer.Load((index * 0x2 + 0x121) << 2));
						
				
						#else
						attributes.alive = (attributeBuffer.Load((index * 0x2 + 0x120) << 2));
						
				
						#if !HAS_STRIPS
						if (!attributes.alive)
							return o;
						#endif
							
						attributes.lifetime = asfloat(attributeBuffer.Load((index * 0x1 + 0x80) << 2));
						attributes.position = asfloat(attributeBuffer.Load3((index * 0x4 + 0xA0) << 2));
						attributes.color = float3(1, 1, 1);
						attributes.alpha = (float)1;
						attributes.axisX = float3(1, 0, 0);
						attributes.axisY = float3(0, 1, 0);
						attributes.axisZ = float3(0, 0, 1);
						attributes.angleX = (float)0;
						attributes.angleY = (float)0;
						attributes.angleZ = (float)0;
						attributes.pivotX = (float)0;
						attributes.pivotY = (float)0;
						attributes.pivotZ = (float)0;
						attributes.size = (float)0.100000001;
						attributes.scaleX = (float)1;
						attributes.scaleY = (float)1;
						attributes.scaleZ = (float)1;
						attributes.age = asfloat(attributeBuffer.Load((index * 0x2 + 0x121) << 2));
						
				
						#endif
						
						// Initialize built-in needed attributes
						#if HAS_STRIPS
						InitStripAttributes(index, attributes, stripData);
						#endif
							
				Orient_4( /*inout */attributes.axisX,  /*inout */attributes.axisY,  /*inout */attributes.axisZ);
				AttributeFromCurve_45ABB90F( /*inout */attributes.size, attributes.age, attributes.lifetime, Size_b);
				AttributeFromCurve_48A86161( /*inout */attributes.color,  /*inout */attributes.alpha, attributes.age, attributes.lifetime, Color_c);
				

				
			#if !HAS_STRIPS
				if (!attributes.alive)
					return o;
			#endif
				
			#if VFX_PRIMITIVE_QUAD
			
			#if HAS_STRIPS
			#if VFX_STRIPS_UV_STRECHED
				o.VFX_VARYING_UV.x = (float)(currentIndex) / (stripData.nextIndex - 1);
			#elif VFX_STRIPS_UV_PER_SEGMENT
				o.VFX_VARYING_UV.x = PARTICLE_IN_EDGE;
			#else
				
			    o.VFX_VARYING_UV.x = texCoord;
			#endif
			
				o.VFX_VARYING_UV.y = float((id & 2) >> 1);
				const float2 vOffsets = float2(0.0f,o.VFX_VARYING_UV.y - 0.5f);
				
			#if VFX_STRIPS_SWAP_UV
				o.VFX_VARYING_UV.xy = float2(1.0f - o.VFX_VARYING_UV.y, o.VFX_VARYING_UV.x);
			#endif
				
				// Orient strips along their tangents
				attributes.axisX = GetStripTangent(attributes.position, currentIndex, stripData);
			#if !VFX_STRIPS_ORIENT_CUSTOM
				attributes.axisZ = attributes.position - GetViewVFXPosition();
			#endif
				attributes.axisY = normalize(cross(attributes.axisZ, attributes.axisX));
				attributes.axisZ = normalize(cross(attributes.axisX, attributes.axisY));
				
			#else
				o.VFX_VARYING_UV.x = float(id & 1);
				o.VFX_VARYING_UV.y = float((id & 2) >> 1);
				const float2 vOffsets = o.VFX_VARYING_UV.xy - 0.5f;
			#endif
				
			#elif VFX_PRIMITIVE_TRIANGLE
			
				const float2 kOffsets[] = {
					float2(-0.5f, 	-0.288675129413604736328125f),
					float2(0.0f, 	0.57735025882720947265625f),
					float2(0.5f,	-0.288675129413604736328125f),
				};
				
				const float kUVScale = 0.866025388240814208984375f;
				
				const float2 vOffsets = kOffsets[id % 3];
				o.VFX_VARYING_UV.xy = (vOffsets * kUVScale) + 0.5f;
				
			#elif VFX_PRIMITIVE_OCTAGON	
				
				const float2 kUvs[8] = 
				{
					float2(-0.5f,	0.0f),
					float2(-0.5f,	0.5f),
					float2(0.0f,	0.5f),
					float2(0.5f,	0.5f),
					float2(0.5f,	0.0f),
					float2(0.5f,	-0.5f),
					float2(0.0f,	-0.5f),
					float2(-0.5f,	-0.5f),
				};
				
				
				cropFactor = id & 1 ? 1.0f - cropFactor : 1.0f;
				const float2 vOffsets = kUvs[id & 7] * cropFactor;
				o.VFX_VARYING_UV.xy = vOffsets + 0.5f;
				
			#endif
				
				
						float3 size3 = float3(attributes.size,attributes.size,attributes.size);
						#if VFX_USE_SCALEX_CURRENT
						size3.x *= attributes.scaleX;
						#endif
						#if VFX_USE_SCALEY_CURRENT
						size3.y *= attributes.scaleY;
						#endif
						#if VFX_USE_SCALEZ_CURRENT
						size3.z *= attributes.scaleZ;
						#endif
						
			#if HAS_STRIPS
				size3 += size3 < 0.0f ? -VFX_EPSILON : VFX_EPSILON; // Add an epsilon so that size is never 0 for strips
			#endif
				
				const float4x4 elementToVFX = GetElementToVFXMatrix(
					attributes.axisX,
					attributes.axisY,
					attributes.axisZ,
					float3(attributes.angleX,attributes.angleY,attributes.angleZ),
					float3(attributes.pivotX,attributes.pivotY,attributes.pivotZ),
					size3,
					attributes.position);
					
				float3 inputVertexPosition = float3(vOffsets, 0.0f);
				float3 vPos = mul(elementToVFX,float4(inputVertexPosition, 1.0f)).xyz;
			
				o.VFX_VARYING_POSCS = TransformPositionVFXToClip(vPos);
			    
			    float3 vPosWS = TransformPositionVFXToWorld(vPos);
				
			    #ifdef VFX_VARYING_POSWS
			        o.VFX_VARYING_POSWS = vPosWS;
			    #endif
			
				float3 normalWS = normalize(TransformDirectionVFXToWorld(normalize(-transpose(elementToVFX)[2].xyz)));
				#ifdef VFX_VARYING_NORMAL
				float normalFlip = (size3.x * size3.y * size3.z) < 0 ? -1 : 1;
				o.VFX_VARYING_NORMAL = normalFlip * normalWS;
				#endif
				#ifdef VFX_VARYING_TANGENT
				o.VFX_VARYING_TANGENT = normalize(TransformDirectionVFXToWorld(normalize(transpose(elementToVFX)[0].xyz)));
				#endif
				#ifdef VFX_VARYING_BENTFACTORS
				
				#if HAS_STRIPS
				#define BENT_FACTOR_MULTIPLIER 2.0f
				#else
				#define BENT_FACTOR_MULTIPLIER 1.41421353816986083984375f
				#endif
				o.VFX_VARYING_BENTFACTORS = vOffsets * normalBendingFactor * BENT_FACTOR_MULTIPLIER;
				#endif
				
				
						#if defined(VFX_VARYING_VELOCITY_CPOS) && defined(VFX_VARYING_VELOCITY_CPOS_PREVIOUS)
						float4x4 previousElementToVFX = (float4x4)0;
						previousElementToVFX[3] = float4(0,0,0,1);
						
						UNITY_UNROLL
						for (int itIndexMatrixRow = 0; itIndexMatrixRow < 3; ++itIndexMatrixRow)
						{
							UNITY_UNROLL
							for (int itIndexMatrixCol = 0; itIndexMatrixCol < 4; ++itIndexMatrixCol)
							{
								uint itIndexMatrix = itIndexMatrixCol * 4 + itIndexMatrixRow;
								uint read = elementToVFXBufferPrevious.Load((index * 16 + itIndexMatrix) << 2);
								previousElementToVFX[itIndexMatrixRow][itIndexMatrixCol] = asfloat(read);
							}
						}
						
						uint previousFrameIndex = elementToVFXBufferPrevious.Load((index * 16 + 15) << 2);
						o.VFX_VARYING_VELOCITY_CPOS = o.VFX_VARYING_VELOCITY_CPOS_PREVIOUS = float4(0.0f, 0.0f, 0.0f, 1.0f);
						if (asuint(currentFrameIndex) - previousFrameIndex == 1u)
						{
							float3 oldvPos = mul(previousElementToVFX,float4(inputVertexPosition, 1.0f)).xyz;
							o.VFX_VARYING_VELOCITY_CPOS_PREVIOUS = TransformPositionVFXToPreviousClip(oldvPos);
							o.VFX_VARYING_VELOCITY_CPOS = TransformPositionVFXToNonJitteredClip(vPos);
						}
						#endif
						
			
				
						#if VFX_USE_COLOR_CURRENT && defined(VFX_VARYING_COLOR)
						o.VFX_VARYING_COLOR = attributes.color;
						#endif
						#if VFX_USE_ALPHA_CURRENT && defined(VFX_VARYING_ALPHA) 
						o.VFX_VARYING_ALPHA = attributes.alpha;
						#endif
						
						#ifdef VFX_VARYING_EXPOSUREWEIGHT
						
						o.VFX_VARYING_EXPOSUREWEIGHT = exposureWeight;
						#endif
						
						#if USE_SOFT_PARTICLE && defined(VFX_VARYING_INVSOFTPARTICLEFADEDISTANCE)
						
						o.VFX_VARYING_INVSOFTPARTICLEFADEDISTANCE = invSoftParticlesFadeDistance;
						#endif
						
						#if (USE_ALPHA_TEST || WRITE_MOTION_VECTOR_IN_FORWARD) && (!VFX_SHADERGRAPH || !HAS_SHADERGRAPH_PARAM_ALPHATHRESHOLD) && defined(VFX_VARYING_ALPHATHRESHOLD)
						
						o.VFX_VARYING_ALPHATHRESHOLD = alphaThreshold;
						#endif
						
						#if USE_UV_SCALE_BIAS
						
						
						#if defined (VFX_VARYING_UV)
						o.VFX_VARYING_UV.xy = o.VFX_VARYING_UV.xy * uvScale + uvBias;
						#endif
						#endif
						
						#if defined(VFX_VARYING_POSWS)
						o.VFX_VARYING_POSWS = TransformPositionVFXToWorld(vPos);
						#endif
						
				
				
						#if USE_FLIPBOOK && defined(VFX_VARYING_UV)
						
						
						VFXUVData uvData = GetUVData(flipBookSize, invFlipBookSize, o.VFX_VARYING_UV.xy, attributes.texIndex);
						o.VFX_VARYING_UV.xy = uvData.uvs.xy;
						#if USE_FLIPBOOK_INTERPOLATION && defined(VFX_VARYING_UV) && defined (VFX_VARYING_FRAMEBLEND)
						o.VFX_VARYING_UV.zw = uvData.uvs.zw;
						o.VFX_VARYING_FRAMEBLEND = uvData.blend;
						#if USE_FLIPBOOK_MOTIONVECTORS && defined(VFX_VARYING_MOTIONVECTORSCALE)
						
						o.VFX_VARYING_MOTIONVECTORSCALE = motionVectorScale * invFlipBookSize;
						#endif
						#endif
						#endif
						
			
				
			    
			    
			
				return o;
			}
			
			
			
			
			
			
			#include "Packages/com.unity.visualeffectgraph/Shaders/VFXCommonOutput.hlsl"
			
			
			
		#if VFX_SHADERGRAPH
			
		#endif
				
			#pragma fragment frag
			ps_output frag(ps_input i)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				ps_output o = (ps_output)0;
				VFXTransformPSInputs(i);
				
							#ifdef VFX_VARYING_NORMAL
							#if USE_DOUBLE_SIDED
							const float faceMul = frontFace ? 1.0f : -1.0f;
							#else
							const float faceMul = 1.0f;
							#endif
								
							float3 normalWS = i.VFX_VARYING_NORMAL * faceMul;
							const VFXUVData uvData = GetUVData(i);
							
							#ifdef VFX_VARYING_TANGENT
							float3 tangentWS = i.VFX_VARYING_TANGENT;
							float3 bitangentWS = cross(i.VFX_VARYING_TANGENT,i.VFX_VARYING_NORMAL);
							
							#if defined(VFX_VARYING_BENTFACTORS) && USE_NORMAL_BENDING	
							float3 bentFactors = float3(i.VFX_VARYING_BENTFACTORS.xy,sqrt(1.0f - dot(i.VFX_VARYING_BENTFACTORS,i.VFX_VARYING_BENTFACTORS)));
							normalWS = tangentWS * bentFactors.x + bitangentWS * bentFactors.y + normalWS * bentFactors.z;
							tangentWS = normalize(cross(normalWS,bitangentWS));
							bitangentWS = cross(tangentWS,normalWS);
							tangentWS *= faceMul;
							#endif
							
							float3x3 tbn = float3x3(tangentWS,bitangentWS,normalWS);
							
							#if USE_NORMAL_MAP
							float3 n = SampleNormalMap(VFX_SAMPLER(normalMap),uvData);
							float normalScale = 1.0f;
							#ifdef VFX_VARYING_NORMALSCALE
							normalScale = i.VFX_VARYING_NORMALSCALE;
							#endif
							normalWS = normalize(lerp(normalWS,mul(n,tbn),normalScale));
							#endif
							#endif
							#endif
							
				
		#if VFX_SHADERGRAPH
		        
		        
		        
		        
		        #if HAS_SHADERGRAPH_PARAM_COLOR
		            o.color.rgb = OUTSG..rgb;
		        #endif
		        
		        #if HAS_SHADERGRAPH_PARAM_ALPHA 
		            o.color.a = OUTSG.;
		        #endif
		#else
			
				#define VFX_TEXTURE_COLOR VFXGetTextureColor(VFX_SAMPLER(mainTexture),i)
				
						
						float4 color = VFXGetFragmentColor(i);
						
						#ifndef VFX_TEXTURE_COLOR
							#define VFX_TEXTURE_COLOR float4(1.0,1.0,1.0,1.0)
						#endif
						
						#if VFX_COLORMAPPING_DEFAULT
							o.color = color * VFX_TEXTURE_COLOR;
						#endif
						
						#if VFX_COLORMAPPING_GRADIENTMAPPED
							
							o.color = SampleGradient(gradient, VFX_TEXTURE_COLOR.a * color.a) * float4(color.rgb,1.0);
						#endif
						
						
				o.color = VFXApplyPreExposure(o.color, i);
		#endif
		
				o.color = VFXApplyFog(o.color,i);
				VFXClipFragmentColor(o.color.a,i);
				o.color.a = saturate(o.color.a);
				o.color = VFXTransformFinalColor(o.color);
				
		#if WRITE_MOTION_VECTOR_IN_FORWARD
				
						float2 velocity = (i.VFX_VARYING_VELOCITY_CPOS.xy/i.VFX_VARYING_VELOCITY_CPOS.w) - (i.VFX_VARYING_VELOCITY_CPOS_PREVIOUS.xy/i.VFX_VARYING_VELOCITY_CPOS_PREVIOUS.w);
						#if UNITY_UV_STARTS_AT_TOP
							velocity.y = -velocity.y;
						#endif
						float4 encodedMotionVector = 0.0f;
						VFXEncodeMotionVector(velocity * 0.5f, encodedMotionVector);
						
				o.outMotionVector = encodedMotionVector;
		        o.outMotionVector.a = o.color.a < i.VFX_VARYING_ALPHATHRESHOLD ? 0.0f : 1.0f; //Independant clipping for motion vector pass
		#endif
				return o;
			}
			ENDHLSL
		}
		

		
	}
}
