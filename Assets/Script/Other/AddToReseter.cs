using UnityEngine;

public class AddToReseter : MonoBehaviour
{
    void Start()
    {
        Reseter.AddToResetList(gameObject);
    }
}
