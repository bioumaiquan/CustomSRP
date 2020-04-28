using UnityEngine;
using UnityEngine.Rendering;

namespace BioumRP.PostProcess
{
    [CreateAssetMenu(menuName = "Rendering/后处理配置文件")]
    public class BioumPostProcessStack : ScriptableObject
    {
        private void OnEnable()
        {
            InitializeStatic();
        }

        static Mesh fullScreenTriangle;
        static Material material;
        static void InitializeStatic()
        {
            if (fullScreenTriangle)
            {
                return;
            }

            fullScreenTriangle = new Mesh
            {
                name = "Post Process FullScreen Triangle",
                vertices = new Vector3[]
                {
                    new Vector3(-1, -1, 0),
                    new Vector3(-1,  3, 0),
                    new Vector3( 3, -1, 0),
                },
                triangles = new int[] { 0, 1, 2 },
            };
            fullScreenTriangle.UploadMeshData(true);

            material = new Material(Shader.Find("Hidden/BioumPostProcess/Copy"))
            {
                name = "Post Process Copy Material",
                hideFlags = HideFlags.HideAndDontSave
            };
        }


        public bool usePost = false;
        public void Render(CommandBuffer cmb, int cameraColorTexID, int cameraDepthTexID)
        {
            if (!usePost)
            {
                cmb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
                cmb.DrawMesh(fullScreenTriangle, Matrix4x4.identity, material);
                return;
            }

            cmb.SetGlobalTexture(cameraColorTexID, cameraColorTexID);
            cmb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            cmb.DrawMesh(fullScreenTriangle, Matrix4x4.identity, material);
        }
    }
}
