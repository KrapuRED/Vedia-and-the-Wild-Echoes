using UnityEngine;
using System.Collections.Generic;

[CreateAssetMenu(fileName = "TaskDataSO", menuName = "Task Data/TaskDataSO")]
public class TaskDataSO : ScriptableObject
{
    public string taskName;
    public Sprite taskIcon;
    public int flagAppearance;
    public List<RecordingDataSO> clueRecordings = new();
}
