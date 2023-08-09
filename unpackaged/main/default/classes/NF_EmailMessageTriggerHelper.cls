public without sharing class NF_EmailMessageTriggerHelper{
    DateTime completionDate = System.now();
    Map<Id, String> emIds = new Map<Id, String>();
    Map<Id, String> UpdateEmids = new Map<Id, String>();
    List<Id> updateCases = new List<Id>();
    List<Id> updateChildCases = new List<Id>();
    Map<Id, String> mapCaseIdWithMilestoneName = new Map<Id, String>();
    Map<Id, String> mapChildCaseIdWithMilestoneName = new Map<Id, String>();
    public void handleAfterInsert(List<EmailMessage> newList){
        System.debug('here');
        Log.push('### bulkAfter');
        // if (UserInfo.getUserType() == 'Standard'){//
        for (EmailMessage em : newList){
            Log.push('### em' + em);
            Log.push('### Incoming' + em.Incoming);
            Log.push('### em.Status' + em.Status);
            if (em.Incoming == false && em.ParentId != NULL && em.Status == '3')
                // NASSC-1315
                emIds.put(em.ParentId, em.ToAddress);
            if (em.Incoming && em.ParentId != NULL && em.Status == '3')
                //NASSC-1315
                UpdateEmids.put(em.ParentId, em.FromAddress);
                
            Log.push('### emIds' + emIds);
            Log.push('### updateEmids' + UpdateEmids);
            Logger.logDebug();

        }
        Log.push('### afterInsert');
        if (emIds.isEmpty() == false){
            Set<Id> emCaseIds = new Set<Id>();
            emCaseIds = emIds.keySet();

            List<Case> caseList = [Select c.Id, c.ContactId, c.OwnerId, c.Status, c.SuppliedEmail, c.EntitlementId, c.ContactEmail, c.SlaStartDate, c.SlaExitDate, (SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name
                                                                                                                                                                    FROM CaseMilestones)
                                   From Case  c
                                   where c.Id IN:emCaseIds AND c.EntitlementId != Null AND c.ParentId = NULL AND c.status != 'Closed' AND c.status != 'Resolved'];
            Log.push('### caseList' + caseList);
            if (caseList.size() > 0){
                for (Case caseObj : caseList){
                    if ((emIds.get(caseObj.Id) == caseObj.ContactEmail) && (caseObj.EntitlementId != null) && (caseObj.SlaStartDate <= completionDate) && (caseObj.SlaStartDate != null) && (caseObj.SlaExitDate == null))
                        updateCases.add(caseObj.Id);
                    Log.push('### CaseMilestones ' + caseObj.CaseMilestones.size());
                    if (caseObj.CaseMilestones.size() > 0)
                        mapCaseIdWithMilestoneName.put(caseObj.Id, caseObj.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }

        Log.push('#### UpdateEmids ' + UpdateEmids);
        //For Child case
        //if (UpdateEmids.isEmpty() == false) {
        if (!UpdateEmids.isEmpty()){
            Log.push('### For child case');
            Set<Id> emCaseIds1 = new Set<Id>();
            emCaseIds1 = UpdateEmids.keySet();
            Log.push('### emCaseIds1' + emCaseIds1);
            List<Case> childcaseList = [Select c.Id, c.ContactId, c.OwnerId, c.Status, c.SuppliedEmail, c.EntitlementId, c.ContactEmail, c.SlaStartDate, c.SlaExitDate, (SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name
                                                                                                                                                                         FROM CaseMilestones)
                                        From Case  c
                                        where c.Id IN:emCaseIds1 AND c.EntitlementId != Null AND c.ParentId != NULL AND c.status != 'Closed' AND c.status != 'Resolved'];
            Log.push('### childcaseList>>' + childcaseList.size());
            if (childcaseList.size() > 0){
                for (Case caseObj1 : childcaseList){
                    Log.push('### UpdateEmids.get(caseObj1.Id)' + UpdateEmids.get(caseObj1.Id));
                    Log.push('### caseObj1.ContactEmail' + caseObj1.ContactEmail);
                    if ((UpdateEmids.get(caseObj1.Id) == caseObj1.ContactEmail) && (caseObj1.EntitlementId != null)//(caseObj1.SlaStartDate <= completionDate)&&
                    //(caseObj1.SlaStartDate != null)
                    )
                        updateChildCases.add(caseObj1.Id);
                    Log.push('insidechildcaseList');
                    if (caseObj1.CaseMilestones.size() > 0)
                        mapChildCaseIdWithMilestoneName.put(caseObj1.Id, caseObj1.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }

        
        Log.push('### updateCases' + updateCases);
        Log.push('### updateChildCases' + updateChildCases);
        Logger.logDebug();
        andFinally();
    }

    public  void handleAfterUpdate(List<EmailMessage> newList){
        Log.push('### bulkAfter');
        // if (UserInfo.getUserType() == 'Standard'){//
        for (EmailMessage em : newList){
            Log.push('### em' + em);
            Log.push('### Incoming' + em.Incoming);
            Log.push('### em.Status' + em.Status);
            if (em.Incoming == false && em.ParentId != NULL && em.Status == '3')
                // NASSC-1315
                emIds.put(em.ParentId, em.ToAddress);
            if (em.Incoming && em.ParentId != NULL && em.Status == '3')
                //NASSC-1315
                UpdateEmids.put(em.ParentId, em.FromAddress);
            Log.push('### emIds' + emIds);
            Log.push('### updateEmids' + UpdateEmids);
            Logger.logDebug();
        }
        Log.push('### afterUpdate');
        //NASSC-1315
        if (emIds.isEmpty() == false){
            Set<Id> emCaseIds = new Set<Id>();
            emCaseIds = emIds.keySet();

            List<Case> caseList = [Select c.Id, c.ContactId, c.OwnerId, c.Status, c.SuppliedEmail, c.EntitlementId, c.ContactEmail, c.SlaStartDate, c.SlaExitDate, (SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name
                                                                                                                                                                    FROM CaseMilestones)
                                   From Case  c
                                   where c.Id IN:emCaseIds AND c.EntitlementId != Null AND c.ParentId = NULL AND c.status != 'Closed' AND c.status != 'Resolved'];
            Log.push('### caseList' + caseList);
            if (caseList.size() > 0){
                for (Case caseObj : caseList){
                    if ((emIds.get(caseObj.Id) == caseObj.ContactEmail) && (caseObj.EntitlementId != null) && (caseObj.SlaStartDate <= completionDate) && (caseObj.SlaStartDate != null) && (caseObj.SlaExitDate == null))
                        updateCases.add(caseObj.Id);
                    Log.push('### CaseMilestones ' + caseObj.CaseMilestones.size());
                    if (caseObj.CaseMilestones.size() > 0)
                        mapCaseIdWithMilestoneName.put(caseObj.Id, caseObj.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }

        Log.push('#### UpdateEmids ' + UpdateEmids);
        //For Child case
        //if (UpdateEmids.isEmpty() == false) {
        if (!UpdateEmids.isEmpty()){
            Log.push('### For child case');
            Set<Id> emCaseIds1 = new Set<Id>();
            emCaseIds1 = UpdateEmids.keySet();
            Log.push('### emCaseIds1' + emCaseIds1);
            List<Case> childcaseList = [Select c.Id, c.ContactId, c.OwnerId, c.Status, c.SuppliedEmail, c.EntitlementId, c.ContactEmail, c.SlaStartDate, c.SlaExitDate, (SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name
                                                                                                                                                                         FROM CaseMilestones)
                                        From Case  c
                                        where c.Id IN:emCaseIds1 AND c.EntitlementId != Null AND c.ParentId != NULL AND c.status != 'Closed' AND c.status != 'Resolved'];
            Log.push('### childcaseList>>' + childcaseList.size());
            if (childcaseList.size() > 0){
                for (Case caseObj1 : childcaseList){
                    Log.push('### UpdateEmids.get(caseObj1.Id)' + UpdateEmids.get(caseObj1.Id));
                    Log.push('### caseObj1.ContactEmail' + caseObj1.ContactEmail);
                    if ((UpdateEmids.get(caseObj1.Id) == caseObj1.ContactEmail) && (caseObj1.EntitlementId != null)//(caseObj1.SlaStartDate <= completionDate)&&
                    //(caseObj1.SlaStartDate != null)
                    )
                        updateChildCases.add(caseObj1.Id);
                    Log.push('insidechildcaseList');
                    if (caseObj1.CaseMilestones.size() > 0)
                        mapChildCaseIdWithMilestoneName.put(caseObj1.Id, caseObj1.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }
        Log.push('### updateCases' + updateCases);
        Log.push('### updateChildCases' + updateChildCases);
        Logger.logDebug();
        andFinally();
    }

    public void andFinally(){
        Log.push('### finaly');
        if(updateCases.isEmpty() == false)
            milestoneUtils.completeMilestone(updateCases,mapCaseIdWithMilestoneName, completionDate);
        
        Log.push('pdateChildCases'+updateChildCases.size());
        if(updateChildCases.size()>0)
        {
            Log.push('### updateChildCases>>'+updateChildCases);
            Log.push('### mapChildCaseIdWithMilestoneName>>'+mapChildCaseIdWithMilestoneName);
            Log.push('### completionDate>>'+completionDate);
            milestoneUtils.completeMilestone(updateChildCases,mapChildCaseIdWithMilestoneName,completionDate);
            Log.push('### inside child method');
        }
        Logger.logDebug();
    }

}