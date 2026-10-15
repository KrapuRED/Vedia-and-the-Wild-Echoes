using System.Collections.Generic;
using UnityEngine.Events;
using UnityEngine;
using System;


public enum StoryState
{
    None,
    Day1,
    Day2,
    Day3,
    Day4,
    Day5,
    Day6,
    Day7
}

public enum DayState
{
    None,
    Daytime,
    NightTime
}
public class StateManager : MonoBehaviour
{
    public static StateManager instance;
    public StoryState currentStoryState;
    public DayState currentDayState;
    private HashSet<string> flags = new HashSet<string>();
    public Action onStateChanged;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(this);
        }
    }
    
    public void SetStoryState(StoryState newState)
    {
        currentStoryState = newState;
        onStateChanged?.Invoke();
    }

    public void SetDayState(DayState newState)
    {
        currentDayState = newState;
        onStateChanged?.Invoke();
    }

    public void SetBoth(StoryState newState, DayState newDayState)
    {
        currentStoryState = newState;
        currentDayState = newDayState;
        onStateChanged?.Invoke();
    }
    public void AddFlag(string flag)
    {
        flags.Add(flag);
    }
    public bool HasFlag(string flag)
    {
        return flags.Contains(flag);
    }

    public void RemoveFlag(string flag)
    {
        if (flags.Contains(flag))
        {
            flags.Remove(flag);
            onStateChanged?.Invoke(); 
        }
    }
    public void ResetState()
    {
        currentStoryState = StoryState.Day1;
        currentDayState = DayState.Daytime;
        flags.Clear();
        onStateChanged?.Invoke();
    }
}
