public  class NF_AgentWorkTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }

    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        NF_AgentWorkTriggerHelper.handleAfterUpdate((Map<Id,AgentWork>) newMap, (Map<Id,AgentWork>) oldMap);
    }
}