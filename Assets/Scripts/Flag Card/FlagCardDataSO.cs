using UnityEngine;

[CreateAssetMenu(fileName = "FlagCardDataSO", menuName = "Flag Card DataSO/FlagCardDataSO")]
public class FlagCardDataSO : ScriptableObject
{
    public string flagCardName;
    public Sprite flagCardSprite;
    public RecordingDataSO recordingData;
}
