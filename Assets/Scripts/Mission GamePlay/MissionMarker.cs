using System;
using UnityEngine;

[System.Serializable]
public enum MissionMarkerState
{
   Passive, 
   Active,
   Flagged
}

[System.Serializable]
public enum MissionMarkerLocation
{
   Unkown,
   Forest,
   River
}

public class MissionMarker : MonoBehaviour, IInteractable
{
   [SerializeField] private MissionMarkerLocation missionMarkerLocation;
   [SerializeField] private MissionMarkerState missionMarkerState ;
   [SerializeField] private RecordingDataSO  missionRecordingData;
   [SerializeField] private bool isSelectedTutorial;
   
   [Header("Rotation Config")]
   [SerializeField] private float maxTilted; 
   [SerializeField] private Material markerFlaggedMaterial;
   [SerializeField] private Material markerPassiveMaterial;
   [SerializeField] private Material markerActiveMaterial;
   [SerializeField] private bool isFlagged;
   
   [SerializeField] private string targetMap = "FlaggingController";
   
   private MeshRenderer _meshRenderer;
   private Camera _camera;
   private bool _isMarkerSelected;
   private string _soundEffectName;
   
   public bool IsFlagged => isFlagged;
   public MissionMarkerState MissionMarkerState => missionMarkerState;
   public RecordingDataSO MissionRecordingData => missionRecordingData;
   public ForestMonitorType ForestMonitorType => missionRecordingData.forestMonitorType;
   public string SoundEffectName => _soundEffectName;
   
   private void Awake()
   {
      _camera  = Camera.main;
      _meshRenderer = GetComponent<MeshRenderer>();
   }

   #region Event
   private void OnEnable()
   {
      GameEvents.OnMissionMarkerRegistered.Invoke(this);
      GameEvents.OnFlaggedMissionMarker.AddListener(FlaggeMissionMarker);
      GameEvents.OnMissionTutorial.AddListener(OnUpdateStateByTutorial);
   }

   private void OnDisable()
   {
      OnRemoveListeners();
      GameEvents.OnMissionMarkerUnregistered.Invoke(this);
      
   }

   private void OnDestroy() =>  OnRemoveListeners();

   private void OnRemoveListeners()
   {
      GameEvents.OnFlaggedMissionMarker.RemoveListener(FlaggeMissionMarker);
      GameEvents.OnMissionTutorial.RemoveListener(OnUpdateStateByTutorial);
   }
    
   #endregion

   private void LateUpdate()
   {
      transform.rotation = Quaternion.LookRotation(transform.position - _camera.transform.position);
   }

   private void BuildSoundEffectName()
   {
      string state = missionMarkerState == MissionMarkerState.Active ? "pam_active" : "passive";
      string location = missionMarkerLocation.ToString().ToLower();

      if (missionMarkerState == MissionMarkerState.Passive)
      {
         _soundEffectName = $"{state}_{location}";
         return;
      }
      
      string recording = MissionRecordingData.recordingClip;
      _soundEffectName = $"{state}_{recording}_{location}";
   }

   private void OnUpdateStateByTutorial(MissionMarkerState markerState, RecordingDataSO recordingData)
   {
      if (isSelectedTutorial)
         UpdateState(markerState, recordingData);
   }
   
   public void UpdateState(MissionMarkerState markerState, RecordingDataSO recordingData)
   {
      if (_meshRenderer == null)
      {
         Debug.LogError($"[{gameObject.name} - {nameof(MissionMarker)}] MeshRenderer not assigned");
         return;
      }
      
      this.missionMarkerState = markerState;
      missionRecordingData = recordingData;
      BuildSoundEffectName();
      
      _meshRenderer.material = markerState switch
      {
         MissionMarkerState.Passive => markerPassiveMaterial,
         MissionMarkerState.Active => markerActiveMaterial,
         _ => markerPassiveMaterial
      };
   }

   public void OnInteract()
   {
      if (isFlagged)
         return;

      InputManager.Instance.SwitchActionMap(targetMap);

      if (TutorialManager.Instance != null && TutorialManager.Instance.IsTutorialActive)
      {
         Debug.Log("On Tutorial Mission Completed");
         TutorialManager.Instance.OnMissionCompleted();
      }
      
      GameEvents.OnShowRecordingPanel.Invoke(this);
   }
   
   private void FlaggeMissionMarker(MissionMarker missionMarkerData)
   {
      if (this !=  missionMarkerData)
         return;
      
      isFlagged = true;
      missionMarkerState = MissionMarkerState.Flagged;
      _meshRenderer.material = markerFlaggedMaterial;
   }
}
