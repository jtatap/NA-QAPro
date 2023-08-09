public class NF_LiveChatTranscriptTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
	public override void afterUpdate(Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
        NF_LiveChatTranscriptTriggerHelper.handleAfterUpdate((Map<Id,LiveChatTranscript>) newMap);
    }
}