using UnityEngine;
using System;

#region CustomEvents
public class CustomEvents
{
    private event Action _action = delegate { };

    public void Invoke()
    {
        _action?.Invoke();
    }
    
    public void AddListener(Action listener)
    {
        _action += listener;
    }
    public void RemoveListener(Action listener)
    {
        _action += listener;
    }
}

public class CustomEvents<T>
{
    private event Action<T> _action = delegate { };
    public void Invoke(T arg)
    {
        _action?.Invoke(arg);
    }
    
    public void AddListener(Action<T> listener)
    {
        _action += listener;
    }
    public void RemoveListener(Action<T> listener)
    {
        _action += listener;
    }
}

public class CustomEvents<T1, T2>
{
    private event Action<T1, T2> _action = delegate { };
    public void Invoke(T1 arg1, T2 arg2)
    {
        _action?.Invoke(arg1, arg2);
    }
    
    public void AddListener(Action<T1, T2> listener)
    {
        _action += listener;
    }
    public void RemoveListener(Action<T1, T2> listener)
    {
        _action += listener;
    }
}

public class CustomEvents<T1, T2, T3>
{
    private event Action<T1, T2, T3> _action = delegate { };
    public void Invoke(T1 arg1, T2 arg2, T3 arg3)
    {
        _action?.Invoke(arg1, arg2, arg3);
    }
    
    public void AddListener(Action<T1, T2, T3> listener)
    {
        _action += listener;
    }
    public void RemoveListener(Action<T1, T2, T3> listener)
    {
        _action += listener;
    }
}

public class CustomEvents<T1, T2, T3, T4>
{
    private event Action<T1, T2, T3, T4> _action = delegate { };
    public void Invoke(T1 arg1, T2 arg2, T3 arg3, T4 arg4)
    {
        _action?.Invoke(arg1, arg2, arg3, arg4);
    }
    
    public void AddListener(Action<T1, T2, T3, T4> listener)
    {
        _action += listener;
    }
    public void RemoveListener(Action<T1, T2, T3, T4> listener)
    {
        _action += listener;
    }
}
#endregion

public static class GameEvents
{
    public static readonly CustomEvents<MissionMarker> OnShowRecordingPanel = new();
    public static readonly CustomEvents OnHideRecordingPanel = new();
    
    public static readonly CustomEvents<MissionMarker> OnFlaggedMissionMarker = new();
    public static readonly CustomEvents<MissionMarker> OnMissionMarkerRegistered = new();
    public static readonly CustomEvents<MissionMarker> OnMissionMarkerUnregistered = new();
    
    public static readonly CustomEvents OnAllTaskDone = new();
}
