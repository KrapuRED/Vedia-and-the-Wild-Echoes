using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class SpriteHDRColor : MonoBehaviour
{
    // [ColorUsage(showAlpha, isHDR)] enables the HDR slider in the Inspector!
    [ColorUsage(true, true)] 
    [SerializeField] private Color hdrColor = Color.white;

    [Tooltip("Reference name in shader. Use _Color for default Sprite shaders/Shader Graph")]
    [SerializeField] private string colorPropertyName = "_Color";

    private SpriteRenderer spriteRenderer;
    private MaterialPropertyBlock propBlock;
    private int colorPropertyID;

    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        propBlock = new MaterialPropertyBlock();
        colorPropertyID = Shader.PropertyToID(colorPropertyName);

        ApplyHDRColor();
    }

    private void OnValidate()
    {
        if (spriteRenderer == null) spriteRenderer = GetComponent<SpriteRenderer>();
        if (propBlock == null) propBlock = new MaterialPropertyBlock();
        colorPropertyID = Shader.PropertyToID(colorPropertyName);

        ApplyHDRColor();
    }

    public void SetHDRColor(Color newHDRColor)
    {
        hdrColor = newHDRColor;
        ApplyHDRColor();
    }

    private void ApplyHDRColor()
    {
        if (spriteRenderer == null) return;

        // Fetch current block and inject HDR color
        spriteRenderer.GetPropertyBlock(propBlock);
        propBlock.SetColor(colorPropertyID, hdrColor);
        spriteRenderer.SetPropertyBlock(propBlock);
    }
}