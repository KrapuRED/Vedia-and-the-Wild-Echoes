using System;
using System.Collections.Generic;
using UnityEngine;

public class TutorialManager : MonoBehaviour
{
    public static TutorialManager Instance {get; private set;}
    
    [SerializeField] private List<TutorialDataSO> listTutorialDataSO = new();
    [SerializeField] private bool isTutorialActive;
    
    [Header("Highlight Overlay")]
    [SerializeField] private  GameObject panelTutorial;
    [Tooltip("CanvasGroup on the full-screen dark panel.")]
    [SerializeField] private CanvasGroup overlayCanvasGroup;
    
    [Tooltip("Empty RectTransform that sits ABOVE the overlay in the same canvas. Targets get reparented here while highlighted.")]
    [SerializeField] private RectTransform highlightLayer;
    
    private readonly Dictionary<string, RectTransform> _highlightTargets = new();
    
    private RectTransform _currentTarget;
    private Transform _originalParentTarget;
    private int _originalSiblingTargetIndex;
    
    private bool _isTutorialDone;
    private int _currentTutorialIndex;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    #region Event System

    private void OnEnable()
    {
        GameEvents.OnRegisterHighlightTarget.AddListener(RegisterTutorialHighlightTarget);
    }

    private void OnDisable() => OnRemoveListeners();

    private void OnDestroy() => OnRemoveListeners();

    private void OnRemoveListeners()
    {
        GameEvents.OnUnregisterHighlightTarget.RemoveListener(UnregisterTutorialHighlightTarget);
    }
    
    #endregion
    
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (!isTutorialActive && !_isTutorialDone)
            {
                StartTutorial();
            }
            else
            {
                ContinueTutorial();
            }
        }
    }

    #region Registry & Unregistry - called by TutorialHighlightTarget

    private void RegisterTutorialHighlightTarget(string highlightID, RectTransform targetHighlight)
    {
        if (string.IsNullOrEmpty(highlightID)) 
            return;
        _highlightTargets[highlightID] = targetHighlight;
    }

    private void UnregisterTutorialHighlightTarget(string highlightID)
    {
        if (string.IsNullOrEmpty(highlightID))
            return;

        if (_currentTarget != null &&
            _highlightTargets.TryGetValue(highlightID, out var registed) &&
            registed == _currentTarget)
        {
            _currentTarget = null;
        }
        
        _highlightTargets.Remove(highlightID);
    }
    
    #endregion

    #region Tutorial flow

    private Transform SwitchPosition()
    {
        return null;
    }
    
    public void  StartTutorial()
    {
        if (isTutorialActive || _isTutorialDone)
            return;

        if (listTutorialDataSO.Count <= 0)
        {
            Debug.LogWarning($"[{this.name} - StartTutorial] Cannot start Tutorial {listTutorialDataSO.Count}!");
            return;
        }
        
        _currentTutorialIndex = 0;
        isTutorialActive = true;
        panelTutorial.SetActive(isTutorialActive);
        
        ShowCurrentStep();
    }

    public void ContinueTutorial()
    {
        if (!isTutorialActive)
            return;
 
        _currentTutorialIndex++;
 
        if (_currentTutorialIndex >= listTutorialDataSO.Count)
        {
            StopTutorial();
            return;
        }
 
        ShowCurrentStep();
        
        GameEvents.OnTutorialStepChanged?.Invoke(listTutorialDataSO[_currentTutorialIndex]);
    }

    public void StopTutorial()
    {
        isTutorialActive = false;
        _isTutorialDone = true;
        isTutorialActive = false;
        panelTutorial.SetActive(isTutorialActive);
        
        ClearHighlight();
        GameEvents.OnTutorialStepCompleted.Invoke();
        Debug.Log($"[{this.name} - StopTutorial] Tutorial finished!");
    }

    #endregion
    
    private void ShowCurrentStep()
    {
        var tutorailData = listTutorialDataSO[_currentTutorialIndex];
        
        if (string.IsNullOrEmpty(tutorailData.highLightID))
            ClearHighlight();
        else
        {
            ShowHighlighting(tutorailData.highLightID);
        }
        
        GameEvents.OnTutorialStepChanged?.Invoke(tutorailData);
    }
    
    #region Highlighting

    private void ShowHighlighting(string highlightID)
    {
        RestoreCurrentTarget();

        if (!_highlightTargets.TryGetValue(highlightID, out var target) || target == null)
        {
            Debug.LogWarning($"[TutorialManager] No registered highlight target for id '{highlightID}'.");
            SetOverlay(false);
            return;
        }
        
        _currentTarget = target;
        _originalParentTarget = target.transform.parent;
        _originalSiblingTargetIndex = target.GetSiblingIndex();
        
        target.SetParent(highlightLayer, worldPositionStays: true);
        target.SetAsLastSibling();
        
        SetOverlay(true);
    }

    private void ClearHighlight()
    {
        RestoreCurrentTarget();
        SetOverlay(false);
    }

    private void RestoreCurrentTarget()
    {
        if (_currentTarget == null)
            return;

        if (_originalParentTarget != null)
        {
            _currentTarget.SetParent(_originalParentTarget, worldPositionStays:true);
            _currentTarget.SetSiblingIndex(_originalSiblingTargetIndex);
        }
        
        _currentTarget = null;
    }

    private void SetOverlay(bool isShow)
    {
        overlayCanvasGroup.alpha = isShow ? 1f : 0f;
        overlayCanvasGroup.blocksRaycasts = isShow;
        overlayCanvasGroup.interactable = isShow;
    }
    
    #endregion
}
