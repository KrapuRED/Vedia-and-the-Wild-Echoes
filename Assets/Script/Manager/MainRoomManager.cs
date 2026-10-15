using UnityEngine;
using System.Collections.Generic;
using DG.Tweening;
using System.Collections;
using UnityEngine.UI;
using Unity.VisualScripting;
public class MainRoomManager : MonoBehaviour
{
    public BirdAnimation birdAnim;
    public List<SpriteRenderer> orielPoses = new List<SpriteRenderer>();
    private SpriteRenderer currentOriel;

    public List<Button> interactableButtons = new List<Button>();
    private bool isAnimating = false;
    [TextArea(3, 25)]
    public List<string> letterPanels = new List<string>();
    public ScrollHandler scrollHandler;
    private bool isLetterClosed = false; 
    private int activeLetterIndex = -1;
    public DayState currentDayState { get; private set; }
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        HideAllOrielPoses();
        ToggleInteractables(new List<int>());
        StateManager.instance.onStateChanged += EvaluateState;
        if(StateManager.instance.currentDayState == DayState.Daytime)
        {
            DayNightManager.Instance.ChangeToDay();
        }

        if(StateManager.instance.currentDayState == DayState.NightTime)
        {
            DayNightManager.Instance.ChangeToNight();
        }

        if (!StateManager.instance.HasFlag("IntroPlayed"))
        {
            StateManager.instance.AddFlag("IntroPlayed");

            StateManager.instance.SetStoryState(StoryState.Day1);
            StateManager.instance.SetDayState(DayState.Daytime);
        }
        else
        {
            EvaluateState();
        }
    }

    void OnDestroy()
    {
        if (StateManager.instance != null)
            StateManager.instance.onStateChanged -= EvaluateState;
    }

    void HideAllOrielPoses()
    {
        foreach (SpriteRenderer oriel in orielPoses)
        {
            if (oriel == null) continue;
            oriel.color = new Color(oriel.color.r, oriel.color.g, oriel.color.b, 0f);
        }
    }
    public void SetOrielPose(int index)
    {
        // Safety check to ensure index exists in the list
        if (index < 0 || index >= orielPoses.Count) return;

        SpriteRenderer targetOriel = orielPoses[index];
        if (targetOriel == currentOriel) return; // Already in this pose

        // 1. Fade out the previous pose if it exists
        if (currentOriel != null)
        {
            currentOriel.DOKill(); // Stop any ongoing fades on it
            currentOriel.DOFade(0f, 1f);
        }

        // 2. Fade in the chosen pose
        targetOriel.DOKill(); // Stop any ongoing fades on it
        targetOriel.DOFade(1f, 1f);

        // 3. Track this as the new active pose
        currentOriel = targetOriel;
    }
    private void EvaluateState()
    {
        Debug.Log($"Evaluating state: {StateManager.instance.currentStoryState} - {StateManager.instance.currentDayState}");
        var story = StateManager.instance;
        switch (story.currentStoryState)
        {
            case StoryState.Day1:
                HandleDay1(story.currentDayState);
                break;

            case StoryState.Day2:
                HandleDay2(story.currentDayState);
                break;

            case StoryState.Day3:
                break;

            case StoryState.Day4:
                break;

            case StoryState.Day5:
                break;
            
            case StoryState.Day6:
                break;
            
            case StoryState.Day7:
                break;
        }
    }

    private void HandleDay1(DayState day)
    {
        switch (day)
        {
            case DayState.Daytime:
                if (!StateManager.instance.HasFlag("ArrivingDay1"))
                {
                    Debug.Log("ArrivingDay1 not flagged, starting arrival sequence.");
                    StateManager.instance.AddFlag("ArrivingDay1");
                    SetOrielPose(0);
                    birdAnim.ShowBird();
                    ToggleInteractables(new List<int> { 0 });
                    return;
                }
                if (!StateManager.instance.HasFlag("BirdDay1"))
                {
                    Debug.Log("BirdDay1 not flagged, starting bird interaction.");
                    StateManager.instance.AddFlag("BirdDay1");
                    SetOrielPose(1);
                    birdAnim.HideBird();
                    ToggleInteractables(new List<int> { 1 });
                    return;
                }
                if (!StateManager.instance.HasFlag("DeskDay1"))
                {
                    Debug.Log("DeskDay1 not flagged, starting letter and dialogue sequence.");
                    StateManager.instance.AddFlag("DeskDay1");
                    // (Here you would show letter 1, play DG1, trigger altar glow)
                    StartCoroutine(LetterAndDialogueSequence(0, 0));
                    return;
                }
                if (!StateManager.instance.HasFlag("AltarDay1"))
                {
                    StateManager.instance.AddFlag("AltarDay1");
                    SetOrielPose(3);
                    DialogueHandler.instance.StartDialogue(1, 0.5f, () => {GoThrone();});
                    return;
                }
                break;
            case DayState.NightTime:
                if (!StateManager.instance.HasFlag("AfterThroneDay1"))
                {
                    StateManager.instance.AddFlag("AfterThroneDay1");
                    StartCoroutine(FadeInAndOutAuto(3,4, 3));
                    return;
                }
                if (!StateManager.instance.HasFlag("AfterNightDeskDay1"))
                {
                    StateManager.instance.AddFlag("AfterNightDeskDay1");
                    SetOrielPose(2);
                    StartCoroutine(StartGoTranslate());
                    return;
                }
                if (!StateManager.instance.HasFlag("AfterTranslateDay1"))
                {
                    StateManager.instance.AddFlag("AfterTranslateDay1");
                    SetOrielPose(2);
                    DialogueHandler.instance.StartDialogue(4, 0.5f, () => {ToggleInteractables(new List<int> { 3 });});
                    return;
                }
                if (!StateManager.instance.HasFlag("BedDay1"))
                {
                    StateManager.instance.AddFlag("BedDay1");
                    SetOrielPose(5);
                    DialogueHandler.instance.StartDialogue(5, 0.5f, () => { GoFlashback();});
                    return;
                }
                break;
        }
    }
    private void HandleDay2(DayState day)
    {
        switch (day)
        {
            case DayState.Daytime:
                if (!StateManager.instance.HasFlag("ArrivingDay2"))
                {
                    StateManager.instance.AddFlag("ArrivingDay2");
                    birdAnim.ShowBird();
                    ToggleInteractables(new List<int> { 0 });
                    return;
                }
                if (!StateManager.instance.HasFlag("BirdDay2"))
                {
                    StateManager.instance.AddFlag("BirdDay2");
                    SetOrielPose(1);
                    birdAnim.HideBird();
                    ToggleInteractables(new List<int> { 1 });
                    return;
                }
                if (!StateManager.instance.HasFlag("DeskDay2"))
                {
                    StateManager.instance.AddFlag("DeskDay2");
                    StartCoroutine(LetterAndDialogueSequence(1, 6));
                    return;
                }
                if (!StateManager.instance.HasFlag("AltarDay2"))
                {
                    StateManager.instance.AddFlag("AltarDay2");
                    SetOrielPose(3);
                    DialogueHandler.instance.StartDialogue(7, 0.5f, () => {GoThrone();});
                    return;
                }
                break;

            case DayState.NightTime:
                if (!StateManager.instance.HasFlag("AfterThroneDay2"))
                {
                    StateManager.instance.AddFlag("AfterThroneDay2");
                    SetOrielPose(3);
                    DialogueHandler.instance.StartDialogue(9, 0.5f, () => {ToggleInteractables(new List<int> { 1 });});
                    return;
                }
                if (!StateManager.instance.HasFlag("AfterNightDeskDay2"))
                {
                    StateManager.instance.AddFlag("AfterNightDeskDay2");
                    SetOrielPose(2);
                    StartCoroutine(StartGoTranslate());
                    return;
                }
                if (!StateManager.instance.HasFlag("AfterTranslateDay2"))
                {
                    StateManager.instance.AddFlag("AfterTranslateDay2");
                    SetOrielPose(2);
                    DialogueHandler.instance.StartDialogue(10, 0.5f, () => {ToggleInteractables(new List<int> { 2,3 });});
                    return;
                }
                if (!StateManager.instance.HasFlag("AltarNight2") && StateManager.instance.HasFlag("AltarClickedNight2"))
                {
                    StateManager.instance.AddFlag("AltarNight2");
                    StateManager.instance.AddFlag("AltarNight2ClickedFirst");
                    GoWaiting();
                    return;
                }
                if (StateManager.instance.HasFlag("BellNight2") && !StateManager.instance.HasFlag("AfterBellNight2"))
                {
                    StateManager.instance.AddFlag("AfterBellNight2");
                    SetOrielPose(3);
                    DialogueHandler.instance.StartDialogue(14, 0.5f, () => {ToggleInteractables(new List<int> { 3 });});
                    return;
                }
                if (!StateManager.instance.HasFlag("BedDay2") && StateManager.instance.HasFlag("BedClickedNight2") && StateManager.instance.HasFlag("AltarNight2ClickedFirst"))
                {
                    StateManager.instance.AddFlag("BedDay2");
                    SetOrielPose(5);
                    DialogueHandler.instance.StartDialogue(15, 0.5f, () => { GoFlashback();});
                    //StateManager.instance.SetStoryState(StoryState.Day3);
                    //StateManager.instance.SetDayState(DayState.Daytime);
                    return;
                }
                if (!StateManager.instance.HasFlag("BedDay2") && StateManager.instance.HasFlag("BedClickedNight2"))
                {
                    StateManager.instance.AddFlag("BedDay2");
                    StateManager.instance.AddFlag("BedDay2ClickedFirst");
                    SetOrielPose(5);
                    DialogueHandler.instance.StartDialogue(16, 0.5f, () => { GoFlashback();});
                    //StateManager.instance.SetStoryState(StoryState.Day3);
                    //StateManager.instance.SetDayState(DayState.Daytime);
                    return;
                }
                break;
        }
    }

    private void HandleDay3(DayState day)
    {
        switch (day)
        {
            case DayState.Daytime:

            if (!StateManager.instance.HasFlag("ArrivingDay3"))
                {
                    StateManager.instance.AddFlag("ArrivingDay3");
                    birdAnim.ShowBird();
                    ToggleInteractables(new List<int> { 0 });
                    return;
                }
            break;
        }
    }
    public void ToggleInteractables(List<int> activeIndex)
    {
        for (int i = 0; i < interactableButtons.Count; i++)
        {
            if (interactableButtons[i] == null) continue;

            bool shouldBeActive = activeIndex.Contains(i);
            interactableButtons[i].enabled = shouldBeActive;
            //Debug.Log($"Setting Button [{interactableButtons[i].gameObject.name}] (Index {i}) Interactable to: {shouldBeActive}");
        }
    }
    public void OnBirdClicked()
    {
        ToggleInteractables(new List<int>());
        if (!StateManager.instance.HasFlag("BirdClickedDay1"))
        {
            StateManager.instance.AddFlag("BirdClickedDay1");
            StateManager.instance.SetDayState(DayState.Daytime);
            return;
        }
        if (!StateManager.instance.HasFlag("BirdClickedDay2"))
        {
            StateManager.instance.AddFlag("BirdClickedDay2");
            StateManager.instance.SetDayState(DayState.Daytime);
            return;
        }
    }

    public void OnDeskClicked()
    {
        ToggleInteractables(new List<int>());
        if (!StateManager.instance.HasFlag("DeskClickedDay1"))
        {
            StateManager.instance.AddFlag("DeskClickedDay1");
            StateManager.instance.SetDayState(DayState.Daytime);
            return;
        }
        if (!StateManager.instance.HasFlag("DeskClickedNight1"))
        {
            StateManager.instance.AddFlag("DeskClickedNight1");
            StateManager.instance.SetDayState(DayState.NightTime);
            return;
        }
        if (!StateManager.instance.HasFlag("DeskClickedDay2"))
        {
            StateManager.instance.AddFlag("DeskClickedDay2");
            StateManager.instance.SetDayState(DayState.Daytime);
            return;
        }
        if (!StateManager.instance.HasFlag("DeskClickedNight2"))
        {
            StateManager.instance.AddFlag("DeskClickedNight2");
            StateManager.instance.SetDayState(DayState.NightTime);
            return;
        }
    }

    public void OnBedClicked()
    {
        ToggleInteractables(new List<int>());
        if (!StateManager.instance.HasFlag("BedClickedNight1"))
        {
            StateManager.instance.AddFlag("BedClickedNight1");
            StateManager.instance.SetDayState(DayState.NightTime);
            return;
        }
        if (!StateManager.instance.HasFlag("BedClickedNight2") && !StateManager.instance.HasFlag("AltarNight2ClickedFirst"))
        {
            StateManager.instance.AddFlag("BedClickedNight2");
            StateManager.instance.SetDayState(DayState.NightTime);
            return;
        }
        if (!StateManager.instance.HasFlag("BedClickedNight2") && StateManager.instance.HasFlag("AltarNight2ClickedFirst"))
        {
            StateManager.instance.AddFlag("BedClickedNight2");
            StateManager.instance.SetDayState(DayState.NightTime);
            return;
        }
    }
    public void OnLetterCloseClicked()
    {
        // Close whatever letter is currently recorded as open
        if (activeLetterIndex >= 0 && activeLetterIndex < letterPanels.Count)
        {
            if (letterPanels[activeLetterIndex] != null)
            {
                scrollHandler.CloseScroll();
            }
        }
        
        isLetterClosed = true; 
        activeLetterIndex = -1; // Reset active tracking
    }
    private IEnumerator LetterAndDialogueSequence(int letterIndex, int dialogueIndex)
    {
        isAnimating = true; 
        ToggleInteractables(new List<int>()); 
        SetOrielPose(2); 
        yield return new WaitForSeconds(1.0f); 
        if (letterIndex >= 0 && letterIndex < letterPanels.Count)
        {
            activeLetterIndex = letterIndex;
            if (letterPanels[activeLetterIndex] != null)
            {
                scrollHandler.OpenScroll(letterPanels[activeLetterIndex]);
            }
        }

        isLetterClosed = false;
        yield return new WaitUntil(() => isLetterClosed);

        // 4. Letter is now closed, proceed to Dialogue / VFX sequences
        DialogueHandler.instance.StartDialogue(dialogueIndex, 0.5f);
        // add altar glow
        // 5. Sequence complete, safely unlock scene and open up Altar interaction
        isAnimating = false;
        ToggleInteractables(new List<int> { 2 }); // Altar clickable (index 2)
    }

    private IEnumerator FadeInAndOutAuto(int index1, int index2, int index3)
    {
        SetOrielPose(index1);
        yield return new WaitForSeconds(1.0f);
        DialogueHandler.instance.StartDialogue(index3, 0.5f, () => {SetOrielPose(index2); ToggleInteractables(new List<int> { 1 });});
        //play audio match
        //change background
    }
    public void OnAltarClicked()
    {
        ToggleInteractables(new List<int>());
        if (!StateManager.instance.HasFlag("AltarClickedDay1"))
        {
            StateManager.instance.AddFlag("AltarClickedDay1");
            StateManager.instance.SetDayState(DayState.Daytime);
            return;
        }
        if (!StateManager.instance.HasFlag("AltarClickedDay2"))
        {
            StateManager.instance.AddFlag("AltarClickedDay2");
            StateManager.instance.SetDayState(DayState.Daytime);
            return;
        }
        if (!StateManager.instance.HasFlag("AltarClickedNight2"))
        {
            StateManager.instance.AddFlag("AltarClickedNight2");
            StateManager.instance.SetDayState(DayState.NightTime);
            return;
        }
    }

    public void GoThrone()
    {
        SceneChangerManager.instance.StartFadeSolidColor(2, "white");
    }

    public void GoWaiting()
    {
        SceneChangerManager.instance.StartFadeSolidColor(4);
    }
    IEnumerator StartGoTranslate()
    {
        yield return new WaitForSeconds(0.5f);
        GoTranslate();
    }
    public void GoTranslate()
    {
        SceneChangerManager.instance.StartFadeSolidColor(3);
    }
    public void GoFlashback()
    {
        SceneChangerManager.instance.StartFadeSolidColor(6);
    }
}
