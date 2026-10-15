using UnityEngine;
using System.Collections.Generic;
[CreateAssetMenu(fileName = "FlashbackData", menuName = "Scriptable Objects/FlashbackData")]
public class FlashbackData : ScriptableObject
{
    public List<FlashbackParagraph> paragraphs = new List<FlashbackParagraph>();
}

[System.Serializable]
public class FlashbackParagraph
{
    [TextArea(3,15)]
    public string text;
}