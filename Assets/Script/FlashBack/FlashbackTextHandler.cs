using System;
using System.Collections;
using TMPro;
using UnityEngine;
using System.Collections.Generic;
using DG.Tweening;
public class FlashbackTextHandler : MonoBehaviour
{
    public static FlashbackTextHandler instance;
    [SerializeField] private TMP_Text flashbackText;
    [SerializeField] private SpriteRenderer leftSpriteRenderer;
    [SerializeField] private List<Sprite> leftSprites = new List<Sprite>();
    [SerializeField] private List<FlashbackData> flashbacks = new List<FlashbackData>();
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

    public void PlayFlashback(int index, int spriteIndex = -1, Action onComplete = null)
    {
        if (index < 0 || index >= flashbacks.Count)
        {
            Debug.LogWarning("Flashback index out of range!");
            return;
        }
        UpdateLeftSprite(spriteIndex);
        StartCoroutine(PlayFlashbackRoutine(flashbacks[index], onComplete));
    }
    private void UpdateLeftSprite(int spriteIndex)
    {
        if (leftSpriteRenderer == null) return;

        if (spriteIndex >= 0 && spriteIndex < leftSprites.Count && leftSprites[spriteIndex] != null)
        {
            leftSpriteRenderer.sprite = leftSprites[spriteIndex];
            leftSpriteRenderer.enabled = true; 
        }
        else
        {
            leftSpriteRenderer.enabled = false; 
        }
    }
    private IEnumerator PlayFlashbackRoutine(FlashbackData data, Action onComplete)
    {
        flashbackText.text = "";
        flashbackText.DOFade(1f, 0.5f);
        foreach (FlashbackParagraph paragraph in data.paragraphs)
        {
            flashbackText.text = "";

            string cleanedText = paragraph.text.Replace("\r", "");
            string[] lines = cleanedText.Split('\n');

            foreach (string line in lines)
            {
                if (string.IsNullOrWhiteSpace(line))
                {
                    flashbackText.text += "\n";
                    continue;
                }
                yield return AddLineWithFade(line);
                yield return WaitForInput();
            }
            yield return FadeOutText();
        }


        onComplete?.Invoke();
    }
    private IEnumerator AddLineWithFade(string line)
    {
        int startIndex = flashbackText.textInfo.characterCount;

        if (flashbackText.text == "")
            flashbackText.text = line;
        else
            flashbackText.text += "\n" + line;

        flashbackText.ForceMeshUpdate();

        int endIndex = flashbackText.textInfo.characterCount;

        // Make only the new line invisible
        for (int i = startIndex; i < endIndex; i++)
        {
            TMP_CharacterInfo charInfo = flashbackText.textInfo.characterInfo[i];

            if (!charInfo.isVisible)
                continue;

            int matIndex = charInfo.materialReferenceIndex;
            int vertexIndex = charInfo.vertexIndex;

            Color32[] colors = flashbackText.textInfo.meshInfo[matIndex].colors32;

            colors[vertexIndex + 0].a = 0;
            colors[vertexIndex + 1].a = 0;
            colors[vertexIndex + 2].a = 0;
            colors[vertexIndex + 3].a = 0;
        }

        flashbackText.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);


        float timer = 0f;
        float duration = 0.5f;

        while (timer < duration)
        {
            timer += Time.deltaTime;
            byte alpha = (byte)Mathf.Lerp(0, 255, timer / duration);

            for (int i = startIndex; i < endIndex; i++)
            {
                TMP_CharacterInfo charInfo = flashbackText.textInfo.characterInfo[i];

                if (!charInfo.isVisible)
                    continue;

                int matIndex = charInfo.materialReferenceIndex;
                int vertexIndex = charInfo.vertexIndex;

                Color32[] colors = flashbackText.textInfo.meshInfo[matIndex].colors32;

                colors[vertexIndex + 0].a = alpha;
                colors[vertexIndex + 1].a = alpha;
                colors[vertexIndex + 2].a = alpha;
                colors[vertexIndex + 3].a = alpha;
            }

            flashbackText.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);

            yield return null;
        }
    }
    private IEnumerator WaitForInput()
    {
        // Wait until player presses
        while (!InputManager.Instance.SkipPressed)
            yield return null;

        // Wait until player releases
        while (InputManager.Instance.SkipPressed)
            yield return null;
    }
    private IEnumerator FadeOutText()
    {
        yield return flashbackText.DOFade(0f, 0.5f).WaitForCompletion();

        flashbackText.text = "";

        // Reset alpha for next paragraph
        flashbackText.DOFade(1f, 0f);
    }

    [ContextMenu("Play flash 1")]
    public void playFlash()
    {
        Debug.Log("Started");
        PlayFlashback(0,0);
    }
}
