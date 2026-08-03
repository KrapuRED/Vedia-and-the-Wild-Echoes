using UnityEngine;
using UnityEditor;

public class TreePainter : EditorWindow
{
    public GameObject treePrefab;
    public Transform parent;

    public float brushRadius = 5f;
    public int density = 5;

    public float minScale = 0.8f;
    public float maxScale = 1.3f;

    public bool randomYRotation = true;

    bool painting = false;

    [MenuItem("Tools/Tree Painter")]
    static void Open()
    {
        GetWindow<TreePainter>("Tree Painter");
    }

    void OnGUI()
    {
        treePrefab = (GameObject)EditorGUILayout.ObjectField(
            "Tree Prefab",
            treePrefab,
            typeof(GameObject),
            false);

        parent = (Transform)EditorGUILayout.ObjectField(
            "Parent",
            parent,
            typeof(Transform),
            true);

        brushRadius = EditorGUILayout.Slider("Brush Radius", brushRadius, 0.5f, 30);

        density = EditorGUILayout.IntSlider("Density", density, 1, 50);

        minScale = EditorGUILayout.FloatField("Min Scale", minScale);
        maxScale = EditorGUILayout.FloatField("Max Scale", maxScale);

        randomYRotation = EditorGUILayout.Toggle("Random Rotation", randomYRotation);

        GUILayout.Space(10);

        painting = GUILayout.Toggle(painting, "Enable Painting", "Button");

        GUILayout.Label("Hold SHIFT + Left Click in Scene View");
    }

    void OnEnable()
    {
        SceneView.duringSceneGui += DuringSceneGUI;
    }

    void OnDisable()
    {
        SceneView.duringSceneGui -= DuringSceneGUI;
    }

    void DuringSceneGUI(SceneView sceneView)
    {
        if (!painting || treePrefab == null)
            return;

        Event e = Event.current;

        Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);

        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            Handles.color = Color.green;
            Handles.DrawWireDisc(hit.point, hit.normal, brushRadius);

            if (e.shift &&
                e.type == EventType.MouseDown &&
                e.button == 0)
            {
                Paint(hit.point);

                e.Use();
            }

            sceneView.Repaint();
        }
    }

    void Paint(Vector3 center)
    {
        for (int i = 0; i < density; i++)
        {
            Vector2 circle = Random.insideUnitCircle * brushRadius;

            Vector3 start =
                center +
                new Vector3(circle.x, 100, circle.y);

            if (Physics.Raycast(start, Vector3.down, out RaycastHit hit, 500))
            {
                GameObject tree =
                    (GameObject)PrefabUtility.InstantiatePrefab(treePrefab);

                Undo.RegisterCreatedObjectUndo(tree, "Paint Tree");

                tree.transform.position = hit.point;

                tree.transform.rotation = Quaternion.FromToRotation(Vector3.up, hit.normal);
       
                tree.transform.rotation *= Quaternion.Euler(-90f, 0f, 0f);

                if (randomYRotation)
                {
                    Vector3 currentEuler = tree.transform.eulerAngles;

                    tree.transform.rotation = Quaternion.Euler(
                        currentEuler.x,
                        Random.Range(0f, 360f),
                        currentEuler.z
                    );
                }
                float scale =
                    Random.Range(minScale, maxScale);

                tree.transform.localScale =
                    Vector3.one * scale;

                if (parent != null)
                    tree.transform.SetParent(parent);
            }
        }
    }
}