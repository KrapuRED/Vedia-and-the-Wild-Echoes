using System;
using UnityEngine;

public class BackToMainMenu : MonoBehaviour
{
    private void Start()
    {
        GameManager.Instance.EndGame();
    }
}
