using UnityEngine;
using UnityEngine.Events;

public class HelperStarterByEvent : MonoBehaviour
{
    [SerializeField] private UnityEvent StartEvent;
    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        StartEvent?.Invoke();
    }
}
