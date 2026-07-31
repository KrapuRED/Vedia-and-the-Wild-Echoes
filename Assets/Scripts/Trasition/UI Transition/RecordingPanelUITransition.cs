using UnityEngine;
using DG.Tweening;
using System;

public class RecordingPanelUITransition : UITransition
{
    [SerializeField] private RecordngPanelUI recordingPanelUI;
    
    private CanvasGroup _mainCanvasGroup;
    private Tween _tween;

    private void Awake()
    {
        _mainCanvasGroup = GetComponent<CanvasGroup>();
    }

    #region Event System
    private void OnEnable()
    {
        GameEvents.OnShowRecordingPanel.AddListener(PlayAnimation);
        GameEvents.OnHideRecordingPanel.AddListener(HideTransition);
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {
        GameEvents.OnShowRecordingPanel.RemoveListener(PlayAnimation);
        GameEvents.OnHideRecordingPanel.AddListener(HideTransition);
        
    }
    #endregion

    private void PlayAnimation(MissionMarker missionMarker)
    {
        recordingPanelUI.UpdateStatuRecord(missionMarker);
        
        ShowTransition();
    }
    
    public override void ShowTransition()
    {
        if (this == null)
        {
            Destroy(gameObject);
            return;
        }
        if (_tween != null)
        {
            _tween.Kill();
            _tween = null;
        }
        
        _tween = _mainCanvasGroup.DOFade(1, 0.3f);
        
        _tween.OnComplete(() =>
        {
            _mainCanvasGroup.blocksRaycasts = true;
            _mainCanvasGroup.interactable = true;
        });
        
        Debug.Log($"[{gameObject.name} - {nameof(RecordingPanelUITransition)}] Show Transition");
    }

    public override void HideTransition()
    {
        if (this == null)
        {
            Destroy(gameObject);
            return;
        }

        if (_tween != null)
        {
            _tween.Kill();
            _tween = null;
        }
        
        _tween = _mainCanvasGroup.DOFade(0, 0.3f);
        
        Debug.Log($"[{gameObject.name} - {nameof(RecordingPanelUITransition)}] Hide Transition");

        _tween.OnComplete(() =>
        {
            recordingPanelUI.EmptRecordngPanelUI();
            
            InputManager.Instance.PopActionMap();
            _mainCanvasGroup.blocksRaycasts = false;
            _mainCanvasGroup.interactable = false;
        });
    }
}
