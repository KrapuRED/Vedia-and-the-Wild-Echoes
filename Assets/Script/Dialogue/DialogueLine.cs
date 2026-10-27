using UnityEngine;
using TMPro;

[System.Serializable]
public class DialogueLine
{
    public string speakerName;
    [TextArea(3, 6)]
    public string text;

    public GameObject characterPrefab;
    public string expression;
    public DialogueSide side;
    public DialogueMusicMode musicMode;
    public int musicIndex;
    public DialogueVFX visualEffect;
    public TMP_FontAsset fontAsset;

    public bool disappearAfterLine;
}

public enum DialogueSide
{
    Left,
    Right
}

public enum DialogueMusicMode
{
    KeepCurrent,

    ChangeMusic,
    StopMusic
}

public enum DialogueVFX
{
    None,
    Shake
}
