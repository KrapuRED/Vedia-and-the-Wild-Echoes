#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(MinMaxRangeAttribute))]
public class MinMaxRangeDrawer : PropertyDrawer
{
   public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
   {
      MinMaxRangeAttribute range = (MinMaxRangeAttribute)attribute;
      
      SerializedProperty minProp = property.FindPropertyRelative("min");
      SerializedProperty maxProp = property.FindPropertyRelative("max");

      if (minProp == null || maxProp == null)
      {
         EditorGUI.LabelField(position, label.text, "Use [MinMaxRange] with RangedFloat.");
         return;
      }
      
      EditorGUI.BeginProperty(position, label, property);
      
      position = EditorGUI.PrefixLabel(position, GUIUtility.GetControlID(FocusType.Passive), label);
      
      float minValue = minProp.floatValue;
      float maxValue = maxProp.floatValue;
      
      float floatFieldWidth = 45f;
      float spacing = 5f;
      
      Rect minFieldRect = new Rect(position.x, position.y, floatFieldWidth, position.height);
      Rect sliderRect = new Rect(position.x + floatFieldWidth + spacing, position.y, position.width - (floatFieldWidth * 2) - (spacing * 2), position.height);
      Rect maxFieldRect = new Rect(position.x + position.width - floatFieldWidth, position.y, floatFieldWidth, position.height);

      // Input Min angka
      minValue = EditorGUI.FloatField(minFieldRect, minValue);
        
      // MinMaxSlider (Double Slider)
      EditorGUI.MinMaxSlider(sliderRect, ref minValue, ref maxValue, range.Min, range.Max);

      // Input Max angka
      maxValue = EditorGUI.FloatField(maxFieldRect, maxValue);

      // Clamp agar min tidak melewati max
      minValue = Mathf.Clamp(minValue, range.Min, maxValue);
      maxValue = Mathf.Clamp(maxValue, minValue, range.Max);

      minProp.floatValue = minValue;
      maxProp.floatValue = maxValue;

      EditorGUI.EndProperty();
   }
}
#endif
