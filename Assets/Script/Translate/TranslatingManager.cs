using UnityEngine;
using System.Collections.Generic;
using TMPro;
using System.Linq;
using System.Text.RegularExpressions;
using System.Collections;

public class TranslatingManager : MonoBehaviour
{
    public List<TranslatingTextSO> translatingTextSOs;
    public List<GodEnum> chosenGods = new List<GodEnum>() { GodEnum.Empty, GodEnum.Empty, GodEnum.Empty };
    public List<UIAnchorToDynamicPhrase> uIAnchorToDynamicPhrases;
    public TMP_Text mainText;
    public PaperHoverAnim PaperHoverAnim;
    public int currentTranslatingIndex = 0;

    [Header("Full Text Reveal Animation Settings")]
    [SerializeField] private string ancientFontOpeningTag = "<font=\"Sakanaserif-Regular SDF\">"; //
    [SerializeField] private string ancientFontClosingTag = "</font>"; //
    [SerializeField] private float fullTextRevealSpeed = 0.04f;
    [Header("Particle Effects")]
    [SerializeField] private ParticleSystem fontChangeParticlePrefab; // Assign in Inspector or direct scene reference

    private string pristineBaseText;
    private Dictionary<int, string> originalWordLiterals = new Dictionary<int, string>();
    private Coroutine masterAnimationCoroutine;
    void Start()
    {
        if (StateManager.instance == null)
        {
            StartTranslating(0);
            return;
        }


        switch (StateManager.instance.currentStoryState)
        {
            case StoryState.Day1:
                StartTranslating(0);
                break;

            case StoryState.Day2:
                StartTranslating(1);
                break;

            case StoryState.Day3:
                StartTranslating(2);
                break;

            case StoryState.Day4:
                StartTranslating(3);
                break;

            case StoryState.Day5:
                StartTranslating(4);
                break;

            case StoryState.Day6:
                StartTranslating(5);
                break;

            case StoryState.Day7:
                StartTranslating(6);
                break;
        }
    }
    public void StartTranslating(int index)
    {
        if (index >= 0 && index < translatingTextSOs.Count)
        {
            if (masterAnimationCoroutine != null) StopCoroutine(masterAnimationCoroutine);
            mainText.text = translatingTextSOs[index].fullText;
            pristineBaseText = translatingTextSOs[index].fullText;
            originalWordLiterals.Clear();

            currentTranslatingIndex = index;
            int activeSlotsCount = translatingTextSOs[index].translatingSlots.Count;

            for (int i = 0; i < uIAnchorToDynamicPhrases.Count; i++)
            {
                var anchor = uIAnchorToDynamicPhrases[i];

                if (i >= activeSlotsCount)
                {
                    anchor.gameObject.SetActive(false);
                    anchor.changeable = false;
                    continue;
                }

                anchor.gameObject.SetActive(true);
                anchor.UpdateTranslatedText(translatingTextSOs[index].translatingSlots[i].translatedText);
                anchor.translatingManager = this;
                anchor.anchorIndex = i;

                anchor.StartTranslating(translatingTextSOs[index].translatingSlots[i].wordIndex);
                originalWordLiterals[i] = GetNthWordLiteralDirect(pristineBaseText, anchor.targetWordIndex);

                if (i == 0)
                    anchor.changeable = true;
            }

            masterAnimationCoroutine = StartCoroutine(AnimateTagAwareFullTextReveal());
        }
    }

    private IEnumerator AnimateTagAwareFullTextReveal()
    {
        List<int> visibleCharRawIndices = GetVisibleCharacterIndices(pristineBaseText);
        int totalVisibleChars = visibleCharRawIndices.Count;

        for (int visibleIndex = 0; visibleIndex <= totalVisibleChars; visibleIndex++)
        {
            int rawCutoffIndex = (visibleIndex < totalVisibleChars)
                ? visibleCharRawIndices[visibleIndex]
                : pristineBaseText.Length;

            string revealedRaw = pristineBaseText.Substring(0, rawCutoffIndex);
            string unrevealedRaw = pristineBaseText.Substring(rawCutoffIndex);

            if (!string.IsNullOrEmpty(unrevealedRaw))
            {
                mainText.text = $"{revealedRaw}{ancientFontOpeningTag}{unrevealedRaw}{ancientFontClosingTag}";
            }
            else
            {
                mainText.text = revealedRaw;
            }

            // --- MOVE AND PLAY PARTICLE SYSTEM ---
            if (visibleIndex < totalVisibleChars && fontChangeParticlePrefab != null)
            {
                mainText.ForceMeshUpdate();
                TMP_TextInfo textInfo = mainText.textInfo;

                if (visibleIndex < textInfo.characterInfo.Length)
                {
                    TMP_CharacterInfo charInfo = textInfo.characterInfo[visibleIndex];

                    if (charInfo.isVisible)
                    {
                        Vector3 localCenter = (charInfo.bottomLeft + charInfo.topRight) * 0.5f;
                        Vector3 worldPos = mainText.transform.TransformPoint(localCenter);

                        // Reposition particle transform
                        fontChangeParticlePrefab.transform.position = worldPos;

                        // Stop previous emission cleanly and trigger burst
                        fontChangeParticlePrefab.Play(false);
                    }
                }
            }

            yield return new WaitForSeconds(fullTextRevealSpeed);
        }

        mainText.text = pristineBaseText;
        masterAnimationCoroutine = null;
    }

