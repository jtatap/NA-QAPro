public  class NF_CallDetailsTriggerHandler extends TriggerHandler{
    public static boolean RUN_ONCE = true;
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
    public override void afterInsert(Map<Id,sObject> newMap){
        List<CallDetail__c> callNewList = new List<CallDetail__c>();
        callNewList.addAll((List<CallDetail__c>)newMap.values());
        NF_CallDetailsTriggerHelper.handleAfterInsert(callNewList);
    }
}