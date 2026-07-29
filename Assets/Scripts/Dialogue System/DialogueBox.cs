using TMPro;
using UnityEngine;

public class DialogueBox : MonoBehaviour
{
    [SerializeField] private TypeEffect typeEffect;
    [SerializeField] private TMP_Text dialogueCharacterNameText;
    [SerializeField] private TMP_Text dialogueBoxText;

    public void UpdateDialogueBox(DialogueData dialogueData)
    {
        if (dialogueCharacterNameText == null || dialogueBoxText == null)
        {
            Debug.LogError($"[{gameObject.name} - UpdateDialogueBox] Dialogue Box Text or Dialogue Box Text are not set");
            return;
        }
        
        if (typeEffect == null)
        {
            Debug.LogError($"[{gameObject.name} - UpdateDialogueBox] type Effect are not set");
            return;
        }

        typeEffect.PlayTypeEffect();
        
        dialogueCharacterNameText.text = dialogueData.characterName;
        dialogueBoxText.text = dialogueData.dialogueLines;
    }
}
