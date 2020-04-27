#ifndef BIOUM_COMMON_INCLUDE
#define BIOUM_COMMON_INCLUDE

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "UnityInput.hlsl"

#define UNITY_MATRIX_M      unity_ObjectToWorld
#define UNITY_MATRIX_I_M    unity_WorldToObject
#define UNITY_MATRIX_V      unity_MatrixV
#define UNITY_MATRIX_VP     unity_MatrixVP
#define UNITY_MATRIX_P      glstate_matrix_projection

#if defined(_SHADOW_MASK_ALWAYS) || defined(_SHADOW_MASK_DISTANCE)
	#define SHADOWS_SHADOWMASK
#endif

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

half Square(half v)
{
	return v * v;
}
half2 Square(half2 v)
{
	return v * v;
}
half3 Square(half3 v)
{
	return v * v;
}

float DistanceSquared(float3 pA, float3 pB) 
{
	return dot(pA - pB, pA - pB);
}

void ClipLOD (float2 positionCS, float fade) 
{
	#if defined(LOD_FADE_CROSSFADE)
		float dither = InterleavedGradientNoise(positionCS.xy, 0);
		clip(fade + (fade < 0.0 ? dither : -dither));
	#endif
}

#endif