using UnityEngine;
using DG.Tweening;
using System;

public class RecordingPanelUITransition : UITransition
{
    [SerializeField] private Recording recording;

    private bool _isOpen;
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
        if (GameEvents.OnShowRecordingPanel != null)
            GameEvents.OnShowRecordingPanel.RemoveListener(PlayAnimation);

        if (GameEvents.OnHideRecordingPanel != null)
            GameEvents.OnHideRecordingPanel.RemoveListener(HideTransition);
    }
    #endregion

    private void PlayAnimation(MissionMarker missionMarker)
    {
        if (this == null)
            return;
        
        if (recording == null)
        {
            Debug.LogError($"[{this.name}] Recording is NULL");
            return;
        }
        
        recording.UpdateRecording(missionMarker);
        
        if (!_isOpen)
            ShowTransition();
    }
    
    public override void ShowTransition()
    {
        if (this == null) return;

        KillActiveTween();
        
        _isOpen = true;
        _tween = _mainCanvasGroup.DOFade(1, 0.3f);
        
        _tween.OnComplete(() =>
        {
            _mainCanvasGroup.blocksRaycasts = true;
            _mainCanvasGroup.interactable = true;
            MusicManager.Instance.DecreaseMusicVolume(.9f);
        });
    }

    public override void HideTransition()
    {
        if (this == null) return;

        KillActiveTween();
        
        InputManager.Instance.PopActionMap();
        
        _tween = _mainCanvasGroup.DOFade(0, 0.3f);
        _tween.OnComplete(() =>
        {
            if (this == null) return; // Safety check dalam async/callback
            _isOpen = false;
            
            if (SoundEffectManager.Instance != null)
                SoundEffectManager.Instance.StopAllSoundEFfectLoop();
                
            _mainCanvasGroup.blocksRaycasts = false;
            _mainCanvasGroup.interactable = false;
            
            if (MusicManager.Instance != null)
                MusicManager.Instance.IncreaseMusicVolume(1f);
            
            if (recording != null)
                recording.ResetRecording();
        });
    }
    
    private void KillActiveTween()
    {
        if (_tween != null && _tween.IsActive())
        {
            _tween.Kill();
            _tween = null;
        }
    }
}
