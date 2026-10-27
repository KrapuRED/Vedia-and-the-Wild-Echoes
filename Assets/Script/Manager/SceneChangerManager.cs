using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections;
using DG.Tweening;
using TMPro;

    
public class SceneChangerManager : MonoBehaviour
{
    [Header("Solid Color Settings")]
    [SerializeField] private Image _fadeImage;
    [SerializeField] private float _fadeDuration = 1f;
    [SerializeField] private float _inBetweenSolidColorDuration = 3f;
    [Header("Loading Settings")]
    [SerializeField] private CanvasGroup _canvasgroup;
    [SerializeField] private Image _iconImage; 
    [SerializeField] private TMP_Text _animationText;
    [SerializeField] private float _inBetweenLoadingDuration = 2f;
    [SerializeField] private float _iconAnimationDuration = 0.1f;
    [SerializeField] private float _textAnimationDuration = 0.1f;
    [SerializeField] private Sprite[] _mioSprites; 
    private Coroutine animationCoroutine;
    private Coroutine textCoroutine;
    private string currentText = "TRAVELING........";
    public static SceneChangerManager instance;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }
    public void StartFadeLoading(int sceneIndex)
    {
        StartCoroutine(FadeRoutineLoading(sceneIndex));
    }
    public void StartFadeStartMusicLoading(int sceneIndex, int musicIndex)
    {
        StartCoroutine(FadeRoutineMusicLoading(sceneIndex, musicIndex));
    }
    private IEnumerator FadeRoutineMusicLoading(int sceneIndex, int musicIndex)
    {
        SceneManager.LoadScene(sceneIndex);
        //AudioManager.instance.PlayMusic(musicIndex);
        yield return StartCoroutine(Fade(0f));
    }
    private IEnumerator FadeRoutineLoading(int sceneIndex)
    {
        animationCoroutine = StartCoroutine(AnimationLoop());
        textCoroutine = StartCoroutine(TextLoop());
        yield return StartCoroutine(Fade(1f));
        yield return new WaitForSeconds(_inBetweenLoadingDuration - 0.1f);
        SceneManager.LoadScene(sceneIndex);
        yield return new WaitForSeconds(0.1f);
        yield return StartCoroutine(Fade(0f));
        StopCoroutine(animationCoroutine);
        StopCoroutine(textCoroutine);
    }
    private IEnumerator AnimationLoop()
    {
        while (true)
        {
            for (int i = 0; i < _mioSprites.Length; i++)
            {
                _iconImage.sprite = _mioSprites[i];
                yield return new WaitForSeconds(_iconAnimationDuration);
            }
        }
    }
    private IEnumerator TextLoop()
    {
        while (true)
        {
            for (int i = 0; i <= currentText.Length; i++)
            {

                _animationText.text = currentText.Substring(0, i);
                yield return new WaitForSeconds(_textAnimationDuration);
            }

            yield return new WaitForSeconds(0.5f);

            for (int i = currentText.Length; i >= 0; i--)
            {
                _animationText.text = currentText.Substring(0, i);
                yield return new WaitForSeconds(0.05f);
            }

            yield return new WaitForSeconds(0.5f);
        }
    }
    private IEnumerator Fade(float targetAlpha)
    {
        yield return _canvasgroup.DOFade(targetAlpha, _fadeDuration).WaitForCompletion();
    }
    private Color GetColorFromString(string colorName)
    {
        if (string.Equals(colorName, "white", System.StringComparison.OrdinalIgnoreCase))
        {
            return Color.white;
        }

        // Defaults to Black for "black" or any unrecognized string
        return Color.black;
    }
    public void StartFadeSolidColor(int sceneIndex = 0, string colorName = "black")
    {
        Color selectedColor = GetColorFromString(colorName);
        selectedColor.a = 0f;
        _fadeImage.color = selectedColor;
        StartCoroutine(FadeRoutineSolidColor(sceneIndex));
    }
    public void StartFadeMusicSolidColor(int sceneIndex, int musicIndex, string colorName = "black")
    {
        Color selectedColor = GetColorFromString(colorName);
        selectedColor.a = 0f;
        _fadeImage.color = selectedColor;
        StartCoroutine(FadeRoutineMusicSolidColor(sceneIndex, musicIndex));
    }
    private IEnumerator FadeRoutineMusicSolidColor(int sceneIndex, int musicIndex)
    {
        Color finalColor = _fadeImage.color;
        finalColor.a = 1f;
        _fadeImage.color = finalColor;
        SceneManager.LoadScene(sceneIndex);
        //AudioManager.instance.PlayMusic(musicIndex);
        yield return StartCoroutine(FadeSolidColor(0f));
    }
    private IEnumerator FadeRoutineSolidColor(int sceneIndex)
    {
        yield return StartCoroutine(FadeSolidColor(1f));
        yield return new WaitForSeconds(_inBetweenSolidColorDuration - 0.1f);
        SceneManager.LoadScene(sceneIndex);
        yield return new WaitForSeconds(0.1f);
        yield return StartCoroutine(FadeSolidColor(0f));
    }

    private IEnumerator FadeSolidColor(float targetAlpha, float dura = -1)
    {
        if(dura < 0)
            dura = _fadeDuration;
        Debug.Log("Fade started");
        float startAlpha = _fadeImage.color.a;
        float time = 0f;

        while (time < dura)
        {
            time += Time.deltaTime;
            float alpha = Mathf.Lerp(startAlpha, targetAlpha, time / dura);
            Color newColor = _fadeImage.color;
            newColor.a = alpha;
            _fadeImage.color = newColor;
            yield return null;
        }

        Color finalColor = _fadeImage.color;
        finalColor.a = targetAlpha;
        _fadeImage.color = finalColor;
    }
    public void StartEmptyFade(float duration,float fadeSpeed = -1, System.Action onComplete = null, Color colors = default)
    {
        if (colors == default)
            colors = Color.white;

        colors.a = 0f;
        _fadeImage.color = colors;
        StartCoroutine(EmptyFadeRoutineSolidColor(duration,fadeSpeed , onComplete));
    }
    private IEnumerator EmptyFadeRoutineSolidColor(float duration,float fadeSpeed, System.Action onComplete = null)
    {
        yield return StartCoroutine(FadeSolidColor(1f,fadeSpeed));
        yield return new WaitForSeconds(_inBetweenSolidColorDuration - 0.1f);
        onComplete.Invoke();
        yield return new WaitForSeconds(duration);
        yield return StartCoroutine(FadeSolidColor(0f,fadeSpeed));
    }
}
