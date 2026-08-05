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
        StartMainGame();
    }

    public void StartMainGame()
    {
        string sceneName = $"GamePlay_MainGame_{currentLevel}";
        TranstionManager.Instance.LoadScene(sceneName, "CrossFade");   
    }
}
