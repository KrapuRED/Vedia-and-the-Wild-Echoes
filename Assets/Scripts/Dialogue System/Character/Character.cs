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
   [SerializeField] private Color showColor;
   
   private SpriteRenderer[] _spriteRenderers;
   private Sequence _fadeSequence;
   
   private void Awake()
   {
      if (characterData == null)
         return;

      _spriteRenderers = GetComponentsInChildren<SpriteRenderer>(true);
   }

   private void OnDestroy()
   {
      _fadeSequence?.Kill();
   }
   
   public void InitCharacter(PositionCharacter position)
   {
      positionCharacter = position;
      bool isFlipped = positionCharacter == PositionCharacter.Left;
      
      foreach (var sr in _spriteRenderers)
      {
         sr.flipX = isFlipped;
      }
   }
   
   public void HideCharacter()
   {
      _fadeSequence?.Kill();
      _fadeSequence = DOTween.Sequence();

      foreach (var sr in _spriteRenderers)
      {
         _fadeSequence.Join(sr.DOColor(hideColor, fadeDuration));
      } 
      
      _fadeSequence.OnComplete(() =>
      {
         foreach (var sr in _spriteRenderers)
            sr.enabled = false;
      });
   }

   public void ShowCharacter()
   {
      _fadeSequence?.Kill();
      _fadeSequence = DOTween.Sequence();

      foreach (var sr in _spriteRenderers)
      {
         _fadeSequence.Join(sr.DOColor(showColor, fadeDuration));
      } 
      
      _fadeSequence.OnComplete(() =>
      {
         foreach (var sr in _spriteRenderers)
            sr.enabled = false;
      });
   }
}
