using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueManager : MonoBehaviour
{
    public static DialogueManager Instance { get; private set; }

    [Header("Dialogue Character Position COnfig")]
    [SerializeField] private DialogueCharacterController character1;
    [SerializeField] private DialogueCharacterController character2;
    
    [Header(("Dialogue Data Config"))] 
    [SerializeField] private DialogueBox dialogueBox;
    [SerializeField] private DialogueDataSO dialogueDataSO;
    
    private int _currDialogueIndex = 0;
    
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        //Init Character from the dialogueDataSO
        StartDialogue();
    }

    private Character FindCharacterByData(CharacterDataSO characterData)
    {
        for (int i = 0; i < character1.Characters.Count; i++)
            if (character1.Characters[i].CharacterData == characterData)
                return character1.Characters[i];

        for (int i = 0; i < character2.Characters.Count; i++)
            if (character2.Characters[i].CharacterData == characterData)
                return character2.Characters[i];

        return null;
    }

    private DialogueCharacterController GetOwningSlot(Character character)
    {
        if (character1.Contains(character))
            return character1;
        if (character2.Contains(character))
            return character2;
        return null;
    }
    
    private void DisplayCurrentLine()
    {
        var line = dialogueDataSO.dialogueData[_currDialogueIndex];
        dialogueBox.UpdateDialogueBox(line);
        
    }
    
    public void StartDialogue()
    {
        if (dialogueBox == null)
        {
            Debug.LogError($"[{gameObject.name} - StartDialogue] Dialogue Box is Null");
            return;
        }
        
        if (dialogueDataSO == null)
        {
            Debug.LogError($"[{gameObject.name} - StartDialogue] Dialogue Data is Null");
            return;
        }
        
        DisplayCurrentLine();
    }
    
    public void ContinueDialogue()
    {
        _currDialogueIndex++;

        if (_currDialogueIndex >= dialogueDataSO.dialogueData.Count)
        {
            EndDialogue();
            return;
        }
        
        DisplayCurrentLine();
    }

    public void SkipDialogue()
    {
        
    }
    
    public void EndDialogue()
    {
        Debug.Log($"[{gameObject.name} - EndDialogue] {dialogueDataSO.dialogueName} is done");
    }
}
