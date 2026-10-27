using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;
public class SwapPaperAnim : MonoBehaviour
{
    [SerializeField] private RectTransform bottomPaper;
    [SerializeField] private RectTransform topPaper;
    [SerializeField] private Vector2 swapPos;
    [SerializeField] private Vector3 finalPos;
    [SerializeField] private float duration;
    [SerializeField] private Ease easeType1 = Ease.Linear;
    [SerializeField] private Ease easeType2 = Ease.Linear;
    private Vector2 defaultPosBottom;
    private Vector3 defaultRotBottom;
    public void StartAnim()
    {
        Sequence seq = DOTween.Sequence();
        bottomPaper.GetComponent<PaperHoverAnim>().resetable = false;
        defaultPosBottom = bottomPaper.anchoredPosition;
        defaultRotBottom = bottomPaper.localEulerAngles;
        bottomPaper.GetComponent<Image>().raycastTarget = false;
        seq.Append(bottomPaper.DOAnchorPos(swapPos, duration).SetEase(easeType1));
        seq.Join(bottomPaper.DORotate(new Vector3(0f, 0f, 0f), duration).SetEase(easeType1));
        seq.AppendCallback(() =>
        {
            topPaper.anchoredPosition = swapPos;
            topPaper.localEulerAngles = new Vector3(0f, 0f, 0f);
            bottomPaper.gameObject.SetActive(false);
            topPaper.gameObject.SetActive(true);
        });
        seq.Append(topPaper.DOAnchorPos(finalPos, duration).SetEase(easeType2));
    }
    public void ReverseAnim()
    {
        Sequence seq = DOTween.Sequence();
        seq.Append(topPaper.DOAnchorPos(swapPos, duration).SetEase(easeType1));
        seq.AppendCallback(() =>
        {
            bottomPaper.anchoredPosition = swapPos;
            bottomPaper.localEulerAngles = new Vector3(0f, 0f, 0f);
            topPaper.gameObject.SetActive(false);
            bottomPaper.gameObject.SetActive(true);
        });
        seq.Append(bottomPaper.DOAnchorPos(defaultPosBottom, duration).SetEase(easeType2));
        seq.Join(bottomPaper.DORotate(defaultRotBottom, duration).SetEase(easeType2));
        seq.AppendCallback(() =>
        {
            bottomPaper.GetComponent<Image>().raycastTarget = true;
            bottomPaper.GetComponent<PaperHoverAnim>().resetable = true;
        });
    }
}
