#ifndef BIOUM_LIT_PASS_INCLUDE
#define BIOUM_LIT_PASS_INCLUDE

#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Shadows.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/GI.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"
#include "../ShaderLibrary/Fog.hlsl"

struct appdata 
{
    float3 positionOS : POSITION;
    half3 normalOS : NORMAL;
    half4 tangentOS : TANGENT;
    float2 baseUV : TEXCOORD0;
    GI_ATTRIBUTE_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float2 baseUV : TEXCOORD1;
    half4 viewAndFog : TEXCOORD2;
    #if defined(NORMAL_MAP)
        half3x3 tangentToWorld : TEXCOORD3;
    #else
        half3 normalWS : TEXCOORD3;
    #endif
    GI_VARYINGS_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f LitVert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);
    TRANSFER_GI_DATA(v, o);

    o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
    o.positionCS = TransformWorldToHClip(o.positionWS);
    o.viewAndFog.xyz = SafeNormalize(_WorldSpaceCameraPos - o.positionWS);
    o.viewAndFog.w = ComputeFogFactor(o.positionWS, 1);

    half3 normalWS = TransformObjectToWorldNormal(v.normalOS);
    #if defined(NORMAL_MAP)
        half3 tangentWS = TransformObjectToWorldDir(v.tangentOS.xyz);
        o.tangentToWorld = CreateTangentToWorld(normalWS, tangentWS, v.tangentOS.w);
    #else
        o.normalWS = normalWS;
    #endif

    o.baseUV = TransformBaseUV(v.baseUV);
    return o;
}

half4 LitFrag(v2f i) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(i);
	ClipLOD(i.positionCS.xy, unity_LODFade.x);

    half4 baseMap = GetBase(i.baseUV);
    #if defined(_ALPHA_TEST)
        half cutoff = GetCutoff(i.baseUV);
        clip(baseMap.a - cutoff);
    #endif

    #if defined(_DITHER)
		float dither = InterleavedGradientNoise(i.positionCS.xy, 0);
		clip(baseMap.a - dither);
	#endif

    #if defined(NORMAL_MAP)
        half3 normalTS = SafeNormalize(GetNormalTS(i.baseUV));
        half3 normalWS = TransformTangentToWorld(normalTS, i.tangentToWorld);
        half3 originalNormal = i.tangentToWorld[2];
    #else
        half3 normalWS = i.normalWS;
        half3 originalNormal = i.normalWS;
    #endif

    Surface surface;
    surface.position = i.positionWS;
    surface.normal = normalWS;
    surface.originalNormal = originalNormal;
    surface.color = baseMap.rgb;
#if SSS
    surface.SSSNormal = lerp(originalNormal, normalWS, UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SSSNormalScale));
    half3 sssMap = GetSSSMap(i.baseUV).rgb;
    surface.SSSColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SSSColor).rgb * sssMap.b;
#endif
    surface.alpha = baseMap.a;
    surface.metallic = GetMetallic(i.baseUV);
    surface.smoothness = GetSmoothness(i.baseUV);
    surface.viewDirection = i.viewAndFog.xyz;
    surface.depth = -TransformWorldToView(i.positionWS).z;
    surface.dither = InterleavedGradientNoise(i.positionCS.xy, 0);
    surface.fresnelStrength = GetFresnel(i.baseUV);

    BRDF brdf = GetBRDF(surface);
    #if defined(_PREMULTIPLY_ALPHA)
        brdf.diffuse *= surface.alpha;
    #endif
    GI gi = GetGI(GI_FRAGMENT_DATA(i), surface, brdf);
    //half3 color = GetLambertLighting(surface);
    half3 color = GetPbrLighting(surface, brdf, gi);
    color += GetEmission(i.baseUV);

    i.viewAndFog.w = ComputeFogFactor(i.positionWS, 1);
    color = MixFogColor(color, i.viewAndFog.w, surface.viewDirection);

    return half4(color, surface.alpha);
}


#endif