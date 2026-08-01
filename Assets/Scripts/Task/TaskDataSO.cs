using UnityEngine;

[CreateAssetMenu(fileName = "TaskDataSO", menuName = "Task Data/TaskDataSO")]
public class TaskDataSO : ScriptableObject
{
    public string taskName;
    public Sprite taskIcon;
    public int flagAppearance;
    public int difficulty;
}
