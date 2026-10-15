using UnityEngine;
using DG.Tweening;

public class TranslatePaperAnim : MonoBehaviour
{
    [Header("Targets")]
    [SerializeField] private RectTransform rectTransform;
    [SerializeField] private RectTransform rectTransform2;
    [SerializeField] private RectTransform rectTransform3;

    [Header("Animation Settings")]
    [SerializeField] private float targetWidth = 400f;
    [SerializeField] private float duration = 1f;
    [SerializeField] private float targetScale = 1.2f;
    [SerializeField] private float duration2 = 0.5f;
    [SerializeField] private float resetDuration = 0.3f; 
    [SerializeField] private Ease easeType = Ease.Linear; 

    [Header("RectTransform 3 Settings")]
    // This allows you to define exactly how far to move along the X and Y axes
    [SerializeField] private Vector2 moveOffset = new Vector2(50f, 0f); 

    // Cached starting values
    private float originalWidth;
    private Vector3 originalScale;
    private Vector2 originalPosition3; // Stores the starting position of rectTransform3

    private void Awake()
    {
        // Cache the default values on startup so we know what to reset to
        originalWidth = rectTransform.sizeDelta.x;
        originalScale = rectTransform2.localScale;
        originalPosition3 = rectTransform3.anchoredPosition; // Cache the starting position
    }

    public void ChangeWidth()
    {
        // Kill active tweens on all objects to avoid conflicts
        rectTransform.DOKill();
        rectTransform2.DOKill();
        rectTransform3.DOKill();

        rectTransform.DOSizeDelta(new Vector2(targetWidth, rectTransform.sizeDelta.y), duration)
            .SetEase(easeType); 
        
        rectTransform2.DOScale(targetScale, duration2)
            .SetEase(easeType);

        // Calculate the target destination by adding the offset to the original position
        Vector2 targetPosition3 = originalPosition3 + moveOffset;

        // Use DOAnchorPos for UI RectTransforms instead of DOMove/DoPosition
        rectTransform3.DOAnchorPos(targetPosition3, duration2)
            .SetEase(easeType);
    }

    public void ResetUI()
    {
        // Always kill active tweens before starting the reset ones
        rectTransform.DOKill();
        rectTransform2.DOKill();
        rectTransform3.DOKill(); // Don't forget to kill the third one too!

        // 1. Return the first RectTransform back to its original width
        rectTransform.DOSizeDelta(new Vector2(originalWidth, rectTransform.sizeDelta.y), resetDuration)
            .SetEase(easeType);

        // 2. Return the second RectTransform back to its original scale
        rectTransform2.DOScale(originalScale, resetDuration)
            .SetEase(easeType);

        // 3. Return the third RectTransform back to its exact starting position
        rectTransform3.DOAnchorPos(originalPosition3, resetDuration)
            .SetEase(easeType);
    }
}