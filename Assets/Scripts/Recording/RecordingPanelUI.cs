using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class RecordingPanelUI : MonoBehaviour
{
    [SerializeField] private GameObject closeButton;
    [SerializeField] private TMP_Text statusRecord;
    [SerializeField] private Sprite irrecgularSprite;
    [SerializeField] private Sprite regularSprite;
    [SerializeField] private Image soundWaveBG;
    [SerializeField] private Image soundRecodingIcon;
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
        closeButton.SetActive(true);
        
        string statusText = markerState switch
        {
            MissionMarkerState.Active   => "Irregular" ,
            MissionMarkerState.Passive  => "Passive" ,
            _                           => "Unknown"
        };

        switch (markerState)
        {
            case MissionMarkerState.Active:
                soundWaveBG.sprite = irrecgularSprite;
                SetImageAlpha(soundWaveBG, 1f);
                break;
            case MissionMarkerState.Passive:
                soundWaveBG.sprite = regularSprite;
                SetImageAlpha(soundWaveBG, 1f);
                break;
            default:
                SetImageAlpha(soundWaveBG, 0f);
                break;
        }
        soundRecodingIcon.sprite = recordingData ? recordingData.recordingSprite : null;
        SetImageAlpha(soundRecodingIcon, 1f);
        statusRecord.text = "SoundScape : " + statusText;
    }

    public void UpdateSoundRecodingIcon(RecordingDataSO recordingData)
    {
        SetImageAlpha(soundRecodingIcon, 1f);
    }

    public void IncorrectRecording()
    {
        correctImage.SetActive(false);
        inCorrectImage.SetActive(false);
    }
    
    public void EmptyRecordingPanelUI()
    {
        statusRecord.text = string.Empty;
        SetImageAlpha(soundRecodingIcon, 0f);
        
        correctImage.SetActive(false);
        inCorrectImage.SetActive(false);
    }

    public void ShowCorrectRecording()
    {
        closeButton.SetActive(false);
        correctImage.SetActive(true);
    }

    public void ShowIncorrectRecording()
    {
        closeButton.SetActive(false);
        inCorrectImage.SetActive(true);
    }
    
}
