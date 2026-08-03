using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TutorialDialogueUI : MonoBehaviour
{
    [SerializeField] private Image characterIcon;
    [SerializeField] private Image dialogueImage;
    [SerializeField] private TMP_Text characterNameText;
    [SerializeField] private TMP_Text dialogueText;
    
    private int _currDialogueIndex = -1;
    
    public int CurrDialogueIndex => _currDialogueIndex;
    
    public void UpdateTutorialDialogueUI(TutorialDataSO tutorialData)
    {
        _currDialogueIndex++;
        
        if ( _currDialogueIndex >= tutorialData.dialogueData.dialogueData.Count)
        {
            return;
        }
        
        var dialogueData = tutorialData.dialogueData.dialogueData[_currDialogueIndex];

        if (characterIcon != null)
            characterIcon.sprite = dialogueData.characterData?.characterIcon;

        characterNameText.text  = dialogueData.characterName;
        dialogueText.text = dialogueData.dialogueLines;
        
        Debug.Log($"{dialogueData.characterName} : {dialogueData.dialogueLines}");
    }

    public void ResetTutorialDialogueUI()
    {
        _currDialogueIndex = -1;
    }
}
