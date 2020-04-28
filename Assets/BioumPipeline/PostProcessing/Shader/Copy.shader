Shader "Hidden/BioumPostProcess/Copy"
{
    SubShader
    {
        Pass
        {
            Cull Off ZTest Always ZWrite Off

            HLSLPROGRAM
            
            #pragma target 3.5
            #pragma vertex CopyPassVertex
            #pragma fragment CopyPassFragment
            #include "ShaderLibrary/PostProcessStack.hlsl"
            ENDHLSL
        }
    }
}
