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
        bool isCorrrect = selectedFlagCard.RecordingData.forestMonitorType ==
                          currentMission.MissionRecordingData.forestMonitorType;
        
        if (isCorrrect)
        {
            recordingPanelUI.ShowCorrectRecording();
            
            SoundEffectManager.Instance.PlaySoundEffect("recording_correct");
            SoundEffectManager.Instance.StopSoundEffectLoop(currentMission.SoundEffectName);
            
            GameEvents.OnFlaggedMissionMarker.Invoke(currentMission);
        }
        else
        {
            SoundEffectManager.Instance.PlaySoundEffect("recording_incorrect");
            recordingPanelUI.ShowIncorrectRecording();
        }
        
        StartCoroutine(OnDelayCoroutine(isCorrrect));
        
        ForestMonitorManager.Instance.UpdateIndicator(currentMission.ForestMonitorType, isCorrrect);
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
