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
}

public class TaskManager : MonoBehaviour
{
    public static TaskManager Instance {get; private set;}

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
                currentTask = 0
            };
            activeTasks.Add(newTaskData);
        }
    }

    private TaskData FindTaskByName(string taskName)
    {
        return  activeTasks.Find(x => x.taskName == taskName);
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
            ForestMonitorManager.Instance.ReportForestMonitor();
    }
    
    public void OnUpdateTask(MissionMarker missionData)
    {
        if (_isAllTaskCompleted)
            return;
        
        var taskData = missionData.MissionRecordingData;
        if (taskData == null)
        {
            Debug.LogError($"[{this.name} - OnUpdateTask] Task data is null!");
            return;
        }
        
        var task = FindTaskByName(taskData.recordingName);
        if (task == null)
        {
            Debug.Log($"[{this.name} - OnUpdateTask] Task data not found!");
            return;
        }
        
        task.currentTask++;
        task.taskUI.UpdateTaskUI(task);
        
        if (task.currentTask >= task.flagAppearanceTask)
        {
            task.isCompleted = true;
            CheckAllTaskCompleted();
            return;
        }
    }
}
