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
      _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
      if (_spriteRenderers == null || _spriteRenderers.Length == 0)
      {
         Debug.LogWarning($"[{gameObject.name}] No SpriteRenderers found on Character or its children");
         return;
      }

      isInitialized = true;

      FullHideCharacter();
   }

   private void PlayAnimationFade(Color targetColor)
   {
      _fadeSequence?.Kill();

      foreach (SpriteRenderer spriteRenderer in _spriteRenderers)
      {
         spriteRenderer.enabled = true;
      }
 
      Sequence sequence = DOTween.Sequence();
      foreach (SpriteRenderer spriteRenderer in _spriteRenderers)
      {
         sequence.Join(spriteRenderer.DOColor(targetColor, fadeDuration));
      }
 
      sequence.OnComplete(() =>
      {
         _fadeSequence = null;
      });
 
      _fadeSequence = sequence;
   }
   
   public void DimCharacter()
   {
      if (!isInitialized)
      {
         Debug.LogWarning($"[{gameObject.name}] Character not initialized");
         return;
      }
      
      Debug.Log($"[{transform.parent.name} - {gameObject.name}] Dimming Character");
      PlayAnimationFade(dimColor);
   }

   public void ShowCharacter()
   {
      if (!isInitialized)
      {
         Debug.LogWarning($"[{gameObject.name}] Character not initialized");
         return;
      }
      
      Debug.Log($"[{transform.parent.name} - {gameObject.name}] Showing Character");
      PlayAnimationFade(showColor);
   }
   
   public void FullHideCharacter()
   {
      if (!isInitialized) return;

      _fadeSequence?.Kill();
      _fadeSequence = null;

      foreach (SpriteRenderer spriteRenderer in _spriteRenderers)
      {
         spriteRenderer.color = hideColor;
         spriteRenderer.enabled = false;
      }
      
      Debug.Log($"[{gameObject.name}] Full Hide Character");
   }
}
