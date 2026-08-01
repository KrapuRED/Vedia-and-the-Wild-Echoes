using UnityEngine;

[CreateAssetMenu(fileName = "RecordingDataSO", menuName = "Recording DataSO/RecordingDataSO")]
public class RecordingDataSO : ScriptableObject
{
    public string recordingName;
    public Sprite recordingSprite;
    public Material recordingMaterial;
    public string recordingClip;
}
