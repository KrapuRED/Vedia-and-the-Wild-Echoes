using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

[Serializable]
public class DialoguePrefabMapping
{
    public string key;
    public GameObject prefab;
}

public class DialogueCsvImporterWindow : EditorWindow
{
    [SerializeField] private TextAsset _csv;
    [SerializeField] private DefaultAsset _outputFolder;
    [SerializeField] private List<DialoguePrefabMapping> _prefabMappings = new List<DialoguePrefabMapping>();
    private string tableName;

    [MenuItem("Tools/Dialogue/CSV Importer")]
    public static void Open()
    {
        GetWindow<DialogueCsvImporterWindow>("Dialogue CSV Importer");
    }

    private void OnGUI()
    {
        EditorGUILayout.Space(8);
        _csv = (TextAsset)EditorGUILayout.ObjectField("CSV", _csv, typeof(TextAsset), false);
        _outputFolder = (DefaultAsset)EditorGUILayout.ObjectField("Output Folder", _outputFolder, typeof(DefaultAsset), false);
        tableName = EditorGUILayout.TextField("Table Name", tableName);
        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("Prefab Mappings", EditorStyles.boldLabel);

        int removeIndex = -1;
        for (int i = 0; i < _prefabMappings.Count; i++)
        {
            EditorGUILayout.BeginHorizontal();
            _prefabMappings[i].key = EditorGUILayout.TextField(_prefabMappings[i].key, GUILayout.MinWidth(120));
            _prefabMappings[i].prefab = (GameObject)EditorGUILayout.ObjectField(_prefabMappings[i].prefab, typeof(GameObject), false);
            if (GUILayout.Button("X", GUILayout.Width(24)))
                removeIndex = i;
            EditorGUILayout.EndHorizontal();
        }

        if (removeIndex >= 0 && removeIndex < _prefabMappings.Count)
            _prefabMappings.RemoveAt(removeIndex);

        if (GUILayout.Button("Add Mapping"))
            _prefabMappings.Add(new DialoguePrefabMapping());

        EditorGUILayout.Space(14);

        GUI.enabled = _csv != null && _outputFolder != null;
        if (GUILayout.Button("Import CSV -> DialogueDatabase Assets", GUILayout.Height(32)))
            Import();
        GUI.enabled = true;
    }

    private void Import()
    {
        string folderPath = AssetDatabase.GetAssetPath(_outputFolder);
        if (string.IsNullOrEmpty(folderPath) || !AssetDatabase.IsValidFolder(folderPath))
        {
            Debug.LogError("Output folder is invalid.");
            return;
        }

        Dictionary<string, GameObject> prefabLookup = BuildPrefabLookup();
        List<List<string>> rows = ParseCsv(_csv.text);

        Dictionary<string, DialogueDatabase> dbByName = new Dictionary<string, DialogueDatabase>(StringComparer.OrdinalIgnoreCase);
        List<PendingChoiceLink> pendingChoiceLinks = new List<PendingChoiceLink>();

        int rowIndex = 0;
        while (rowIndex < rows.Count)
        {
            string firstColumn = GetCell(rows, rowIndex, 1);
            if (IsDialogueNameRow(firstColumn))
            {
                string dialogueName = firstColumn.Trim();
                DialogueDatabase database = GetOrCreateDatabase(folderPath, dialogueName);

                if (database.lines == null)
                    database.lines = new List<DialogueLine>();

                if (database.choices == null)
                    database.choices = new List<DialogueChoice>();

                database.lines.Clear();
                database.choices.Clear();

                dbByName[dialogueName] = database;

                rowIndex++;
                ImportDialogueBlock(rows, ref rowIndex, database, prefabLookup, pendingChoiceLinks);

                EditorUtility.SetDirty(database);
                continue;
            }

            rowIndex++;
        }

        ResolveChoiceLinks(folderPath, dbByName, pendingChoiceLinks);

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Dialogue CSV import complete.");
    }

    private void ImportDialogueBlock(List<List<string>> rows, ref int rowIndex, DialogueDatabase database, Dictionary<string, GameObject> prefabLookup, List<PendingChoiceLink> pendingChoiceLinks)
    {
        while (rowIndex < rows.Count)
        {
            string firstColumn = GetCell(rows, rowIndex, 1);

            if (IsDialogueNameRow(firstColumn))
                return;

            if (IsTokenRow(firstColumn, "Lines"))
            {
                rowIndex++;
                rowIndex++;
                ImportLines(rows, ref rowIndex, database, prefabLookup);
                continue;
            }

            if (IsTokenRow(firstColumn, "Choices"))
            {
                rowIndex++;
                rowIndex++;
                ImportChoices(rows, ref rowIndex, database, pendingChoiceLinks);
                continue;
            }

            rowIndex++;
        }
    }

