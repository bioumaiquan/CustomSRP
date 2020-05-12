using UnityEngine;
using UnityEngine.Rendering;
using BioumRP.PostProcess;

namespace BioumRP
{
    public partial class CameraRenderer
    {
        ScriptableRenderContext context;
        Camera camera;

        const string mainBufferName = "Render Camera";
        CommandBuffer mainBuffer = new CommandBuffer
        {
            name = mainBufferName
        };

        const string postProcessBufferName = "Post Process";
        CommandBuffer postProcessBuffer = new CommandBuffer
        {
            name = postProcessBufferName
        };

        CullingResults cullingResults;
        Lighting lighting = new Lighting();

        static int cameraColorTexID = Shader.PropertyToID("_CameraColorTexture");
        static int cameraDepthTexID = Shader.PropertyToID("_CameraDepthTexture");

        public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing, 
            ShadowSettings shadowSettings, BioumPostProcessStack postProcessStack)
        {
            this.context = context;
            this.camera = camera;

            PrepareBuffer();
            PrepareForSceneView(); //因为会在场景中添加mesh, 所以在culling之前调用

            if (!HasCullingResult(shadowSettings))
            {
                return;
            }

            mainBuffer.BeginSample(SampleName);
            ExecuteBuffer();
            lighting.Setup(context, cullingResults, shadowSettings);
            mainBuffer.EndSample(SampleName);

            if (postProcessStack)
            {
                mainBuffer.GetTemporaryRT(cameraColorTexID, camera.pixelWidth, camera.pixelHeight, 0, FilterMode.Bilinear);
                mainBuffer.GetTemporaryRT(cameraDepthTexID, camera.pixelWidth, camera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.Depth);
                mainBuffer.SetRenderTarget(
                    cameraColorTexID, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store,
                    cameraDepthTexID, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            }

            RenderSetup();

            DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);
            DrawUnsupportedShaders();
            DrawGizmos();

            if (postProcessStack)
            {
                postProcessStack.Render(postProcessBuffer, cameraColorTexID, cameraDepthTexID);
                context.ExecuteCommandBuffer(postProcessBuffer);
                postProcessBuffer.Clear();
                mainBuffer.ReleaseTemporaryRT(cameraColorTexID);
                mainBuffer.ReleaseTemporaryRT(cameraDepthTexID);
            }

            lighting.Cleanup();
            Submit();
        }

        //设置
        void RenderSetup()
        {
            context.SetupCameraProperties(camera);
            CameraClearFlags flags = camera.clearFlags;

            mainBuffer.ClearRenderTarget(
                flags <= CameraClearFlags.Depth,
                flags == CameraClearFlags.Color,
                flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear);

            mainBuffer.BeginSample(SampleName);
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
            mainBuffer.EndSample(SampleName);
            ExecuteBuffer();
            context.Submit();
        }

        //执行
        void ExecuteBuffer()
        {
            context.ExecuteCommandBuffer(mainBuffer);
            mainBuffer.Clear();
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
