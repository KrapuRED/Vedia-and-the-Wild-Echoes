using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class FlagCard : MonoBehaviour
{
    [SerializeField] private FlagCardDataSO flagCardData;
    [SerializeField] private TMP_Text flagCardName;
    [SerializeField] private Image flagCardImage;
    
    public ForestMonitorType ForestMonitorType => flagCardData.forestMonitorType;
    public RecordingDataSO RecordingData => flagCardData.recordingData;

    private void Start() => InitFlagCard();

    public void InitFlagCard()
    {
        if (flagCardData == null)
        {
            Debug.LogWarning($"{this.name} Flag Card Data is NULL");
            return;
        }
        
        if (flagCardData != null) 
            flagCardImage.sprite = flagCardData.flagCardSprite;
    
        flagCardName.text = flagCardData.flagCardName;
    }
    
    public void ShowFlagCardName() => flagCardName.text = flagCardData.flagCardName;
    public void HideFlagCardName() => flagCardName.text = string.Empty;
}
