using System;
using UnityEngine;
using DG.Tweening;

public class UIOpeningDialogueTransition : UITransition
{
    [Header("Opening DialogueUI SceneTransition Configuration")]
    [SerializeField] private float cameraTransitionDuration = 0.5f;
    [SerializeField] private float dialogueTransitionDuration = 0.5f;
    
    [Header("Camera UI SceneTransition Configuration")]
    [SerializeField] private Vector3 endPosition;
    private Vector3 _startPositionCam;
    
    [Header("Dialogue SceneTransition Configuration")]
    [SerializeField] private RectTransform dialogueRectTransform;
    [SerializeField] private CanvasGroup dialogueCanvasGroup;
    [SerializeField] private Vector2 onScreenPosition;
    [SerializeField] private Vector2 offScreenPosition;
    
    private Camera _camera;
    private Sequence  _transition;

    private void Awake()
    {
        if (_camera == null)
        {
            _camera = Camera.main;
            _startPositionCam = _camera.transform.position;
        }
    }

    public override void ShowTransition()
    {
        Debug.Log($"{gameObject.name} Showing UI SceneTransition");
        
        _transition?.Kill();

        _camera.transform.position = _startPositionCam;
        dialogueRectTransform.anchoredPosition = offScreenPosition;
        dialogueCanvasGroup.alpha = 0f;
        
        _transition = DOTween.Sequence();
        // Camera slide to position
        _transition.Append(_camera.transform.DOMove(endPosition, cameraTransitionDuration).SetEase(Ease.OutQuad));
        
        //Show Dialogue box
        _transition.Append(dialogueRectTransform.DOAnchorPos(onScreenPosition, dialogueTransitionDuration).SetEase(Ease.OutBack));
        _transition.Join(dialogueCanvasGroup.DOFade(1f, dialogueTransitionDuration));

        _transition.OnComplete(() => {
            onTransitionIn?.Invoke();
            dialogueCanvasGroup.interactable = true;
            dialogueCanvasGroup.blocksRaycasts = true;
        });
    }

    public override void HideTransition()
    {
        _transition?.Kill();

        _transition = DOTween.Sequence();

        _transition.Append(dialogueRectTransform.DOAnchorPos(offScreenPosition, dialogueTransitionDuration).SetEase(Ease.InBack));
        _transition.Join(dialogueCanvasGroup.DOFade(0f, dialogueTransitionDuration));
        
        _transition.OnComplete(() => {
            onTransitionOut?.Invoke();
            dialogueCanvasGroup.interactable = false;
            dialogueCanvasGroup.blocksRaycasts = false;
        });
    }
}
