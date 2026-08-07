using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueManager : MonoBehaviour
{
    public static DialogueManager Instance { get; private set; }

    [Header("Dialogue Character Position Config")]
    [SerializeField] private List<DialogueCharacterController> slots = new();
    
    [Header("Character Pool")]
    [Tooltip("Parent transform holding ONE instance of every Character that can appear in dialogue.")]
    [SerializeField] private Transform characterPoolRoot;
    private List<Character> _characterPool = new();

    [Header(("Dialogue Data Config"))] [SerializeField]
    private UIOpeningDialogueTransition dialogueTransition;
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
        
        if (characterPoolRoot != null)
        {
            _characterPool = characterPoolRoot.GetComponentsInChildren<Character>(true).ToList();
        }
        else
        {
            Debug.LogWarning($"[{gameObject.name}] Character Pool Root is not assigned");
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
        var match = _characterPool.FirstOrDefault(c => c.CharacterData == characterData);
        if (match == null)
            Debug.Log($"[{gameObject.name}] Character {characterData.name} not found in pool");

        return match;
    }

    private DialogueCharacterController GetSlotByPosition(PositionCharacter position)
    {
        return slots.FirstOrDefault(s => s.PositionCharacter == position);
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
        var exisitingSlot = slots.FirstOrDefault(s => s.ActiveCharacter != null
                                                      && s.ActiveCharacter.CharacterData == characterData);

        if (exisitingSlot != null)
        {
            TouchSlot(exisitingSlot);
            return exisitingSlot;
        }
        
        
        int activeSlot =  slots.Count(s => s.ActiveCharacter != null);

        if (activeSlot == 0)
        {
            var middle = GetSlotByPosition(PositionCharacter.Middle);
            TouchSlot(middle);
            return middle;
        }

        if (activeSlot == 1)
        {
            var middle = GetSlotByPosition(PositionCharacter.Middle);
            var left = GetSlotByPosition(PositionCharacter.Left);
            var right = GetSlotByPosition(PositionCharacter.Right);

            if (middle.ActiveCharacter != null)
            {
                var perCharacter = middle.ActiveCharacter;
                middle.ClearActiveCharacterReference();
                left.AssignCharacter(perCharacter);
                TouchSlot(left);
            }
            
            TouchSlot(right);
            return right;
        }

        var lru = GetLeastRecentlyUsedSlot();
        TouchSlot(lru);
        return lru;
    }
    
    private void DisplayCurrentLine()
    {
        var line = dialogueDataSO.dialogueData[_currDialogueIndex];
        var targetData = line.characterData;
        var targetCharacter = FindCharacterByData(targetData);
        
        if (targetCharacter == null) return;
        
        var targetSlot = AssignSlot(targetData);

        if (targetSlot.ActiveCharacter != null && targetSlot.ActiveCharacter != targetCharacter)
        {
            targetSlot.ActiveCharacter.FullHideCharacter();
        }
        
        targetSlot.AssignCharacter(targetCharacter);

        foreach (var slot in slots)
        {
            if (slot == targetSlot)
            {
                slot.ShowActiveCharacter();
            }
            else
            {
                slot.DimActiveCharacter();
            }
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
    
    public void EndDialogue()
    {
        Debug.Log($"[{gameObject.name} - EndDialogue] {dialogueDataSO.DialogueName} is done");

        foreach (var slot in slots)
        {
            if (slot.ActiveCharacter != null)
                slot.ActiveCharacter.FullHideCharacter();
        }
        
        dialogueTransition.HideTransition();
        isDialogueActive = false;
    }
}
