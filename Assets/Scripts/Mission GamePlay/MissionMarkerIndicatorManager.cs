using System;
using System.Collections.Generic;
using UnityEngine;

public class MissionMarkerIndicatorManager : MonoBehaviour
{
    public static MissionMarkerIndicatorManager Instance {get; private set; }
    
    [SerializeField] private Transform containerIndicator;
    [SerializeField] private RectTransform canvasRect;
    [SerializeField] private RectTransform indicatorPrefab;
    [SerializeField] private float edgePadding = 60f;
    
    private Camera _camera;
    private readonly Dictionary<MissionMarker, RectTransform> _indicators  = new();

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
        }
        
        _camera = Camera.main;
    }
    
    #region Event

    private void OnEnable()
    {
        GameEvents.OnMissionMarkerRegistered.AddListener(RegisterIndicator);
        GameEvents.OnMissionMarkerUnregistered.AddListener(UnregisterIndicator);
    }

    private void OnDisable() => OnRemoveListeners();

    private void OnDestroy() =>  OnRemoveListeners();

    private void OnRemoveListeners()
    {
        GameEvents.OnMissionMarkerRegistered.RemoveListener(RegisterIndicator);
        GameEvents.OnMissionMarkerUnregistered.RemoveListener(UnregisterIndicator);
    }
    
    #endregion

    private void RegisterIndicator(MissionMarker marker)
    {
        if (_indicators.ContainsKey(marker)) return;
        var indicator = Instantiate(indicatorPrefab, containerIndicator);
        _indicators.Add(marker, indicator);
    }

    private void UnregisterIndicator(MissionMarker marker)
    {
        if (!_indicators.TryGetValue(marker, out var indicator)) return;
        
        if (indicator != null)
            Destroy(indicator.gameObject);
        
        _indicators.Remove(marker);
    }

    private void LateUpdate()
    {
        if (_indicators.Count <= 0) return;
        
        float screenWidth = Screen.width;
        float screenHeight = Screen.height;
        
        Vector2 screenCenter = new Vector2(screenWidth , screenHeight) * 0.5f;
        Vector2 maxBounds = screenCenter - new Vector2(edgePadding , edgePadding);

        foreach (var kvp in _indicators)
        {
            MissionMarker marker = kvp.Key;
            RectTransform indicator = kvp.Value;
            
            if (marker.MissionMarkerState != MissionMarkerState.Active)
            {
                indicator.gameObject.SetActive(false);
                continue;
            }
            
            bool onScreen = ScreenIndicatorUtility.IsOnCamera(_camera, marker.transform.position, out Vector3 viewportPos);
            indicator.gameObject.SetActive(!onScreen);
            if (onScreen) continue;

            if (viewportPos.z < 0)
            {
                viewportPos.x = 1f -  viewportPos.x;
                viewportPos.y = 1f -  viewportPos.y;
            }
            
            Vector2 screenPos = new Vector2(viewportPos.x * Screen.width, viewportPos.y * Screen.height);
            Vector2 dir = (screenPos - screenCenter).normalized;
            float angle = Mathf.Atan2(dir.y, dir.x);
            
            float scaleX = dir.x != 0 ? maxBounds.x / Mathf.Abs(dir.x) : float.MaxValue;
            float scaleY = dir.y != 0 ? maxBounds.y / Mathf.Abs(dir.y) : float.MaxValue;
            float scale = Mathf.Min(scaleX, scaleY);
            
            indicator.anchoredPosition = screenCenter + dir * scale - screenCenter; // relative to canvas center anchor
            indicator.rotation = Quaternion.Euler(0, 0, angle * Mathf.Rad2Deg - 90f); // -90 if arrow art points "up"
        }
    }
}
