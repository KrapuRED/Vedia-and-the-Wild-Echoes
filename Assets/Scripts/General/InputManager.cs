using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    public static InputManager Instance {get; private set; }

    [Header("Settings")]
    [SerializeField] private InputActionAsset gamePlayInput;
    [SerializeField] private string defaultActionMap;

    [Header("Debug Info (Read Only)")]
    [SerializeField] private string currentMapName;
    public event Action<string> OnActionMapChanged;

    [SerializeField] private InputActionMap _currentMap;
    private readonly Stack<string> _mapHistory = new();
    
    private Coroutine _switchMapCoroutine;
    
    public string DefaultActionMap => defaultActionMap;
    public InputActionMap CurrentMap => _currentMap;
    
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
        }
        
        gamePlayInput.FindActionMap("Global")?.Enable();
        
        Cursor.lockState = CursorLockMode.Confined;
    }

    private void Start() => SwitchActionMap(defaultActionMap, false);

    public InputActionMap GetActionMap(string actionMap)
    {
        if (gamePlayInput == null)
        {
            Debug.LogError($"[{nameof(InputManager)}] gamePlayInput Asset Not yet been assign to Inspector!");
            return null;
        }
        
        Debug.Log($"[{nameof(InputManager)}] GetActionMap called : {actionMap}");
        var map = gamePlayInput.FindActionMap(actionMap, throwIfNotFound: false);
        if (map == null)
            Debug.LogError($"[{nameof(InputManager)}] No action map found for '{actionMap}'");

        return map;
    }

    public void SwitchActionMap(string mapName, bool remember = false)
    {
        if (_switchMapCoroutine != null)
            StopCoroutine(_switchMapCoroutine);

        _switchMapCoroutine = StartCoroutine(DeferredSwitchActionMap(mapName, remember));
    }

    public void PopActionMap()
    {
        SwitchActionMap(_mapHistory.Count > 0 ? _mapHistory.Pop() : defaultActionMap);
    }
    
    private void ExecuteSwitchActionMap(string mapName, bool remember)
    {
        var targetMap = GetActionMap(mapName);
        if (targetMap == null)
            return;

        // Jika map target sudah aktif, abaikan
        if (_currentMap != null && _currentMap.name == mapName && _currentMap.enabled)
            return;

        
        if (_currentMap != null)
        {
            if (remember)
            {
                _mapHistory.Push(_currentMap.name);
            }
            _currentMap.Disable();
        }
        
        _currentMap = targetMap;
        
        _currentMap.Enable();

        currentMapName = _currentMap.name;
        OnActionMapChanged?.Invoke(mapName);
        
        Debug.LogWarning($"{_currentMap?.name} enabled={_currentMap?.enabled}");
        Debug.Log($"[{nameof(InputManager)}] Success Switched to '{mapName}'");
    }
    
    private IEnumerator DeferredSwitchActionMap(string mapName, bool remember)
    {
        yield return null;

        ExecuteSwitchActionMap(mapName, remember);
    }
    
    public bool IsMapActive(string mapName) =>  _currentMap != null && _currentMap.name == mapName;
}
