using UnityEngine;
using System.Collections.Generic;

[System.Serializable]
public enum TutorialDialoguePosition
{
    Left,
    Right,
    LeftDown,
    LeftUp,
    RightDown,
    RightUp,
}

[CreateAssetMenu(fileName = "TutorialDataSO", menuName = "Tutorial DataSO/TutorialDataSO")]
public class TutorialDataSO : ScriptableObject
{
    public string tutorialName;
    public List<string> highLightIDs;
    public TutorialDialoguePosition tutorialDialoguePosition;
    public string tutorialDialogue;
}
