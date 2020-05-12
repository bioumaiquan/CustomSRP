#ifndef BIOUM_LIT_INPUT_INCLUDED
#define BIOUM_LIT_INPUT_INCLUDED

TEXTURE2D(_BaseMap);
TEXTURE2D(_NormalMap);
TEXTURE2D(_SSSMap);
TEXTURE2D(_EmissionMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(half4, _BaseMap_ST)
	UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
	UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionColor)
	UNITY_DEFINE_INSTANCED_PROP(half4, _SSSColor)
	UNITY_DEFINE_INSTANCED_PROP(half, _SSSNormalScale)
	UNITY_DEFINE_INSTANCED_PROP(half, _NormalScale)
	UNITY_DEFINE_INSTANCED_PROP(half, _Cutoff)
	UNITY_DEFINE_INSTANCED_PROP(half, _Metallic)
	UNITY_DEFINE_INSTANCED_PROP(half, _Smoothness)
	UNITY_DEFINE_INSTANCED_PROP(half, _Fresnel)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

half2 TransformBaseUV (half2 baseUV) 
{
	half4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
	return baseUV * baseST.xy + baseST.zw;
}

half4 GetBase (half2 baseUV) 
{
	half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseUV);
	half4 color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
	return map * color;
}

half4 GetSSSMap (half2 baseUV) 
{
	half4 map = SAMPLE_TEXTURE2D(_SSSMap, sampler_BaseMap, baseUV);
	return map;
}

half3 GetEmission (half2 baseUV) 
{
	half4 map = SAMPLE_TEXTURE2D(_EmissionMap, sampler_BaseMap, baseUV);
	half4 color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmissionColor);
	return map.rgb * color.rgb;
}

half3 GetNormalTS (half2 baseUV) 
{
	half4 map = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, baseUV);
	half scale = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalScale);
	return UnpackNormalScale(map, scale);
}

half GetCutoff (half2 baseUV) 
{
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff);
}

half GetMetallic (half2 baseUV) 
{
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
}

half GetSmoothness (half2 baseUV) 
{
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);
}

half GetFresnel (half2 baseUV) 
{
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Fresnel);
}

#endif