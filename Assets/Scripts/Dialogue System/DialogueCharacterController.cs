using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueCharacterController : MonoBehaviour
{
    [SerializeField] private List<Character> characters = new();
    [SerializeField] private Character activeCharacter;
    [SerializeField] private PositionCharacter positionCharacter;
    
    public Character ActiveCharacter => activeCharacter;
    public IReadOnlyList<Character> Characters => characters;
    
    private void Awake()
    {
        characters = GetComponentsInChildren<Character>(true).ToList();
    }

    public void ChangeCharacterByData(CharacterDataSO targetData)
    {
        var targetCharacter = characters.FirstOrDefault(c => c.CharacterData == targetData);

        if (targetCharacter == null)
        {
            Debug.LogWarning($"[{gameObject.name}] Character data {targetData.name} tidak ditemukan di child!");
            return;
        }
        
        if (activeCharacter == targetCharacter)
        {
            ShowActiveCharacter();
            return;
        }      
        
        if (activeCharacter != null)
        {
            activeCharacter.FullHideCharacter();
        }

        activeCharacter = targetCharacter;
        ShowActiveCharacter();
    }
    
    public void ShowActiveCharacter() => activeCharacter?.ShowCharacter();
    public void DimActiveCharacter() => activeCharacter?.DimCharacter();

    public void ClearActiveCharacterReference()
    {
        activeCharacter = null;
    }
    
    public void ClearSlot()
    {
        if (activeCharacter == null)
            return;
        
        activeCharacter.FullHideCharacter();
        activeCharacter = null;
    }
}
