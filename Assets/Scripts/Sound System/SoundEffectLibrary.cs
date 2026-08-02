using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct SoundEffectData
{
    public string groupID;
    public List<AudioClip> clips;
}

public class SoundEffectLibrary : MonoBehaviour
{ [SerializeField] private List<SoundEffectData> soundEffectList = new();
    
    public AudioClip GetClipByID(string groupID)
    {
        foreach (var effect in soundEffectList)
        {
            if (effect.groupID == groupID)
            {
                if (effect.clips.Count > 0)
                {
                    int index = Random.Range(0, effect.clips.Count);
                    return effect.clips[index];
                }
                else
                {
                    Debug.LogWarning($"Sound effect group '{groupID}' has no clips!");
                    return null;
                }
            }
        }
        Debug.LogWarning($"Sound effect group '{groupID}' not found!");
        return null;
    }
}
