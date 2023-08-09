public  class NF_IREStagingTableTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
    public override void afterInsert(Map<Id,sObject> newMap){
        List<IRE_StagingTable__c> newList = new List<IRE_StagingTable__c>();
        newList.addAll((List<IRE_StagingTable__c>) newMap.values());
        NF_IREStagingTableTriggerHelper.handleAfterInsert(newList);
    }
}