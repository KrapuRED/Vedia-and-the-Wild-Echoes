using System;
using UnityEngine;

[System.Serializable]
public enum MissionMarkerState
{
   Passive, 
   Active
}

public class MissionMarker : MonoBehaviour, IInteractable
{
   [SerializeField] private MissionMarkerState markerState ;
   [SerializeField] private float maxTilted; 
   [SerializeField] private Material markerPassiveMaterial;
   [SerializeField] private Material markerActiveMaterial;
   [SerializeField] private bool isFlagged;
   
   [SerializeField] private string targetMap = "FlaggingController";
   
   private MeshRenderer _meshRenderer;
   private Camera _camera;
   
   public bool IsFlagged => isFlagged;

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
      Debug.Log($"[{gameObject.name} - {nameof(MissionMarker)}] Success change state: {markerState}");
      
      if (_meshRenderer == null)
      {
         Debug.LogError($"[{gameObject.name} - {nameof(MissionMarker)}] MeshRenderer not assigned");
         return;
      }
      
      this.markerState = markerState;
      
      _meshRenderer.material = markerState switch
      {
         MissionMarkerState.Passive => markerPassiveMaterial,
         MissionMarkerState.Active => markerActiveMaterial,
         _ => markerPassiveMaterial
      };
   }

   public void OnIntrect()
   {
      
      InputManager.Instance.SwitchActionMap(targetMap);
      Debug.Log($"[{gameObject.name} - {nameof(MissionMarker)}] OnIntrect");
   }
}
