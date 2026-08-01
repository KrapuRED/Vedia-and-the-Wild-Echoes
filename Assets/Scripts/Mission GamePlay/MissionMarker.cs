using UnityEngine;

[System.Serializable]
public enum MissionMarkerState
{
   Passive, 
   Active,
   Flagged
}

public class MissionMarker : MonoBehaviour, IInteractable
{
   [SerializeField] private MissionMarkerState missionMarkerState ;
   [SerializeField] private RecordingDataSO  missionRecordingData;
   
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
   
   public bool IsFlagged => isFlagged;
   public MissionMarkerState MissionMarkerState => missionMarkerState;
   public RecordingDataSO MissionRecordingData => missionRecordingData;
   
   private void Awake()
   {
      _camera  = Camera.main;
      _meshRenderer = GetComponent<MeshRenderer>();
   }
   
   #region Event

   private void OnEnable()
   {
      GameEvents.OnFlaggedMissionMarker.AddListener(FlaggeMissionMarker);
      GameEvents.OnMissionMarkerRegistered.Invoke(this);
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
   }
    
   #endregion

   private void LateUpdate()
   {
      transform.rotation = Quaternion.LookRotation(transform.position - _camera.transform.position);
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
      
      GameEvents.OnShowRecordingPanel.Invoke(this);
      Debug.Log($"[{gameObject.name} - {nameof(MissionMarker)}] On interact");
   }
   
   private void FlaggeMissionMarker(MissionMarker missionMarkerData)
   {
      if (this !=  missionMarkerData)
         return;
      
      isFlagged = true;
      missionMarkerState = MissionMarkerState.Flagged;
      _meshRenderer.material = markerFlaggedMaterial;
   }
   
   //if out side of camera show indicator went active
}
