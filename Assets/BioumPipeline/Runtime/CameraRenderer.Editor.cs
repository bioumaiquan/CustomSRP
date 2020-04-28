using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.Rendering;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace BioumRP
{
    partial class CameraRenderer
    {
        partial void DrawUnsupportedShaders();
        partial void DrawGizmos();
        partial void PrepareForSceneView();
        partial void PrepareBuffer();

#if UNITY_EDITOR
        static ShaderTagId[] legacyShaderTagIds = {
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM"),
    };
        static Material errorMaterial;
        partial void DrawUnsupportedShaders() //绘制SRP不兼容的旧shader
        {
            if (errorMaterial == null)
            {
                errorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));
            }
            SortingSettings sortingSettings = new SortingSettings(camera);
            DrawingSettings drawingSettings = new DrawingSettings(legacyShaderTagIds[0], sortingSettings)
            {
                overrideMaterial = errorMaterial
            };
            for (int i = 0; i < legacyShaderTagIds.Length; i++)
            {
                drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
            }
            FilteringSettings filteringSettings = FilteringSettings.defaultValue;
            context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
        }

        partial void DrawGizmos()
        {
            if (Handles.ShouldRenderGizmos())
            {
                context.DrawGizmos(camera, GizmoSubset.PreImageEffects);
                context.DrawGizmos(camera, GizmoSubset.PostImageEffects);
            }
        }

        partial void PrepareForSceneView()
        {
            if (camera.cameraType == CameraType.SceneView)
            {
                ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
            }
        }

        string SampleName { get; set; }
        partial void PrepareBuffer()
        {
            Profiler.BeginSample("Editor Only");
            mainBuffer.name = SampleName = camera.name;
            Profiler.EndSample();
        }
#else
    const string SampleName = bufferName;
#endif
    }
}
