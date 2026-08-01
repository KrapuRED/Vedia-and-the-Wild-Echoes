using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ForestMonitorUI : MonoBehaviour
{
    [SerializeField] private Slider sliderIndicator;
    [SerializeField] private TMP_Text valueIndicator;

    public void InitForestMonitorUI(float maxValue, float currentValue)
    {
        sliderIndicator.value = currentValue /  maxValue;
        valueIndicator.text = $"{currentValue:F0}%";
    }
    
    public void UpdateForestMonitorUI(float maxValue, float currentValue)
    {
        sliderIndicator.value = currentValue /  maxValue;
        valueIndicator.text = $"{currentValue:F0}%";
    }
}
