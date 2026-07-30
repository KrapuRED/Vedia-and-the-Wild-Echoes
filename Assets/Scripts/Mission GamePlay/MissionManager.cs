using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Pool;
using Random = UnityEngine.Random;

public class MissionMarkerData
{
    public string missionMarkerName;
    public MissionMarker missionMarkerData;
    public float activeTimer;
    public float currentTimer;
}

public class MissionManager : MonoBehaviour
{
    public  static MissionManager Instance { get; private set; }

    [Header("Mission Configuration")]
    [SerializeField] private int maxMissions;
    [SerializeField] private List<MissionMarkerData> areaMissionSelected =  new();
    
    [Header("Area Spawning Mission")] 
    [SerializeField] private Transform areaMission;
    [SerializeField] private List<MissionMarker> missionMarkers = new();
    
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

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
            StartMission();

        foreach (var missionMarker in areaMissionSelected)
        {
            if (missionMarker == null)
                continue;

            if (missionMarker.currentTimer >= missionMarker.activeTimer)
            {
                missionMarker.missionMarkerData.UpdateState(MissionMarkerState.Active);
                Debug.Log($"{missionMarker.missionMarkerName} {missionMarker.activeTimer}");
            }
            else
            {
                missionMarker.currentTimer += Time.deltaTime;
            }
        }
    }
    

    public void StartMission()
    {
        if (areaMission == null)
        {
            Debug.LogError($"{nameof(areaMission)} is null in {gameObject.name}");
            return;
        }
        
        int randomIndex = Random.Range(0, missionMarkers.Count);
        
        var selectedMission = missionMarkers[randomIndex];
        MissionMarkerData markerData = new MissionMarkerData
        {
            missionMarkerName = selectedMission.name,
            missionMarkerData = selectedMission,
            activeTimer = 0,
            
        };
        
        areaMissionSelected.Add(markerData);
    }
}
