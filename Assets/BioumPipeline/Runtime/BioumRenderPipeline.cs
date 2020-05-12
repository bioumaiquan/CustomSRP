using UnityEngine;
using UnityEngine.Rendering;
using BioumRP.PostProcess;

namespace BioumRP
{
    public class BioumRenderPipeline : RenderPipeline
    {
        bool useDynamicBatching, useGPUInstancing;
        ShadowSettings shadowSettings;

        public BioumRenderPipeline(bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatching,
            ShadowSettings shadowSettings)
        {
            this.useDynamicBatching = useDynamicBatching;
            this.useGPUInstancing = useGPUInstancing;
            GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatching;
            GraphicsSettings.lightsUseLinearIntensity = true;
            this.shadowSettings = shadowSettings;
        }

        CameraRenderer renderer = new CameraRenderer();
        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {
            foreach (Camera camera in cameras)
            {
                BioumPostProcessBehaviour behaviour = camera.GetComponent<BioumPostProcessBehaviour>();
                renderer.Render(context, camera, useDynamicBatching, useGPUInstancing, shadowSettings, behaviour?.PostProcessStack);
            }
        }
    }
}
