#ifndef BIOUM_POST_PROCESS_STACK
#define BIOUM_POST_PROCESS_STACK

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

TEXTURE2D(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);
float4 _ProjectionParams;

struct VertexInput 
{
	half4 positionOS : POSITION;
};

struct VertexOutput 
{
	half4 positionCS : SV_POSITION;
	half2 uv : TEXCOORD0;
};

VertexOutput CopyPassVertex (VertexInput input) 
{
	VertexOutput output;
	output.positionCS = float4(input.positionOS.xy, 0.0, 1.0);

	output.uv = input.positionOS.xy * 0.5 + 0.5;
	if (_ProjectionParams.x < 0)
	{
		output.uv.y = 1 - output.uv.y;
	}

	return output;
}

float4 CopyPassFragment (VertexOutput input) : SV_TARGET 
{
	return SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, input.uv) * half4(1,0,0,1);
}

#endif // BIOUM_POST_PROCESS_STACK