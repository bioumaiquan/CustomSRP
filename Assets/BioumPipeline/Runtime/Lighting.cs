using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;

namespace BioumRP
{
    public class Lighting
    {
        const string bufferName = "Lighting";
        CommandBuffer buffer = new CommandBuffer
        {
            name = bufferName
        };

        CullingResults cullingResults;
        Shadows shadows = new Shadows();
        public void Setup(ScriptableRenderContext contex, CullingResults cullingResults, ShadowSettings shadowSettings)
        {
            this.cullingResults = cullingResults;

            buffer.BeginSample(bufferName);

            shadows.Setup(contex, cullingResults, shadowSettings);
            SetupLights();
            shadows.Render();

            buffer.EndSample(bufferName);
            contex.ExecuteCommandBuffer(buffer);
            buffer.Clear();
        }

        const int maxDirLightCount = 4;
        static readonly int dirLightCountId = Shader.PropertyToID("_DirectionalLightCount");
        static readonly int dirLightColorsId = Shader.PropertyToID("_DirectionalLightColors");
        static readonly int dirLightDirectionsId = Shader.PropertyToID("_DirectionalLightDirections");
        static readonly int dirLightShadowDataId = Shader.PropertyToID("_DirectionalLightShadowData");

        static Vector4[] dirLightColors = new Vector4[maxDirLightCount];
        static Vector4[] dirLightDirections = new Vector4[maxDirLightCount];
        static Vector4[] dirLightShadowData = new Vector4[maxDirLightCount];

        void SetupLights()
        {
            NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;

            int dirLightCount = 0;
            for (int i = 0; i < visibleLights.Length; i++)
            {
                VisibleLight visibleLight = visibleLights[i];
                if (visibleLight.lightType == LightType.Directional)
                {
                    SetupDirectionalLight(dirLightCount++, ref visibleLight);
                    if (dirLightCount >= maxDirLightCount)
                    {
                        break;
                    }
                }
            }

            buffer.SetGlobalInt(dirLightCountId, dirLightCount);
            buffer.SetGlobalVectorArray(dirLightColorsId, dirLightColors);
            buffer.SetGlobalVectorArray(dirLightDirectionsId, dirLightDirections);
            buffer.SetGlobalVectorArray(dirLightShadowDataId, dirLightShadowData);
        }

        void SetupDirectionalLight(int index, ref VisibleLight visibleLight)
        {
            dirLightColors[index] = visibleLight.finalColor;
            dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);
            dirLightShadowData[index] = shadows.ReserveDirectionalShadows(visibleLight.light, index);
        }

        public void Cleanup()
        {
            shadows.Cleanup();
        }
    }
}
