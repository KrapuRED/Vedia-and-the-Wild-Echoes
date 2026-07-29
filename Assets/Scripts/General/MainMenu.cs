using System;
using UnityEngine;

public class MainMenu : MonoBehaviour
{
    [Header(("Animtion Trasnsiton UI"))] 
    [SerializeField] private UITransition uiTransition;

    private void Start()
    {
        uiTransition.ShowTransition();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
            uiTransition.ShowTransition();
    }

    public void PlayGame()
    {
        uiTransition.HideTransition();
    }
}
