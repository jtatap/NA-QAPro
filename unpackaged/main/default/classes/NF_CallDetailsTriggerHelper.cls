public class NF_CallDetailsTriggerHelper{
    public static void handleAfterInsert(List<CallDetail__c> newCallDetails){
        Log.push('CallDetailsTriggerHandler->entered clearCallDetailsOnCase method');
        List<Id> caseIds = new List<Id>();
        for (CallDetail__c callDetail : newCallDetails){
            caseIds.add(callDetail.case__c);//capture parent case id's
        }
        Log.push('Parent case ids found ' + caseIds);
        List<Case> parentCases = [select id, CallDirection__c, CallDurationInSeconds__c, CallEndTime__c, CallStartTime__c, Comments__c, SkillName__c, NumberDialed__c, Channel__c
                                  from Case
                                  where id in:caseIds];

        for (Case parentCase : parentCases){
             //clear call details
            parentCase.CallDirection__c = null;
            parentCase.CallDurationInSeconds__c = null;
            parentCase.CallEndTime__c = null;
            parentCase.CallStartTime__c = null;
            parentCase.Comments__c = null;
            parentCase.SkillName__c = null;
            parentCase.NumberDialed__c = null;
        }
        //update parent cases after call details cleared
        Logger.logDebug();
        update parentCases;
    }

}