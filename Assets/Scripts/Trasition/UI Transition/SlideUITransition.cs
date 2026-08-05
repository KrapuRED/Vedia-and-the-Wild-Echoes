using UnityEngine;
using DG.Tweening;

public class SlideUITransition : UITransition
{
    [Header("MainMenu UI SceneTransition Configuration")]
    [SerializeField] private float transitionDuration = 0.5f;
    
    [Header("UI References & Positions")]
    [SerializeField] private RectTransform  uiElement;
    [SerializeField] private Vector2 onScreenPosition;
    [SerializeField] private Vector2 offScreenPosition;
    
    [SerializeField] private bool isPanelOpen;
    
    private Tween _transition;
    
    public void PlayTransition()
    {
        if (!isPanelOpen)
        {
            ShowTransition();
            isPanelOpen = true;
        }
        else
        {
            HideTransition();
            isPanelOpen = false;
        }
    }
    
    public override void ShowTransition()
    {
        uiElement.DOKill();
        uiElement.anchoredPosition = offScreenPosition;
        
        _transition = uiElement.DOAnchorPos(onScreenPosition, transitionDuration).SetEase(Ease.OutBack);

        _transition.OnComplete(() => onTransitionIn?.Invoke());
    }

    public override void HideTransition()
    {
        uiElement.DOKill();

        _transition = uiElement.DOAnchorPos(offScreenPosition, transitionDuration)
            .SetEase(Ease.InBack);

        _transition.OnComplete(() => onTransitionOut?.Invoke());
    }
}
