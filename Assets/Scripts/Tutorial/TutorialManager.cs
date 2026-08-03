using System;
using System.Collections.Generic;
using UnityEngine;

public class TutorialManager : MonoBehaviour
{
    public static TutorialManager Instance {get; private set;}
    
    [SerializeField] private GameObject buttonContinueTutorial;
    [SerializeField] private TutorialDialogueUI tutorialDialogueUI;
    [SerializeField] private List<TutorialDataSO> listTutorialDataSO = new();
    [SerializeField] private RecordingDataSO recordingDataSO;
    [SerializeField] private bool isTutorialActive;
    [SerializeField] private bool isMissionTutorialComplete;
    
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
    private int _currentTutorialDialogueIndex;
    
    public bool IsTutorialActive => isTutorialActive;
    
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
        }
    }

    #region Registry & Unregistry - called by TutorialHighlightTarget

    private void RegisterTutorialHighlightTarget(string highlightID, RectTransform targetHighlight)
    {
        if (string.IsNullOrEmpty(highlightID)) 
            return;
        
        Debug.Log("Succes Register HighlightTarget");
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
        _positionDialogue[tutorialDialoguePosition] = targetPosition;
    }
    
    private void UnregisterTutorialPosition(TutorialDialoguePosition tutorialDialoguePosition)
    {
        _positionDialogue.Remove(tutorialDialoguePosition);
    }
    
    #endregion

    #region Tutorial flow

    private RectTransform SwitchPosition(TutorialDataSO tutorialData)
    {
        if (_positionDialogue.TryGetValue(tutorialData.tutorialDialoguePosition, out var targetPosition))
            return targetPosition;

        Debug.LogWarning($"[{name} - SwitchPosition] No registered position for '{tutorialData.tutorialDialoguePosition}' (step: {tutorialData.name}).");
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
        _currentTutorialDialogueIndex = 0;
        isTutorialActive = true;
        panelTutorial.SetActive(isTutorialActive);
        
        ShowCurrentStep(listTutorialDataSO[_currentTutorialIndex]);
    }

    public void ContinueTutorial()
    {
        var tutorailData    = listTutorialDataSO[_currentTutorialIndex];
        int dialogueCount   = tutorailData.tutorialDialogueDatas.Count;

        bool dialogueExhausted = _currentTutorialDialogueIndex + 1 >= dialogueCount;
        
        buttonContinueTutorial.SetActive(!isMissionTutorialComplete);
        
        if (dialogueExhausted)
        {
            Debug.Log($"[{this.name} - ContinueTutorial] Dialogue finished!");

            _currentTutorialDialogueIndex = 0;
            _currentTutorialIndex++;
            
            if (_currentTutorialIndex >= listTutorialDataSO.Count && isMissionTutorialComplete)
            {
                StopTutorial();
                return;
            }
            
            tutorailData = listTutorialDataSO[_currentTutorialIndex];
        }
        else
        {
            _currentTutorialDialogueIndex++;
        }
        
        ShowCurrentStep(tutorailData);
    }

    public void StopTutorial()
    {
        ClearHighlight();
        
        isTutorialActive = false;
        _isTutorialDone = true;
        isTutorialActive = false;
        panelTutorial.SetActive(isTutorialActive);
        
        GameEvents.OnTutorialStepCompleted.Invoke();
        Debug.Log($"[{this.name} - StopTutorial] Tutorial finished!");
    }

    #endregion
    
    private void ShowCurrentStep(TutorialDataSO tutorailData)
    {
        RestoreCurrentTarget();
        
        var position = SwitchPosition(tutorailData);
        var currentDialogueData = tutorailData.tutorialDialogueDatas[_currentTutorialDialogueIndex];
        
        bool hasAnyHighlight = false;

        if (tutorailData.tutorialDialogueDatas[_currentTutorialDialogueIndex].listHighligthId != null)
        {
            foreach (var highLightID in tutorailData.tutorialDialogueDatas[_currentTutorialDialogueIndex].listHighligthId)
            {
                if (string.IsNullOrEmpty(highLightID))
                    continue;
                
                AddHighlighting(highLightID);
                hasAnyHighlight = true;
            }
        }
        
        tutorialDialogueUI.UpdateTutorialDialogueUI(tutorailData, position, _currentTutorialDialogueIndex);
        SetOverlay(hasAnyHighlight);

        bool isNextStepMission = CheckNextIsMissionTutorial(tutorailData);
        
        if (currentDialogueData.tutorialMission != TutorialMissionType.None || isNextStepMission)
        {
            GameEvents.OnMissionTutorial.Invoke(MissionMarkerState.Active, recordingDataSO);
        }
        
        if (currentDialogueData.tutorialMission != TutorialMissionType.None)
        {
            buttonContinueTutorial.SetActive(false);
            isMissionTutorialComplete = false;
        }
        else
        {
            buttonContinueTutorial.SetActive(true);
            isMissionTutorialComplete = true;
        }
        
    }

    private bool CheckNextIsMissionTutorial(TutorialDataSO tutorialData)
    {
        int nextIndex = _currentTutorialDialogueIndex + 1;
        if (nextIndex < tutorialData.tutorialDialogueDatas.Count)
        {
            return tutorialData.tutorialDialogueDatas[nextIndex].tutorialMission != TutorialMissionType.None;
        }
        return false;
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

    public void OnMissionCompleted()
    {
        if (!isTutorialActive)
            return;
        
        Debug.Log($"[{this.name} - OnMissionCompleted] Mission Tutorial finished!");
        
        isMissionTutorialComplete = true;
        ContinueTutorial(); 
    }
}
