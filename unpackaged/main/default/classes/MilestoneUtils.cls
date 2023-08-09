/*
 Class for Case Milestone To autoComplete the Milestone .
 */
public class MilestoneUtils{
    public static void completeMilestone(List<Id> caseIds, Map<Id, String> mapCaseIdWithMilestoneName, DateTime complDate){
        Log.push('completeMilestone');
        List<CaseMilestone> cmsToUpdate = [select Id, cm.completionDate, cm.MilestoneType.Name, cm.caseId
                                           from CaseMilestone cm
                                           where caseId in:caseIds and completionDate = null
                                           limit 1];
        Log.push('cmsToUpdate>>>' + cmsToUpdate);
        if (cmsToUpdate.size() > 0){
            for (CaseMilestone cm : cmsToUpdate){
                if (cm.MilestoneType.Name == mapCaseIdWithMilestoneName.get(cm.caseId))
                    cm.completionDate = complDate;
            }
            update cmsToUpdate;
        }
        Logger.logDebug();
    }

}