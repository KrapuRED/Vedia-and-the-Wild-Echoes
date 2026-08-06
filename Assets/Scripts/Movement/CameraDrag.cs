using UnityEngine;
using UnityEngine.InputSystem;

public class CameraDrag : CursorController
{
    [SerializeField] private Collider borderCam;
    
    [Header("Cursor Converter Configuration")]
    [SerializeField] private string actionMapName;
    [SerializeField] private InputActionReference dragHoldAction;
    [SerializeField] private InputActionReference dragDeltaAction;
    [SerializeField] private float dragSpeed = 0.05f;
    [SerializeField] private Texture2D dragTexture2D;
    [SerializeField] private Texture2D defaultTexture2D;
    
    private Camera _camera;
    [SerializeField] private bool isDragging;
    private InputManager _inputManager;
    
    private void Awake()
    {
        if (_camera == null)
            _camera = Camera.main;
        
        _inputManager = InputManager.Instance;
        ChangeCursor(defaultTexture2D);
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

    private void ChangeCursor(Texture2D  cursorTexture)
    {
        Debug.Log("Changing Cursor");
        Cursor.SetCursor(cursorTexture, Vector2.zero, CursorMode.Auto);
    }
    
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
        ChangeCursor(dragTexture2D);
        isDragging = true;
    }

    private void OnDragCanceled(InputAction.CallbackContext _)
    {
        ChangeCursor(defaultTexture2D);

        isDragging = false;
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
        Vector3 targetPosition = transform.position + dragVector;
    
        transform.position = ClampToBorder(targetPosition);
    }
    
    private Vector3 ClampToBorder(Vector3 position)
    {
        if (borderCam == null)
            return position;

        Bounds bounds = borderCam.bounds;

        position.x = Mathf.Clamp(position.x, bounds.min.x, bounds.max.x);
        position.z = Mathf.Clamp(position.z, bounds.min.z, bounds.max.z);
        // y left untouched — you're dragging on a horizontal plane, not clamping height

        return position;
    }
}
