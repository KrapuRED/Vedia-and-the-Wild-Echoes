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
    [SerializeField] private Transform containerSoundClue;
    [SerializeField] private SoundEffectPlayer buttonPrefab;
    
    public void InitTaskUI(TaskDataSO taskData)
    {
        foreach (Transform child in containerSoundClue)
            Destroy(child.gameObject);
        
        taskName.text = taskData.taskName;
        taskIcon.sprite = taskData.taskIcon;
        counterSlider.maxValue = taskData.flagAppearance;
        
        foreach (var recording in taskData.clueRecordings)
        {
            var button = Instantiate(buttonPrefab, containerSoundClue);
            Debug.Log($"Sound Effect : {recording.recordingClip}");
            button.InitSoundEffectPlayer(recording.recordingClip);
        }
        
        counterTask.text = $"0 / {taskData.flagAppearance}";
    }

    public void UpdateTaskUI(TaskData taskData)
    {
        counterTask.text = $"{taskData.currentTask} / {taskData.flagAppearanceTask}";
        counterFillSlider.SetActive(true);
        counterSlider.value = taskData.currentTask;
    }
}
