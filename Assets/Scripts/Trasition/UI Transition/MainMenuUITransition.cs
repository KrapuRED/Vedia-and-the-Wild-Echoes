using System;
using UnityEngine;
using DG.Tweening;

public class MainMenuUITransition : UITransition
{
    [Header("MainMenu UI Transition Configuration")]
    [SerializeField] private float transitionDuration = 0.5f;
    
    [Header("UI References & Positions")]
    [SerializeField] private RectTransform  uiElement;
    [SerializeField] private Vector2 onScreenPosition;
    [SerializeField] private Vector2 offScreenPosition;

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
        
        uiElement.DOAnchorPos(onScreenPosition, transitionDuration).SetEase(Ease.OutBack);

    }

    public override void HideTransition()
    {
        uiElement.DOKill();

        uiElement.DOAnchorPos(offScreenPosition, transitionDuration)
            .SetEase(Ease.InBack);
    }
}
