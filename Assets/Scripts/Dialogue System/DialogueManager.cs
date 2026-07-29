using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueManager : MonoBehaviour
{
    public static DialogueManager Instance { get; private set; }

    [Header("Dialogue Character Position COnfig")]
    [SerializeField] private Transform character1;
    [SerializeField] private Transform character2;
    
    [Header(("Dialogue Data Config"))] 
    [SerializeField] private DialogueBox dialogueBox;
    [SerializeField] private DialogueDataSO dialogueDataSO;
    
    private int _currDialogueIndex = 0;
    
    private readonly Dictionary<string, Character> _spawnedCharacters = new();
    
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
        InitCharacters();
        StartDialogue();
    }

    private void InitCharacters()
    {
        if (dialogueDataSO == null || dialogueDataSO.dialogueData.Count == 0)
            return;

        // Grab the first two DISTINCT characters that appear in the dialogue
        var distinctSpeakers = dialogueDataSO.dialogueData
            .Where(d => d.characterData != null)
            .Select(d => d.characterData)
            .Distinct()
            .Take(2)
            .ToList();

        Transform[] slots = { character1, character2 };
        PositionCharacter[] positions = { PositionCharacter.Left, PositionCharacter.Right };

        for (int i = 0; i < distinctSpeakers.Count; i++)
        {
            var data = distinctSpeakers[i];

            if (data.characterPrefab == null)
            {
                Debug.LogWarning($"[DialogueManager - InitCharacters] {data.characterName} has no characterPrefab assigned");
                continue;
            }

            Character instance = Instantiate(data.characterPrefab, slots[i].position, Quaternion.identity, slots[i]);
            instance.InitCharacter(positions[i]);
            instance.HideCharacter(); // start hidden, shown when they speak

            _spawnedCharacters[data.characterName] = instance;
        }

    }

    private void DisplayCurrentLine()
    {
        var line = dialogueDataSO.dialogueData[_currDialogueIndex];
        dialogueBox.UpdateDialogueBox(line);

        // Show the current speaker, dim everyone else
        foreach (var kvp in _spawnedCharacters)
        {
            if (kvp.Key == line.characterName)
                kvp.Value.ShowCharacter();
            else
                kvp.Value.HideCharacter();
        }
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
