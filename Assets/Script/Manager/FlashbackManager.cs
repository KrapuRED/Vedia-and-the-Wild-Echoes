using UnityEngine;

public class FlashbackManager : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        if (!StateManager.instance.HasFlag("FlashbackDay1"))
        {
            StateManager.instance.AddFlag("FlashbackDay1");
            FlashbackTextHandler.instance.PlayFlashback(0,0, () => {StateManager.instance.SetBoth(StoryState.Day2, DayState.Daytime);GoMain();});
            return;
        }
        if (!StateManager.instance.HasFlag("FlashbackDay2"))
        {
            StateManager.instance.AddFlag("FlashbackDay2");
            FlashbackTextHandler.instance.PlayFlashback(1,1,() => {StateManager.instance.SetBoth(StoryState.Day3, DayState.Daytime);GoMenu();});
            return;
        }
    }

    void GoMain()
    {
        SceneChangerManager.instance.StartFadeSolidColor(1);
    }

    void GoMenu()
    {
        SceneChangerManager.instance.StartFadeSolidColor(0);
    }
}
