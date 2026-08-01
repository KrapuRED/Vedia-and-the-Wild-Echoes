using UnityEngine;

public class Recording : MonoBehaviour
{
    [SerializeField] private RecordingPanelUI recordingPanelUI;
    [SerializeField] private MissionMarker currentMission;
    [SerializeField] private FlagCard selectedFlagCard;

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
    }

    public void ResetRecording()
    {
        recordingPanelUI.EmptyRecordingPanelUI();
        currentMission = null;
        selectedFlagCard = null;
    }
    
    public void CheckMission()
    {
        if (selectedFlagCard.RecordingData.recordingName == currentMission.MissionRecordingData.recordingName)
        {
            Debug.Log($"[{gameObject.name}] Successfully checked recording");
            GameEvents.OnFlaggedMissionMarker.Invoke(currentMission);
        }
        else
        {
            Debug.Log($"[{gameObject.name}] Failed checking recording");
        }
    }
}
