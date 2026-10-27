using UnityEngine;
using TMPro;
using System.Collections.Generic;
using UnityEngine.UI;
using System.Linq;
using System.Text.RegularExpressions;
using System.Collections;

[RequireComponent(typeof(RectTransform))]
public class UIAnchorToDynamicPhrase : MonoBehaviour
{
    [SerializeField] private TMP_Text textComponent;
    [SerializeField] private List<Button> childButtons;
    public int anchorIndex;
    public TranslatingManager translatingManager;

    [Tooltip("The 1-based index of the word you want to target.")]
    public int targetWordIndex = 5;

    [Tooltip("Time delay between each letter changing over.")]
    public float typingSpeed = 0.08f;

    private RectTransform myRectTransform;
    [SerializeField] private List<translatedTextGod> translatedText;
    [SerializeField] private GameObject childHitbox;
    public bool changeable = false;

    // Layout configuration tags
    public string openingTags { get; private set; } = "<font=\"Sakanaserif-Regular SDF\"><size=50>";
    public string closingTags { get; private set; } = "</size></font>";
    public string defaultWord { get; private set; }

    public bool isChanged = false;
    public TranslateOptionAnimator translateOptionAnimator;
    private bool isInitialized;

    // --- Concurrent State Machine Data ---
    public string CurrentTargetWord { get; private set; }
    public int CurrentStep { get; set; }
    public int MaxSteps { get; set; }
    public bool IsAnimatingIntoTags { get; set; }

    private void Awake()
    {
        myRectTransform = GetComponent<RectTransform>();
    }

    public void StartTranslating(int index)
    {
        if (textComponent == null) return;

        targetWordIndex = index;
        isInitialized = true;
        string liveFullText = textComponent.text;

        defaultWord = GetNthWordLiteral(liveFullText, targetWordIndex);
        ExtractCurrentTagsForWord(liveFullText, targetWordIndex);

        // Setup base target state
        CurrentTargetWord = defaultWord;
        CurrentStep = defaultWord.Length;
        MaxSteps = defaultWord.Length;
        IsAnimatingIntoTags = true;
    }

    public void OpenChildButtons()
    {
        if (translatedText == null || childButtons == null || !changeable) return;

        childHitbox.SetActive(true);

        // 1. Reset all physical buttons to inactive
        foreach (var button in childButtons)
        {
            button.gameObject.SetActive(false);
            button.onClick.RemoveAllListeners();
        }

        if (translatingManager == null) return;

        // 2. Determine the total number of translating slots from the manager's active state
        int totalSlotsCount = translatingManager.translatingTextSOs[translatingManager.currentTranslatingIndex].translatingSlots.Count;

        // 3. Cache the globally chosen gods for easier lookups
        List<GodEnum> chosen = translatingManager.chosenGods;
        GodEnum currentSelectedGod = (anchorIndex >= 0 && anchorIndex < chosen.Count) ? chosen[anchorIndex] : GodEnum.Empty;
        // 4. Spawn/configure buttons based on slot counts and rules
        int buttonSlotIndex = 0;
        List<GameObject> spawningButton = new List<GameObject>();
        for (int i = 0; i < translatedText.Count; i++)
        {
            var data = translatedText[i];
            GodEnum currentLoopGod = data.godEnum;

            // --- CONDITION: IF THERE IS ONLY 1 SLOT TOTAL ---
            if (totalSlotsCount == 1)
            {

            }

            // --- CONDITION: IF THERE ARE 2 SLOTS TOTAL ---
            else if (totalSlotsCount == 2)
            {
                if (anchorIndex == 0)
                {
                    // Index 0: Has 3 options initially. If chosen, hide its own choice.
                    if (currentSelectedGod != GodEnum.Empty && currentLoopGod == currentSelectedGod)
                    {
                        continue;
                    }
                }
                else if (anchorIndex == 1)
                {
                    // Index 1: ONLY shows the choice made in Slot 0.
                    bool matchesSlot0 = chosen.Count > 0 && chosen[0] != GodEnum.Empty && currentLoopGod == chosen[0];

                    if (!matchesSlot0)
                    {
                        continue; // Skip if it isn't what index 0 chose
                    }
                }
            }

            // --- CONDITION: IF THERE ARE 3 SLOTS TOTAL ---
            else if (totalSlotsCount >= 3)
            {
                if (anchorIndex == 0)
                {
                    if (currentSelectedGod != GodEnum.Empty && currentLoopGod == currentSelectedGod)
                    {
                        continue;
                    }
                }
                else if (anchorIndex == 1)
                {
                    bool isChosenBySlot0 = chosen.Count > 0 && chosen[0] != GodEnum.Empty && currentLoopGod == chosen[0];
                    bool isChosenBySelf = currentSelectedGod != GodEnum.Empty && currentLoopGod == currentSelectedGod;

                    if (isChosenBySlot0 || isChosenBySelf)
                    {
                        continue;
                    }
                }
                else if (anchorIndex == 2)
                {
                    bool matchesSlot0 = chosen.Count > 0 && chosen[0] != GodEnum.Empty && currentLoopGod == chosen[0];
                    bool matchesSlot1 = chosen.Count > 1 && chosen[1] != GodEnum.Empty && currentLoopGod == chosen[1];
                    bool isChosenBySelf = currentSelectedGod != GodEnum.Empty && currentLoopGod == currentSelectedGod;

                    bool isAValidPreviousChoice = matchesSlot0 || matchesSlot1;

                    if (!isAValidPreviousChoice || isChosenBySelf)
                    {
                        continue;
                    }
                }
            }

            // --- END OF FILTER LOGIC ---

            if (buttonSlotIndex >= childButtons.Count) break;

            Button currentButton = childButtons[buttonSlotIndex];
            string textToDisplay = data.translatedText;

            currentButton.GetComponentInChildren<TMP_Text>().text = textToDisplay;

            string capturedText = textToDisplay;
            currentButton.onClick.AddListener(() =>
            {
                ChangeText(capturedText);
            });
            spawningButton.Add(currentButton.gameObject);
            buttonSlotIndex++;
        }
        translateOptionAnimator.AnimateButton(spawningButton.ToArray());
    }
    public void CloseChildButtons()
    {
        if (childButtons == null) return;
        GameObject[] activeButtons = childButtons.Where(b => b.gameObject.activeSelf).Select(b => b.gameObject).ToArray();
        foreach (var button in childButtons)
        {
            button.onClick.RemoveAllListeners();
        }
        translateOptionAnimator.AnimateButtonHide(activeButtons,childHitbox);
    }

