using System.Collections;
using UnityEngine;

public class MusicManager : MonoBehaviour
{
    public static MusicManager Instance { get; private set; }

    [SerializeField] private MusicLibrary musicLibrary;

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
    
    public void PlayMusic(string trackName, float fadeDuration = 0.5f)
    {
        StartCoroutine(AnimateMusicCrossFade(musicLibrary.GetTrack(trackName), fadeDuration));
    }

    IEnumerator AnimateMusicCrossFade(AudioClip audioClip, float duration)
    {
        float percent = 0f;

        while (percent < 1f)
        {
            percent += Time.deltaTime * 1 / duration;
            musicSource.volume = Mathf.Lerp(1f, 0, percent);
            yield return null;
        }

        musicSource.clip = audioClip;
        musicSource.Play();

        percent = 0f;
        while (percent < 1f)
        {
            percent += Time.deltaTime * 1 / duration;
            musicSource.volume = Mathf.Lerp(0, 1f, percent);
            yield return null;
        }
    }
}
