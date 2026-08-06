using UnityEngine;
using System.Collections; 
    
public class SoundEffectPlayer : MonoBehaviour
{
   [SerializeField] private string soundEffectName;
   [SerializeField] private float soundResetTimer;
   
   [SerializeField] private bool _hasPlayed;
   
   public void InitSoundEffectPlayer(string soundEffect) => soundEffectName = soundEffect; 
   
   public void PlaySoundEffect()
   {
      if (this == null)
         return;

      if (soundResetTimer <= 0)
      {
         SoundEffectManager.Instance.PlaySoundEffect(soundEffectName);
         return;
      }
      
      if (!_hasPlayed)
      {
         _hasPlayed = true;
         StartCoroutine(ResetPlaySoundEffect(soundResetTimer));
         SoundEffectManager.Instance.PlaySoundEffect(soundEffectName);
      }
   }

   private IEnumerator ResetPlaySoundEffect(float resetTime)
   {
      yield return new WaitForSeconds(resetTime);
      _hasPlayed = false;
   }
}
