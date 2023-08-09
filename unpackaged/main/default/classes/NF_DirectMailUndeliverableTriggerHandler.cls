public with sharing class NF_DirectMailUndeliverableTriggerHandler extends TriggerHandler {
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
    public override void afterInsert(Map<Id,sObject> newMap){
        List<DirectMailUndeliverablesStaging__c> newList = new List<DirectMailUndeliverablesStaging__c>();
        newList.addAll((List<DirectMailUndeliverablesStaging__c>)newMap.values());
        NF_DirectMailUndeliverableTriggerHelper.handleAfterInsert(newList);
    }
}