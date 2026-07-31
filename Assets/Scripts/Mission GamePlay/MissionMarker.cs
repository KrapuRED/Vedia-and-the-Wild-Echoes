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
   [SerializeField] private Material markerPassiveMaterial;
   [SerializeField] private Material markerActiveMaterial;
   
   private MeshRenderer _meshRenderer;
   private Camera _camera;

   private void Awake()
   {
      _camera  = Camera.main;
      _meshRenderer = GetComponent<MeshRenderer>();
   }

   private void LateUpdate()
   {
      transform.rotation = Quaternion.LookRotation(transform.position - _camera.transform.position);
   }

   public void UpdateState(MissionMarkerState markerState)
   {
      if (_meshRenderer == null)
      {
         Debug.LogError($"[{gameObject.name} - {nameof(MissionMarker)}] MeshRenderer not assigned");
         return;
      }
      
      this.markerState = markerState;
      
      Debug.Log($"[{gameObject.name} - {nameof(MissionMarker)}] Success change state: {markerState}");
   }
}
