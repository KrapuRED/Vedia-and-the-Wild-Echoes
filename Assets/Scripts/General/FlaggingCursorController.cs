using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.EventSystems;

public class FlaggingCursorController : MonoBehaviour
{
    [SerializeField] private string actionMap = "FlaggingController";

    [SerializeField] private LayerMask dropLayerMask; // Image that have this can drop
    
    [Header("Cursor Flagging Configuration")]
    [SerializeField] private Canvas canvas;                       // your root canvas
    [SerializeField] private RectTransform dragLayer;
    [SerializeField] private InputActionReference clickFlagPoint;
    [SerializeField] private InputActionReference dragFlagPoint;
    private FlagCard _selectedFlagCard;
    
    private Vector2 _grabOffset;
    private RectTransform _draggedRect;
    private Transform _originalParent;
    private int _originalSiblingIndex;
    private bool _isDragging;
    
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
        clickFlagPoint.action.started += OnClickFlagCard;
        clickFlagPoint.action.canceled += OnDropFlagCard;
        clickFlagPoint.action.Enable();
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {
        clickFlagPoint.action.started -= OnClickFlagCard;
        clickFlagPoint.action.canceled -= OnDropFlagCard;
    }
    #endregion

    private void Update()
    {
        if (!_inputManager.IsCurrentActionMap(actionMap))
            return;
        
        if (!_isDragging || _draggedRect == null) return;
        
        Vector2 screenPos = Pointer.current.position.ReadValue();
        
        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            dragLayer, screenPos,
            canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : _camera,
            out Vector2 localPoint);
        
        _draggedRect.anchoredPosition = localPoint +  _grabOffset;
        
        // if inside drop Layer, and went drop change RecordPanelUI
    }
    
    private Vector2 GetLocalPos(Vector2 screenPos)
    {
        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            dragLayer, screenPos,
            canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : _camera,
            out Vector2 localPoint);
        
        return localPoint;
    }
    
    private void OnClickFlagCard(InputAction.CallbackContext _)
    {
        if (!_inputManager.IsCurrentActionMap(actionMap))
            return;
        
        Vector2 screenPos =  Pointer.current.position.ReadValue();
        Vector2 localPoint = GetLocalPos(screenPos);
        
        PointerEventData pointerEventData = new PointerEventData(EventSystem.current) {position = screenPos};
        var results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(pointerEventData, results);

        foreach (var result in results)
        {
            if (result.gameObject.TryGetComponent(out FlagCard card))
            {
                _selectedFlagCard = card;
                _draggedRect = card.GetComponent<RectTransform>();
                
                _originalParent = _draggedRect.parent;
                _originalSiblingIndex = _draggedRect.GetSiblingIndex();
                _draggedRect.SetParent(dragLayer, worldPositionStays: true);
                _draggedRect.SetAsLastSibling();
                
                _grabOffset = _draggedRect.anchoredPosition - localPoint;
                _isDragging = true;
                break;
            }
        }
    }
    
    private void OnDropFlagCard(InputAction.CallbackContext _)
    {
        if (!_inputManager.IsCurrentActionMap(actionMap))
            return;
        
        if (_selectedFlagCard != null)
        {
            // TODO: check for a valid drop target here (raycast again),
            // otherwise snap back to where it came from:
            _draggedRect.SetParent(_originalParent, worldPositionStays: true);
            _draggedRect.SetSiblingIndex(_originalSiblingIndex);
        }

        Vector2 screenPos =  Pointer.current.position.ReadValue();
        
        PointerEventData pointerEventData = new PointerEventData(EventSystem.current) {position = screenPos};
        var results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(pointerEventData, results);
        
        foreach (var result in results)
        {
            if (result.gameObject.TryGetComponent(out Recording recording))
            {
                recording.DropFlagCard(_selectedFlagCard);
                break;
            }
        }
        
        _isDragging = false;
        _selectedFlagCard = null;
        _draggedRect = null;
    }
}
