using System;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance {get; private set;}

    [SerializeField] private bool isGameActive;
    [SerializeField] private int currentLevel;
    [SerializeField] private int maxLevel;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
            return;
        }
    }

    private void Start()
    {
        if (!isGameActive)
            return;
        
        StartMainGame();
    }

    public void StartMainGame()
    {
        string sceneName = $"GamePlay_MainGame_{currentLevel}";
        TranstionManager.Instance.LoadScene(sceneName, "CrossFade");   
    }

    public void NextStory()
    {
        string sceneName = $"GamePlay_MainStory_{currentLevel}";
        isGameActive = false;
        
        TranstionManager.Instance.LoadScene(sceneName, "CrossFade"); 
    }

    public void NextLevel()
    {
        currentLevel++;

        if (currentLevel > maxLevel)
        {
            isGameActive = false;
            TranstionManager.Instance.LoadScene("Credit", "CrossFade");
            return;
        }
        
        isGameActive = true;
        string sceneName = $"GamePlay_MainGame_{currentLevel}";
        TranstionManager.Instance.LoadScene(sceneName, "CrossFade");   
    }

    public void EndGame()
    {
        currentLevel = 0;
        TranstionManager.Instance.LoadScene("Gameplay_MainMenu", "CrossFade");
    }
}
