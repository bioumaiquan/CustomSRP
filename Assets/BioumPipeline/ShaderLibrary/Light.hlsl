#ifndef BIOUM_LIGHT_INCLUDED
#define BIOUM_LIGHT_INCLUDED

#define MAX_DIRECTIONAL_LIGHT_COUNT 4

CBUFFER_START(_BioumRPLight)
    int _DirectionalLightCount;
    half4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
    half4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
    half4 _DirectionalLightShadowData[MAX_DIRECTIONAL_LIGHT_COUNT];  //x:shadow strength  y:lightID
CBUFFER_END

struct Light 
{
    half3 color;
    half3 direction;
    half attenuation;
};

int GetDirectionalLightCount()
{
    return _DirectionalLightCount;
}

DirectionalShadowData GetDirectionalShadowData(int lightIndex, ShadowData shadowData) 
{
	DirectionalShadowData data = (DirectionalShadowData)0;
	data.strength = _DirectionalLightShadowData[lightIndex].x * shadowData.strength;
	data.tileIndex = _DirectionalLightShadowData[lightIndex].y + shadowData.cascadeIndex;
    data.normalBias = _DirectionalLightShadowData[lightIndex].z;
	return data;
}

Light GetDirectionalLight(int index, Surface surfaceWS, ShadowData shadowData)
{
    Light light;
    light.color = _DirectionalLightColors[index].rgb;
    light.direction = _DirectionalLightDirections[index].xyz;
    DirectionalShadowData dirShadowData = GetDirectionalShadowData(index, shadowData);
    light.attenuation = GetDirectionalShadowAttenuation(dirShadowData, shadowData, surfaceWS);
    return light;
}



#endif