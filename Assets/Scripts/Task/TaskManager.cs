using System;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class TaskData
{
    public string taskName;
    public int flagAppearanceTask;
    public int currentTask;
    public TaskUI taskUI;
    public bool isCompleted;
    public TaskDataSO taskRecondingData; 
}

public class TaskManager : MonoBehaviour
{
    public static TaskManager Instance {get; private set;}

    [SerializeField] private GameObject buttonEvaluationImpact;
    
    [Header("Task Configration")] 
    [SerializeField] private TaskUI taskUIPrefab;
    [SerializeField] private Transform containerContentTask;
    [SerializeField] private List<TaskDataSO> contentTasks = new();
    [SerializeField] private List<TaskData> activeTasks = new();

    private bool _isAllTaskCompleted;
    
    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(gameObject);
            return;
        }
        else
        {
            Instance = this;
        }
        
        foreach (var child in containerContentTask.GetComponentsInChildren<TaskUI>())
        {
            Destroy(child.gameObject);
        }
        
    }

    #region Event

    private void OnEnable()
    {
        GameEvents.OnFlaggedMissionMarker.AddListener(OnUpdateTask);
    }

    private void OnDisable() => OnRemoveListeners();

    private void OnDestroy() =>  OnRemoveListeners();

    private void OnRemoveListeners()
    {
        GameEvents.OnFlaggedMissionMarker.RemoveListener(OnUpdateTask);
    }
    
    #endregion
    
    private void Start()
    {
        DisplayTask();
    }

    private void DisplayTask()
    {
        if (taskUIPrefab == null)
        {
            Debug.LogError("TaskUI prefab is not assigned!");
            return;
        }

        foreach (var contentTask in contentTasks)
        {
            TaskUI newTaskUI = Instantiate(taskUIPrefab, containerContentTask);
            newTaskUI.InitTaskUI(contentTask);
            
            TaskData newTaskData = new TaskData()
            {
                taskName = contentTask.taskName,
                flagAppearanceTask = contentTask.flagAppearance,
                taskUI = newTaskUI,
                taskRecondingData = contentTask,
                currentTask = 0
            };
            activeTasks.Add(newTaskData);
        }
    }

    private TaskData FindTaskByName(string taskName)
    {
        var activeTaskData = activeTasks.Find(x => x.taskName == taskName);
        return activeTaskData;
    }

    private TaskData FindTaskBySoundForestMonitoring(ForestMonitorType forestMonitorType, string soundEffectName)
    {
        var activeTaskData = activeTasks.Find(acd => acd.taskRecondingData.clueRecordings[0].forestMonitorType == forestMonitorType);
        return null;
    }

    private void CheckAllTaskCompleted()
    {
        bool isCompleted = true;
        foreach (var activeTask in activeTasks)
        {
            if (!activeTask.isCompleted)
            {
                isCompleted = false;
            }
        }

        _isAllTaskCompleted = isCompleted;
        
        if (isCompleted)
        {
            buttonEvaluationImpact.SetActive(true);
            SoundEffectManager.Instance.PlaySoundEffect("evaluate_button_pop_up");
            GameEvents.OnAllTaskDone.Invoke();
        }
    }
    
    public void OnUpdateTask(MissionMarker missionData)
    {
        if (_isAllTaskCompleted)
            return;
        
        var recordingData = missionData.MissionRecordingData;
        if (recordingData == null)
        {
            Debug.LogError($"[{this.name} - OnUpdateTask] Task data is null!");
            return;
        }
        
        TaskData task = null;
        if (missionData.MissionRecordingData.forestMonitorType == ForestMonitorType.Biodiversity)
        {
            task = FindTaskByName(recordingData.recordingName);
        }
        else
        {
            task = FindTaskByName(missionData.MissionRecordingData.forestMonitorType.ToString());
        }
        
        if (task == null)
        {
            Debug.LogWarning($"[{this.name} - OnUpdateTask] Task data not found!");
            return;
        }
        
        task.currentTask++;
        task.taskUI.UpdateTaskUI(task);
        Debug.LogWarning($"[{this.name} - OnUpdateTask] Task {task.taskName} completed!");
        
        if (task.currentTask >= task.flagAppearanceTask)
        {
            task.isCompleted = true;
            CheckAllTaskCompleted();
            return;
        }
    }
}
