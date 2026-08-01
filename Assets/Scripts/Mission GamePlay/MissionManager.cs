using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;

[Serializable]
public class SelectedMissionMarkerData
{
    public string missionMarkerName;
    public MissionMarkerState missionMarkerState;
    public MissionMarker missionMarkerData;
    public float activeTimer;
    public float currentTimer;
}

public class MissionManager : MonoBehaviour
{
    public static MissionManager Instance { get; private set; }
    
    [Header("Mission Configuration")]
    [SerializeField] private int maxMissions;
    [SerializeField] private List<RecordingDataSO> passiveRecordingsList = new();
    [SerializeField] private List<RecordingDataSO> activeRecordingsList = new();
    [SerializeField] private List<SelectedMissionMarkerData> missionMarkerPassive =  new();
    [SerializeField] private List<SelectedMissionMarkerData> missionMarkerActive =  new();
    
    [Header("Mission Marker Timer Configuration")]
    [SerializeField] private float minPassiveMarkerTimer;
    [SerializeField] private float maxPassiveMarkerTimer;
    [SerializeField] private float minActiveMarkerTimer;
    [SerializeField] private float maxActiveMarkerTimer;

    [Header("Area Spawning Mission")] 
    [SerializeField] private Transform areaMission;
    [SerializeField] private List<MissionMarker> missionMarkers = new();
    
