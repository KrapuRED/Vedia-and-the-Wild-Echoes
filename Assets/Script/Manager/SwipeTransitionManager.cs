using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using DG.Tweening;
using UnityEngine.UI;
public enum Direction
{
    TopToBottom,
    BottomToTop    
}

[System.Serializable]
public class SceneTransitionData
{
    public string sceneName;
    public Sprite scenePreview;
}

public class SwipeTransitionManager : MonoBehaviour
{
    public static SwipeTransitionManager instance;

    [SerializeField] RectTransform scenePreview;
    [SerializeField] Image previewImage;
    [SerializeField] List<SceneTransitionData> sceneTransitions;
    public Vector2 topPosition;
    public Vector2 middlePosition;
    public Vector2 bottomPosition;
    public float slideDuration = 0.6f;

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
        scenePreview.gameObject.SetActive(false);
    }

    public void LoadScene(string sceneName, Direction direction)
    {
        StartCoroutine(Transition(sceneName, direction));
    }

    IEnumerator Transition(string sceneName, Direction direction)
    {
        SceneTransitionData data = sceneTransitions.Find(
            x => x.sceneName == sceneName
        );

        if (data == null)
        {
            Debug.LogError("No preview found for scene: " + sceneName);
            yield break;
        }
        // Set preview image
        previewImage.sprite = data.scenePreview;
        // 1. Enable GameObject
        scenePreview.gameObject.SetActive(true);
        scenePreview.DOKill();

        // 2. Set starting position according to direction
        Vector2 startPos = (direction == Direction.TopToBottom) ? topPosition : bottomPosition;
        scenePreview.anchoredPosition = startPos;

        // 3. Force Canvas rebuild so Unity applies the start position immediately on this frame
        Canvas.ForceUpdateCanvases();

        // 4. Wait one frame so UI layout stabilizes before starting DOTween
        yield return null;

        yield return scenePreview.DOAnchorPos(middlePosition, slideDuration).SetEase(Ease.OutQuart).WaitForCompletion();

        // Preview is now covering the current scene.
        // Load the actual destination scene.
        SceneManager.LoadScene(sceneName);

        yield return null;

        scenePreview.gameObject.SetActive(false);
    }

    [ContextMenu("Test Transition - Top To Bottom")]
    void TestTopToBottom()
    {
        LoadScene(
            "WaitingRoom",
            Direction.TopToBottom
        );
    }


    [ContextMenu("Test Transition - Bottom To Top")]
    void TestBottomToTop()
    {
        LoadScene(
            "TranslateRoom",
            Direction.BottomToTop
        );
    }
}
