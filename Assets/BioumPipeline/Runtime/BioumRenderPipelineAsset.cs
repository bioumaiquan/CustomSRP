using UnityEngine;
using UnityEngine.Rendering;

namespace BioumRP
{
    [CreateAssetMenu(menuName = "Rendering/渲染管线配置文件")]
    public class BioumRenderPipelineAsset : RenderPipelineAsset
    {
        [SerializeField]
        bool useDynamicBatching = true, useGPUInstancing = true, useSRPBatching = true;
        [SerializeField]
        ShadowSettings shadows = default;

        protected override RenderPipeline CreatePipeline()
        {
            return new BioumRenderPipeline(useDynamicBatching, useGPUInstancing, useSRPBatching, shadows);
        }
    }
}
