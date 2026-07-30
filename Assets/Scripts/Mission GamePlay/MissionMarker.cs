using System;
using UnityEngine;

[System.Serializable]
public enum MissionMarkerState
{
   Passive, 
   Active
}

public class MissionMarker : MonoBehaviour
{
   [SerializeField] private MissionMarkerState markerState ;
   [SerializeField] private float maxTilted; 
   
   private Camera _camera;

   private void Awake()
   {
      _camera  = Camera.main;
   }

   private void LateUpdate()
   {
      transform.rotation = Quaternion.LookRotation(transform.position - _camera.transform.position);
   }

   public void UpdateState(MissionMarkerState markerState)
   {
      this.markerState = markerState;
   }
}
