using UnityEngine;
using UnityEngine.Events;

public abstract class UITransition : MonoBehaviour
{
    [Header("Event UITransition Configuration")]
    [SerializeField] protected UnityEvent onTransitionIn;
    [SerializeField] protected UnityEvent onTransitionOut;
    
    public abstract void ShowTransition();
    public abstract void HideTransition();
}
