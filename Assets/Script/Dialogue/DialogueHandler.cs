using UnityEngine;
using TMPro;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.Events;
using System;
using DG.Tweening;
using System.Text.RegularExpressions;
public class DialogueHandler : MonoBehaviour
{
    public static DialogueHandler instance;

    [Header("UI")]
    public TMP_Text dialogueText;
    public TMP_Text monologueText;
    public TMP_Text speakerText;
    public TMP_Text skipText;
    public GameObject dialogueBox;
    public GameObject monologueBox;
    public GameObject nameBox;

    [SerializeField] private CanvasGroup dialogueCanvasGroup;
    [SerializeField] private CanvasGroup monologueCanvasGroup;
    [SerializeField] private float fadeDuration = 0.5f;

    [Header("Timing")]
    public float dialogueDelay;
    public float letterDelay;

    //[Header("Animators")]
    // public Animator dialogueBoxAnimator;
    // public Animator transitionAnimator;

    [Header("Characters")]
    public Transform leftSlot;
    public Transform rightSlot;

    [Header("Choices")]
    public GameObject choicePanel;
    // public DialogueChoiceButton choiceButtonPrefab;
    public Transform choiceContainer;

    [Header("Dialogue List")]
    [SerializeField] private List<DialogueDatabase> dialogueList;

    // [SerializeField] Animator skipAnim;

    private DialogueDatabase currentDialogue;
    private int currentIndex;
    private bool isTyping;

    private Coroutine typingRoutine;
    private Coroutine skipRoutine;

    public UnityEvent OnDialogueStart;
    public UnityEvent OnDialogueEnd;
    public Action OnComplete;
    private string previousMap;
    public CanvasGroup canvasGroup;
    private bool isTypingSFXPlaying;
    private bool vfxPlayedThisLine;
    private bool skipStartAnimation;
    public float typingSFXLength = 0.003f;
    // public DOTweenAnimation anim;

    [SerializeField] private TMP_FontAsset defaultFont;
    int dialogueVersion = 0; // Used to prevent old coroutines from interfering when skipping
    public bool isSkipping = false;
    bool isBusy = false;
    bool skipJustActivated = false;
    bool hasCompletedDialogue = false;
    private bool isPausedByTag;
    private bool wasMonologue = false;
    private Sequence transitionSequence;
    private bool firstLine = true;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void StartDialogue(int dialogueIndex, float delay = 0f, Action onComplete = null)
    {
        hasCompletedDialogue = false;
        firstLine = true;
        dialogueVersion++;
        isSkipping = false;
        isBusy = false;
        skipJustActivated = false;
        isTyping = false;

        if (typingRoutine != null)
        {
            StopCoroutine(typingRoutine);
            typingRoutine = null;
        }

        if (skipRoutine != null)
        {
            StopCoroutine(skipRoutine);
            skipRoutine = null;
            dialogueText.text = "";
            speakerText.text = "";
            skipText.text = "";
            monologueText.text = "";
        }
        OnComplete = onComplete;
        var currentMap = InputManager.Instance.playerInput.currentActionMap?.name;

        if (currentMap != "Dialogue")
        {
            previousMap = currentMap;
            Debug.Log("Saved Map: " + previousMap);
        }
        InputManager.Instance.SwitchTo("Dialogue");
        OnDialogueStart?.Invoke();

        currentDialogue = dialogueList[dialogueIndex];
        currentIndex = 0;

        dialogueBox.SetActive(false);
        monologueBox.SetActive(false);
        nameBox.SetActive(false);

        StartCoroutine(StartRoutine(delay));
    }

