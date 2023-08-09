public  class NF_EmailMessageTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    //Checks to see if the trigger has been disabled either by custom metadata or by running code
    public override Boolean isDisabled(){
        return disableTrigger;
    }

    public override void afterInsert(Map<Id,sObject> newMap){
        List<EmailMessage> newList = new List<EmailMessage>();
        newList.addAll((List<EmailMessage>) newMap.values());
        NF_EmailMessageTriggerHelper nfhelper = new NF_EmailMessageTriggerHelper();
        nfhelper.handleAfterInsert(newList);
    }

    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        List<EmailMessage> newList = new List<EmailMessage>();
        newList.addAll((List<EmailMessage>) newMap.values());
        NF_EmailMessageTriggerHelper nfhelper = new NF_EmailMessageTriggerHelper();
        nfhelper.handleAfterUpdate(newList);
    }
}