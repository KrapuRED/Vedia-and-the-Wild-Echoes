using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;
using DG.Tweening;
[System.Serializable]
public class BellDialogueData
{
    public Button bellButton;
    public int dialogueIndex; 
    public GameObject background;
}
[System.Serializable]
public class DayWaitingConfig
{
    public StoryState targetDay;
    public List<BellDialogueData> chamberBells = new List<BellDialogueData>();
}
public class WaitingRoomManager : MonoBehaviour
{
    [SerializeField] private Image flashImage; // Full-screen white Image
    [SerializeField] private float flashDuration = 0.2f;
    public List<DayWaitingConfig> dayConfigurations = new List<DayWaitingConfig>();
    private List<BellDialogueData> activeBells = new List<BellDialogueData>();

    void Start()
    {
        SetupCurrentDayBells();
    }

    private void SetupCurrentDayBells()
    {
        StoryState currentDay = StateManager.instance.currentStoryState;
        
        // Find the configuration matching the current day
        DayWaitingConfig currentConfig = dayConfigurations.Find(config => config.targetDay == currentDay);

        if (currentConfig != null)
        {
            activeBells = new List<BellDialogueData>(currentConfig.chamberBells);

            foreach (BellDialogueData bellData in activeBells)
            {
                if (bellData.bellButton == null) continue;

                BellDialogueData localData = bellData; 
                localData.bellButton.onClick.AddListener(() => OnBellClicked(localData));
            }
        }
        else
        {
            Debug.LogWarning($"No bell configuration set up for {currentDay}!");
        }
    }

    public void OnBellClicked(BellDialogueData data)
    {
        Sequence sequence = DOTween.Sequence();
        sequence.Append(flashImage.DOFade(1f, flashDuration));
        sequence.AppendCallback(() =>
        {
            foreach (BellDialogueData bellData in activeBells)
            {
                bellData.bellButton.gameObject.SetActive(false);

                if (bellData.background != null)
                    bellData.background.SetActive(false);
            }

            if (data.background != null)
                data.background.SetActive(true);
        });
        sequence.Append(flashImage.DOFade(0f, flashDuration));
        sequence.AppendCallback(() =>
        {
            DialogueHandler.instance.StartDialogue(data.dialogueIndex, 0.5f, () =>
            {
                data.bellButton.interactable = false;
                if (EvaluateSceneState())
                    return;
                Sequence returnSequence = DOTween.Sequence();

                // Flash to white again
                returnSequence.Append(flashImage.DOFade(1f, flashDuration));

                // Switch back to bells while white
                returnSequence.AppendCallback(() =>
                {
                    if (data.background != null)
                        data.background.SetActive(false);

                    foreach (BellDialogueData bellData in activeBells)
                    {
                        bellData.bellButton.gameObject.SetActive(true);
                    }
                });

                // Reveal bells again
                returnSequence.Append(flashImage.DOFade(0f, flashDuration));
            });
        });
    }
    private bool EvaluateSceneState()
    {
        bool allBellsDead = true;
        foreach (BellDialogueData bellData in activeBells)
        {
            if (bellData.bellButton != null && bellData.bellButton.interactable)
            {
                allBellsDead = false;
                break;
            }
        }

        if (allBellsDead)
        {
            // Condition: Semua bell mati -> FADE TO WHITE / NEXT SCENE
            Debug.Log("All bells are dead! Progressing out of the chamber scene...");
            if (!StateManager.instance.HasFlag("BellNight2"))
            {
                StateManager.instance.AddFlag("BellNight2");
                StateManager.instance.SetDayState(DayState.NightTime);
                SceneChangerManager.instance.StartFadeSolidColor(1); 
                return true;
            }
        }
        return false;
    }
}
