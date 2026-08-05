using UnityEngine;
using System.Collections;

public abstract class SceneTransition : MonoBehaviour
{
    public abstract IEnumerator TranstionIn();
    public abstract IEnumerator TranstionOut();
}
