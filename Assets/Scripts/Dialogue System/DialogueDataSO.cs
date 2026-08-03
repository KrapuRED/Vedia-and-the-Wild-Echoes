using UnityEngine;
using System.Collections.Generic;

[System.Serializable]
public class DialogueData
{
    public string characterName;
    public CharacterDataSO characterData;
    public string dialogueLines;
}

[CreateAssetMenu(fileName = "DialogueDataSO", menuName = "Dialogue Data/DialogueDataSO")]
public class DialogueDataSO : ScriptableObject
{
    public string DialogueName;
    public List<DialogueData> dialogueData = new();
}