    /// <summary>
    /// Returns the raw character index in the source string for every actual visible character, skipping HTML tags.
    /// </summary>
    private List<int> GetVisibleCharacterIndices(string source)
    {
        List<int> indices = new List<int>();
        bool insideTag = false;

        for (int i = 0; i < source.Length; i++)
        {
            char c = source[i];

            if (c == '<')
            {
                insideTag = true;
                continue;
            }

            if (c == '>')
            {
                insideTag = false;
                continue;
            }

            if (!insideTag)
            {
                indices.Add(i);
            }
        }

        return indices;
    }

    public void ChangeWord(int index, GodEnum godEnum)
    {
        for (int i = 0; i < translatingTextSOs[currentTranslatingIndex].translatingSlots.Count; i++)
        {
            if (i == index)
            {
                Debug.Log($"Setting index {i} to {godEnum} because it is the changed index {index}");
                chosenGods[i] = godEnum;
            }
            else if (i > index)
            {
                uIAnchorToDynamicPhrases[i].RevertToNormal();
                chosenGods[i] = GodEnum.Empty;
                if (i == index + 1)
                {
                    Debug.Log($"Setting index {i} to changeable because it is after the changed index {index}");
                    uIAnchorToDynamicPhrases[i].changeable = true;
                }
                else
                {
                    Debug.Log($"Reverting index {i} to normal because it is after the changed index {index}");
                    uIAnchorToDynamicPhrases[i].changeable = false;
                }
            }
        }
        CheckCompletion();
    }

    public void AnimateAnchorWord(int anchorIndex, string targetWord, bool intoTags)
    {
        var anchor = uIAnchorToDynamicPhrases[anchorIndex];

        string currentWordInMesh = GetNthWordLiteralDirect(mainText.text, anchor.targetWordIndex);
        string cleanedTargetWord = StripTags(targetWord);

        anchor.CurrentStep = 0;

        // --- FIX: Ensure MaxSteps is at least the length of the default word so we cleanly slice it all away ---
        int defaultWordLength = anchor.defaultWord != null ? anchor.defaultWord.Length : 0;
        anchor.MaxSteps = Mathf.Max(currentWordInMesh.Length, cleanedTargetWord.Length, defaultWordLength);

        anchor.GetType().GetProperty("CurrentTargetWord").SetValue(anchor, cleanedTargetWord);
        anchor.IsAnimatingIntoTags = intoTags;

        if (masterAnimationCoroutine == null)
        {
            masterAnimationCoroutine = StartCoroutine(MasterConcurrentAnimationLoop());
        }
    }

    private IEnumerator MasterConcurrentAnimationLoop()
    {
        bool stillAnimating = true;

        // Filter to only check active anchors to avoid errors
        var activeAnchors = uIAnchorToDynamicPhrases.Where(a => a.gameObject.activeSelf).ToList();
        if (activeAnchors.Count == 0) yield break;

        float shortestSpeedTick = activeAnchors.Min(a => a.typingSpeed);

        while (stillAnimating)
        {
            stillAnimating = false;

            foreach (var anchor in activeAnchors)
            {
                if (anchor.CurrentStep < anchor.MaxSteps)
                {
                    anchor.CurrentStep++;
                    stillAnimating = true;

                    // --- TRIGGER PARTICLE EFFECT ON STEP CHANGE ---
                    TriggerParticleAtAnchorWord(anchor);
                }
            }

            string combinedText = pristineBaseText;
            var orderedAnchors = activeAnchors.OrderByDescending(a => a.targetWordIndex).ToList();

            foreach (var anchor in orderedAnchors)
            {
                if (!originalWordLiterals.ContainsKey(anchor.anchorIndex)) continue;

                string oldWordLiteral = originalWordLiterals[anchor.anchorIndex];
                string dynamicReplacementBlock = anchor.GetFormattedBlockForCurrentFrame(oldWordLiteral);

                combinedText = ReplaceNthWordWithFullBlock(combinedText, anchor.targetWordIndex, dynamicReplacementBlock);
            }

            mainText.text = combinedText;

            if (!stillAnimating) break;
            yield return new WaitForSeconds(shortestSpeedTick);
        }

        masterAnimationCoroutine = null;
    }

