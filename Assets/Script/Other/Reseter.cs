using UnityEngine;
using System.Collections.Generic;
public class Reseter : MonoBehaviour
{
    public static Reseter instance;
    public static List<GameObject> persistentObjects = new List<GameObject>();
    void Awake()
    {
        if(instance != null)
        {
            Destroy(gameObject);
            return;
        }
        DontDestroyOnLoad(this);
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F10))
        {
            ResetPersistentObjects();
            //AudioManager.instance.ChangeMusic(4);
            SceneChangerManager.instance.StartFadeSolidColor(0);
        }
    }
    public static void AddToResetList(GameObject obj)
    {
        if (!persistentObjects.Contains(obj))
        {
            persistentObjects.Add(obj);
            DontDestroyOnLoad(obj);
        }
    }
    public static void RemoveFromResetList(GameObject obj)
    {
        if (persistentObjects.Contains(obj))
        {
            persistentObjects.Remove(obj);
        }
    }

    public static void ResetPersistentObjects()
    {
        Debug.Log("Resetting Persistent Objects");
        foreach (var obj in persistentObjects)
        {
            if (obj != null)
                Destroy(obj);
        }

        persistentObjects.Clear();
    }
}
