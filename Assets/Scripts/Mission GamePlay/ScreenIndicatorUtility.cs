using UnityEngine;

public static class ScreenIndicatorUtility
{
    public static bool IsOnCamera(Camera camera, Vector3 wordldPos, out Vector3 viewportPos)
    {
        viewportPos = camera.WorldToViewportPoint(wordldPos);
        return viewportPos.z > 0f &&
               viewportPos.x > 0f && viewportPos.x < 1f &&
               viewportPos.y > 0f && viewportPos.y < 1f;
    }
}