    IEnumerator StartRoutine(float delay)
    {
        yield return new WaitForSeconds(delay);

        //pengelapan layar


        //yield return new WaitForSeconds(1.2f);
        ShowLine();

        yield return new WaitForSeconds(0.1f);

        //dialogueBox.SetActive(true);

        if (currentDialogue.lines.Count == 0)
        {
            EndDialogue();
            yield break;
        }
    }
    void ShowLine()
    {
        Debug.Log("Showing: " +
        currentDialogue.lines[currentIndex].speakerName +
        " | " +
        currentDialogue.lines[currentIndex].text);
        DialogueLine line = currentDialogue.lines[currentIndex];
        bool isMonologue = !string.IsNullOrWhiteSpace(line.speakerName) &&
                       line.speakerName.Trim().ToLower() == "monologue";
        vfxPlayedThisLine = false;
        string processedText = line.text;
        HandleVisualEffect(line);
        vfxPlayedThisLine = true;
        HandleMusic(line);
        if (transitionSequence != null) transitionSequence.Kill();
        transitionSequence = DOTween.Sequence();

        if (firstLine)
        {
            // First time showing a box: just fade it in
            if (isMonologue)
            {
                monologueBox.SetActive(true);
                monologueCanvasGroup.alpha = 0f;
                transitionSequence.Append(monologueCanvasGroup.DOFade(1f, 1f));

                dialogueBox.SetActive(false);
                nameBox.SetActive(false);
                speakerText.text = "";
            }
            else
            {
                dialogueBox.SetActive(true);
                nameBox.SetActive(true);
                dialogueCanvasGroup.alpha = 0f;
                transitionSequence.Append(dialogueCanvasGroup.DOFade(1f, 1f));

                monologueBox.SetActive(false);
                speakerText.text = line.speakerName;
            }
            firstLine = false;
        }
        else if (isMonologue != wasMonologue)
        {
            // Switched from Dialogue to Monologue (or vice versa): Crossfade
            if (isMonologue)
            {
                transitionSequence.Append(dialogueCanvasGroup.DOFade(0f, fadeDuration));
                transitionSequence.AppendCallback(() => {
                    dialogueBox.SetActive(false);
                    nameBox.SetActive(false);

                    monologueBox.SetActive(true);
                    monologueCanvasGroup.alpha = 0f;
                    speakerText.text = "";
                });
                transitionSequence.Append(monologueCanvasGroup.DOFade(1f, fadeDuration));
            }
            else
            {
                transitionSequence.Append(monologueCanvasGroup.DOFade(0f, fadeDuration));
                transitionSequence.AppendCallback(() => {
                    monologueBox.SetActive(false);

                    dialogueBox.SetActive(true);
                    nameBox.SetActive(true);
                    dialogueCanvasGroup.alpha = 0f;
                    speakerText.text = line.speakerName;
                });
                transitionSequence.Append(dialogueCanvasGroup.DOFade(1f, fadeDuration));
            }
        }
        else 
        {
            // Same box type as last line: No fading needed, just ensure active
            if (isMonologue)
            {
                monologueBox.SetActive(true);
                monologueCanvasGroup.alpha = 1f;
                speakerText.text = "";
            }
            else
            {
                dialogueBox.SetActive(true);
                nameBox.SetActive(true);
                dialogueCanvasGroup.alpha = 1f;
                speakerText.text = line.speakerName;
            }
        }

        wasMonologue = isMonologue;
        TMP_Text targetText = isMonologue ? monologueText : dialogueText;
        targetText.font = line.fontAsset != null ? line.fontAsset : defaultFont;

        UpdateModeUI();
        int versionAtStart = dialogueVersion;

        if (typingRoutine != null)
        {
            try { StopCoroutine(typingRoutine); } catch { }
            typingRoutine = null;
        }
        typingRoutine = StartCoroutine(TypeTextWithCues(targetText, line.text, versionAtStart));
    }

    public void NextLine()
    {
        if (isBusy || isSkipping || skipJustActivated) return;
        if (isTyping)
        {
            if (typingRoutine != null)
                StopCoroutine(typingRoutine);
            isBusy = false;
            DialogueLine line = currentDialogue.lines[currentIndex];
            bool isMonologue = line.speakerName.Trim().ToLower() == "monologue";

            TMP_Text targetText = isMonologue ? monologueText : dialogueText;

            targetText.font = line.fontAsset != null ? line.fontAsset : defaultFont;
            targetText.text = RemoveAllTags(line.text);
            isTyping = false;
            typingRoutine = null;
            if (!isSkipping)
            {
                isBusy = false;
                return;
            }
        }

        if (isSkipping)
        {
            isSkipping = false;
            return;
        }

        currentIndex++;
        Debug.Log("Current Index: " + currentIndex);
        if (currentIndex >= currentDialogue.lines.Count)
        {
            if (currentDialogue.choices != null &&
                currentDialogue.choices.Count > 0)
            {
                ShowChoices();
                return;
            }

            EndDialogue();
            return;
        }

        ShowLine();
    }

