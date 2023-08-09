public class NF_BotSessionPopulateFieldsHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
	public override void afterInsert(Map<Id,sObject> newMap){
        NF_BotSessionPopulateFieldsHelper.handleAfterInsert((Map<Id,ebotdata__Bot_Session__c>) newMap);
    }
}