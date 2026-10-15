using UnityEngine;

public class ThroneRoomManager : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        if (!StateManager.instance.HasFlag("ThroneDay1"))
        {
            StateManager.instance.AddFlag("ThroneDay1");
            StateManager.instance.SetDayState(DayState.NightTime);
            DialogueHandler.instance.StartDialogue(2, 0.5f, () => {GoMain();});
            return;
        }
        if (!StateManager.instance.HasFlag("ThroneDay2"))
        {
            StateManager.instance.AddFlag("ThroneDay2");
            StateManager.instance.SetDayState(DayState.NightTime);
            DialogueHandler.instance.StartDialogue(8, 0.5f, () => {GoMain();});
            return;
        }
    }

    void GoMain()
    {
        SceneChangerManager.instance.StartFadeSolidColor(1, "white");
    }
}
