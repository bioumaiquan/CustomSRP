Shader "Bioum RP/Lit"
{
    Properties
    {
        _BaseMap ("Main Tex", 2D) = "white" {}
        _BaseColor ("Color", Color) = (0.5, 0.5, 0.5, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Fresnel ("Fresnel", Range(0, 1)) = 1
        _Cutoff ("Cutoff", Range(0, 1)) = 0.5

        [NoScaleOffset] _EmissionMap("Emission", 2D) = "white" {}
		[HDR] _EmissionColor("Emission", Color) = (0.0, 0.0, 0.0, 0.0)

        [KeywordEnum(On, Clip, Dither, Off)] _Shadows ("Shadows", Float) = 0

        [HideInInspector]_SrcBlend ("Src Blend", Float) = 1
        [HideInInspector]_DstBlend ("Dst Blend", Float) = 0
        [HideInInspector]_ZWrite ("Z Write", Float) = 1
        [HideInInspector]_AlphaTest ("Alpha Test", Float) = 0
        [HideInInspector]_PremulAlpha ("Premultiply Alpha", Float) = 0

        [HideInInspector] _MainTex("Texture for Lightmap", 2D) = "white" {}
		[HideInInspector] _Color("Color for Lightmap", Color) = (0.5, 0.5, 0.5, 1.0)
    }
    SubShader
    {
        HLSLINCLUDE
        #include "../ShaderLibrary/Common.hlsl"
		#include "LitInput.hlsl"
        ENDHLSL

        Pass
        {
            Tags{"LightMode"="BioumLit"}
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            HLSLPROGRAM
            #pragma target 3.5
            #pragma multi_compile_instancing
            #pragma shader_feature _ALPHA_TEST
            #pragma shader_feature _PREMULTIPLY_ALPHA
            #pragma multi_compile _ _DIRECTIONAL_PCF3 _DIRECTIONAL_PCF5 _DIRECTIONAL_PCF7
            #pragma multi_compile _ _CASCADE_BLEND_SOFT _CASCADE_BLEND_DITHER
            #pragma multi_compile _ _SHADOW_MASK_ALWAYS _SHADOW_MASK_DISTANCE
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile _ BIOUM_FOG_SIMPLE
            #pragma multi_compile _ BIOUM_FOG_HEIGHT
            #pragma multi_compile _ BIOUM_FOG_SCATTERING
            #pragma vertex LitVert
            #pragma fragment LitFrag
            #include "LitPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode"="ShadowCaster"}
            ColorMask 0
            HLSLPROGRAM
            #pragma target 3.5
            #pragma multi_compile_instancing
            #pragma vertex ShadowCasterVert
            #pragma fragment ShadowCasterFrag
            #pragma shader_feature _ _SHADOWS_CLIP _SHADOWS_DITHER
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #include "ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass 
        {
			Tags {"LightMode" = "Meta"}
			Cull Off

			HLSLPROGRAM
			#pragma target 3.5
			#pragma vertex MetaPassVertex
			#pragma fragment MetaPassFragment
			#include "MetaPass.hlsl"
			ENDHLSL
		}
    }
    CustomEditor "BioumShaderGUI"
}
