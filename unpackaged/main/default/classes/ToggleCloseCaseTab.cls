/**
 * Created by bryananderson on 11/13/19.
 */
public with sharing class ToggleCloseCaseTab{
    @AuraEnabled
    public static Boolean getDisableStatus(String caseId){
        Case c = [SELECT Id, Status
                  FROM Case
                  WHERE Id = :caseId];
        if (c.Status == 'Open'){
            return true;
        } else{
            return false;
        }
    }

    @AuraEnabled
    public static String doCaseRouting(String caseId){
        List<Case> cases = [SELECT Id, Origin, Status, Personal_Queue_Id__c, Originating_Queue_Id__c, OwnerId, CaseNumber
                            FROM Case
                            WHERE Id = :caseId];
        if (cases.size() > 0){
            Case c = cases[0];
            if (c.Status == 'Open' && c.OwnerId == UserInfo.getUserId()){
                if (c.Personal_Queue_Id__c != null){
                    c.OwnerId = c.Personal_Queue_Id__c;
                } else if (c.Originating_Queue_Id__c != null && c.Origin != 'Chat'){
                    Log.push('Setting originating queue from ToggleCloseCaseTab');
                    c.OwnerId = c.Originating_Queue_Id__c;
                }
            }
            update c;
            Logger.logDebug();
            return 'Case Owner Id: ' + c.OwnerId + ' - Case Id: ' + c.Id + ' - Case Number: ' + c.CaseNumber + ' - Case Status: ' + c.Status;
        } else{
            return null;
        }
    }

}