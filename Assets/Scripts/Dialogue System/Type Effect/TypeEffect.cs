using UnityEngine;

public abstract class TypeEffect : MonoBehaviour
{
    public bool IsTyping { get;  set; }
    
    public abstract void PlayTypeEffect();
    public abstract void SkipType();
    public abstract void SkipDialogue();
}
