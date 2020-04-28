using UnityEngine;

namespace BioumRP.PostProcess
{
    [RequireComponent(typeof(Camera))]
    public class BioumPostProcessBehaviour : MonoBehaviour
    {
        [SerializeField]
        BioumPostProcessStack postProcessStack = null;
        public BioumPostProcessStack PostProcessStack
        {
            get => postProcessStack;
        }
    }
}
