using System;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public struct MusicTrack
{
    public string Name;
    public AudioClip Clip;
}

public class MusicLibrary : MonoBehaviour
{
    public List<MusicTrack> trackList = new List<MusicTrack>();

    public AudioClip GetTrack(string nameTrack)
    {
        foreach (var track in trackList)
        {
            if (track.Name == nameTrack)
                return track.Clip;
        }
        Debug.LogWarning($"Music track '{nameTrack}' not found!");
        return null;
    }
}
