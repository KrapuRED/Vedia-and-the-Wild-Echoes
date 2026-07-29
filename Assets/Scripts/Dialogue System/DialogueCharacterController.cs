using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueCharacterController : MonoBehaviour
{
    [SerializeField] private List<Character> characters = new();
    [SerializeField] private Character activeCharacter;
    
    public Character ActiveCharacter => activeCharacter;
    public IReadOnlyList<Character> Characters => characters;
    
    private void Awake()
    {
        characters = GetComponentsInChildren<Character>(true).ToList();
    }

    public void ChangeCharacter(Character nextCharacter)
    {
        
    }
    
    public bool Contains(Character character) => characters.Contains(character);

    public void ShowActiveCharacter() => activeCharacter?.ShowCharacter();
    public void DimActiveCharacter() => activeCharacter?.HideCharacter();

    public void ClearSlot()
    {
        
    }
}
