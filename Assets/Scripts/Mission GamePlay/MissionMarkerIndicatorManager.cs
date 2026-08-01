using System;
using System.Collections.Generic;
using UnityEngine;

public class MissionMarkerIndicatorManager : MonoBehaviour
{
    public static MissionMarkerIndicatorManager instance {get; private set; }
    
    [SerializeField] private RectTransform canvasRect;
    [SerializeField] private RectTransform indicatorPrefab;
    [SerializeField] private float edgePadding = 60f;
    
    private Camera _camera;
    private readonly Dictionary<MissionMarker, RectTransform> _indicators  = new();

    private void Awake() => _camera = Camera.main;
    
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
        GameEvents.OnMissionMarkerRegistered.AddListener(RegisterIndicator);
        GameEvents.OnMissionMarkerUnregistered.AddListener(UnregisterIndicator);
    }
    
    #endregion

    private void RegisterIndicator(MissionMarker marker)
    {
        if (_indicators.ContainsKey(marker)) return;
        var indicator = Instantiate(indicatorPrefab, canvasRect);
        _indicators.Add(marker, indicator);
    }

    private void UnregisterIndicator(MissionMarker marker)
    {
        if (!_indicators.TryGetValue(marker, out var indicator)) return;
        Destroy(indicator.gameObject);
        _indicators.Remove(marker);
    }

    private void LateUpdate()
    {
        Vector2 screenCenter = new Vector2(Screen.width , Screen.height) * 0.5f;
        Vector2 maxBounds = screenCenter - new Vector2(edgePadding , edgePadding);

        foreach (var kvp in _indicators)
        {
            MissionMarker marker = kvp.Key;
            RectTransform indicator = kvp.Value;
            
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
            float cos = Mathf.Cos(angle);
            float sin = Mathf.Sin(angle);
            float scaleX = cos != 0 ? maxBounds.x / Mathf.Abs(cos) : float.MaxValue;
            float scaleY = cos != 0 ? maxBounds.y / Mathf.Abs(sin) : float.MaxValue;
            float scale = Mathf.Min(scaleX, scaleY);
            
            indicator.anchoredPosition = screenCenter + dir * scale - screenCenter; // relative to canvas center anchor
            indicator.rotation = Quaternion.Euler(0, 0, angle * Mathf.Rad2Deg - 90f); // -90 if arrow art points "up"
        }
    }
}
