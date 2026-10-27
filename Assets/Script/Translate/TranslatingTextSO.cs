using UnityEngine;
using System.Collections.Generic;

[CreateAssetMenu(fileName = "TranslatingTextSO", menuName = "Scriptable Objects/TranslatingTextSO")]
public class TranslatingTextSO : ScriptableObject
{
    [TextArea(3, 10)]
    public string fullText;
    public List<TranslatingSlot> translatingSlots;
}
[System.Serializable]
public class TranslatingSlot
{
    public int wordIndex;
    public List<translatedTextGod> translatedText;
}
[System.Serializable]
public class translatedTextGod
{
    public GodEnum godEnum;
    public string translatedText;
}