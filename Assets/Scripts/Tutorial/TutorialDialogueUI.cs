using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TutorialDialogueUI : MonoBehaviour
{
    [Tooltip("The panel that should actually move to each step's target position. Defaults to this object's own RectTransform if left empty.")]
    [SerializeField] private RectTransform dialogueRootRect;
    
    [SerializeField] private Image characterIcon;
    [SerializeField] private TMP_Text characterNameText;
    [SerializeField] private TMP_Text dialogueText;
    
    private int _currDialogueIndex = -1;
    
    public int CurrDialogueIndex => _currDialogueIndex;
    
    public void UpdateTutorialDialogueUI(TutorialDataSO tutorialData, RectTransform positionDialogue)
    {
        _currDialogueIndex++;
        
        if ( _currDialogueIndex >= tutorialData.dialogueData.dialogueData.Count)
        {
            return;
        }
        
        if (positionDialogue != null && dialogueRootRect != null)
        {
            dialogueRootRect.position = positionDialogue.position;

            bool onRightSide = positionDialogue.position.x > Screen.width * 0.5f;
            SetFlipped(onRightSide);
        }
        
        var dialogueData = tutorialData.dialogueData.dialogueData[_currDialogueIndex];
        

        characterNameText.text  = dialogueData.characterName;
        dialogueText.text = dialogueData.dialogueLines;
        
        Debug.Log($"{dialogueData.characterName} : {dialogueData.dialogueLines}");
    }

    private void SetFlipped(bool isFlipped)
    {
        float scaleX = isFlipped ? -1f : 1f;
        
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
    
    public void ResetTutorialDialogueUI()
    {
        _currDialogueIndex = -1;
    }
}
