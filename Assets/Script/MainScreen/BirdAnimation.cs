using UnityEngine;
using DG.Tweening;

public class BirdAnimation : MonoBehaviour
{
    [SerializeField] private Vector2 targetPos;
    [SerializeField] private Ease easeType = Ease.OutQuad;
    [SerializeField] private float duration = 1f;
    
    [Header("Arc Settings")]
    [SerializeField] private float arcHeight = 0.5f; // How high/low it bobbles
    [SerializeField] private int arcBounces = 2;       // How many times it bobs up and down

    [Header("Flap Settings")]
    [SerializeField] private float flapInterval = 0.15f; // Speed of wing flap (seconds per frame)

    [Header("Sprites")]
    [SerializeField] private Sprite spriteMount;
    [SerializeField] private Sprite spriteFly;
    [SerializeField] private Sprite spriteLowWing;

    public Vector2 startPos;
    private Vector3 startScale;
    private SpriteRenderer spriteRenderer;
    private Sequence activeSequence;

    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        startPos = transform.localPosition;
        startScale = transform.localScale;
        
        // Initial setup
        transform.localPosition = targetPos;
    }


    public void ShowBird(System.Action onComplete = null)
    {
        activeSequence?.Kill();
        activeSequence = DOTween.Sequence();

        // 1. Smooth arc path from targetPos -> startPos
        activeSequence.Append(
            transform.DOLocalJump(startPos, arcHeight, arcBounces, duration)
                     .SetEase(easeType)
        );

        // 2. Scale back to original size
        activeSequence.Join(
            transform.DOScale(startScale, duration)
                     .SetEase(easeType)
        );

        // 3. Flap wings continuously while moving
        activeSequence.Join(CreateFlapTween(duration));

        // 4. Landed state
        activeSequence.OnComplete(() =>
        {
            spriteRenderer.sprite = spriteMount;
        });
    }

    public void HideBird()
    {
        activeSequence?.Kill();

        // Flip sprite facing direction
        Vector3 flippedScale = new Vector3(-Mathf.Abs(startScale.x), startScale.y, startScale.z);
        transform.localScale = flippedScale;

        activeSequence = DOTween.Sequence();

        // 1. Smooth arc path from startPos -> targetPos
        activeSequence.Append(
            transform.DOLocalJump(targetPos, arcHeight, arcBounces, duration)
                     .SetEase(easeType)
        );

        // 2. Scale down to zero
        activeSequence.Join(
            transform.DOScale(Vector3.zero, duration)
                     .SetEase(easeType)
        );

        // 3. Flap wings continuously while flying away
        activeSequence.Join(CreateFlapTween(duration));
    }

    /// <summary>
    /// Creates a tween that toggles between spriteFly and spriteLowWing based on time intervals.
    /// </summary>
    private Tween CreateFlapTween(float totalDuration)
    {
        bool isFlySprite = true;
        
        return DOVirtual.Float(0f, totalDuration, totalDuration, elapsed =>
        {
            // Toggle sprite based on time step
            bool shouldBeFly = (Mathf.FloorToInt(elapsed / flapInterval) % 2) == 0;
            if (shouldBeFly != isFlySprite)
            {
                isFlySprite = shouldBeFly;
                spriteRenderer.sprite = isFlySprite ? spriteFly : spriteLowWing;
            }
        }).SetEase(Ease.Linear);
    }

    private void OnDestroy()
    {
        activeSequence?.Kill();
    }
}