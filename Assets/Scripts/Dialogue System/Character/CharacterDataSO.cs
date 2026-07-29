using UnityEngine;

[CreateAssetMenu(fileName = "CharacterDataSO", menuName = "Character Data/CharacterDataSO")]
public class CharacterDataSO : ScriptableObject
{
    public string characterName;
    public Character characterPrefab;
}
