using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace BioumRP
{
    [ExecuteAlways, DisallowMultipleComponent]
    public class FogExtension : MonoBehaviour
    {
        [SerializeField, ColorUsage(false, true)]
        Color fogColor = Color.gray;
        [SerializeField, Min(0)]
        float distanceStart = 0;
        [SerializeField, Range(0f, 1f)]
        float distanceFalloff = 1;
        [SerializeField]
        float heightStart = 0;
        [SerializeField, Range(0f, 2f)]
        float heightFalloff = 1;
        [SerializeField]
        bool distanceFog = false;
        [SerializeField]
        bool heightFog = false;
        [SerializeField]
        bool sunScattering = false;
        [SerializeField, Range(0,1)]
        float sunScatteringStrength = 0.5f;
        [SerializeField, Min(0.1f)]
        float sunScatteringRange = 4;

        public enum Quality { low, high, }
        [SerializeField]
        Quality quality = Quality.low;

        void OnEnable()
        {
            SetFogParam();
        }

        void SetFogParam()
        {
            float dFalloff = distanceFalloff * distanceFalloff * distanceFalloff * distanceFalloff;
            float hFalloff = heightFalloff * heightFalloff * heightFalloff * heightFalloff;
            Vector4 fogParam = new Vector4(distanceStart, dFalloff, heightStart, hFalloff);
            SetFogParam(fogParam);
        }

        void SetFogParam(Vector4 fogParam)
        {
            RenderSettings.fog = false;

            if (distanceFog)
            {
                Shader.EnableKeyword("BIOUM_FOG_SIMPLE");
            }
            else
            {
                Shader.DisableKeyword("BIOUM_FOG_SIMPLE");
            }

            if (heightFog)
            {
                Shader.EnableKeyword("BIOUM_FOG_HEIGHT");
            }
            else
            {
                Shader.DisableKeyword("BIOUM_FOG_HEIGHT");
            }

            if (sunScattering && (distanceFog || heightFog))
            {
                Shader.EnableKeyword("BIOUM_FOG_SCATTERING");
            }
            else
            {
                Shader.DisableKeyword("BIOUM_FOG_SCATTERING");
            }

            if (distanceFog || heightFog)
            {
                Shader.SetGlobalColor("Bioum_FogColor", fogColor);
                Shader.SetGlobalVector("Bioum_FogScatteringParam", new Vector4(sunScatteringStrength, sunScatteringRange, 0, 0));
                Shader.SetGlobalVector("Bioum_FogParam", fogParam);
            }

            if (quality == Quality.low)
            {

            }
        }

        void OnValidate()
        {
            SetFogParam();
        }
    }
}
