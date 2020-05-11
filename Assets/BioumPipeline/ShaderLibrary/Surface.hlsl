#ifndef BIOUM_SURFACE_INCLUDE
#define BIOUM_SURFACE_INCLUDE

struct Surface 
{
    half3 position;
    half3 normal;
    half3 color;
    half alpha;
    half metallic;
    half smoothness;
    half3 viewDirection;
    float depth;
    half dither; //for cascade blend
    half fresnelStrength;
};

#endif