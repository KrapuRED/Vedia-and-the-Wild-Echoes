using UnityEngine;

public class MusicPlayer : MonoBehaviour
{
    [SerializeField] private string musicTrack;
    
    void Start()
    {
        MusicManager.Instance.PlayMusic(musicTrack);
    }
}
