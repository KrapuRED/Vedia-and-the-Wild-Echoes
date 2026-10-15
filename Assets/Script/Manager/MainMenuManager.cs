using UnityEngine;

public class MainMenuManager : MonoBehaviour
{
    public void OnStart()
    {
        SceneChangerManager.instance.StartFadeSolidColor(5, "white");
    }
}
