using TMPro;
using UnityEngine;

public class ForestEvaluationImpactUI : MonoBehaviour
{
   [SerializeField] private ForestMonitorUI biodiversityIndicator;
   [SerializeField] private ForestMonitorUI threatIndicator;
   [SerializeField] private ForestMonitorUI forestSustainIndicator;
   [SerializeField] private TMP_Text evaluationImpactDescription;
   
   public void ForestEvaluation(float biodiversity, float threat, float forestSustain ,float minValue, float maxValue,
      ForestHealthEvaluation forestEvaluation)
   {
      Debug.Log($"[{gameObject.name} - ForestEvaluationImpactUI] ForestEvaluation get called!");
      
      biodiversityIndicator.InitForestMonitorUI(minValue, maxValue,biodiversity);
      threatIndicator.InitForestMonitorUI(minValue,maxValue,threat);
      forestSustainIndicator.InitForestMonitorUI(minValue,maxValue,forestSustain);
      
      Debug.Log($"Game is done this the eval : {forestEvaluation.ForestEvaluationDescription}");
      evaluationImpactDescription.text = forestEvaluation.ForestEvaluationDescription;
   }
}
