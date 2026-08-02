using UnityEngine;
using DG.Tweening;

public class CrossFadeUITransition : UITransition
{
    [SerializeField] private float duration;
    [SerializeField] private GameObject currentUIObject;
    [SerializeField] private CanvasGroup canvasGroup;

    private Tween _tween;
    
    public override void ShowTransition()
    {
        if (currentUIObject != null)
            currentUIObject.SetActive(true);

        if (canvasGroup == null)
        {
            Debug.LogWarning($"[{this.name} - CrossFadeUITransition] Canvas Group is null");
            return;
        }
        
        if (_tween != null)
        {
            _tween.Kill();
            _tween = null;
        }
        
        _tween = canvasGroup.DOFade(1f, duration).SetEase(Ease.Linear);
        
        
        _tween.OnComplete(() =>
        {
            canvasGroup.interactable = true;
            canvasGroup.blocksRaycasts = true;

            onTransitionIn?.Invoke();
            
            _tween = null;
        });

    }

    public override void HideTransition()
    {
        if (canvasGroup == null)
        {
            Debug.LogWarning($"[{this.name} - CrossFadeUITransition] Canvas Group is null");
            return;
        }
        
        if (_tween != null)
        {
            _tween.Kill();
            _tween = null;
        }
        
        _tween = canvasGroup.DOFade(1f, duration).SetEase(Ease.Linear);
        
        _tween.OnComplete(() =>
        {
            canvasGroup.interactable = false;
            canvasGroup.blocksRaycasts = false;
            
            onTransitionOut?.Invoke();
            
            if (currentUIObject != null)
                currentUIObject.SetActive(false);
            
            _tween = null;
        });
    }
}
