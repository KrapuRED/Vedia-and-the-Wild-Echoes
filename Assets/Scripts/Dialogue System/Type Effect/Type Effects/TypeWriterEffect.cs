using TMPro;
using UnityEngine;
using System.Collections;

public class TypeWriterEffect : TypeEffect
{
    private bool isReadyNewText = true;

    [Header("Type Writer Effect Configuration")]
    [SerializeField] private TMP_Text textBox;
    [SerializeField] private float charactertPerSeconds = 20;
    [SerializeField] private float interpuncuationDelay = 0.5f;
    private int _currentVisibleCharacterIndex;
    private Coroutine _typeWriterCoroutine;

    private WaitForSeconds _simpleyDelay;
    private WaitForSeconds _interpuncuationDelay;

    [Header("Skip Option")]
    [SerializeField] private bool quickSkipEnabled;
    [SerializeField][Min(1)] private int skipSpeedUp = 5;

    private WaitForSeconds _skipDelay;
    public bool CurrentlySkipping { get; private set; }

    [Header("Event Functional")]
    [SerializeField]
    [Range(0.1f, 0.5f)] private float textBoxFullEventDelayTime = 0.2f;
    private WaitForSeconds _textBoxFullEventDelay;
    
    
    private void Awake()
    {
        _simpleyDelay = new WaitForSeconds(1f / charactertPerSeconds);
        _interpuncuationDelay = new WaitForSeconds(interpuncuationDelay);

        _skipDelay = new WaitForSeconds(1f / (charactertPerSeconds * skipSpeedUp));
        _textBoxFullEventDelay = new WaitForSeconds(textBoxFullEventDelayTime);
    }
    
    public override void PlayTypeEffect()
    {
        StartTyping();
    }

    public override void SkipType()
    {
        
    }

    public override void SkipDialogue()
    {
        if (textBox.maxVisibleCharacters >= textBox.textInfo.characterCount - 1)
        {
            return;
        }

        if (CurrentlySkipping)
            return;

        CurrentlySkipping = true;

        if (!quickSkipEnabled)
        {
            StartCoroutine(SkipSpeedUpReset());
            return;
        }

        StopCoroutine(_typeWriterCoroutine);
        textBox.maxVisibleCharacters = textBox.textInfo.characterCount;
        IsTyping = false;
        isReadyNewText = true;
    }
    
    private void StartTyping()
    {
        IsTyping = true;
        isReadyNewText = false;

        if (_typeWriterCoroutine != null)
            StopCoroutine(_typeWriterCoroutine);

        textBox.maxVisibleCharacters = 0;
        _currentVisibleCharacterIndex = 0;

        textBox.ForceMeshUpdate();

        _typeWriterCoroutine = StartCoroutine(TypeWriting());
    }

    IEnumerator TypeWriting()
    {
        TMP_TextInfo textInfo = textBox.textInfo;

        while (_currentVisibleCharacterIndex < textInfo.characterCount)
        {
            var lastCharacterIndex = textInfo.characterCount - 1;

            if (_currentVisibleCharacterIndex == lastCharacterIndex)
            {
                textBox.maxVisibleCharacters++;
                yield return _textBoxFullEventDelay;
                
                isReadyNewText = true;
                IsTyping = false;
                yield break;
            }

            //Call Sound Typin Effect Here

            char character = textInfo.characterInfo[_currentVisibleCharacterIndex].character;

            textBox.maxVisibleCharacters++;

            if (!CurrentlySkipping &&
                (character == '?' || character == '.' || character == ',' || character == ':' || character == ';' ||
                character == '!' || character == '-'))
            {
                yield return _interpuncuationDelay;
            }
            else
            {
                yield return CurrentlySkipping ? _skipDelay : _simpleyDelay;
            }

            _currentVisibleCharacterIndex++;
        }
    }
    
    IEnumerator SkipSpeedUpReset()
    {
        yield return new WaitUntil(() => textBox.maxVisibleCharacters == textBox.textInfo.characterCount - 1);
        CurrentlySkipping = false;
    }
}
