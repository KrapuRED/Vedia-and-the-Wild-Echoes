using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    public static InputManager Instance;
    public PlayerInput playerInput;
    public string defaultActionMap;
    public bool SkipPressed { get; private set; }
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }

        playerInput = GetComponent<PlayerInput>();
        defaultActionMap = playerInput.currentActionMap.name;
    }
    public void OnSkip(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            SkipPressed = true;
        }
    }    public void SwitchTo(string mapName)
    {
        Debug.Log(playerInput.currentActionMap.name + " Before");
        playerInput.SwitchCurrentActionMap(mapName);
    }
    public void SwitchToDefault()
    {
        Debug.Log(playerInput.currentActionMap.name + " Before");
        playerInput.SwitchCurrentActionMap(defaultActionMap);
        Debug.Log(playerInput.currentActionMap.name + " After");
    }
    private void LateUpdate()
    {
        SkipPressed = false;
    }
}
