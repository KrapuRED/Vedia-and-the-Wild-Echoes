using System;
using UnityEngine;
using DG.Tweening;

public class MainMenuUITransition : UITransition
{
    [Header("MainMenu UI SceneTransition Configuration")]
    [SerializeField] private float transitionDuration = 0.5f;
    
    [Header("UI References & Positions")]
    [SerializeField] private RectTransform  uiElement;
    [SerializeField] private Vector2 onScreenPosition;
    [SerializeField] private Vector2 offScreenPosition;
    
    private Tween _transition;

    private void Awake()
    {
        if (uiElement == null)
            uiElement = GetComponent<RectTransform>();
    }

    public override void ShowTransition()
    {
        //Going From top to bit bottom then adjust a bit
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
