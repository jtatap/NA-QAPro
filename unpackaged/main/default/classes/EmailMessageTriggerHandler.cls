/*
*
NASSC-1315
*/

public without sharing class EmailMessageTriggerHandler implements ITrigger {
    DateTime completionDate= System.now();
    Map<Id, String> emIds = new Map<Id, String>();
    Map<Id, String> UpdateEmids  = new Map<Id, String>();
    List<Id> updateCases = new List<Id>();
    List<Id> updateChildCases = new List<Id>();
    Map<Id, String> mapCaseIdWithMilestoneName = new Map<Id, String>();
    Map<Id, String> mapChildCaseIdWithMilestoneName = new Map<Id, String>();
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void  bulkBefore(){
        
    }
    
    /**
* bulkAfter
*
* This method is called prior to execution of an AFTER trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkAfter(){   
        
        if(trigger.isinsert || trigger.isupdate){ // NASSC-1315
            
            System.debug('### bulkAfter');
            // if (UserInfo.getUserType() == 'Standard'){//
            for (sObject newRec : Trigger.new){
                EmailMessage em = (EmailMessage)newRec;
                system.debug('### em' +em);
                system.debug('### Incoming' +em.Incoming);
                system.debug('### em.Status' +em.Status);
                if(em.Incoming==false && em.ParentId != NULL && em.Status == '3') // NASSC-1315
                    emIds.put(em.ParentId, em.ToAddress);
                
                if(em.Incoming && em.ParentId != NULL && em.Status == '3') //NASSC-1315
                    UpdateEmids.put(em.ParentId,em.FromAddress);
                
                system.debug('### emIds' +emIds);
                system.debug('### updateEmids' +UpdateEmids);
                
            }
        }
    }
    
    
    /**
* beforeInsert
*
* This method is called iteratively for each record to be inserted during a BEFORE
* trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
*/
    public void  beforeInsert(SObject obj){
        
    }
    
    /**
* beforeUpdate
*
* This method is called iteratively for each record to be updated during a BEFORE
* trigger.
*/
    public void  beforeUpdate(SObject oldSo, SObject so){
        
    }
    
    /**
* beforeDelete
*
* This method is called iteratively for each record to be deleted during a BEFORE
* trigger.
*/
    
    public void  beforeDelete(SObject so){
        
    }
    
    /**
* afterInsert
*
* This method is called iteratively for each record inserted during an AFTER
* trigger. Always put field validation in the 'After' methods in case another trigger
* has modified any values. The record is 'read only' by this point.
*/
    public void  afterInsert(SObject so){
        System.debug('### afterInsert');
        if (emIds.isEmpty() == false){
            Set <Id> emCaseIds = new Set<Id>();
            emCaseIds = emIds.keySet();
            
            List<Case> caseList = [Select c.Id, c.ContactId, c.OwnerId, c.Status,c.SuppliedEmail, c.EntitlementId, c.ContactEmail, c.SlaStartDate, c.SlaExitDate,
                                   ( SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name FROM CaseMilestones )
                                   From Case c where c.Id IN :emCaseIds AND c.EntitlementId != Null AND c.ParentId = NULL AND c.status !='Closed' AND c.status !='Resolved'];
             System.debug('### caseList' + caseList);
            if (caseList.size()>0){
                for (Case caseObj:caseList) {
                    if ((emIds.get(caseObj.Id)==caseObj.ContactEmail)&& (caseObj.EntitlementId != null)&& (caseObj.SlaStartDate <= completionDate)&&
                        (caseObj.SlaStartDate != null)&& (caseObj.SlaExitDate == null)) 
                        updateCases.add(caseObj.Id);
                    
                   
                     System.debug('### CaseMilestones ' + caseObj.CaseMilestones.size());
                    if(caseObj.CaseMilestones.size() > 0) mapCaseIdWithMilestoneName.put(caseObj.Id, caseObj.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }
        
        system.debug('#### UpdateEmids ' + UpdateEmids);
        //For Child case
        //if (UpdateEmids.isEmpty() == false) {
        if (!UpdateEmids.isEmpty()) {
            system.debug('### For child case');
            Set <Id> emCaseIds1 = new Set<Id>();
            emCaseIds1 = UpdateEmids.keySet();
            System.debug('### emCaseIds1'+emCaseIds1);
            List<Case> childcaseList = [Select c.Id, c.ContactId, c.OwnerId, c.Status,c.SuppliedEmail, c.EntitlementId,c.ContactEmail, c.SlaStartDate, c.SlaExitDate,
                                        ( SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name FROM CaseMilestones )
                                        From Case c where c.Id IN :emCaseIds1 AND c.EntitlementId != Null AND c.ParentId  != NULL AND c.status !='Closed' AND c.status !='Resolved'];
            System.debug('### childcaseList>>'+childcaseList.size());
            if (childcaseList.size()>0){
                for (Case caseObj1:childcaseList) {
                    System.debug('### UpdateEmids.get(caseObj1.Id)'+UpdateEmids.get(caseObj1.Id));
                    System.debug('### caseObj1.ContactEmail'+caseObj1.ContactEmail);
                    if ((UpdateEmids.get(caseObj1.Id)==caseObj1.ContactEmail)&&
                        (caseObj1.EntitlementId != null)
                        //(caseObj1.SlaStartDate <= completionDate)&&
                        //(caseObj1.SlaStartDate != null)
                       )
                        updateChildCases.add(caseObj1.Id);
                    System.debug('insidechildcaseList');
                    if(caseObj1.CaseMilestones.size() > 0) mapChildCaseIdWithMilestoneName.put(caseObj1.Id, caseObj1.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }
        System.debug('### updateCases'+updateCases);
        System.debug('### updateChildCases'+updateChildCases);
    }
    
    
    
    /**
* afterUpdate : For child case atocompletion of milestone on first reply .
*
* This method is called iteratively for each record updated during an AFTER
* trigger.
*/
    public void  afterUpdate(SObject oldSo, SObject so){
        System.debug('### afterUpdate'); 
        //NASSC-1315
        if (emIds.isEmpty() == false){
            Set <Id> emCaseIds = new Set<Id>();
            emCaseIds = emIds.keySet();
            
            List<Case> caseList = [Select c.Id, c.ContactId,
                                   c.OwnerId, c.Status,c.SuppliedEmail,
                                   c.EntitlementId, c.ContactEmail,
                                   c.SlaStartDate, c.SlaExitDate,
                                   ( SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name FROM CaseMilestones )
                                   From Case c where c.Id IN :emCaseIds AND c.EntitlementId != Null AND c.ParentId = NULL AND c.status !='Closed' AND c.status !='Resolved'];
            System.debug('### caseList' + caseList);
            if (caseList.size()>0){
                for (Case caseObj:caseList) {
                    if ((emIds.get(caseObj.Id)==caseObj.ContactEmail)&&
                        (caseObj.EntitlementId != null)&&
                        (caseObj.SlaStartDate <= completionDate)&&
                        (caseObj.SlaStartDate != null)&&
                        (caseObj.SlaExitDate == null))
                        updateCases.add(caseObj.Id);
                    
                   
                     System.debug('### CaseMilestones ' + caseObj.CaseMilestones.size());
                    if(caseObj.CaseMilestones.size() > 0) mapCaseIdWithMilestoneName.put(caseObj.Id, caseObj.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }
        
        system.debug('#### UpdateEmids ' + UpdateEmids);
        //For Child case
        //if (UpdateEmids.isEmpty() == false) {
        if (!UpdateEmids.isEmpty()) {
            system.debug('### For child case');
            Set <Id> emCaseIds1 = new Set<Id>();
            emCaseIds1 = UpdateEmids.keySet();
            System.debug('### emCaseIds1'+emCaseIds1);
            List<Case> childcaseList = [Select c.Id, c.ContactId,
                                        c.OwnerId, c.Status,c.SuppliedEmail,
                                        c.EntitlementId,c.ContactEmail,
                                        c.SlaStartDate, c.SlaExitDate,
                                        ( SELECT TargetDate, CaseId, MilestoneTypeId, MilestoneType.Name FROM CaseMilestones )
                                        From Case c where c.Id IN :emCaseIds1 AND c.EntitlementId != Null AND c.ParentId  != NULL AND c.status !='Closed' AND c.status !='Resolved'];
            System.debug('### childcaseList>>'+childcaseList.size());
            if (childcaseList.size()>0){
                for (Case caseObj1:childcaseList) {
                    System.debug('### UpdateEmids.get(caseObj1.Id)'+UpdateEmids.get(caseObj1.Id));
                    System.debug('### caseObj1.ContactEmail'+caseObj1.ContactEmail);
                    if ((UpdateEmids.get(caseObj1.Id)==caseObj1.ContactEmail)&&
                        (caseObj1.EntitlementId != null)
                        //(caseObj1.SlaStartDate <= completionDate)&&
                        //(caseObj1.SlaStartDate != null)
                       )
                        updateChildCases.add(caseObj1.Id);
                    System.debug('insidechildcaseList');
                    if(caseObj1.CaseMilestones.size() > 0) mapChildCaseIdWithMilestoneName.put(caseObj1.Id, caseObj1.CaseMilestones[0].MilestoneType.Name);
                }
            }
        }
        System.debug('### updateCases'+updateCases);
        System.debug('### updateChildCases'+updateChildCases);

    }
    
    
    
    /**
* afterDelete
*
* This method is called iteratively for each record deleted during an AFTER
* trigger.
*/
    public void  afterDelete(SObject so){
        
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this 
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        System.debug('### finaly');
        if(updateCases.isEmpty() == false)
            milestoneUtils.completeMilestone(updateCases,mapCaseIdWithMilestoneName, completionDate);
        
        System.debug('pdateChildCases'+updateChildCases.size());
        if(updateChildCases.size()>0)
        {
            System.debug('### updateChildCases>>'+updateChildCases);
            System.debug('### mapChildCaseIdWithMilestoneName>>'+mapChildCaseIdWithMilestoneName);
            System.debug('### completionDate>>'+completionDate);
            milestoneUtils.completeMilestone(updateChildCases,mapChildCaseIdWithMilestoneName,completionDate);
            system.debug('### inside child method');
        }
    }
}