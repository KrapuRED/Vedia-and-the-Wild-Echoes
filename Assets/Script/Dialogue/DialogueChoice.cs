using UnityEngine;
using System;

[System.Serializable]
public class DialogueChoice
{
    public string choiceText;
    public DialogueDatabase nextDialogue;
    public bool affectsTime;
    public int dayLimit;
}
