public class NF_ZdTicketCommentsTriggerHandler extends TriggerHandler {
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
    public override void beforeInsert(List<sObject> newList){
       	NF_ZdTicketCommentsTriggerHelper.handleBeforeInsert((List<ZdTicketComment__c>) newList);
    }
}