    void ShowLineInstant(int index)
    {
        DialogueLine line = currentDialogue.lines[index];
        bool isMonologue = !string.IsNullOrWhiteSpace(line.speakerName) && line.speakerName.Trim().ToLower() == "monologue";
        if (transitionSequence != null) transitionSequence.Kill();
        if (isMonologue)
        {
            monologueBox.SetActive(true);
            monologueCanvasGroup.alpha = 1f;
            dialogueBox.SetActive(false);
            nameBox.SetActive(false);
            speakerText.text = "";

        }
        else
        {
            monologueBox.SetActive(false);
            dialogueBox.SetActive(true);
            nameBox.SetActive(true);
            dialogueCanvasGroup.alpha = 1f;
            speakerText.text = line.speakerName;
        }
        wasMonologue = isMonologue;
        firstLine = false;

        dialogueText.text = "";
        monologueText.text = "";

        TMP_Text targetText = isMonologue ? monologueText : dialogueText;

        targetText.font = line.fontAsset != null ? line.fontAsset : defaultFont;
        targetText.text = RemoveAllTags(line.text);
        HandleVisualEffect(line);
        HandleMusic(line);
    }

    IEnumerator SkipToEnd()
    {
        int version = dialogueVersion;
        int startIndex = currentIndex + 1;
        for (int i = startIndex; i < currentDialogue.lines.Count; i++)
        {
            if (version != dialogueVersion)
                yield break;

            if (!isSkipping)
                yield break;
            ShowLineInstant(i);

            bool isFinalLine = i == currentDialogue.lines.Count - 1;

            // Stop on choices
            if (isFinalLine &&
                currentDialogue.choices != null &&
                currentDialogue.choices.Count > 0)
            {
                isSkipping = false;

                UpdateModeUI();

                yield return new WaitForSeconds(0.15f);

                ShowChoices();

                yield break;
            }

            // Faster skip speed
            yield return new WaitForSeconds(0.010f);
        }

        isBusy = false;

        isSkipping = false;

        UpdateModeUI();

        if (currentDialogue.choices == null ||
            currentDialogue.choices.Count == 0)
        {
            yield return new WaitForSeconds(0.15f);

            EndDialogue();
        }
        else
        {
            ShowChoices();
        }
    }

    IEnumerator TypeTextWithCues(TMP_Text targetText, string fullText, int version)
    {
        if (version != dialogueVersion)
        {
            yield break; // Exit if this coroutine is outdated
        }
        bool isMonologue = targetText == monologueText;
        if (isMonologue)
        {
            isTyping = false;
            targetText.text = RemoveAllTags(fullText);

            // Wait here in the coroutine until the user presses the skip button
            yield return WaitForFreshSkipPress();
            if (version != dialogueVersion)
            {
                yield break; // Exit if this coroutine is outdated
            }
            if (isSkipping)
            {
                yield break;
            }
            // Once pressed, advance to the next line and exit this routine
            NextLine();
            yield break;
        }
        string plainText = RemoveAllTags(fullText);
        if (targetText.text == plainText) 
        {
            isTyping = false; 
        }
        else 
        {
            isTyping = true;
            isPausedByTag = false;
            targetText.text = "";
            for (int i = 0; i < fullText.Length; i++)
            {
                if (version != dialogueVersion)
                {
                    yield break; // Exit if this coroutine is outdated
                }
                if (fullText[i] == '#')
                {
                    int j = i + 1;
                    string number = "";

                    while (j < fullText.Length && char.IsDigit(fullText[j]))
                    {
                        number += fullText[j];
                        j++;
                    }

                    if (float.TryParse(number, out float delay))
                    {
                        isPausedByTag = true;

                        float t = 0f;
                        while (t < delay)
                        {
                            if (InputManager.Instance.SkipPressed)
                            {
                                targetText.text = RemoveAllTags(fullText);
                                isTyping = false;
                                yield break;
                            }
                            t += Time.deltaTime;
                            yield return null;
                        }

                        isPausedByTag = false;
                        i = j - 1;
                        continue;
                    }
                }
                if (fullText[i] == '<' && i + 2 < fullText.Length && fullText[i + 1] == '/')
                {
                    int endIndex = fullText.IndexOf('>', i);
                    if (endIndex != -1)
                    {
                        string number = fullText.Substring(i + 2, endIndex - (i + 2));
                        if (!isSkipping && int.TryParse(number, out int sfxIndex))
                        {
                            //AudioManager.instance.PlaySFX(sfxIndex);
                        }

                        i = endIndex;
                        continue;
                    }
                }
                else
                {
                    targetText.text += fullText[i];
                    if (fullText[i] == '.')
                    {
                        yield return new WaitForSeconds(1f); 
                    }
                    else if (fullText[i] == '?')
                    {
                        yield return new WaitForSeconds(1f); 
                    }
                    else if (fullText[i] == '!')
                    {
                        yield return new WaitForSeconds(1f); 
                    }
                    else if (fullText[i] == ',')
                    {
                        yield return new WaitForSeconds(0.75f); 
                    }

                }
                if (!char.IsWhiteSpace(fullText[i]))
                {
                    if (!isSkipping)
                    {
                        //PlayTypingSFX(); // your typing sound
                    }
                }
                if (!isSkipping && InputManager.Instance.SkipPressed)
                {
                    i = SkipToNextCue(targetText, fullText, i);
                }
                float elapsed = 0f;

                while (elapsed < letterDelay)
                {
                    if (version != dialogueVersion)
                    {
                        yield break; // Exit if this coroutine is outdated
                    }
                    elapsed += Time.deltaTime;
                    yield return null;
                }
            }
        }
        isTyping = false;
        if (version != dialogueVersion)
        {
            yield break; // Exit if this coroutine is outdated
        }
        yield return WaitForFreshSkipPress();
        if (version != dialogueVersion)
        {
            yield break; // Exit if this coroutine is outdated
        }
        if (isSkipping)
        {
            yield break;
        }
        NextLine();
    }

