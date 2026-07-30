using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class CameraDrag : MonoBehaviour
{
    [Header("Cursor Converter Configuration")]
    [SerializeField] private string actionMapName;
    [SerializeField] private InputActionReference dragHoldAction;
    [SerializeField] private InputActionReference dragDeltaAction;
    [SerializeField] private float dragSpeed = 0.05f;
    
    private Camera _camera;
    [SerializeField] private bool isDragging;
    private bool _pendingStart;
    private bool _pendingCancel;
    private InputManager _inputManager;
    
    private void Awake()
    {
        if (_camera == null)
            _camera = Camera.main;
        
        _inputManager = InputManager.Instance;
    }
    
    #region Event System

    private void OnEnable()
    {
        if (_inputManager != null)
            _inputManager.OnActionMapChanged += HandleMapChange;
        
        if (dragHoldAction != null)
        {
            dragHoldAction.action.started += OnDragStarted;
            dragHoldAction.action.canceled += OnDragCanceled;
        }
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {
        Debug.Log("OnRemoveListener");
        if (dragHoldAction != null)
        {
            dragHoldAction.action.started -= OnDragStarted;
            dragHoldAction.action.canceled -= OnDragCanceled;
        }
        
        if (_inputManager != null)
            _inputManager.OnActionMapChanged -= HandleMapChange;
    }

    private void HandleMapChange(string mapName)
    {
        if (mapName != actionMapName)
            isDragging = false;
        
        if (dragHoldAction != null)
            dragHoldAction.action.Enable();
    }
    
    #endregion
    
    private void OnDragStarted(InputAction.CallbackContext _)
    {
        if (isDragging) return;
        Debug.Log("OnDragStarted");
        isDragging = true;
        _pendingStart = true;
    }

    private void OnDragCanceled(InputAction.CallbackContext _)
    {
        isDragging = false;
        _pendingCancel = true;
    }

    private void Update()
{
    if (_pendingStart)
    {
        _pendingStart = false;
        InputManager.Instance?.SwitchActionMap(actionMapName, remember: true);
    }

    if (_pendingCancel)
    {
        _pendingCancel = false;
        InputManager.Instance?.PopActionMap();
    }
}
    
    private void LateUpdate()
    {
        if (!isDragging || dragDeltaAction == null) return;
        
        Vector2 mouseDelta = dragDeltaAction.action.ReadValue<Vector2>();
        if (mouseDelta == Vector2.zero)
            return;
        
        Vector3 right = _camera.transform.right;
        Vector3 forward = _camera.transform.forward;
        
        right.y = 0;
        forward.y = 0;

        right.Normalize();
        forward.Normalize();
        
        Vector3 dragVector = (-right * mouseDelta.x - forward * mouseDelta.y) * dragSpeed;
        transform.position += dragVector;
    }
}
