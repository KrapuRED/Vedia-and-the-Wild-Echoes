using UnityEditor;
using UnityEngine;

public class FindPackageAssetGUID
{
    [MenuItem("Tools/Find SpriteShape Icon GUID")]
    public static void PrintGUID()
    {
        string path = "Packages/com.unity.2d.spriteshape/Editor/Icons/SpriteShapeController@64.png";
        string guid = AssetDatabase.AssetPathToGUID(path);
        Debug.Log("GUID for SpriteShapeController@64.png: " + guid);
    }
}
