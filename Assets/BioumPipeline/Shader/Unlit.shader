Shader "Bioum RP/Unlit"
{
    Properties
    {
        _BaseMap ("Main Tex", 2D) = "white" {}
        [HideInInspector]_BaseColor ("Color", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
    }
    SubShader
    {
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex UnlitVert
            #pragma fragment UnlitFrag
            #include "UnlitPass.hlsl"

            ENDHLSL
        }
    }
}
