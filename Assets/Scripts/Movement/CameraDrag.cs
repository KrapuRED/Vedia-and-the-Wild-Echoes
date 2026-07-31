using UnityEngine;
using UnityEngine.InputSystem;

public class CameraDrag : CursorController
{
    [Header("Cursor Converter Configuration")]
    [SerializeField] private string actionMapName;
    [SerializeField] private InputActionReference dragHoldAction;
    [SerializeField] private InputActionReference dragDeltaAction;
    [SerializeField] private float dragSpeed = 0.05f;
    
    private Camera _camera;
    [SerializeField] private bool isDragging;
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
        if (dragHoldAction != null)
        {
            dragHoldAction.action.performed += OnDragStarted;
            dragHoldAction.action.canceled += OnDragCanceled;
            dragHoldAction.action.Enable();
        }
        
        if (dragDeltaAction != null)
            dragDeltaAction.action.Enable();
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {
        if (dragHoldAction != null)
        {
            dragHoldAction.action.performed -= OnDragStarted;
            dragHoldAction.action.canceled -= OnDragCanceled;
        }
    }
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
            isDragging = false;
        }
        
        if (dragHoldAction != null)
            dragHoldAction.action.Enable();
    }
    
    private void OnDragStarted(InputAction.CallbackContext _)
    {
        if (isDragging) return;
        
        HandleMapChange(actionMapName);
        
        isDragging = true;
    }

    private void OnDragCanceled(InputAction.CallbackContext _)
    {
        if (isDragging) 
            HandleMapChange(_inputManager.DefaultActionMap);
        
        isDragging = false;
    }
    
    private void LateUpdate()
    {
        if (!isDragging || dragDeltaAction == null) return;
        
        if (!_inputManager.IsOverlayActive(actionMapName))
            return;
        
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
