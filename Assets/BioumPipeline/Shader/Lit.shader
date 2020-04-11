Shader "Bioum RP/Lit"
{
    Properties
    {
        _BaseMap ("Main Tex", 2D) = "white" {}
        _BaseColor ("Color", Color) = (0.5, 0.5, 0.5, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5

        [HideInInspector]_SrcBlend ("Src Blend", Float) = 1
        [HideInInspector]_DstBlend ("Dst Blend", Float) = 0
        [HideInInspector]_ZWrite ("Z Write", Float) = 1
        [HideInInspector]_AlphaTest ("Alpha Test", Float) = 0
        [HideInInspector]_PremulAlpha ("Premultiply Alpha", Float) = 0
    }
    SubShader
    {
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
            #pragma shader_feature _ALPHA_TEST
            #include "ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "BioumShaderGUI"
}
