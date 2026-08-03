using UnityEngine;

public class SoundEffectPlayer : MonoBehaviour
{
   [SerializeField] private string soundEffectName;

   public void InitSoundEffectPlayer(string soundEffect) => soundEffectName = soundEffect; 
   
   public void PlaySoundEffect()
   {
      SoundEffectManager.Instance.PlaySoundEffect(soundEffectName);
   }
}
