using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DayNightManager : MonoBehaviour
{
    public static DayNightManager Instance { get; private set; }   
    public SpriteRenderer lightSpriteRenderer;
    public Light2D globalLight;
    public Vector2 MinMaxOpacity;
    public Color dayColor;
    public Color nightColor;

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
    }
    [ContextMenu("ChangeToNight")]
    public void ChangeToNight()
    {
        Color newColor = lightSpriteRenderer.color;
        newColor.a = MinMaxOpacity.x;
        lightSpriteRenderer.color = newColor;
        globalLight.color = nightColor;
    }
    [ContextMenu("ChangeToDay")]
    public void ChangeToDay()
    {
        Color newColor = lightSpriteRenderer.color;
        newColor.a = MinMaxOpacity.y;
        lightSpriteRenderer.color = newColor;
        globalLight.color = dayColor;
    }
}
