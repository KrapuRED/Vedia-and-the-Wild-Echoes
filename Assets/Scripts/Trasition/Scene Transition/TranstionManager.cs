using System.Linq;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class TranstionManager : MonoBehaviour
{
    public static  TranstionManager Instance {get; private set;}

    [SerializeField] private Transform contianerTransition;
    //[SerializeField] private Slider progressBar;
    [SerializeField] private List<SceneTransition> transitions =  new();

    private CancellationTokenSource _cts;
    
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
            return;
        }
        
        transitions.Clear();
        transitions = contianerTransition.GetComponentsInChildren<SceneTransition>(true).ToList();
    }

    public void LoadScene(string sceneName, string transitionName)
    {
        StartCoroutine(LoadSceneAsync(sceneName, transitionName));
    }

    private IEnumerator LoadSceneAsync(string sceneName, string transitionName)
    {
        SceneTransition transition = transitions.First(t => t.name == transitionName);

        AsyncOperation scene = SceneManager.LoadSceneAsync(sceneName);
        scene.allowSceneActivation = false;

        yield return transition.TranstionIn();

        //progressBar.gameObject.SetActive(true);

        do
        {
            //progressBar.value = scene.progress;
            yield return null;
        } while (scene.progress < 0.9f);

        yield return new WaitForSeconds(1f);

        scene.allowSceneActivation = true;

        yield return null;
        //progressBar.gameObject.SetActive(false);

        yield return transition.TranstionOut();
        GameEvents.OnStartMainGame.Invoke();
    }
}
