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
        public Color fogColor = Color.gray;
        [SerializeField, ColorUsage(false, true)]
        public Color SunScatteringColor = new Color(0.9f, 0.78f, 0.51f);
        [SerializeField]
        public float distanceStart = 0;
        [SerializeField, Range(0f, 1f)]
        public float distanceFalloff = 1;
        [SerializeField]
        public float heightStart = 0;
        [SerializeField, Range(0f, 2f)]
        public float heightFalloff = 1;
        [SerializeField]
        public bool distanceFog = false;
        [SerializeField]
        public bool heightFog = false;
        [SerializeField]
        public bool sunScattering = false;

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
                Shader.EnableKeyword("BIOU_FOG_SIMPLE");
            }
            else
            {
                Shader.DisableKeyword("BIOU_FOG_SIMPLE");
            }

            if (heightFog)
            {
                Shader.EnableKeyword("BIOU_FOG_HEIGHT");
            }
            else
            {
                Shader.DisableKeyword("BIOU_FOG_HEIGHT");
            }

            if (sunScattering && (distanceFog || heightFog))
            {
                Shader.EnableKeyword("BIOU_FOG_SCATTERING");
            }
            else
            {
                Shader.DisableKeyword("BIOU_FOG_SCATTERING");
            }

            if (sunScattering && (distanceFog || heightFog))
            {
                //Shader.SetGlobalColor(ShaderUniforms.Scene.FogColor, fogColor);
                //Shader.SetGlobalColor(ShaderUniforms.Scene.FogSunColor, SunScatteringColor);
                //Shader.SetGlobalVector(ShaderUniforms.Scene.FogParam, fogParam);
            }
        }

#if UNITY_EDITOR
        void Update()
        {
            SetFogParam();
        }
#endif

    }
}
