#ifndef BIOUM_LIGHTING_INCLUDE
#define BIOUM_LIGHTING_INCLUDE

struct FSphericalGausian
{
    half3 Axis;
    half Sharpness;
    half Amplitude;
};

half DotCosineLobe(FSphericalGausian SG, half3 normalWS)
{
    half muDotN = dot(SG.Axis, normalWS);
    half c0 = 0.36, c1 = 0.25 / c0;

    half eml = exp(-SG.Sharpness);
    half em2l = eml * eml;
    half rl = rcp(SG.Sharpness);

    half scale = 1 + 2 * em2l - rl;
    half bias = (eml - em2l) * rl - em2l;

    half x = sqrt(1 - scale);
    half x0 = c0 * muDotN;
    half x1 = c1 * x;

    half n = x0 + x1;
    half y = (abs(x0) <= x1) ? n * n / x : saturate(muDotN);

    return scale * y + bias;
}

FSphericalGausian MakeNormalizedSG(half3 lightDirWS, half sharpness)
{
    FSphericalGausian SG;
    SG.Axis = lightDirWS;
    SG.Sharpness = sharpness;
    SG.Amplitude = SG.Sharpness / (TWO_PI * (1 - exp(-2 * SG.Sharpness)));
    return SG;
}

half3 SGDiffuseLighting(half3 normalWS, half3 lightDirWS, half3 SSSColor)
{
    FSphericalGausian redKernel = MakeNormalizedSG(lightDirWS, 1 / max(SSSColor.r, 0.001));
    FSphericalGausian greenKernel = MakeNormalizedSG(lightDirWS, 1 / max(SSSColor.g, 0.001));
    FSphericalGausian blueKernel = MakeNormalizedSG(lightDirWS, 1 / max(SSSColor.b, 0.001));
    half3 diffuse = half3(DotCosineLobe(redKernel, normalWS), DotCosineLobe(greenKernel, normalWS), DotCosineLobe(blueKernel, normalWS));

    //filmic tonemapping
    half3 x = max(0, (diffuse - 0.004));
    diffuse = (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
    return diffuse;
}

half3 IncomingLight(Surface surface, Light light)
{
    #if defined(SSS)
        half3 SG = SGDiffuseLighting(surface.SSSNormal, light.direction, surface.SSSColor);
        return light.color * SG * light.attenuation;
    #else
        half ndotl = saturate(dot(surface.normal, light.direction));
        return light.color * ndotl * light.attenuation;
    #endif
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