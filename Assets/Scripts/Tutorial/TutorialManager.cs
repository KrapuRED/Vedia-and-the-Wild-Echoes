using System;
using System.Collections.Generic;
using UnityEngine;

public class TutorialManager : MonoBehaviour
{
    public static TutorialManager Instance {get; private set;}
    
    [SerializeField] private TutorialDialogueUI tutorialDialogueUI;
    [SerializeField] private List<TutorialDataSO> listTutorialDataSO = new();
    [SerializeField] private bool isTutorialActive;
    
    [Header("Highlight Overlay")]
    [SerializeField] private  GameObject panelTutorial;
    [Tooltip("CanvasGroup on the full-screen dark panel.")]
    [SerializeField] private CanvasGroup overlayCanvasGroup;
    
    [Tooltip("Empty RectTransform that sits ABOVE the overlay in the same canvas. Targets get reparented here while highlighted.")]
    [SerializeField] private RectTransform highlightLayer;
    
    private readonly Dictionary<TutorialDialoguePosition, RectTransform> _positionDialogue = new(); 
    private readonly Dictionary<string, RectTransform> _highlightTargets = new();
    
    private Dictionary<string, RectTransform> _currentTargets    = new();
    private Dictionary<string, Transform> _originalParentTargets = new();
    private Dictionary<string, int> _originalSiblingTargetIndexs = new();
    
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
        GameEvents.OnUnregisterHighlightTarget.AddListener(UnregisterTutorialHighlightTarget);
        GameEvents.OnRegisterDialoguePosition.AddListener(RegisterTutorialPosition);
        GameEvents.OnUnregisterDialoguePosition.AddListener(UnregisterTutorialPosition);
    }

    private void OnDisable() => OnRemoveListeners();

    private void OnDestroy() => OnRemoveListeners();

    private void OnRemoveListeners()
    {
        GameEvents.OnUnregisterHighlightTarget.RemoveListener(UnregisterTutorialHighlightTarget);
        GameEvents.OnUnregisterHighlightTarget.RemoveListener(UnregisterTutorialHighlightTarget);
        GameEvents.OnRegisterDialoguePosition.RemoveListener(RegisterTutorialPosition);
        GameEvents.OnUnregisterDialoguePosition.RemoveListener(UnregisterTutorialPosition);
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

        _currentTargets.Remove(highlightID);
        _originalParentTargets.Remove(highlightID);
        _originalSiblingTargetIndexs.Remove(highlightID);
 
        _highlightTargets.Remove(highlightID);
    }

    private void RegisterTutorialPosition(TutorialDialoguePosition tutorialDialoguePosition, RectTransform targetPosition)
    {
        if (tutorialDialoguePosition == null)
            return;
        
        Debug.Log($"[{this.name} - RegisterTutorialPosition] RegisterTutorialPosition to {targetPosition.name}]");
        _positionDialogue[tutorialDialoguePosition] = targetPosition;
    }
    
    private void UnregisterTutorialPosition(TutorialDialoguePosition tutorialDialoguePosition)
    {
        if (tutorialDialoguePosition == null)
            return;
        
        Debug.Log($"[{this.name} - UnregisterTutorialPosition] UnregisterTutorialPosition]");
        _positionDialogue.Remove(tutorialDialoguePosition);
    }
    
    #endregion

    #region Tutorial flow

    private RectTransform SwitchPosition(TutorialDataSO tutorialData)
    {
        Debug.Log("SwitchPosition get called");

        if (_positionDialogue.TryGetValue(tutorialData.tutorialDialoguePosition, out var targetPosition))
        {
            return  targetPosition;
        }
            
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
        
        ShowCurrentStep(listTutorialDataSO[_currentTutorialIndex]);
    }

    public void ContinueTutorial()
    {
        if (!isTutorialActive)
            return;
 
        var tutorailData = listTutorialDataSO[_currentTutorialIndex];
        int dialogueCount = tutorailData.dialogueData.dialogueData.Count;

        bool dialogueExhausted = tutorialDialogueUI.CurrDialogueIndex + 1 >= dialogueCount;
        
        if (dialogueExhausted)
        {
            Debug.Log($"[{this.name} - ContinueTutorial] Dialogue finished!");
            _currentTutorialIndex++;
            tutorialDialogueUI.ResetTutorialDialogueUI();
            
            if (_currentTutorialIndex >= listTutorialDataSO.Count)
            {
                StopTutorial();
                return;
            }
            
            tutorailData = listTutorialDataSO[_currentTutorialIndex];
        }
        
        ShowCurrentStep(tutorailData);
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
    
    private void ShowCurrentStep(TutorialDataSO tutorailData)
    {
        RestoreCurrentTarget();
        
        var position = SwitchPosition(tutorailData);
        
        bool hasAnyHighlight = false;

        if (tutorailData.highLightIDs != null)
        {
            foreach (var highLightID in tutorailData.highLightIDs)
            {
                if (string.IsNullOrEmpty(highLightID))
                    continue;
                
                AddHighlighting(highLightID);
                hasAnyHighlight = true;
            }
        }
        
        tutorialDialogueUI.UpdateTutorialDialogueUI(tutorailData, position);
        
        SetOverlay(hasAnyHighlight);
        GameEvents.OnTutorialStepChanged?.Invoke(tutorailData);
    }
    
    #region Highlighting

    private void AddHighlighting(string highlightID)
    {
        if (!_highlightTargets.TryGetValue(highlightID, out var target) || target == null)
        {
            Debug.LogWarning($"[TutorialManager] No registered highlight target for id '{highlightID}'.");
            return;
        }

        _currentTargets[highlightID] = target;
        _originalParentTargets[highlightID] = target.parent;
        _originalSiblingTargetIndexs[highlightID] = target.GetSiblingIndex();
        
        target.SetParent(highlightLayer, worldPositionStays:true);
        target.SetAsLastSibling();
    }

    private void ClearHighlight()
    {
        RestoreCurrentTarget();
        SetOverlay(false);
    }

    private void RestoreCurrentTarget()
    {
        if (_currentTargets == null)
            return;

        foreach (var currentTarget in _currentTargets)
        {
            var data = currentTarget.Key;
            var target = currentTarget.Value;

            if (target == null)
                continue;

            if (_originalParentTargets.TryGetValue(data, out var originalParent) &&
                _originalSiblingTargetIndexs.TryGetValue(data, out var originalIndex))
            {
                target.SetParent(originalParent);
                target.SetSiblingIndex(originalIndex);
            }
        }
        
        _currentTargets.Clear();
        _originalParentTargets.Clear();
        _originalSiblingTargetIndexs.Clear();
    }

    private void SetOverlay(bool isShow)
    {
        overlayCanvasGroup.alpha = isShow ? 1f : 0f;
        overlayCanvasGroup.blocksRaycasts = isShow;
        overlayCanvasGroup.interactable = isShow;
    }
    
    #endregion
}
