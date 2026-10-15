using UnityEngine;
using DG.Tweening;

public class PaperHoverAnim : MonoBehaviour
{
    [SerializeField] private RectTransform rectTransform3;
    [SerializeField] private Vector2 moveOffset = new Vector2(50f, 0f);

    // Add a field to define the rotation angle (in degrees)
    [SerializeField] private float rotationAngle = 15f;

    [SerializeField] private Ease easeType = Ease.Linear;
    [SerializeField] private float duration = 1f;
    [SerializeField] private bool isRelative = true;
    public bool resetable = true; // New field to control whether the UI can be reset
    public Vector2 originalPosition3;
    public Vector3 originalRotation3;
    [ContextMenu("Reset Original Position and Rotation")]
    void Awake()
    {
        if (originalPosition3 == Vector2.zero && originalRotation3 == Vector3.zero)
        {
            originalPosition3 = rectTransform3.anchoredPosition;
            originalRotation3 = rectTransform3.localEulerAngles;
        }
    }
    public void ChangeWidth()
    {
        rectTransform3.DOKill();

        // 1. Handle Movement

        if (isRelative)
        {
            Vector2 targetPosition3 = originalPosition3 + moveOffset;
            Vector3 targetRotation3 = originalRotation3 + new Vector3(0f, 0f, rotationAngle);
            rectTransform3.DORotate(targetRotation3, duration)
                .SetEase(easeType);
            rectTransform3.DOAnchorPos(targetPosition3, duration)
                .SetEase(easeType);
        }
        else
        {
            rectTransform3.DORotate(new Vector3(0f, 0f, rotationAngle), duration)
            .SetEase(easeType);
            rectTransform3.DOAnchorPos(moveOffset, duration)
                .SetEase(easeType);
        }
    }

    public void ResetUI()
    {
        if(!resetable) return; 
        rectTransform3.DOKill();
        // 1. Reset Position
        rectTransform3.DOAnchorPos(originalPosition3, duration)
            .SetEase(easeType);

        // 2. Reset Rotation
        rectTransform3.DORotate(originalRotation3, duration)
            .SetEase(easeType);
    }
}