using UnityEngine;
using UnityEngine.Rendering;
using BioumRP;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
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