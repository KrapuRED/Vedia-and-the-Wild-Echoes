using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class FlaggingCursorController : CursorController
{
    [Header("Cursor Converter Configuration")]
    [SerializeField] private LayerMask interactLayerMask;
    [SerializeField] private string actionMapName;
    [SerializeField] private InputActionReference clickPoint;
    [SerializeField] private InputActionReference clickFlagPoint;
    [SerializeField] private InputActionReference dragFlagPoint;
    
    private FlagCard _selectedFlagCard;
    
    private InputManager _inputManager;
    private Camera _camera;

    private void Awake()
    {
        _inputManager = InputManager.Instance;
        _camera = Camera.main;
    }

    #region Event System

    private void OnEnable()
    {
        if (clickPoint != null)
        {
            clickPoint.action.performed += OnClickMissionMarkerCallback;
            clickPoint.action.canceled += OnClickMissionMarkerCallback;
            clickPoint.action.Enable();
        }
        
        if (clickPoint != null)
            clickPoint.action.Enable();
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {
        if (clickPoint != null)
        {
            clickPoint.action.performed -= OnClickMissionMarkerCallback;
            clickPoint.action.canceled -= OnClickMissionMarkerCallback;
        }
    }
    
    private void OnClickMissionMarkerCallback(InputAction.CallbackContext _) => OnClickMissionMarker();

    #endregion

    public override void HandleMapChange(string mapName)
    {
        if (_inputManager == null)
        {
            Debug.LogError($"[{gameObject.name}] No InputManager found!");
            return;
        }
        
        bool enterActionMap = mapName == actionMapName && !string.IsNullOrEmpty(actionMapName);

        if (enterActionMap)
        {
            if (_inputManager.IsCurrentActionMap(actionMapName))
                return;
            
            if (_inputManager.IsCurrentActionMap(_inputManager.DefaultActionMap))
                _inputManager.SwitchActionMap(actionMapName);
        }
        else
        {
            if (!_inputManager.IsCurrentActionMap(actionMapName))
                return;
            
            _inputManager.PopActionMap();
        }
    }
    
    private void OnClickMissionMarker()
    {
        Debug.Log($"[{gameObject.name}] OnClickMissionMarker");
        
        if (CheckRaycast())
            HandleMapChange(actionMapName);
    }
    
    public void OnClickFlagCard(InputAction.CallbackContext _)
    {
        
    }
    
    public void OnDragFlagCard(InputAction.CallbackContext _)
    {
        
    }
    
    public void OnDropFlagCard(InputAction.CallbackContext _)
    {
        
    }
    
    private bool CheckRaycast()
    {
        Debug.Log("CheckRaycast");
        
        Vector2 screenPos = dragFlagPoint.action.ReadValue<Vector2>();
        Ray ray = _camera.ScreenPointToRay(screenPos);
        
        Debug.DrawRay(ray.origin, ray.direction * 100f, Color.red, 2.0f);
        
        RaycastHit hitInfo;

        if (Physics.Raycast(ray, out hitInfo, interactLayerMask))
        {
            if (hitInfo.collider.TryGetComponent<IInteractable>(out IInteractable interactable))
            {
                interactable.OnIntrect();
                return true;
            }
            else
            {
                Debug.LogWarning($"Object {hitInfo.collider.name} not have IInteractable!");
            }
        }
        else
        {
            Debug.Log("Raycast Failed");
        }
        
        return false;
    }
}
