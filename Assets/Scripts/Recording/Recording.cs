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
    
    public MissionMarker SelectedMissionMarker => currentMission;
    
    public void UpdateRecording(MissionMarker missionMarker)
    {
        if (missionMarker == null || recordingPanelUI == null)
        {
            Debug.LogError($"[{this.name}] CurrentMission or recordingPanelUI is NULL");
            return;
        }
        
        currentMission = missionMarker;
        recordingPanelUI.UpdateStatusRecord(currentMission.MissionMarkerState, currentMission.MissionRecordingData);
        SoundEffectManager.Instance.PlaySoundEffectLoop(currentMission.SoundEffectName);
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
        bool isCorrectType = selectedFlagCard.RecordingData.forestMonitorType ==
                          currentMission.MissionRecordingData.forestMonitorType;

        bool isCorrectRecord = true;
        
        if (isCorrectType && selectedFlagCard.RecordingData.forestMonitorType == ForestMonitorType.Biodiversity)
        {
            isCorrectRecord = currentMission.MissionRecordingData.recordingName == selectedFlagCard.RecordingData.recordingName;
        }

        if (isCorrectType)
        {
            recordingPanelUI.ShowCorrectRecording();
            SoundEffectManager.Instance.PlaySoundEffect("recording_correct");
        }
        else
        {
            SoundEffectManager.Instance.PlaySoundEffect("recording_incorrect");
            recordingPanelUI.ShowIncorrectRecording();
        }

        GameEvents.OnFlaggedMissionMarker.Invoke(currentMission, isCorrectType);

        StartCoroutine(OnDelayCoroutine(isCorrectType));
        ForestMonitorManager.Instance.UpdateIndicator(currentMission.ForestMonitorType, isCorrectRecord);
    }

    private void OnTutorialMissionMarker(bool isCorrect)
    {
        if (!isCorrect)
            return;

        TutorialManager.Instance.OnMissionCompleted();
        recordingPanelUITransition.HideTransition();
    }
    
    private IEnumerator OnDelayCoroutine(bool isCorrrect)
    {
        yield return new WaitForSeconds(delay);
        
        if (TutorialManager.Instance.IsTutorialActive)
        {
            recordingPanelUI.IncorrectRecording();
            OnTutorialMissionMarker(isCorrrect);
            yield break;
        }        
        recordingPanelUITransition.HideTransition();
    }
}
