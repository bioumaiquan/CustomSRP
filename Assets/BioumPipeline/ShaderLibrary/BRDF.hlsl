#ifndef BIOUM_BRDF_INCLUDE
#define BIOUM_BRDF_INCLUDE

struct BRDF 
{
    half3 diffuse;
    half3 specular;
    half roughness;
};

#define MIN_REFLECTIVITY 0.04
half OneMinusReflectivity(half metallic) 
{
	half range = 1.0 - MIN_REFLECTIVITY;
	return range - metallic * range;
}

BRDF GetBRDF(Surface surface)
{
    half oneMinusReflectivity = OneMinusReflectivity(surface.metallic);

    BRDF brdf;
    brdf.diffuse = surface.color * oneMinusReflectivity;
    brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);

    float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);  // 1 - smoothness
	brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);  // roughness^2

    return brdf;
}

half SpecularStrength(Surface surface, BRDF brdf, Light light)
{
	half3 h = SafeNormalize(light.direction + surface.viewDirection);
	half nh2 = Square(saturate(dot(surface.normal, h)));
	half lh2 = Square(saturate(dot(light.direction, h)));
	half r2 = Square(brdf.roughness);
	half d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
	half normalization = brdf.roughness * 4.0 + 2.0;
	return r2 / (d2 * max(0.1, lh2) * normalization);
}

half3 DirectBRDF(Surface surface, BRDF brdf, Light light)
{
    return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

#endif