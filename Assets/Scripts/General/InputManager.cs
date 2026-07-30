using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    public static InputManager Instance {get; private set; }

    [SerializeField] private InputActionAsset gamePlayInput;
    [SerializeField] private string defaultActionMap = "Gameplay";

    public event Action<string> OnActionMapChanged;

    [SerializeField] private InputActionMap _currentMap;
    private readonly Stack<string> _mapHistory = new();
    
    public InputActionMap CurrentMap => _currentMap;
    
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
        }
        
        Cursor.lockState = CursorLockMode.Confined;
    }

    private void Start() => SwitchActionMap(defaultActionMap, true);
    
    public InputActionMap GetActionMap(string actionMap)
    {
        var map = gamePlayInput.FindActionMap(actionMap, throwIfNotFound: false);
        if (map == null)
            Debug.LogError($"No action map found for {actionMap}");
        return map;
    }

    public void SwitchActionMap(string mapName, bool remember = false)
    {
        Debug.Log($"Switching to {mapName}");
        var targetMap = GetActionMap(mapName);
        if (targetMap == null)
            return;

        if (_currentMap != null && _currentMap.name != mapName)
        {
            if (remember) _mapHistory.Push(_currentMap.name);
            _currentMap.Disable();
        }
        
        _currentMap = targetMap;
        _currentMap.Enable();
        OnActionMapChanged?.Invoke(mapName);
    }

    public void PopActionMap()
    {
        SwitchActionMap(_mapHistory.Count > 0 ? _mapHistory.Pop() : defaultActionMap);
    }
    
    public bool IsMapActive(string mapName) =>  _currentMap != null && _currentMap.name == mapName;
}
