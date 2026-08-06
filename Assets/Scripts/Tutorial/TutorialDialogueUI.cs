using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Febucci.UI;
using Febucci.UI.Core;

public class TutorialDialogueUI : MonoBehaviour
{
    public TypewriterCore typewriter;
    TextAnimatorSettings settings;
    
    [Tooltip("The panel that should actually move to each step's target position. Defaults to this object's own RectTransform if left empty.")]
    [SerializeField] private RectTransform dialogueRootRect;
    [SerializeField] private string typeSoundEffect;
    
    [SerializeField] private Image characterIcon;
    [SerializeField] private TMP_Text characterNameText;
    [SerializeField] private TMP_Text dialogueText;

    private void Awake()
    {
        settings = TextAnimatorSettings.Instance;
    }

    private void OnEnable()
    {
        if (typewriter != null)
        {
            typewriter.onCharacterVisible.AddListener(PlayTypeSound);
        }
    }

    public void UpdateTutorialDialogueUI(TutorialDataSO tutorialData, RectTransform positionDialogue, int currDialogueIndex)
    {
        if ( currDialogueIndex >= tutorialData.tutorialDialogueDatas.Count)
        {
            return;
        }
        
        if (positionDialogue != null && dialogueRootRect != null)
        {
            dialogueRootRect.position = positionDialogue.position;

            bool onRightSide = positionDialogue.position.x > Screen.width * 0.5f;
            SetFlipped(onRightSide);
        }
        
        var tutorialDialogueData = tutorialData.tutorialDialogueDatas[currDialogueIndex];

        characterIcon.sprite = tutorialDialogueData.characterSprite;
        characterNameText.text  = tutorialDialogueData.characterName;
        BuildDialogueText(tutorialDialogueData.tutorialDialogueLine);
    }
    
    private void PlayTypeSound(Char character)
    {
        if (Char.IsWhiteSpace(character))
            return;
        
        if (!string.IsNullOrEmpty(typeSoundEffect))
            SoundEffectManager.Instance.PlaySoundEffect(typeSoundEffect);
    }
    
    private void BuildDialogueText(string line)
    {
        string builtText = line;
        
        typewriter.ShowText(builtText);
    }
    
    private void SetFlipped(bool isFlipped)
    {
        float scaleX = isFlipped ? 1f : -1f;
        
        if (characterIcon != null)
            FlipRectX(characterIcon.rectTransform, scaleX);
        
        if (isFlipped)
            characterIcon.transform.SetAsLastSibling();
        else
        {
            characterIcon.transform.SetAsFirstSibling();
        }
    }

    private static void FlipRectX(RectTransform rect, float scaleX)
    {
        var scale = rect.localScale;
        scale.x = scaleX;
        rect.localScale = scale;
    }
}
