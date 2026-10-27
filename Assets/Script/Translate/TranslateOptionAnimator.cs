using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class TranslateOptionAnimator : MonoBehaviour
{
    [Header("Spread Settings")]
    [SerializeField] private float minUpwardDistance = 50f;
    [SerializeField] private float maxUpwardDistance = 150f;
    [SerializeField] private float minHorizontalDistance = -150f;
    [SerializeField] private float maxHorizontalDistance = 150f;
    [SerializeField] private float spreadDuration = 0.5f;

    [Header("Reverse / Hide Settings")]
    [SerializeField] private float hideDuration = 0.35f;
    [SerializeField] private Ease hideEase = Ease.InQuad;

    [Header("Spacing Constraint")]
    [Tooltip("Minimum distance required between any two button centers")]
    [SerializeField] private float minGapBetweenButtons = 80f;
    [Tooltip("Maximum attempts to find a non-overlapping spot per button")]
    [SerializeField] private int maxPlacementAttempts = 20;

    [Header("Hover Settings")]
    [SerializeField] private float hoverRadius = 15f;
    [SerializeField] private float minHoverDuration = 1.5f;
    [SerializeField] private float maxHoverDuration = 2.5f;

    /// <summary>
    /// Spreads buttons out to random non-overlapping points while fading in, then starts hover.
    /// </summary>
    public void AnimateButton(GameObject[] targets)
    {
        List<Vector2> usedPositions = new List<Vector2>();

        foreach (var button in targets)
        {
            if (button == null) continue;

            // Stop any active hover or hide tweens
            button.transform.DOKill();

            RectTransform buttonRect = button.GetComponent<RectTransform>();
            
            // Get or add CanvasGroup for fading
            CanvasGroup canvasGroup = GetOrAddCanvasGroup(button);

            // 1. Initial reset
            canvasGroup.alpha = 0f;
            buttonRect.anchoredPosition = Vector2.zero;
            button.SetActive(true);

            // 2. Calculate target position
            Vector2 spreadTargetPos = GetValidSpreadPosition(usedPositions);
            usedPositions.Add(spreadTargetPos);

            // 3. Animate Spread & Fade In
            Sequence spreadSequence = DOTween.Sequence();
            spreadSequence.Join(canvasGroup.DOFade(1f, spreadDuration).SetEase(Ease.OutQuad));
            spreadSequence.Join(buttonRect.DOAnchorPos(spreadTargetPos, spreadDuration).SetEase(Ease.OutCubic));

            // 4. Start Hover Phase
            spreadSequence.OnComplete(() => StartRandomHover(buttonRect, spreadTargetPos));
        }
    }

    /// <summary>
    /// Reverses the animation: fades out and pulls buttons back to origin, then deactivates them.
    /// </summary>
    public void AnimateButtonHide(GameObject[] targets,GameObject parent)
    {
        foreach (var button in targets)
        {
            if (button == null || !button.activeSelf) continue;

            // Stop hover animation loops immediately
            button.transform.DOKill();

            RectTransform buttonRect = button.GetComponent<RectTransform>();
            CanvasGroup canvasGroup = GetOrAddCanvasGroup(button);

            // Sequence to fade out and move back to center
            Sequence hideSequence = DOTween.Sequence();
            hideSequence.Join(canvasGroup.DOFade(0f, hideDuration).SetEase(hideEase));
            hideSequence.Join(buttonRect.DOAnchorPos(Vector2.zero, hideDuration).SetEase(Ease.InCubic));

            // Deactivate object when done
            hideSequence.OnComplete(() =>
            {
                if (button != null)
                {
                    button.SetActive(false);
                }
                parent.SetActive(false);
            });
        }
    }

    private CanvasGroup GetOrAddCanvasGroup(GameObject target)
    {
        if (!target.TryGetComponent<CanvasGroup>(out var canvasGroup))
        {
            canvasGroup = target.AddComponent<CanvasGroup>();
        }
        return canvasGroup;
    }

    private Vector2 GetValidSpreadPosition(List<Vector2> existingPositions)
    {
        Vector2 candidatePos = Vector2.zero;

        for (int attempt = 0; attempt < maxPlacementAttempts; attempt++)
        {
            float randomX = Random.Range(minHorizontalDistance, maxHorizontalDistance);
            float randomY = Random.Range(minUpwardDistance, maxUpwardDistance);
            candidatePos = new Vector2(randomX, randomY);

            bool isTooClose = false;
            foreach (Vector2 pos in existingPositions)
            {
                if (Vector2.Distance(candidatePos, pos) < minGapBetweenButtons)
                {
                    isTooClose = true;
                    break;
                }
            }

            if (!isTooClose) break;
        }

        return candidatePos;
    }

    private void StartRandomHover(RectTransform rectTransform, Vector2 basePosition)
    {
        Vector2 randomOffset = Random.insideUnitCircle * hoverRadius;
        Vector2 targetHoverPos = basePosition + randomOffset;
        float randomDuration = Random.Range(minHoverDuration, maxHoverDuration);

        rectTransform.DOAnchorPos(targetHoverPos, randomDuration)
            .SetEase(Ease.InOutSine)
            .OnComplete(() =>
            {
                if (rectTransform != null && rectTransform.gameObject.activeSelf)
                {
                    StartRandomHover(rectTransform, basePosition);
                }
            });
    }

    private void OnDisable()
    {
        transform.DOKill(true);
    }
}