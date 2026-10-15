using UnityEngine;
using System.Linq;
using DG.Tweening;
using UnityEngine.InputSystem;
public class PrologueCutsceneManager : MonoBehaviour
{
    [System.Serializable]
    public class SequenceItem
    {
        public int index;
        public CanvasGroup canvasGroup;
        public bool clearPrevious;
    }
    [SerializeField] private SequenceItem[] items;
    [SerializeField] private float fadeDuration = 0.5f;

    private int currentIndex = 0;

    private void Awake()
    {
        items = items.OrderBy(i => i.index).ToArray();

        foreach (var item in items)
        {
            item.canvasGroup.alpha = 0;
        }
    }
    private void Start()
    {
        items[0].canvasGroup.DOFade(1, fadeDuration);
        currentIndex = 1;
    }

    public void Next(InputAction.CallbackContext context)
    {
        if (!context.performed)
            return;
        if (currentIndex >= items.Length)
        {
            SceneChangerManager.instance.StartFadeSolidColor(1);
            return;
        }

        SequenceItem item = items[currentIndex];
        if (item.clearPrevious)
        {
            for (int i = 0; i < currentIndex; i++)
            {
                items[i].canvasGroup.DOFade(0, fadeDuration);
            }
        }

        item.canvasGroup.DOFade(1, fadeDuration);

        currentIndex++;
    }
}
