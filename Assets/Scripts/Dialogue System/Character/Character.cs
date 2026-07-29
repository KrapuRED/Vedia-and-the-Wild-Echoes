using System;
using UnityEngine;
using DG.Tweening;

[System.Serializable]
public enum PositionCharacter
{
   Left,
   Middle,
   Right
}

public class Character : MonoBehaviour
{
   [Header("Character Configuration")]
   [SerializeField] private CharacterDataSO characterData;
   [SerializeField] private PositionCharacter positionCharacter;
   
   [Header("Show/Hide Character")]
   [SerializeField] private float fadeDuration;
   [SerializeField] private Color hideColor;
   [SerializeField] private Color dimColor;
   [SerializeField] private Color showColor;
   
   private bool isInitialized = false;
   private SpriteRenderer[] _spriteRenderers;
   private Sequence _fadeSequence;

   public CharacterDataSO CharacterData => characterData;

   private void Awake()
   {
      InitCharacter();
   }

   private void OnDestroy()
   {
      _fadeSequence?.Kill();
   }
   
   public void InitCharacter()
   {
      
   }

   private void RunFade(Color targetColor, System.Action onComplete)
   {
     
   }
   
   public void HideCharacter()
   {
      
   }

   public void ShowCharacter()
   {
      
   }
   
   public void FullHideCharacter()
   {
      
   }
}
