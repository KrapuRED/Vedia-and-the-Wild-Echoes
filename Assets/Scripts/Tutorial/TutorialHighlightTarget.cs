using UnityEngine;

public class TutorialHighlightTarget : MonoBehaviour
{
    [SerializeField] private string highlightID;
 
    [SerializeField] private RectTransform _rectTransform;
 
    private void Awake()
    {
        _rectTransform = GetComponent<RectTransform>();
    }
 
    private void OnEnable()
    {
       GameEvents.OnRegisterHighlightTarget.Invoke(highlightID, _rectTransform);
    }
 
    private void OnDisable()
    {
       GameEvents.OnUnregisterHighlightTarget.Invoke(highlightID);
       
    }
}
