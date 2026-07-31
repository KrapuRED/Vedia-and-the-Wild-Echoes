using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class RecordngPanelUI : MonoBehaviour
{
    [SerializeField] private TMP_Text statuRecord;
    [SerializeField] private Image soundRecodingIcon;
    [SerializeField] private Image soundFlagIcon;

    public void UpdateStatuRecord(MissionMarker missionMarker)
    {
        string statusText = missionMarker.MarkerState switch
        {
            MissionMarkerState.Active   => "Irregular",
            MissionMarkerState.Passive  => "Passive",
            _                           => "Unknown"
        };
        
        statuRecord.text = "SoundScape : " +  statusText;
    }

    public void UpdateSoundRecodingIcon()
    {
        
    }

    public void EmptRecordngPanelUI()
    {
        statuRecord.text = string.Empty;
        soundRecodingIcon.sprite = null;
        soundFlagIcon.sprite = null;
    }
}
