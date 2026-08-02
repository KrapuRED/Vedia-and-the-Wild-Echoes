using System.Collections;
using UnityEngine;

public class Recording : MonoBehaviour
{
    [SerializeField] private RecordingPanelUITransition recordingPanelUITransition;
    [SerializeField] private RecordingPanelUI recordingPanelUI;
    [SerializeField] private MissionMarker currentMission;
    [SerializeField] private FlagCard selectedFlagCard;

    [Header("Delay Configuration")]
    [SerializeField] private float delay;
    
    public void UpdateRecording(MissionMarker missionMarker)
    {
        if (missionMarker == null || recordingPanelUI == null)
        {
            Debug.LogError($"[{this.name}] CurrentMission or recordingPanelUI is NULL");
            return;
        }
        
        currentMission = missionMarker;
        recordingPanelUI.UpdateStatusRecord(currentMission.MissionMarkerState, currentMission.MissionRecordingData);
    }
    
    public void DropFlagCard(FlagCard flagCard)
    {
        if (currentMission.MissionMarkerState ==  MissionMarkerState.Passive)
            return;
        
        selectedFlagCard = flagCard;
        recordingPanelUI.UpdateSoundRecodingIcon(flagCard.RecordingData);

        CheckMission();
    }

    public void ResetRecording()
    {
        recordingPanelUI.EmptyRecordingPanelUI();
        currentMission = null;
        selectedFlagCard = null;
    }
    
    private void CheckMission()
    {
        bool isCorrrect = selectedFlagCard.RecordingData.recordingName ==
                          currentMission.MissionRecordingData.recordingName;
        
        if (isCorrrect)
        {
            Debug.Log($"[{gameObject.name}] Successfully checked recording");
            GameEvents.OnFlaggedMissionMarker.Invoke(currentMission);
            recordingPanelUI.ShowCorrectRecording();
        }
        else
        {
            Debug.Log($"[{gameObject.name}] Failed checking recording");
            recordingPanelUI.ShowIncorrectRecording();
        }
        
        ForestMonitorManager.Instance.UpdateIndicator(currentMission.ForestMonitorType, isCorrrect);
        StartCoroutine(OnDelayCoroutine());
    }
    
    private IEnumerator OnDelayCoroutine()
    {
        
        yield return new WaitForSeconds(delay);
        recordingPanelUITransition.HideTransition();
    }
}
