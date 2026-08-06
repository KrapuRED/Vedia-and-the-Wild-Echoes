using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class Recording : MonoBehaviour
{
    [SerializeField] private RecordingPanelUITransition recordingPanelUITransition;
    [SerializeField] private RecordingPanelUI recordingPanelUI;
    [SerializeField] private MissionMarker currentMission;
    [SerializeField] private FlagCard selectedFlagCard;
    [SerializeField] private Image flagIcon;
    
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

        flagIcon.gameObject.SetActive(false);
        currentMission = missionMarker;
        recordingPanelUI.UpdateStatusRecord(currentMission.MissionMarkerState, currentMission.MissionRecordingData);
        SoundEffectManager.Instance.PlaySoundEffectLoop(currentMission.SoundEffectName);
    }
    
    public void DropFlagCard(FlagCard flagCard)
    {
        if (currentMission.MissionMarkerState ==  MissionMarkerState.Passive)
            return;

        flagIcon.sprite = flagCard.flagData.flagCardSprite;
        flagIcon.gameObject.SetActive(true);
        
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
        InputManager.Instance.PopActionMap();
        
        bool isCorrectType = selectedFlagCard.RecordingData.forestMonitorType ==
                          currentMission.MissionRecordingData.forestMonitorType;

        bool isCorrectRecord = true;

        Debug.LogWarning($"{selectedFlagCard.RecordingData.forestMonitorType }  { currentMission.MissionRecordingData.forestMonitorType} {isCorrectType}");

        if (selectedFlagCard.RecordingData.forestMonitorType == ForestMonitorType.Biodiversity)
        {
            isCorrectRecord = isCorrectRecord &&
                              currentMission.MissionRecordingData.recordingName == selectedFlagCard.RecordingData.recordingName;
        }
        else
        {
            isCorrectRecord = isCorrectType;
        }

        if (isCorrectRecord)
        {
            recordingPanelUI.ShowCorrectRecording();
            SoundEffectManager.Instance.PlaySoundEffect("recording_correct");
        }
        else
        {
            SoundEffectManager.Instance.PlaySoundEffect("recording_incorrect");
            recordingPanelUI.ShowIncorrectRecording();
        }
        
        GameEvents.OnFlaggedMissionMarker.Invoke(currentMission, isCorrectRecord);
        StartCoroutine(OnDelayCoroutine(isCorrectType));
        ForestMonitorManager.Instance.UpdateIndicator(currentMission.ForestMonitorType, isCorrectRecord);
    }

    private void OnTutorialMissionMarker(bool isCorrect)
    {
        if (!isCorrect)
        {
            InputManager.Instance.SwitchActionMap("FlaggingController");
            return;
        }

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
