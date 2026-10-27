using UnityEditor;
using UnityEngine;

public class AnchorTools
{
    // Shortcut: Ctrl + ] (Windows) or Cmd + ] (Mac)
    [MenuItem("Tools/Anchors to Corners %g")] 
    static void AnchorsToCorners()
    {
        // Check if we actually have a selection
        if (Selection.activeTransform == null) return;

        foreach (Transform transform in Selection.transforms)
        {
            RectTransform t = transform as RectTransform;
            if (t == null) continue;

            RectTransform pt = t.parent as RectTransform;
            if (pt == null) continue;

            // Record for Undo (Ctrl+Z)
            Undo.RecordObject(t, "Anchors to Corners");

            // Calculate the new anchor percentages based on current pixel offsets
            Vector2 newMin = new Vector2(t.anchorMin.x + t.offsetMin.x / pt.rect.width,
                                         t.anchorMin.y + t.offsetMin.y / pt.rect.height);
            Vector2 newMax = new Vector2(t.anchorMax.x + t.offsetMax.x / pt.rect.width,
                                         t.anchorMax.y + t.offsetMax.y / pt.rect.height);

            t.anchorMin = newMin;
            t.anchorMax = newMax;
            
            // Set offsets to zero so the image fills the anchor area perfectly
            t.offsetMin = Vector2.zero;
            t.offsetMax = Vector2.zero;
        }
    }
    }