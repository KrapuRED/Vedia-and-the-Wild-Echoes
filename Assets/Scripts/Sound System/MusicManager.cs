using System.Collections;
using UnityEngine;

public class MusicManager : MonoBehaviour
{
    public static MusicManager Instance { get; private set; }

    [SerializeField] private MusicLibrary musicLibrary;
    [SerializeField] private float musicVolume;
    
    [Header("Music Audio Source Settings")]
    [SerializeField] private AudioSource musicSource;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
            Destroy(gameObject);
    }

    private void SetMusicVolume(float volume)
    {
        musicVolume = Mathf.Clamp01(volume);
        musicSource.volume = musicVolume;
    }
    
    public void IncreaseMusicVolume(float increasAmount) => SetMusicVolume(musicVolume + increasAmount);
    public void DecreaseMusicVolume(float amountDecrease) =>   SetMusicVolume(musicVolume - amountDecrease);
    
    public void PlayMusic(string trackName, float fadeDuration = 0.5f)
    {
        StartCoroutine(AnimateMusicCrossFade(musicLibrary.GetTrack(trackName), fadeDuration));
    }

    IEnumerator AnimateMusicCrossFade(AudioClip audioClip, float duration)
    { 
        float startVolume = musicSource.volume;
        float percent = 0f;

        while (percent < 1f)
        {
            percent += Time.deltaTime / duration;
            musicSource.volume = Mathf.Lerp(startVolume, 0f, percent);
            yield return null;
        }

        musicSource.clip = audioClip;
        musicSource.Play();

        percent = 0f;
        while (percent < 1f)
        {
            percent += Time.deltaTime / duration;
            musicSource.volume = Mathf.Lerp(0f, musicVolume, percent);
            yield return null;
        }

        musicSource.volume = musicVolume; 
    }
}
