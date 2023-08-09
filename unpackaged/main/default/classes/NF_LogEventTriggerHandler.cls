public class NF_LogEventTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }
	public override void afterInsert(Map<Id,sObject> newMap){
        List<Log_Event__e> newList = new List<Log_Event__e>();
        newList.addAll((List<Log_Event__e>) newMap.values());
        NF_LogEventTriggerHelper.handleAfterInsert(newList);
    }
}