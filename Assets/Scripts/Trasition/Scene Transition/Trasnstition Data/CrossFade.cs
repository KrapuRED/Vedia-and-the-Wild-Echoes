using System.Collections;
using DG.Tweening;
using UnityEngine;

public class CrossFade : SceneTransition
{
    [SerializeField] private float transitionDuration;
    [SerializeField] private CanvasGroup  canvasGroup;
    
    public override IEnumerator TranstionIn()
    {
        this.gameObject.SetActive(true);
        
        var tweener  = canvasGroup.DOFade(1,transitionDuration);
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;
        
        yield return tweener.WaitForCompletion();
    }

    public override IEnumerator TranstionOut()
    {
        
        var tweener  = canvasGroup.DOFade(0,transitionDuration);
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;

        tweener.OnComplete(()=> this.gameObject.SetActive(false));
        
        yield return tweener.WaitForCompletion();
    }
}
