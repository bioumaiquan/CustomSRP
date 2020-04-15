using UnityEngine;
using UnityEngine.Rendering;

namespace BioumRP
{
    public partial class CameraRenderer
    {
        ScriptableRenderContext context;
        Camera camera;

        const string bufferName = "Render Camera";
        CommandBuffer buffer = new CommandBuffer
        {
            name = bufferName
        };

        CullingResults cullingResults;
        Lighting lighting = new Lighting();

        public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing, ShadowSettings shadowSettings)
        {
            this.context = context;
            this.camera = camera;

            PrepareBuffer();
            PrepareForSceneView(); //因为会在场景中添加mesh, 所以在culling之前调用

            if (!HasCullingResult(shadowSettings))
            {
                return;
            }

            buffer.BeginSample(SampleName);
            ExecuteBuffer();
            lighting.Setup(context, cullingResults, shadowSettings);
            buffer.EndSample(SampleName);

            RenderSetup();

            DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);
            DrawUnsupportedShaders();
            DrawGizmos();

            lighting.Cleanup();
            Submit();
        }

        //设置
        void RenderSetup()
        {
            context.SetupCameraProperties(camera);
            CameraClearFlags flags = camera.clearFlags;

            buffer.ClearRenderTarget(
                flags <= CameraClearFlags.Depth,
                flags == CameraClearFlags.Color,
                flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear);

            buffer.BeginSample(SampleName);
            ExecuteBuffer();
        }

        //static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
        static ShaderTagId[] bioumShaderTagID =
        {
        new ShaderTagId("SRPDefaultUnlit"),
        new ShaderTagId("BioumLit"),
    };
        //绘制可见的物体
        void DrawVisibleGeometry(bool useDynamicBatching, bool useGPUInstancing)
        {
            SortingSettings sortingSettings = new SortingSettings(camera)
            {
                criteria = SortingCriteria.CommonOpaque
            };
            DrawingSettings drawingSettings = new DrawingSettings(bioumShaderTagID[0], sortingSettings)
            {
                enableDynamicBatching = useDynamicBatching,
                enableInstancing = useGPUInstancing,
                perObjectData = 
                    PerObjectData.ReflectionProbes |
                    PerObjectData.Lightmaps | PerObjectData.ShadowMask | 
                    PerObjectData.LightProbe | PerObjectData.OcclusionProbe |
                    PerObjectData.LightProbeProxyVolume | PerObjectData.OcclusionProbeProxyVolume
            };
            for (int i = 0; i < bioumShaderTagID.Length; i++)
            {
                drawingSettings.SetShaderPassName(i, bioumShaderTagID[i]);
            }
            FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

            context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings); //绘制不透明物体

            context.DrawSkybox(camera);

            sortingSettings.criteria = SortingCriteria.CommonTransparent;
            drawingSettings.sortingSettings = sortingSettings;
            filteringSettings.renderQueueRange = RenderQueueRange.transparent;
            context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings); //绘制透明物体
        }

        //提交上下文
        void Submit()
        {
            buffer.EndSample(SampleName);
            ExecuteBuffer();
            context.Submit();
        }

        //执行
        void ExecuteBuffer()
        {
            context.ExecuteCommandBuffer(buffer);
            buffer.Clear();
        }

        //判断相机范围内是否有模型, 并返回模型的信息
        bool HasCullingResult(ShadowSettings shadowSettings)
        {
            if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
            {
                p.shadowDistance = Mathf.Min(shadowSettings.maxDistance, camera.farClipPlane);
                cullingResults = context.Cull(ref p);
                return true;
            }
            return false;
        }
    }
}
