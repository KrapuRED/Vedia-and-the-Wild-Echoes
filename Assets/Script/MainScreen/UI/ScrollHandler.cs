using UnityEngine;
using DG.Tweening;
using TMPro;
using UnityEngine.UI;
public class ScrollHandler : MonoBehaviour
{
    public Animator anim;
    public TMP_Text scrollText;
    [SerializeField] private RectTransform textRect;
    [SerializeField] private RectTransform backgroundRect;
    [SerializeField] private RectTransform containerRect;

    public void OpenScroll(string text)
    {
        scrollText.text = text;
        LayoutRebuilder.ForceRebuildLayoutImmediate(textRect);
        LayoutRebuilder.ForceRebuildLayoutImmediate(backgroundRect);
        LayoutRebuilder.ForceRebuildLayoutImmediate(containerRect);
        anim.SetBool("isShow", true);
    }
    public void CloseScroll()
    {
        anim.SetBool("isShow", false);
    }
}
