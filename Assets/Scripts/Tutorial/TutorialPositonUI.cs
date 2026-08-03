using System;
using UnityEngine;

public class TutorialPositonUI : MonoBehaviour
{
    [SerializeField] private TutorialDialoguePosition tutorialDialoguePosition;

    private void OnEnable()
    {
        GameEvents.OnRegisterDialoguePosition.Invoke(tutorialDialoguePosition, this.transform as  RectTransform);
    }

    private void OnDisable()
    {
        GameEvents.OnUnregisterDialoguePosition.Invoke(tutorialDialoguePosition);
    }
}
