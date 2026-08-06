using System;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public enum ForestMonitorType
{
    Biodiversity,
    Threat
}

[Serializable]
public class ForestHealthEvaluation
{
    public string ForestEvaluationName;
    [MinMaxRange(0f, 100f)] 
    public RangedFloat EvaluationRange;
    public string ForestEvaluationDescription;
} 

public class ForestMonitorManager : MonoBehaviour
{
    public static ForestMonitorManager Instance {get; private set; }

    [SerializeField] private List<ForestHealthEvaluation> forestHealthEvaluations = new();
    
    [SerializeField] private ForestEvaluationImpactUI forestEvaluationImpactUI;
    
    [Header("Forest Monitor Indicator")]
    [SerializeField] private ForestMonitorUI biodiversityIndicator;
    [SerializeField] private ForestMonitorUI threatIndicator;
    [SerializeField] private ForestMonitorUI forestSustainabilityIndicator;

    [Header("Forest Monitor Indicator Configuration")] 
    [SerializeField] private float minIndicator;
    [SerializeField] private float maxIndicator;
    
    [Header("Forest Monitor Biodiversity Configuration")] 
    [SerializeField] private float currBiodiversityIndicator;
    [SerializeField] private float gainBiodiversityIndicator;
    [SerializeField] private float reduceBiodiversityIndicator;
    [SerializeField] private float startBiodiversityIndicator;
    
    [Header("Forest Monitor Threat Configuration")] 
    [SerializeField] private float currThreatIndicator;
    [SerializeField] private float gainThreatIndicator;
    [SerializeField] private float reduceBiodiversityIndicatorByThreat;
    [SerializeField] private float reduceThreatIndicator;
    [SerializeField] private float startThreatIndicator;
    
    [Header("Forest Monitor Forest Sustainability Configuration")] 
    [SerializeField] private float currForestSustainability;
    [SerializeField] private float startForestSustainability;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start() => InitializeIndicator();

    private void InitializeIndicator()
    {
        currBiodiversityIndicator = startBiodiversityIndicator;
        currThreatIndicator = startThreatIndicator;
        currForestSustainability = startForestSustainability;
        
        biodiversityIndicator.InitForestMonitorUI(minIndicator, maxIndicator, currBiodiversityIndicator);
        threatIndicator.InitForestMonitorUI(minIndicator, maxIndicator, currThreatIndicator);
        forestSustainabilityIndicator.InitForestMonitorUI(minIndicator, maxIndicator, currForestSustainability);

        UpdateForestSustainability();
    }
    
    private void UpdateForestSustainability()
    {
        float biodiversityFraction = currBiodiversityIndicator / maxIndicator;
        float threatEmptyFraction  = 1f - (currThreatIndicator / maxIndicator);
        
        biodiversityFraction = Mathf.Clamp01(biodiversityFraction);
        threatEmptyFraction  = Mathf.Clamp01(threatEmptyFraction);
        
        float sustainabilityFraction = (biodiversityFraction * 0.5f) + (threatEmptyFraction * 0.5f);
        currForestSustainability = sustainabilityFraction * maxIndicator;
        
        forestSustainabilityIndicator.UpdateForestMonitorUI(minIndicator, maxIndicator, currForestSustainability);
    }
    
    public void UpdateBiodiversityIndicator(bool isCorrect)
    {
        if (!isCorrect)
            return;
            
        currBiodiversityIndicator += gainBiodiversityIndicator;
        
        biodiversityIndicator.UpdateForestMonitorUI(minIndicator, maxIndicator, currBiodiversityIndicator);
        UpdateForestSustainability();
    }

    public void UpdateThreatIndicator(bool isCorrect)
    {
        if (isCorrect)
        {
            currThreatIndicator -= reduceThreatIndicator;
        }
        else
        {
            currBiodiversityIndicator -= reduceBiodiversityIndicatorByThreat;
            currThreatIndicator += gainThreatIndicator;
            biodiversityIndicator.UpdateForestMonitorUI(minIndicator, maxIndicator, currBiodiversityIndicator);
        }
        
        threatIndicator.UpdateForestMonitorUI(minIndicator, maxIndicator, currThreatIndicator);
        UpdateForestSustainability();
    }
    
    public void UpdateIndicator(ForestMonitorType forestMonitorType, bool isCorrect)
    {
        switch (forestMonitorType)
        {
            case ForestMonitorType.Biodiversity:
                UpdateBiodiversityIndicator(isCorrect);
                break;
            case ForestMonitorType.Threat:
                UpdateThreatIndicator(isCorrect);
                break;
            default:
                Debug.Log($"There no ForestMonitorType {forestMonitorType.ToString()}!");
                break;
        }
    }
    
    public void ReportForestMonitor()
    {
        var forestEval = forestHealthEvaluations.Find(eval => 
            currForestSustainability >= eval.EvaluationRange.min && 
            currForestSustainability <= eval.EvaluationRange.max);
        
        forestEvaluationImpactUI.ForestEvaluation(currBiodiversityIndicator, currThreatIndicator,currForestSustainability, minIndicator , maxIndicator, forestEval);
    }
}