    private void ImportLines(List<List<string>> rows, ref int rowIndex, DialogueDatabase database, Dictionary<string, GameObject> prefabLookup)
    {
        while (rowIndex < rows.Count)
        {
            string firstColumn = GetCell(rows, rowIndex, 1);

            if (IsDialogueNameRow(firstColumn) || IsTokenRow(firstColumn, "Choices") || IsTokenRow(firstColumn, "Lines"))
                return;

            string speakerName = GetCell(rows, rowIndex, 1);
            string text = GetCell(rows, rowIndex, 2);

            bool isEmptyRow = string.IsNullOrWhiteSpace(speakerName) && string.IsNullOrWhiteSpace(text);
            if (isEmptyRow)
            {
                rowIndex++;
                continue;
            }

            DialogueLine line = new DialogueLine();
            line.speakerName = speakerName ?? "";
            line.text = text ?? "";
            line.characterPrefab = ResolvePrefab(prefabLookup, GetCell(rows, rowIndex, 3));
            line.expression = GetCell(rows, rowIndex, 4) ?? "";
            line.side = ParseSide(GetCell(rows, rowIndex, 5));
            line.musicMode = ParseMusicMode(GetCell(rows, rowIndex, 6));
            line.musicIndex = ParseIntSafe(GetCell(rows, rowIndex, 7), 0);
            line.visualEffect = ParseVfx(GetCell(rows, rowIndex, 8));

            database.lines.Add(line);
            rowIndex++;
        }
    }

    private void ImportChoices(List<List<string>> rows, ref int rowIndex, DialogueDatabase database, List<PendingChoiceLink> pendingChoiceLinks)
    {
        while (rowIndex < rows.Count)
        {
            string firstColumn = GetCell(rows, rowIndex, 1);

            if (IsDialogueNameRow(firstColumn) || IsTokenRow(firstColumn, "Choices") || IsTokenRow(firstColumn, "Lines"))
                return;

            string choiceText = GetCell(rows, rowIndex, 1);
            string nextDialogueName = GetCell(rows, rowIndex, 2);

            bool isEmptyRow = string.IsNullOrWhiteSpace(choiceText) && string.IsNullOrWhiteSpace(nextDialogueName);
            if (isEmptyRow)
            {
                rowIndex++;
                continue;
            }

            DialogueChoice choice = new DialogueChoice();
            choice.choiceText = choiceText ?? "";
            choice.nextDialogue = null;
            choice.affectsTime = ParseBoolSafe(GetCell(rows, rowIndex, 3));
            choice.dayLimit = ParseIntSafe(GetCell(rows, rowIndex, 4), 0);

            database.choices.Add(choice);

            if (!string.IsNullOrWhiteSpace(nextDialogueName))
            {
                pendingChoiceLinks.Add(new PendingChoiceLink
                {
                    choice = choice,
                    nextDialogueName = nextDialogueName.Trim()
                });
            }

            rowIndex++;
        }
    }

    private void ResolveChoiceLinks(string folderPath, Dictionary<string, DialogueDatabase> dbByName, List<PendingChoiceLink> pendingChoiceLinks)
    {
        for (int i = 0; i < pendingChoiceLinks.Count; i++)
        {
            PendingChoiceLink link = pendingChoiceLinks[i];
            if (link.choice == null || string.IsNullOrWhiteSpace(link.nextDialogueName))
                continue;

            if (dbByName.TryGetValue(link.nextDialogueName, out DialogueDatabase existingLoadedDatabase))
            {
                link.choice.nextDialogue = existingLoadedDatabase;
                continue;
            }

            string assetPath = Path.Combine(folderPath, link.nextDialogueName + ".asset").Replace("\\", "/");
            DialogueDatabase existingAssetDatabase = AssetDatabase.LoadAssetAtPath<DialogueDatabase>(assetPath);
            if (existingAssetDatabase != null)
            {
                dbByName[link.nextDialogueName] = existingAssetDatabase;
                link.choice.nextDialogue = existingAssetDatabase;
                continue;
            }

            Debug.LogWarning("Next Dialogue '" + link.nextDialogueName + "' not found for choice '" + link.choice.choiceText + "'.");
        }
    }

    private DialogueDatabase GetOrCreateDatabase(string folderPath, string dialogueName)
    {
        string assetPath = Path.Combine(folderPath, dialogueName + ".asset").Replace("\\", "/");
        DialogueDatabase existingDatabase = AssetDatabase.LoadAssetAtPath<DialogueDatabase>(assetPath);
        if (existingDatabase != null)
            return existingDatabase;

        DialogueDatabase newDatabase = ScriptableObject.CreateInstance<DialogueDatabase>();
        AssetDatabase.CreateAsset(newDatabase, assetPath);
        return newDatabase;
    }

    private Dictionary<string, GameObject> BuildPrefabLookup()
    {
        Dictionary<string, GameObject> lookup = new Dictionary<string, GameObject>(StringComparer.OrdinalIgnoreCase);

        for (int i = 0; i < _prefabMappings.Count; i++)
        {
            DialoguePrefabMapping mapping = _prefabMappings[i];
            if (mapping == null)
                continue;

            if (string.IsNullOrWhiteSpace(mapping.key) || mapping.prefab == null)
                continue;

            string cleanKey = mapping.key.Trim();
            lookup[cleanKey] = mapping.prefab;
        }

        return lookup;
    }

