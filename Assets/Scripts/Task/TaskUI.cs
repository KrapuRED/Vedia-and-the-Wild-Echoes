using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TaskUI : MonoBehaviour
{
    [SerializeField] private TMP_Text taskName;
    [SerializeField] private Image taskIcon;
    [SerializeField] private TMP_Text counterTask;
    [SerializeField] private Slider counterSlider;
    [SerializeField] private GameObject counterFillSlider;

    public void InitTaskUI(TaskDataSO taskData)
    {
        taskName.text = taskData.taskName;
        taskIcon.sprite = taskData.taskIcon;
        counterSlider.maxValue = taskData.flagAppearance;
        
        counterTask.text = $"0 / {taskData.flagAppearance}";
    }

    public void UpdateTaskUI(TaskData taskData)
    {
        counterTask.text = $"{taskData.currentTask} / {taskData.flagAppearanceTask}";
        counterFillSlider.SetActive(true);
        counterSlider.value = taskData.currentTask;
    }
}
