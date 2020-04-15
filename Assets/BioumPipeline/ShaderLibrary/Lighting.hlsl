#ifndef BIOUM_LIGHTING_INCLUDE
#define BIOUM_LIGHTING_INCLUDE

half3 IncomingLight(Surface surface, Light light)
{
    half ndotl = saturate(dot(surface.normal, light.direction));
    return light.color * ndotl * light.attenuation;
}

//lambert start
half3 GetLambertLighting(Surface surface, Light light)
{
    return IncomingLight(surface, light) * surface.color;
}
half3 GetLambertLighting (Surface surface) 
{
    half3 color = 0; 
    int dirLightCount = GetDirectionalLightCount();
    ShadowData shadowData = GetShadowData(surface);
    for (int i = 0; i < dirLightCount; i++)
    {
        Light light = GetDirectionalLight(i, surface, shadowData);
        color += GetLambertLighting(surface, light);
    }
    return color;
}
//lambert end


//pbr start
half3 GetPbrLighting(Surface surface, Light light, BRDF brdf)
{
    return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
}
half3 GetPbrLighting(Surface surface, BRDF brdf, GI gi)
{
    ShadowData shadowData = GetShadowData(surface);
    shadowData.shadowMask = gi.shadowMask;

    half3 color = IndirectBRDF(surface, brdf, gi.diffuse, gi.specular); 
    int dirLightCount = GetDirectionalLightCount();
    for (int i = 0; i < dirLightCount; i++)
    {
        Light light = GetDirectionalLight(i, surface, shadowData);
        color += GetPbrLighting(surface, light, brdf);
    }


    return color;
}
//pbr end

#endif