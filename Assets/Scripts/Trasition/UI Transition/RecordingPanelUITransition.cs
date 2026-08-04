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
        GameEvents.OnShowRecordingPanel.RemoveListener(PlayAnimation);
        GameEvents.OnHideRecordingPanel.RemoveListener(HideTransition);
        
    }
    #endregion

    private void PlayAnimation(MissionMarker missionMarker)
    {
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
        
        _isOpen = true;
        _tween = _mainCanvasGroup.DOFade(1, 0.3f);
        
        _tween.OnComplete(() =>
        {
            _mainCanvasGroup.blocksRaycasts = true;
            _mainCanvasGroup.interactable = true;
            MusicManager.Instance.DecreaseMusicVolume(.5f);
        });
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
        
        InputManager.Instance.PopActionMap();
        
        _tween = _mainCanvasGroup.DOFade(0, 0.3f);
        _tween.OnComplete(() =>
        {
            _isOpen  = false;
            SoundEffectManager.Instance.StopAllSoundEFfectLoop();
            _mainCanvasGroup.blocksRaycasts = false;
            _mainCanvasGroup.interactable = false;
            MusicManager.Instance.IncreaseMusicVolume(1f);
            
            recording.ResetRecording();
        });
    }
    
}
