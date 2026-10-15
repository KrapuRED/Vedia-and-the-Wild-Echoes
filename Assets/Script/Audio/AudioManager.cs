using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Audio;
using System;
using DG.Tweening;
using System.Collections;
public class AudioManager : MonoBehaviour
{
    [System.Serializable]
    public class Sound
    {
        public AudioClip clip;
        public bool loop;

        [Range(0f, 1f)]
        public float Volume = 1.0f;

        [HideInInspector]
        public AudioSource source;
    }

    public Slider musicSlider;
    public Slider sfxSlider;

    public Sound[] music;
    public Sound[] rythmGame;
    public Sound[] sfx;

    public AudioMixerGroup musicGroup;
    public AudioMixerGroup sfxGroup;

    public static AudioManager instance;

    public float fadeDuration;
    public float fadeDurationRythm;
    public float _delayBetween = 0.5f;

    private Sound CurrentMusic;
    private Sound beforeRythmGame;
    private Sound pausedMusic;
    private float pausedTime;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
            return;
        }

        DontDestroyOnLoad(gameObject);
        InitializeSounds(music, musicGroup);
        InitializeSounds(sfx, sfxGroup);
        InitializeSounds(rythmGame, musicGroup);
    }

    private void Update()
    {
        if (musicSlider != null)
        {
            MusicVolume(musicSlider.value);
            PlayerPrefs.SetFloat("MusicVolume", musicSlider.value);
        }
        if (sfxSlider != null)
        {
            SFXVolume(sfxSlider.value);
            PlayerPrefs.SetFloat("SFXVolume", sfxSlider.value);
        }
    }

    private void InitializeSounds(Sound[] sounds, AudioMixerGroup group)
    {
        foreach (Sound s in sounds)
        {
            s.source = gameObject.AddComponent<AudioSource>();
            s.source.clip = s.clip;
            s.source.loop = s.loop;
            s.source.volume = s.Volume;
            s.source.outputAudioMixerGroup = group;

            // Force preload audio data to avoid delay on first play
            if (s.clip != null && !s.clip.preloadAudioData)
            {
                s.clip.LoadAudioData();
            }
        }
    }


    public void PlaySFX(int index)
    {
        Sound s = sfx[index];
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        s.source.PlayOneShot(s.clip, s.Volume);
    }
    public void StopSFX(int index)
    {
        Sound s = sfx[index];
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        s.source.Stop();
    }

    public void ChangeMusic(int to)
    {
        Sound ss = music[to];
        StartCoroutine(ChangeMusicRoutine(ss, fadeDuration));
    }

    private IEnumerator ChangeMusicRoutine(Sound ss, float fadeDuration)
    {
        Sound s = CurrentMusic;
        CurrentMusic = ss;
        if (s != null)
        {
            float time = 0f;
            float startVolume = s.source.volume;

            while (time < fadeDuration)
            {
                time += Time.deltaTime;
                float volume = Mathf.Lerp(startVolume, 0f, time / fadeDuration);
                s.source.volume = volume;
                yield return null;
            }

            s.source.Stop();
            s.source.volume = startVolume;
        }

        yield return new WaitForSeconds(_delayBetween);

        ss.source.volume = 0f;
        ss.source.Play();

        float fadeInTime = 0f;
        while (fadeInTime < fadeDuration)
        {
            fadeInTime += Time.deltaTime;
            float volume = Mathf.Lerp(0f, ss.Volume, fadeInTime / fadeDuration);
            ss.source.volume = volume;
            yield return null;
        }

        ss.source.volume = ss.Volume;
        
    }

    public void StartRythmGame(int index)
    {
        beforeRythmGame = CurrentMusic;
        Sound ss = rythmGame[index];
        StartCoroutine(ChangeMusicRoutine(ss, fadeDurationRythm));
    }

    public void StopRythmGame()
    {
        Debug.Log("Stopping Rythm Game");
        StartCoroutine(ChangeMusicRoutine(beforeRythmGame, fadeDurationRythm));
    }

    public void PlayMusic(int index)
    {
        Sound s = music[index];
        s.source.volume = 0f;
        s.source.Play();
        s.source.DOFade(s.Volume, fadeDuration);
        CurrentMusic = s;
    }

    public void StopMusic()
    {
        Sound s = CurrentMusic;
        if (s == null)
        {
            return;
        }
        s.source.DOFade(0f, fadeDuration).OnComplete(() => s.source.Stop());
    }

    public void StopAllMusic()
    {
        foreach (Sound s in music)
        {
            s.source.Stop();
        }
    }

    public void StopAllSfx()
    {
        foreach (Sound s in sfx)
        {
            s.source.Stop();
        }
    }

    public void StopAll()
    {
        foreach (Sound s in sfx)
        {
            s.source.Stop();
        }
        foreach (Sound s in music)
        {
            s.source.Stop();
        }
    }

    public void MusicVolume(float volume)
    {
        foreach (Sound s in music)
        {
            s.source.volume = volume;
        }
    }

    public void SFXVolume(float volume)
    {
        foreach (Sound s in sfx)
        {
            s.source.volume = volume;
        }
    }

    public void PauseSfx()
    {
        for (int i = 0; i < 6 && i < sfx.Length; i++)
        {
            sfx[i].source.Pause();
        }
    }

    public void UnPauseSfx()
    {
        for (int i = 0; i < 6 && i < sfx.Length; i++)
        {
            sfx[i].source.UnPause();
        }
    }

    public void PauseMusic(int index)
    {
        Sound s = music[index];
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        s.source.Pause();
    }

    public void UnpauseMusic(int index)
    {
        Sound s = music[index];
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        s.source.UnPause();
    }
    public IEnumerator PauseMusicWithFade(float duration)
    {
        if (CurrentMusic == null) yield break;

        pausedMusic = CurrentMusic;
        pausedTime = pausedMusic.source.time;

        yield return pausedMusic.source
            .DOFade(0f, duration)
            .WaitForCompletion();

        pausedMusic.source.Pause();
    }
    public IEnumerator ResumeMusicWithFade(float duration)
    {
        if (pausedMusic == null) yield break;

        pausedMusic.source.time = pausedTime;
        pausedMusic.source.Play();

        yield return pausedMusic.source
            .DOFade(pausedMusic.Volume, duration)
            .WaitForCompletion();
    }
}
