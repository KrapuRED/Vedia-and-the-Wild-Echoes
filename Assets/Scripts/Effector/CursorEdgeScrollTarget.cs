using UnityEngine;
using UnityEngine.InputSystem;

public class CursorEdgeScrollTarget : MonoBehaviour
{
   [Header("References")]
    [SerializeField] private Camera cam;

    [Header("Edge Scroll")]
    [Tooltip("How much of each screen edge triggers scrolling.")]
    [Range(0.05f, 0.4f)]
    [SerializeField] private float edgeSize = 0.18f;
    [Tooltip("Maximum look-ahead distance on the X axis.")]
    [SerializeField] private float maxYawAngle = 15f;
    [Tooltip("Maximum look-ahead distance on the Y axis.")]
    [SerializeField] private float maxPitchAngle = 10f;

    [Header("Smoothing")]
    [Tooltip("Lower = snappier, Higher = smoother")]
    [SerializeField] private float smoothTime = 0.08f;
    
    private float velocityX;
    private float velocityY;
    
    private float velocityYaw;
    private float velocityPitch;
    private Vector3 originRotation;

    private void Awake()
    {
        if (cam == null)
            cam = Camera.main;
        
        originRotation = cam.transform.rotation.eulerAngles;
    }

    private void LateUpdate()
    {
        Vector2 mouse = Mouse.current.position.ReadValue();
        float viewportX = mouse.x / Screen.width;
        float viewportY = mouse.y / Screen.height;
        
        float desiredYaw = CalculateAxisOffset(viewportX, maxYawAngle);
        
        float desiredPitch = -CalculateAxisOffset(viewportY, maxPitchAngle);

        float targetYaw = originRotation.y + desiredYaw;
        float targetPitch = originRotation.x + desiredPitch;

        Vector3 currentRot = cam.transform.eulerAngles;
        
        float smoothYaw = Mathf.SmoothDampAngle(currentRot.y, targetYaw, ref velocityYaw, smoothTime);
        float smoothPitch = Mathf.SmoothDampAngle(currentRot.x, targetPitch, ref velocityPitch, smoothTime);

        cam.transform.rotation = Quaternion.Euler(smoothPitch, smoothYaw, originRotation.z);
    }

    private float CalculateAxisOffset(float viewportValue, float maxOffset)
    {
        if (viewportValue > 1f - edgeSize)
        {
            float t = Mathf.InverseLerp(1f - edgeSize, 1f, viewportValue);
            return t * maxOffset;
        }
        else if (viewportValue < edgeSize)
        {
            float t = Mathf.InverseLerp(edgeSize, 0f, viewportValue);
            return -t * maxOffset;
        }
        return 0f;
    }
}