    private bool _isMissionMarkerActive;
    private readonly HashSet<MissionMarker> _assignedMarkers = new();
    
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
        }

        missionMarkers = areaMission.GetComponentsInChildren<MissionMarker>().ToList();
    }

    #region Event

    private void OnEnable()
    {
        GameEvents.OnFlaggedMissionMarker.AddListener(RemoveMissionMarker);
    }

    private void OnDisable() => OnRemoveListeners();

    private void OnDestroy() =>  OnRemoveListeners();

    private void OnRemoveListeners()
    {
        GameEvents.OnFlaggedMissionMarker.RemoveListener(RemoveMissionMarker);
    }
    
    #endregion
    
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && !_isMissionMarkerActive)
        {
            _isMissionMarkerActive = true;
            StartMission();
        }
 
        if (!_isMissionMarkerActive)
            return;
            
        UpdatePassiveMissionMarker();
        UpdateActiveMissionMarker();
    }

    private RecordingDataSO GetActiveRecordingData()
    {
        int randomIndex = Random.Range(0, activeRecordingsList.Count);
        return activeRecordingsList[randomIndex];
    }
    
    private RecordingDataSO GetPassiveRecordingData()
    {
        int randomIndex = Random.Range(0, passiveRecordingsList.Count);
        return passiveRecordingsList[randomIndex];
    }

    private void UpdatePassiveMissionMarker()
    {
        if (missionMarkerPassive.Count <= 0)
        {
            Debug.LogWarning($"[{gameObject.name} - UpdatePassiveMissionMarker] List in Mission Marker Passive is NULL or EMPTY!");
            return;
        }
        
        if (missionMarkerActive.Count >= maxMissions)
            return; 
        
        List<SelectedMissionMarkerData> toPromote = null;
        
        foreach (var missionMarker in missionMarkerPassive)
        {
            if (missionMarker == null)
                continue;
            
            if (missionMarker.missionMarkerState ==  MissionMarkerState.Active)
                continue;
            
            missionMarker.currentTimer += Time.deltaTime;
            
            if (missionMarker.currentTimer >= missionMarker.activeTimer)
            {
                if (missionMarkerActive.Count + (toPromote?.Count ?? 0) >= maxMissions)
                    break;

                toPromote ??= new List<SelectedMissionMarkerData>();
                toPromote.Add(missionMarker);
            }
        }
        
        if (toPromote == null)
            return;
        
        foreach (var markerData  in toPromote)
        {
            Debug.Log($"{markerData.missionMarkerName} State {markerData.missionMarkerState}");
            AssignActiveMissionMarker(markerData);
        }
    }
    
    private void UpdateActiveMissionMarker()
    {
        if (missionMarkerActive.Count <= 0)
        {
            Debug.LogWarning($"[{gameObject.name} - UpdateActiveMissionMarker] List in Mission Marker Active is NULL or EMPTY!");
            return;
        }
        
        List<SelectedMissionMarkerData> toDemote = null;
        
        foreach (var missionMarker in missionMarkerActive)
        {
            if (missionMarker == null)
                continue;

            if (missionMarker.missionMarkerState ==  MissionMarkerState.Passive)
                continue;
            
            missionMarker.currentTimer += Time.deltaTime;
            
            if (missionMarker.currentTimer >= missionMarker.activeTimer)
            {
                toDemote ??= new List<SelectedMissionMarkerData>();
                toDemote.Add(missionMarker);
            }
        }
        
        if (toDemote == null)
            return;
        
        foreach (var markerData  in toDemote)
        {
            Debug.Log($"{markerData.missionMarkerName} State {markerData.missionMarkerState}");
            GameEvents.OnHideRecordingPanel.Invoke();
            AssignPassiveMissionMarker(markerData);
        }
    }

    private float GetRandomPassiveMarkerTimer() => Random.Range(minPassiveMarkerTimer, maxPassiveMarkerTimer);
    private float GetRandomActiveMarkerTimer() => Random.Range(minActiveMarkerTimer, maxActiveMarkerTimer);

    public void StartMission()
    {
        if (areaMission == null)
        {
            Debug.LogError($"{nameof(areaMission)} is null in {gameObject.name}");
            return;
        }

        for (int i = 0; i < missionMarkers.Count; i++)
        {
            var availableMarkers = missionMarkers.Where(
                m => m != null && !_assignedMarkers.Contains(m)).ToList();
        
            int randomIndex = Random.Range(0, availableMarkers.Count);   // <- use the filtered list
            var selectedMission = availableMarkers[randomIndex];
        
            SelectedMissionMarkerData markerData = new SelectedMissionMarkerData
            {
                missionMarkerName = selectedMission.name,
                missionMarkerData = selectedMission,
            };
        
            //cannot have same missionMarkerData
            AssignPassiveMissionMarker(markerData);
            _assignedMarkers.Add(selectedMission); 
        }
    }
    
    private void AssignPassiveMissionMarker(SelectedMissionMarkerData markerData)
    {
        if (markerData == null)
        {
            Debug.LogError($"{nameof(areaMission)} is null in {gameObject.name}");
            return;
        }
        missionMarkerActive.Remove(markerData);

        markerData.missionMarkerState = MissionMarkerState.Passive; 
        markerData.missionMarkerData.UpdateState(markerData.missionMarkerState, GetPassiveRecordingData());
        
        markerData.currentTimer = 0;
        markerData.activeTimer = GetRandomPassiveMarkerTimer();
        
        missionMarkerPassive.Add(markerData);
        Debug.Log($"{gameObject.name} Successfully Assigned to Passive Mission Marker {markerData.missionMarkerName}");

    }
    
    private void AssignActiveMissionMarker(SelectedMissionMarkerData markerData)
    {
        if (markerData == null)
        {
            Debug.LogError($"{nameof(areaMission)} is null in {gameObject.name}");
            return;
        }
        
        missionMarkerPassive.Remove(markerData);

        markerData.missionMarkerState = MissionMarkerState.Active; 
        markerData.missionMarkerData.UpdateState(markerData.missionMarkerState, GetActiveRecordingData());
        
        markerData.currentTimer = 0;
        markerData.activeTimer = GetRandomActiveMarkerTimer();
        
        missionMarkerActive.Add(markerData);
        Debug.Log($"{gameObject.name} Successfully Assigned to Active Mission Marker {markerData.missionMarkerName}");
    }

    private SelectedMissionMarkerData FindSelectedMissionMarker(MissionMarker markerData)
    {
        foreach (var selectedMissionMarker in missionMarkerActive)
        {
            if (selectedMissionMarker.missionMarkerData == markerData)
                return selectedMissionMarker;
        }
        
        foreach (var selectedMissionMarker in missionMarkerPassive)
        {
            if (selectedMissionMarker.missionMarkerData == markerData)
                return selectedMissionMarker;
        }
        
        return null;
    }
    
    private void RemoveMissionMarker(MissionMarker markerData)
    {
        var missionMarker =  FindSelectedMissionMarker(markerData);
        
        if (missionMarkerPassive.Contains(missionMarker))
            missionMarkerPassive.Remove(missionMarker);
        
        if (missionMarkerActive.Contains(missionMarker))
            missionMarkerActive.Remove(missionMarker);
        
        _assignedMarkers.Remove(markerData);
    }
}
