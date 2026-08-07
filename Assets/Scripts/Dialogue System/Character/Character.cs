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
   [SerializeField] private bool isFullHide;
   
   [Header("Show/Hide Character")]
   [SerializeField] private float fadeDuration;
   [SerializeField] private Color hideColor;
   [SerializeField] private Color dimColor;
   [SerializeField] private Color showColor;
   
   [Header("Move Character")]
   [SerializeField] private float moveDuration = 0.5f;
   [SerializeField] private Ease moveEase = Ease.InOutQuad;
   
   private bool isInitialized = false;
   private SpriteRenderer[] _spriteRenderers;
   private Sequence _fadeSequence;
   private Tween _moveTween;
   
   public bool IsInitialized => isInitialized;

   public CharacterDataSO CharacterData => characterData;

   private void Awake() => InitCharacter();

   private void OnDestroy()
   {
      _fadeSequence?.Kill();
      _moveTween?.Kill();
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

   public void MoveCharacter(Transform newPosition, PositionCharacter position)
   {
      if (position == PositionCharacter.Left)
         transform.localRotation = Quaternion.Euler(0, 180, 0);
      
      if (!isInitialized)
      {
         Debug.LogWarning($"[{gameObject.name}] Character not initialized");
         return;
      }

      if (newPosition == null)
      {
         Debug.LogWarning($"[{gameObject.name}] newPosition is null");
         return;
      }
      
      _moveTween?.Kill();
      _moveTween = transform.DOMove(newPosition.position, moveDuration)
         .SetEase(moveEase)
         .OnComplete(() => _moveTween = null);
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
      isFullHide = false;
      PlayAnimationFade(dimColor);
   }

   public void ShowCharacter()
   {
      if (!isInitialized)
      {
         Debug.LogWarning($"[{gameObject.name}] Character not initialized");
         return;
      }
      
      isFullHide = false;
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
      
      isFullHide = true;
      Debug.Log($"[{gameObject.name}] Full Hide Character");
   }
}