    private void TriggerParticleAtAnchorWord(UIAnchorToDynamicPhrase anchor)
    {
        if (fontChangeParticlePrefab == null || mainText == null) return;

        mainText.ForceMeshUpdate();
        TMP_TextInfo textInfo = mainText.textInfo;

        int zeroBasedWordIndex = anchor.targetWordIndex - 1;
        if (zeroBasedWordIndex < 0 || zeroBasedWordIndex >= textInfo.wordCount) return;

        TMP_WordInfo wordInfo = textInfo.wordInfo[zeroBasedWordIndex];

        // Calculate the character index inside the word corresponding to CurrentStep
        int targetCharIndex = wordInfo.firstCharacterIndex + Mathf.Clamp(anchor.CurrentStep - 1, 0, wordInfo.characterCount - 1);

        if (targetCharIndex < textInfo.characterInfo.Length)
        {
            TMP_CharacterInfo charInfo = textInfo.characterInfo[targetCharIndex];

            if (charInfo.isVisible)
            {
                // Position at character center
                Vector3 localCenter = (charInfo.bottomLeft + charInfo.topRight) * 0.5f;
                Vector3 worldPos = mainText.transform.TransformPoint(localCenter);

                // Move particle transform and play without clearing existing particles
                fontChangeParticlePrefab.transform.position = worldPos;
                fontChangeParticlePrefab.Play(false);
            }
        }
    }
    private string ReplaceNthWordWithFullBlock(string source, int targetIndex, string newBlock)
    {
        string pattern = @"((?:<[^>]+>)*)([a-zA-Z0-9'\-]+)((?:</[^>]+>)*)";
        int currentWordIndex = 0;

        return Regex.Replace(source, pattern, m =>
        {
            currentWordIndex++;
            if (currentWordIndex == targetIndex) return newBlock;
            return m.Value;
        });
    }

    private string GetNthWordLiteralDirect(string source, int targetIndex)
    {
        string pattern = @"(?<tag><[^>]+>)|(?<word>[a-zA-Z0-9'\-]+)";
        int currentWordIndex = 0;
        foreach (Match match in Regex.Matches(source, pattern))
        {
            if (match.Groups["word"].Success)
            {
                currentWordIndex++;
                if (currentWordIndex == targetIndex) return match.Groups["word"].Value;
            }
        }
        return "";
    }

    private string StripTags(string text)
    {
        return Regex.Replace(text, @"<[^>]*>", string.Empty);
    }
    private void CheckCompletion()
    {
        // Get how many slots the current ScriptableObject actually uses
        int requiredSlots = translatingTextSOs[currentTranslatingIndex].translatingSlots.Count;

        // Check if the first 'requiredSlots' choices are filled (not Empty)
        bool isComplete = chosenGods.Take(requiredSlots).All(g => g != GodEnum.Empty);

        if (isComplete)
        {
            PaperHoverAnim.ChangeWidth();
        }
        else
        {
            PaperHoverAnim.ResetUI();
        }
    }
    public void CompleteTranslation()
    {
        GodEnum mostChosenGod = GetMostChosenGod();
        SceneChangerManager.instance.StartFadeSolidColor(1);
    }
    public GodEnum GetMostChosenGod()
    {
        int requiredSlots = translatingTextSOs[currentTranslatingIndex].translatingSlots.Count;

        var mostChosen = chosenGods
            .Take(requiredSlots)                 // Only check active slots
            .Where(g => g != GodEnum.Empty)       // Ignore unselected slots
            .GroupBy(g => g)                      // Group by GodEnum type
            .OrderByDescending(group => group.Count()) // Sort by highest frequency
            .FirstOrDefault();                    // Pick top group

        // Returns the GodEnum, or GodEnum.Empty if no gods were chosen yet
        return mostChosen != null ? mostChosen.Key : GodEnum.Empty;
    }
}