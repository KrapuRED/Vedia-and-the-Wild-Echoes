using System;
using TMPro;
using UnityEngine;
using Febucci.UI;
using Febucci.UI.Core;

public class DialogueBox : MonoBehaviour
{
    [Header("Text Animator")] 
    [SerializeField] private TypewriterCore typewriter;

    [SerializeField] private string typeSoundEffect;
    private TextAnimatorSettings _settings;
    [SerializeField] private TMP_Text dialogueCharacterNameText;
    [SerializeField] private TMP_Text dialogueBoxText;

    private void Awake()
    {
        _settings = TextAnimatorSettings.Instance;
    }
    
    private void OnEnable()
    {
        if (typewriter != null)
        {
            typewriter.onCharacterVisible.AddListener(PlayTypeSound);
        }
    }

    private void OnDisable() => RemoveListeners();
    private void OnDestroy() => RemoveListeners();

    private void RemoveListeners()
    {
        typewriter.onCharacterVisible.RemoveAllListeners();
    }

    private void PlayTypeSound(Char character)
    {
        if (Char.IsWhiteSpace(character))
            return;
        
        if (!string.IsNullOrEmpty(typeSoundEffect))
            SoundEffectManager.Instance.PlaySoundEffect(typeSoundEffect);
    }
    
    public void UpdateDialogueBox(DialogueData dialogueData)
    {
        if (dialogueCharacterNameText == null || dialogueBoxText == null)
        {
            Debug.LogError($"[{gameObject.name} - UpdateDialogueBox] Dialogue Box Text or Dialogue Box Text are not set");
            return;
        }
        
        dialogueCharacterNameText.text = dialogueData.characterName;
        typewriter.ShowText(dialogueData.dialogueLines);
    }
}
