using UnityEngine;
using DG.Tweening;
using System;

public class RecordingPanelUITransition : UITransition
{
    [SerializeField] private Recording recording;
    [SerializeField] private string targetMap = "FlaggingController";
    
    private CanvasGroup _mainCanvasGroup;
    private Tween _tween;
    [SerializeField] private bool _isSubscribed;

    private void Awake()
    {
        _mainCanvasGroup = GetComponent<CanvasGroup>();
        SubscribeEvents();
    }

    #region Event System
    
    private void OnDestroy() => OnRemoveListener();

    private void SubscribeEvents()
    {
        if (_isSubscribed) return;
        _isSubscribed = true;
        GameEvents.OnShowRecordingPanel.AddListener(RequestShowRecordingPanel);
        GameEvents.OnHideRecordingPanel.AddListener(RequestHideRecordingPanel);
        Debug.Log($"[{name}] Subscribed = {_isSubscribed}");
    }
    
    private void OnRemoveListener()
    { 
        if (!_isSubscribed) return;
        _isSubscribed = false;
        GameEvents.OnShowRecordingPanel.RemoveListener(RequestShowRecordingPanel);
        GameEvents.OnHideRecordingPanel.RemoveListener(RequestHideRecordingPanel);
    }
    #endregion

    private void RequestShowRecordingPanel(MissionMarker missionMarker)
    {
        if (recording == null)
        {
            Debug.LogError($"[{this.name}] Recording is NULL");
            return;
        }
        
        Debug.Log($"[{this.name}] Request Show RecordingPanel");
        recording.UpdateRecording(missionMarker);
        ShowTransition();
    }
    
    private void RequestHideRecordingPanel(MissionMarker missionMarker)
    {
        if (recording == null || recording.SelectedMissionMarker != missionMarker)
            return;
        
        Debug.Log($"[{this.name}] Request Hide RecordingPanel");
        HideTransition();
    }
    
    public override void ShowTransition()
    {
 
        KillActiveTween();

        _tween = _mainCanvasGroup.DOFade(1, 0.3f);
        
        _tween.OnComplete(() =>
        {
            InputManager.Instance.SwitchActionMap(targetMap);
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
