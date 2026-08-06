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
    
    private readonly Dictionary<MissionMarker, SelectedMissionMarkerData> _markerLookup = new();
    private readonly List<SelectedMissionMarkerData> _promoteBuffer = new();
    private readonly List<SelectedMissionMarkerData> _demoteBuffer = new();
    
    [SerializeField] private bool _isMissionMarkerActive;
    private readonly HashSet<MissionMarker> _assignedMarkers = new();
    
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
            return;
        }

        missionMarkers = areaMission.GetComponentsInChildren<MissionMarker>().ToList();
    }

    #region Event

    private void OnEnable()
    {
        OnRemoveListeners();
        
        GameEvents.OnFlaggedMissionMarker.AddListener(RemoveMissionMarker);
        GameEvents.OnAllTaskDone.AddListener(ClearAllMissionMarkers);
        GameEvents.OnTutorialStepCompleted.AddListener(StartMission);
    }

    private void OnDisable() => OnRemoveListeners();

    private void OnDestroy() =>  OnRemoveListeners();

    private void OnRemoveListeners()
    {
        if (GameEvents.OnFlaggedMissionMarker != null)
            GameEvents.OnFlaggedMissionMarker.RemoveListener(RemoveMissionMarker);
        
        if (GameEvents.OnAllTaskDone != null)
            GameEvents.OnAllTaskDone.RemoveListener(ClearAllMissionMarkers);
        
        if (GameEvents.OnTutorialStepCompleted != null)
            GameEvents.OnTutorialStepCompleted.RemoveListener(StartMission);
    }
    
    #endregion
    
    private void Update()
    {
        if (!_isMissionMarkerActive)
            return;
        
        float dt = Time.deltaTime;
        UpdatePassiveMissionMarker(dt);
        UpdateActiveMissionMarker(dt);
    }

    private void RefreshMissionMarkers()
    {
        if (missionMarkers == null)
            missionMarkers = new List<MissionMarker>();
        else
            missionMarkers.Clear();

        if (areaMission != null)
        {
            missionMarkers = areaMission.GetComponentsInChildren<MissionMarker>(true).ToList();
        }
        
        _markerLookup.Clear();
        missionMarkerPassive.Clear();
        missionMarkerActive.Clear();
         
    }
    
    private void ClearAllMissionMarkers()
    {
        missionMarkerActive.Clear();
        missionMarkerPassive.Clear();
        _markerLookup.Clear();
        
        _isMissionMarkerActive = false;
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

    private void UpdatePassiveMissionMarker(float dt)
    {
        if (missionMarkerPassive.Count <= 0)
            return;
 
        if (missionMarkerActive.Count >= maxMissions)
            return;
        
        _promoteBuffer.Clear();
        
        foreach (var missionMarker in missionMarkerPassive)
        {
            if (missionMarker == null)
                continue;
            
            if (missionMarker.missionMarkerState ==  MissionMarkerState.Active)
                continue;
            
            missionMarker.currentTimer += dt;

            if (missionMarker.currentTimer >= missionMarker.activeTimer)
            {
                if (missionMarkerActive.Count + _promoteBuffer.Count >= maxMissions)
                    break;
                
                _promoteBuffer.Add(missionMarker);
            }
        }
        
        for (int i = 0; i < _promoteBuffer.Count; i++)
            AssignActiveMissionMarker(_promoteBuffer[i]);
    }
    
    private void UpdateActiveMissionMarker(float dt)
    {
        if (missionMarkerActive.Count <= 0)
            return;
        
        _demoteBuffer.Clear();
        
        foreach (var missionMarker in missionMarkerActive)
        {
            if (missionMarker == null)
                continue;
            
            if (missionMarker.missionMarkerState == MissionMarkerState.Passive)
                continue;
            
            missionMarker.currentTimer += dt;
            
            if (missionMarker.currentTimer >= missionMarker.activeTimer)
                _demoteBuffer.Add(missionMarker);
        }
        
        for (int i = 0; i < _demoteBuffer.Count; i++)
        {
            GameEvents.OnHideRecordingPanel.Invoke(_demoteBuffer[i].missionMarkerData);
            AssignPassiveMissionMarker(_demoteBuffer[i]);
        }
    }

    private float GetRandomPassiveMarkerTimer() => Random.Range(minPassiveMarkerTimer, maxPassiveMarkerTimer);
    private float GetRandomActiveMarkerTimer() => Random.Range(minActiveMarkerTimer, maxActiveMarkerTimer);

    private static void Shuffle<T>(IList<T> list)
    {
        for (int i = list.Count - 1; i > 0; i--)
        {
            int j = Random.Range(0, i + 1);
            (list[i], list[j]) = (list[j], list[i]);
        }
    }
    
    public void StartMission()
    {
        if (this == null) return;

        _isMissionMarkerActive = true;
        Debug.LogWarning($"[MissionManager] StartMission Get CALLED in {gameObject.name}");
        if (areaMission == null)
        {
            Debug.LogError($"{nameof(areaMission)} is null in {gameObject.name}");
            return;
        }
        
        RefreshMissionMarkers();
        
        if (missionMarkers.Count == 0)
        {
            Debug.LogError($"[MissionManager] Tidak ada MissionMarker ditemukan di bawah {areaMission.name}!");
            return;
        }
        
        var shuffled = new List<MissionMarker>(missionMarkers.Count);
        for (int i = 0; i < missionMarkers.Count; i++)
        {
            if (missionMarkers[i] != null)
                shuffled.Add(missionMarkers[i]);
        }

        Shuffle(shuffled);

        foreach (var selectMission in shuffled)
        {
            if (_markerLookup.ContainsKey(selectMission))
                continue;
            
            if (selectMission.MissionMarkerState == MissionMarkerState.Flagged)
                continue;
            
            var markerData = new SelectedMissionMarkerData
            {
                missionMarkerName = selectMission.name,
                missionMarkerData = selectMission
            };
            
            AssignPassiveMissionMarker(markerData);
            _markerLookup[selectMission] = markerData;
        }
        _isMissionMarkerActive = true;
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
    
    private void RemoveMissionMarker(MissionMarker markerData, bool isCorret)
    {
        if (!isCorret)
            return;
        
        var missionMarker =  FindSelectedMissionMarker(markerData);
        
        if (missionMarkerPassive.Contains(missionMarker))
            missionMarkerPassive.Remove(missionMarker);
        
        if (missionMarkerActive.Contains(missionMarker))
            missionMarkerActive.Remove(missionMarker);
        
        _assignedMarkers.Remove(markerData);
    }
}
