using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class PerObjectMaterialProperties : MonoBehaviour
{

	static int baseColorID = Shader.PropertyToID("_BaseColor");
	static int metallicID = Shader.PropertyToID("_Metallic");
	static int smoothnessID = Shader.PropertyToID("_Smoothness");
    static int emissionColorId = Shader.PropertyToID("_EmissionColor");

    public Color baseColor = Color.white;
	[Range(0,1)]
	public float metallic = 0;
	[Range(0, 1)]
	public float smoothness = 0.5f;
    [SerializeField, ColorUsage(false, true)]
    Color emissionColor = Color.black;

    static MaterialPropertyBlock block;

    private void OnEnable()
    {
        OnValidate();
    }
    void OnValidate()
	{
		if (block == null)
		{
			block = new MaterialPropertyBlock();
		}
		block.SetColor(baseColorID, baseColor);
        block.SetColor(emissionColorId, emissionColor);
        block.SetFloat(metallicID, metallic);
		block.SetFloat(smoothnessID, smoothness);
		GetComponent<Renderer>().SetPropertyBlock(block);
	}
}