    int SkipToNextCue(TMP_Text targetText, string text, int startIndex)
    {
        int i = startIndex + 1;

        while (i < text.Length)
        {
            // Stop BEFORE delay cue
            if (text[i] == '#')
                return i - 1;

            // Stop BEFORE SFX cue
            if (text[i] == '<' && i + 2 < text.Length && text[i + 1] == '/')
                return i - 1;

            // Instantly reveal safe characters
            targetText.text += text[i];
            i++;
        }

        // No more cues → finish line
        dialogueText.text = RemoveAllTags(text);
        return text.Length;
    }

    void EndDialogue()
    {
        if (hasCompletedDialogue) return;
        hasCompletedDialogue = true;
        if (transitionSequence != null) transitionSequence.Kill();
        dialogueVersion++;

        StopAllCoroutines();
        // Stop typing coroutine
        if (typingRoutine != null)
        {
            StopCoroutine(typingRoutine);
            typingRoutine = null;
        }

        // Stop skip coroutine
        if (skipRoutine != null)
        {
            StopCoroutine(skipRoutine);
            skipRoutine = null;
        }
        isBusy = false;
        skipJustActivated = false;
        isTyping = false;
        isSkipping = false;
        // if (skipAnim != null) skipAnim.SetBool("isClicked", false);
        // if (dialogueBoxAnimator != null)
        //     dialogueBoxAnimator.SetTrigger("StopDialogue");

        // if (transitionAnimator != null)
        //     transitionAnimator.SetBool("isShowing", false);
        dialogueText.text = "";
        speakerText.text = "";
        skipText.text = "";
        choicePanel.SetActive(false);

        dialogueBox.SetActive(false);
        monologueBox.SetActive(false);
        nameBox.SetActive(false);
        DOVirtual.DelayedCall(0.5f, () => OnComplete?.Invoke());
        OnDialogueEnd?.Invoke(); //SHOW OBJECTS HERE

        if (!string.IsNullOrEmpty(previousMap))
        {
            Debug.Log("Restoring Map: " + previousMap);
            InputManager.Instance.SwitchTo(previousMap);
            previousMap = null;
        }
    }

    void ShowChoices()
    {
        isSkipping = false;
        choicePanel.SetActive(true);

        foreach (Transform child in choiceContainer)
            Destroy(child.gameObject);

        foreach (DialogueChoice choice in currentDialogue.choices)
        {
            // DialogueChoiceButton btn =
            //     Instantiate(choiceButtonPrefab, choiceContainer);

            // btn.Setup(choice);
        }

        // EventSystem.current.SetSelectedGameObject(choiceContainer.GetChild(0).gameObject);
    }

    public void OnChoiceSelected(DialogueChoice choice)
    {
        Debug.Log("Selected");
        if (choice.dayLimit > 0)
        {
            // DayLimitHandler.instance.StartTimedPhase(choice.dayLimit);
        }
        choicePanel.SetActive(false);
        dialogueText.text = "";
        speakerText.text = "";
        skipText.text = "";
        OnDialogueEnd?.Invoke();
        skipStartAnimation = true;
        StartDialogue(dialogueList.IndexOf(choice.nextDialogue), 0f, OnComplete);
    }

