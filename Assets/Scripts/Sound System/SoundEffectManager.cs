using System;
using System.Collections.Generic;
using UnityEngine;

public class SoundEffectManager : MonoBehaviour
{
   public static SoundEffectManager Instance { get; private set; }

   [SerializeField] private SoundEffectLibrary soundEffectLibrary;

   [Header("Sound Effec Audio Source Settings")]
   [SerializeField] private AudioSource soundSource;
   [SerializeField] private AudioSource soundSourceLoop;
   
   private Dictionary<string, AudioSource> _loopSources = new();
   
   private void Awake()
   {
      if (Instance == null)
      {
         Instance = this;
      }
      else
         Destroy(gameObject);
   }
   
   public void PlaySoundEffect(string groupID)
   {
      AudioClip clip = soundEffectLibrary.GetClipByID(groupID);
      if (clip != null)
         soundSource.PlayOneShot(clip);
      else
         Debug.LogWarning($"[SoundEffectManager] Clip not found: {groupID}");
   }

   public void PlaySoundEffectLoop(string groupID)
   {
      if (string.IsNullOrEmpty(groupID))
      {
         Debug.LogWarning($"[{this.name}] Tried to play a sound loop with a null/empty groupID.");
         return;
      }
      
      if (_loopSources.ContainsKey(groupID))
         return;

      AudioClip clip = soundEffectLibrary.GetClipByID(groupID);

      if (clip == null)
      {
         Debug.LogWarning($"Loop clip not found: {groupID}");
         return;
      }

      GameObject loopObj = new GameObject($"Loop_{groupID}");
      loopObj.transform.SetParent(transform);

      AudioSource source = loopObj.AddComponent<AudioSource>();

      source.clip = clip;
      source.loop = true;
      source.Play();

      _loopSources.Add(groupID, source);
   }

   public void StopSoundEffect()
   {
      if (soundSource.isPlaying)
         soundSource.Stop();
   }

   public void StopSoundEffectLoop(string groupID)
   {
      if (!_loopSources.TryGetValue(groupID, out AudioSource source))
         return;

      source.Stop();

      Destroy(source.gameObject);

      _loopSources.Remove(groupID);
   }

   public void StopAllSoundEFfectLoop()
   {
      Debug.Log("StopAllSoundEFfectLoop");
      foreach (var source in _loopSources.Values)
      {
         if (source != null)
            source.Stop();
      }
      _loopSources.Clear();
   }
}