    private GameObject ResolvePrefab(Dictionary<string, GameObject> prefabLookup, string prefabKey)
    {
        if (string.IsNullOrWhiteSpace(prefabKey))
            return null;

        string cleanKey = prefabKey.Trim();
        if (prefabLookup.TryGetValue(cleanKey, out GameObject prefab))
            return prefab;

        return null;
    }

    private bool IsDialogueNameRow(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return false;

        string trimmed = value.Trim();
        if (trimmed.StartsWith(tableName, StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed.Substring(tableName.Length);
        bool hasDigit = false;
        for (int i = 0; i < trimmed.Length; i++)
        {
            char c = trimmed[i];

            if (char.IsDigit(c))
            {
                hasDigit = true;
                continue;
            }

            if (c == '.')
                continue;

            return false;
        }

        return hasDigit;
    }

    private bool IsTokenRow(string value, string token)
    {
        if (string.IsNullOrWhiteSpace(value))
            return false;

        return string.Equals(value.Trim(), token, StringComparison.OrdinalIgnoreCase);
    }

    private DialogueSide ParseSide(string rawValue)
    {
        string normalized = NormalizeEnumToken(rawValue);

        if (string.Equals(normalized, "right", StringComparison.OrdinalIgnoreCase))
            return DialogueSide.Right;

        return DialogueSide.Left;
    }

    private DialogueMusicMode ParseMusicMode(string rawValue)
    {
        string normalized = NormalizeEnumToken(rawValue);

        if (string.Equals(normalized, "changemusic", StringComparison.OrdinalIgnoreCase))
            return DialogueMusicMode.ChangeMusic;

        if (string.Equals(normalized, "stopmusic", StringComparison.OrdinalIgnoreCase))
            return DialogueMusicMode.StopMusic;

        return DialogueMusicMode.KeepCurrent;
    }

    private DialogueVFX ParseVfx(string rawValue)
    {
        string normalized = NormalizeEnumToken(rawValue);

        if (string.IsNullOrWhiteSpace(normalized))
            return DialogueVFX.None;

        if (string.Equals(normalized, "screenshake", StringComparison.OrdinalIgnoreCase))
            return DialogueVFX.Shake;

        return DialogueVFX.None;
    }

    private string NormalizeEnumToken(string rawValue)
    {
        if (string.IsNullOrWhiteSpace(rawValue))
            return "";

        StringBuilder builder = new StringBuilder();
        string trimmed = rawValue.Trim();

        for (int i = 0; i < trimmed.Length; i++)
        {
            char character = trimmed[i];
            if (char.IsLetterOrDigit(character))
                builder.Append(character);
        }

        return builder.ToString();
    }

    private int ParseIntSafe(string rawValue, int fallbackValue)
    {
        if (string.IsNullOrWhiteSpace(rawValue))
            return fallbackValue;

        if (int.TryParse(rawValue.Trim(), out int parsedValue))
            return parsedValue;

        return fallbackValue;
    }

    private bool ParseBoolSafe(string rawValue)
    {
        if (string.IsNullOrWhiteSpace(rawValue))
            return false;

        string normalized = rawValue.Trim().ToLowerInvariant();
        return normalized == "true" || normalized == "1" || normalized == "yes" || normalized == "y" || normalized == "t";
    }

    private string GetCell(List<List<string>> rows, int rowIndex, int columnIndex)
    {
        if (rowIndex < 0 || rowIndex >= rows.Count)
            return null;

        List<string> row = rows[rowIndex];
        if (row == null)
            return null;

        if (columnIndex < 0 || columnIndex >= row.Count)
            return null;

        return row[columnIndex];
    }

    private List<List<string>> ParseCsv(string csvText)
    {
        List<List<string>> rows = new List<List<string>>();
        List<string> currentRow = new List<string>();
        StringBuilder currentCell = new StringBuilder();

        bool isInsideQuotes = false;
        int index = 0;

        while (index < csvText.Length)
        {
            char character = csvText[index];

            if (character == '"')
            {
                if (isInsideQuotes && index + 1 < csvText.Length && csvText[index + 1] == '"')
                {
                    currentCell.Append('"');
                    index += 2;
                    continue;
                }

                isInsideQuotes = !isInsideQuotes;
                index++;
                continue;
            }

            if (!isInsideQuotes && character == ',')
            {
                currentRow.Add(currentCell.ToString());
                currentCell.Length = 0;
                index++;
                continue;
            }

            if (!isInsideQuotes && (character == '\n' || character == '\r'))
            {
                if (character == '\r' && index + 1 < csvText.Length && csvText[index + 1] == '\n')
                    index++;

                currentRow.Add(currentCell.ToString());
                currentCell.Length = 0;

                rows.Add(currentRow);
                currentRow = new List<string>();

                index++;
                continue;
            }

            currentCell.Append(character);
            index++;
        }

        currentRow.Add(currentCell.ToString());
        rows.Add(currentRow);

        return rows;
    }

    private class PendingChoiceLink
    {
        public DialogueChoice choice;
        public string nextDialogueName;
    }
}