    void HandleMusic(DialogueLine line)
    {
        switch (line.musicMode)
        {
            case DialogueMusicMode.KeepCurrent:
                // do nothing
                break;

            case DialogueMusicMode.ChangeMusic:
                //AudioManager.instance.ChangeMusic(line.musicIndex);
                break;

            case DialogueMusicMode.StopMusic:
                //AudioManager.instance.StopMusic();
                break;
        }
    }

    void HandleVisualEffect(DialogueLine line)
    {
        if (isSkipping) return;
        switch (line.visualEffect)
        {
            case DialogueVFX.None:
                break;

            case DialogueVFX.Shake:
                // anim.DOPlayForwardAllById("Shake");
                break;
        }
    }

    string RemoveAllTags(string text)
    {
        text = Regex.Replace(text, @"</\d+>", "");
        text = Regex.Replace(text, @"#\d+", "");
        return text;
    }

    void PlayTypingSFX()
    {
        if (isTypingSFXPlaying) return;

        // AudioManager.instance.PlaySFX(3);
        StartCoroutine(TypingSFXCooldown());
    }

    IEnumerator TypingSFXCooldown()
    {
        isTypingSFXPlaying = true;
        yield return new WaitForSeconds(typingSFXLength);
        isTypingSFXPlaying = false;
    }

    public void SkipDialogue()
    {
        if (!dialogueBox.activeSelf) return;
        if (choicePanel.activeSelf) return;
        isSkipping = !isSkipping;
        //skipAnim.SetBool("isClicked", isSkipping);
        dialogueVersion++; // Invalidate old coroutines
        skipJustActivated = isSkipping;
        StartCoroutine(ResetSkipLock());
        UpdateModeUI();
        Debug.Log("Skipping: " + isSkipping);
        if (!isSkipping)
        {
            isBusy = false;

            if (skipRoutine != null)
            {
                StopCoroutine(skipRoutine);
                skipRoutine = null;
            }
            DialogueLine line = currentDialogue.lines[currentIndex];
            dialogueText.text = RemoveAllTags(line.text); // Ensure text is visible
            isTyping = false;
            bool isMonologue = line.speakerName.Trim().ToLower() == "monologue";
            TMP_Text targetText = isMonologue ? monologueText : dialogueText;

            typingRoutine = StartCoroutine(TypeTextWithCues(targetText, line.text, dialogueVersion));
            return;
        }
        isBusy = true;
        if (isSkipping && isTyping)
        {
            if (typingRoutine != null)
            {
                StopCoroutine(typingRoutine);
                typingRoutine = null;
            }
            DialogueLine line = currentDialogue.lines[currentIndex];
            dialogueText.font = line.fontAsset != null ? line.fontAsset : defaultFont;
            dialogueText.text = RemoveAllTags(line.text);
            isTyping = false;
            typingRoutine = null;
            skipRoutine = StartCoroutine(SkipToEnd());
            return;
        }
        if (currentIndex >= currentDialogue.lines.Count - 1)
        {
            isSkipping = false;

            UpdateModeUI();

            if (currentDialogue.choices != null &&
                currentDialogue.choices.Count > 0)
            {
                ShowChoices();
            }
            else
            {
                EndDialogue();
            }

            return;
        }

        currentIndex++;

        ShowLineInstant(currentIndex);

        skipRoutine = StartCoroutine(SkipToEnd());
    }

    void UpdateModeUI()
    {
        // SKIP TEXT
        skipText.text = isSkipping ? "Skip" : "Skip";
    }

    IEnumerator ResetSkipLock()
    {
        yield return new WaitForSeconds(0.5f); // wait 1 frame
        skipJustActivated = false;
    }

    IEnumerator WaitForFreshSkipPress()
    {
        // Wait until released first
        yield return new WaitUntil(() => !InputManager.Instance.SkipPressed);

        // Then wait for NEW press
        yield return new WaitUntil(() => InputManager.Instance.SkipPressed);

        // Wait one frame so state stabilizes
        yield return null;
    }
    
    [ContextMenu("Play DG1")]
    public void playDialogue()
    {
        StartDialogue(0, 0);
    }
}

