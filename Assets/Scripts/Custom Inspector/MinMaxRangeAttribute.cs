using UnityEngine;

public class MinMaxRangeAttribute : PropertyAttribute
{
    public float Min { get; private set; }
    public float Max { get; private set; }

    public MinMaxRangeAttribute(float min, float max)
    {
        Min = min;
        Max = max;
    }
}

[System.Serializable]
public struct RangedFloat
{
    public float min;
    public float max;

    public RangedFloat(float min, float max)
    {
        this.min = min;
        this.max = max;
    }
}