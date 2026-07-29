using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueManager : MonoBehaviour
{
    public static DialogueManager Instance { get; private set; }

    [Header("Dialogue Character Position Config")]
    [SerializeField] private List<DialogueCharacterController> slots = new();
    
    [Header(("Dialogue Data Config"))] 
    [SerializeField] private DialogueBox dialogueBox;
    [SerializeField] private DialogueDataSO dialogueDataSO;
    
    private int _currDialogueIndex = -1;
    private readonly List<DialogueCharacterController> _recencyOrder = new();
    private bool isDialogueActive = false;
    
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

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
            StartDialogue();
    }

    #region ============== Dialogue Character Controller ==============

    private Character FindCharacterByData(CharacterDataSO characterData)
    {
        foreach (var slot in slots)
        {
            var match = slot.Characters.FirstOrDefault(c => c.CharacterData == characterData);
            if (match != null)
                return match;
        }
 
        Debug.Log($"[{gameObject.name}] Character {characterData.name} not found");
        return null;
    }

    private void TouchSlot(DialogueCharacterController slot)
    {
        _recencyOrder.Remove(slot);
        _recencyOrder.Insert(0, slot);
    }

    private DialogueCharacterController GetLeastRecentlyUsedSlot()
    {
        for (int i = _recencyOrder.Count - 1; i >= 0; i--)
        {
            if (slots.Contains(_recencyOrder[i]))
                return _recencyOrder[i];
        }
        
        return slots.FirstOrDefault(s => s.ActiveCharacter != null) ?? slots[0];
    }
    
    private DialogueCharacterController AssignSlot(CharacterDataSO characterData)
    {
        var existingSlot = slots.FirstOrDefault(s => s.ActiveCharacter != null && s.ActiveCharacter.CharacterData == characterData);
        if (existingSlot != null)
        {
            Debug.Log("Using existing slot");
            TouchSlot(existingSlot);
            return existingSlot;
        }
        
        var freeSlot = slots.FirstOrDefault(s => s.ActiveCharacter == null);
        if (freeSlot != null)
        {
            Debug.Log("Using Free slot");
            TouchSlot(freeSlot);
            return freeSlot;
        }
        
        Debug.Log("Find slot by LRU");
        var lru = GetLeastRecentlyUsedSlot();
        TouchSlot(lru);
        return lru;
    }
    
    private void DisplayCurrentLine()
    {
        var line = dialogueDataSO.dialogueData[_currDialogueIndex];
        var targetData = line.characterData;
        
        var targetSlot = AssignSlot(targetData);

        foreach (var slot in slots)
        {
            if (slot != targetSlot && slot.ActiveCharacter != null && slot.ActiveCharacter.CharacterData == targetData)
            {
                slot.ClearSlot();
            }
        }
        
        targetSlot.ChangeCharacterByData(targetData);
        
        foreach (var slot in slots)
        {
            if (slot == targetSlot)
            {
                Debug.Log($"[{gameObject.name} - DisplayCurrentLine] Character {targetData.name} show in {targetSlot.name}");
                slot.ShowActiveCharacter();
            }
            else
                slot.DimActiveCharacter();
        }

        dialogueBox.UpdateDialogueBox(line);
    }

    #endregion
    
    public void StartDialogue()
    {
        if (isDialogueActive)
            return;
        
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
        
        isDialogueActive = true;
        _currDialogueIndex = 0;
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
