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

public enum TutorialMissionType
{
    None,
    ClickIcon,
    DragFlag
}

[System.Serializable]
public class TutorialDialogueData
{
    public string characterName;
    public Sprite characterSprite;
    [TextArea(10,10)]public string tutorialDialogueLine;
    public List<string> listHighligthId = new();
    public TutorialMissionType tutorialMission;
    public string tutorialActionMapMission;
}

[CreateAssetMenu(fileName = "TutorialDataSO", menuName = "Tutorial DataSO/TutorialDataSO")]
public class TutorialDataSO : ScriptableObject
{
    public string tutorialName;
    public List<TutorialDialogueData> tutorialDialogueDatas = new();
    public TutorialDialoguePosition tutorialDialoguePosition;
}
