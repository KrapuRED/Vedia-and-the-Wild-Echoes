using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class RecordingPanelUI : MonoBehaviour
{
    [SerializeField] private TMP_Text statusRecord;
    [SerializeField] private Image soundRecodingIcon;
    [SerializeField] private Image soundFlagIcon;
    [SerializeField] private GameObject correctImage;
    [SerializeField] private GameObject inCorrectImage;
    
    private void SetImageAlpha(Image img, float alpha)
    {
        if (img == null) return;
        Color color = img.color;
        color.a = alpha;
        img.color = color;
    }
    
    public void UpdateStatusRecord(MissionMarkerState markerState, RecordingDataSO recordingData)
    {
        correctImage.SetActive(false);
        inCorrectImage.SetActive(false);
        
        string statusText = markerState switch
        {
            MissionMarkerState.Active   => "Irregular",
            MissionMarkerState.Passive  => "Passive",
            _                           => "Unknown"
        };

        if (soundFlagIcon.sprite == null)
            SetImageAlpha(soundFlagIcon, 0f);

        soundRecodingIcon.sprite = recordingData ? recordingData.recordingSprite : null;

        SetImageAlpha(soundRecodingIcon, 1f);
        statusRecord.text = "SoundScape : " + statusText;
    }

    public void UpdateSoundRecodingIcon(RecordingDataSO recordingData)
    {
        soundFlagIcon.sprite = recordingData.recordingSprite;
        SetImageAlpha(soundFlagIcon, 1f);
        SetImageAlpha(soundRecodingIcon, 1f);
    }

    public void EmptyRecordingPanelUI()
    {
        statusRecord.text = string.Empty;
        SetImageAlpha(soundFlagIcon, 0f);
        SetImageAlpha(soundRecodingIcon, 0f);
        
        correctImage.SetActive(false);
        inCorrectImage.SetActive(false);
    }
    
    public void ShowCorrectRecording() => correctImage.SetActive(true);
    public void ShowIncorrectRecording() => inCorrectImage.SetActive(true);
    
}
