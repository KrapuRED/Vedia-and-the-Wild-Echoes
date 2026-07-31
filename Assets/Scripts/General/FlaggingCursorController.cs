 using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class FlaggingCursorController : MonoBehaviour
{
    [Header("Cursor Converter Configuration")]
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
        
        /*if (clickFlagPoint != null)
        {
            clickFlagPoint.action.performed += OnClickFlagCard;
            clickFlagPoint.action.Enable();
        }

        if (dragFlagPoint != null)
        {
            dragFlagPoint.action.performed += OnDragFlagCard;
            dragFlagPoint.action.canceled += OnDropFlagCard;
            dragFlagPoint.action.Enable();
        }*/
    }

    private void OnDisable() => OnRemoveListener();
    private void OnDestroy() => OnRemoveListener();

    private void OnRemoveListener()
    {

    }
    #endregion
    
    /*public void OnClickFlagCard(InputAction.CallbackContext _)
    {
        
    }
    
    public void OnDragFlagCard(InputAction.CallbackContext _)
    {
        
    }
    
    public void OnDropFlagCard(InputAction.CallbackContext _)
    {
        
    }*/
}
