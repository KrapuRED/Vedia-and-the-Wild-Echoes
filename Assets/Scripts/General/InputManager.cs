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
    private readonly Stack<string> _overlayStack = new();
    
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

    private void Start() => SwitchActionMap(defaultActionMap);

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
            PopActionMap();

    }
    
    public InputActionMap GetActionMap(string actionMap)
    {
        if (gamePlayInput == null)
        {
            Debug.LogError($"[{nameof(InputManager)}] gamePlayInput Asset Not yet been assign to Inspector!");
            return null;
        }

        var map = gamePlayInput.FindActionMap(actionMap, throwIfNotFound: false);
        if (map == null)
            Debug.LogError($"[{nameof(InputManager)}] No action map found for '{actionMap}'");

        return map;
    }

    public void SwitchActionMap(string mapName)
    {
        if (_switchMapCoroutine != null)
            StopCoroutine(_switchMapCoroutine);

        _switchMapCoroutine = StartCoroutine(DeferredSwitchActionMap(mapName));
    }

    public void PopActionMap()
    {
        if (_switchMapCoroutine != null)
        {
            StopCoroutine(_switchMapCoroutine);
            _switchMapCoroutine = null;
        }

        if (_overlayStack.Count <= 1)
        {
            if (_overlayStack.Count == 1)
            {
                string lastMap =  _overlayStack.Pop();
                if (lastMap != currentMapName)
                    GetActionMap(lastMap)?.Disable();
            }
            
            ExecuteSwitchActionMapDirect(currentMapName);
            return;
        }
        
        string removed = _overlayStack.Pop();
        GetActionMap(removed)?.Disable();

        string next = _overlayStack.Count > 0 ? _overlayStack.Peek() : defaultActionMap;
        GetActionMap(next)?.Enable();
        currentMapName = next;
        OnActionMapChanged?.Invoke(next);
    }

    private void ExecuteSwitchActionMapDirect(string mapName)
    {
        var map = GetActionMap(mapName);
        if (map == null) return;
        
        if (_overlayStack.Count > 0 && _overlayStack.Peek() == mapName) return;
        
        map.Enable();
        _overlayStack.Push(mapName);
        currentMapName = mapName;
        OnActionMapChanged?.Invoke(mapName);
    }
    
    private void ExecuteSwitchActionMap(string mapName)
    {
        var map = GetActionMap(mapName);
        if (map == null)
            return;

        if (_overlayStack.Contains(mapName))
        {
            Debug.LogWarning($"[{nameof(InputManager)}] '{mapName}' is already active in the overlay stack.");
            return;
        }

        map.Enable();
        _overlayStack.Push(mapName);
        currentMapName = mapName;
        OnActionMapChanged?.Invoke(mapName);
    }
    
    private IEnumerator DeferredSwitchActionMap(string mapName)
    {
        yield return null;

        ExecuteSwitchActionMap(mapName);
    }
    
    public bool IsCurrentActionMap(string mapName) => currentMapName == mapName;
    public bool IsOverlayActive(string mapName) => _overlayStack.Contains(mapName);
}
