using UnityEngine;

[CreateAssetMenu(fileName = "CharacterDataSO", menuName = "Character Data/CharacterDataSO")]
public class CharacterDataSO : ScriptableObject
{
    public string characterName;
    public Sprite characterIcon;
    public Character characterPrefab;
}