    public void UpdateTranslatedText(List<translatedTextGod> newTranslatedText)
    {
        translatedText = newTranslatedText.ToList();
    }

    public void ChangeText(string newWord)
    {
        if (textComponent == null || !isInitialized) return;
        CloseChildButtons();
        isChanged = true;

        string liveFullText = textComponent.text;
        ExtractCurrentTagsForWord(liveFullText, targetWordIndex);

        translatingManager.ChangeWord(anchorIndex, translatedText.FirstOrDefault(t => t.translatedText == newWord)?.godEnum ?? GodEnum.Empty);

        // Delegate concurrent animation work to manager hub
        translatingManager.AnimateAnchorWord(anchorIndex, newWord, false);
    }

    public void RevertToNormal()
    {
        if (textComponent == null || !isInitialized || !isChanged) return;

        isChanged = false;
        translatingManager.AnimateAnchorWord(anchorIndex, defaultWord, true);
    }

    public string GetFormattedBlockForCurrentFrame(string oldWordLiteral)
    {
        int step = CurrentStep;
        string newWord = CurrentTargetWord ?? ""; // Prevent null issues
        if (oldWordLiteral == null) oldWordLiteral = "";

        string finalReplacementBlock;

        if (!IsAnimatingIntoTags)
        {
            string outsideTags = newWord.Substring(0, Mathf.Min(step, newWord.Length));
            string insideTags = "";

            if (step < oldWordLiteral.Length)
            {
                insideTags = oldWordLiteral.Substring(step);
            }

            if (string.IsNullOrEmpty(insideTags))
                finalReplacementBlock = outsideTags;
            else
                finalReplacementBlock = $"{outsideTags}{openingTags}{insideTags}{closingTags}";
        }
        else
        {
            string insideTags = newWord.Substring(0, Mathf.Min(step, newWord.Length));
            string outsideTags = "";

            if (step < oldWordLiteral.Length)
            {
                outsideTags = oldWordLiteral.Substring(step);
            }

            if (string.IsNullOrEmpty(insideTags))
                finalReplacementBlock = outsideTags;
            else
                finalReplacementBlock = $"{openingTags}{insideTags}{closingTags}{outsideTags}";
        }

        return finalReplacementBlock;
    }

    private void LateUpdate()
    {
        if (textComponent == null || !isInitialized) return;

        textComponent.ForceMeshUpdate();
        TMP_TextInfo textInfo = textComponent.textInfo;

        int zeroBasedIndex = targetWordIndex - 1;
        if (zeroBasedIndex < 0 || zeroBasedIndex >= textInfo.wordCount) return;

        TMP_WordInfo wInfo = textInfo.wordInfo[zeroBasedIndex];
        int startIndex = wInfo.firstCharacterIndex;
        int endIndex = wInfo.lastCharacterIndex;

        float minX = float.MaxValue; float maxX = float.MinValue;
        float minY = float.MaxValue; float maxY = float.MinValue;

        for (int i = startIndex; i <= endIndex; i++)
        {
            if (i >= textInfo.characterInfo.Length) break;
            TMP_CharacterInfo charInfo = textInfo.characterInfo[i];
            if (!charInfo.isVisible) continue;

            if (charInfo.bottomLeft.x < minX) minX = charInfo.bottomLeft.x;
            if (charInfo.topRight.x > maxX) maxX = charInfo.topRight.x;
            if (charInfo.bottomLeft.y < minY) minY = charInfo.bottomLeft.y;
            if (charInfo.topRight.y > maxY) maxY = charInfo.topRight.y;
        }

        if (minX == float.MaxValue) return;

        Vector3 localCenter = new Vector3((minX + maxX) * 0.5f, (minY + maxY) * 0.5f, 0);
        float width = maxX - minX;
        float height = maxY - minY;

        Vector3 worldPos = textComponent.transform.TransformPoint(localCenter);
        Vector3 localImagePos = myRectTransform.parent.InverseTransformPoint(worldPos);

        myRectTransform.localPosition = localImagePos;
        myRectTransform.sizeDelta = new Vector2(width, height);
    }

    private void ExtractCurrentTagsForWord(string source, int targetIndex)
    {
        string pattern = @"((?:<[^>]+>)*)([a-zA-Z0-9'\-]+)((?:</[^>]+>)*)";
        int currentWordIndex = 0;

        foreach (Match match in Regex.Matches(source, pattern))
        {
            currentWordIndex++;
            if (currentWordIndex == targetIndex)
            {
                if (match.Groups[1].Success && !string.IsNullOrEmpty(match.Groups[1].Value))
                    openingTags = match.Groups[1].Value;

                if (match.Groups[3].Success && !string.IsNullOrEmpty(match.Groups[3].Value))
                    closingTags = match.Groups[3].Value;

                break;
            }
        }
    }

    private string GetNthWordLiteral(string source, int targetIndex)
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
}