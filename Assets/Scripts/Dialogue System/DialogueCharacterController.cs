using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class DialogueCharacterController : MonoBehaviour
{
    [SerializeField] private Character activeCharacter;
    [SerializeField] private PositionCharacter positionCharacter;
    
    public Character ActiveCharacter => activeCharacter;
    public PositionCharacter PositionCharacter => positionCharacter;

    public void AssignCharacter(Character characterTarget)
    {
       if (characterTarget == null) return;

       if (activeCharacter == characterTarget)
       {
           ShowActiveCharacter();
           return;
       }
        
       activeCharacter = characterTarget;
       characterTarget.MoveCharacter(transform);
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
