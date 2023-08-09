public class NF_AccountTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }

    public override void beforeDelete(Map<Id, sObject> oldMap){
        NF_AccountTriggerHelper.handleBeforeDelete((Map<Id, Account>)oldMap);
    }

    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        NF_AccountTriggerHelper.handleAfterUpdate((Map<Id, Account>)oldMap, (Map<Id, Account>)newMap);
    }

    public override void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        NF_AccountTriggerHelper.handleBeforeUpdate((Map<Id, Account>)newMap, (Map<Id, Account>)oldMap);
    }

}