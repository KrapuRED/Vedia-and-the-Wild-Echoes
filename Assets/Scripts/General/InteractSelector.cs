using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.EventSystems;

public class InteractSelector : MonoBehaviour
{
    [SerializeField] private InputActionReference clickPoint;
    [SerializeField] private InputActionReference pointerPosition;
    [SerializeField] private LayerMask interactLayerMask;

    private bool _isPointerOverUI;
    private Camera _camera;
    private Vector2 _screenPosition;
    private InputManager _inputManager;
    
    private void Awake()
    {
        _camera = Camera.main;
        _inputManager = InputManager.Instance;
    }

    #region Event System
    private void OnEnable()
    {
        if (clickPoint != null)
        {
            clickPoint.action.performed += OnClickMissionMarkerCallback;
            clickPoint.action.Enable();
        }
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {
        if (clickPoint != null)
        {
            clickPoint.action.performed -= OnClickMissionMarkerCallback;
        }
    }
    
    private void OnClickMissionMarkerCallback(InputAction.CallbackContext _) => OnClickMissionMarker();

    #endregion
    
    private void Update()
    {
        if (!_inputManager.IsCurrentActionMap(_inputManager.DefaultActionMap))
            return;
        
        if (Pointer.current != null)
        {
            _screenPosition = Pointer.current.position.ReadValue();
        }
    }
    
    private void OnClickMissionMarker()
    {

        CheckRaycast();
    }

    private void CheckRaycast()
    {
        if (_camera == null)
        {
            Debug.LogError("Camera reference is missing!");
            return;
        }
        
        Ray ray = _camera.ScreenPointToRay(_screenPosition);
        Debug.DrawRay(ray.origin, ray.direction * 500f, Color.red, 2f);
        
        if (Physics.Raycast(ray, out var hit, 500f, interactLayerMask))
        {
            Debug.Log($"Raycast Hit: {hit.collider.name}");
        
            if (hit.collider.TryGetComponent<IInteractable>(out var interactable))
            {
                interactable.OnInteract();
            }
        }
    }
}
