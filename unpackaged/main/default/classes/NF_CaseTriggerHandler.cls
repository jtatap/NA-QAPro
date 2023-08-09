public class NF_CaseTriggerHandler extends TriggerHandler{
    public static Boolean disableTrigger = false;
    public override Boolean isDisabled(){
        return disableTrigger;
    }
    public override void beforeInsert(List<sObject> newList){
        NF_CaseTriggerHelper nf = new NF_CaseTriggerHelper();
        nf.handleBeforeInsert((List<Case>)newList);
    }

    public override void afterInsert(Map<Id, sObject> newMap){
        NF_CaseTriggerHelper nf = new NF_CaseTriggerHelper();
        nf.handleAfterInsert((Map<Id, Case>)newMap);
        /*if (utilityClass.triggerEnabled(String.valueOf(this).substring(0, String.valueOf(this).indexOf(':')))){
            if (PrivacyCaseTriggerHandler.isFirstRun){
                PrivacyCaseTriggerHandler.isFirstRun = False;
                PrivacyCaseTriggerHandler.sendEmailsIfNecessary();
            }
        }*/
    }

    public override void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        NF_CaseTriggerHelper nf = new NF_CaseTriggerHelper();
        nf.handleBeforeUpdate((Map<Id, Case>)newMap, (Map<Id, Case>)oldMap);
    }

    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        NF_CaseTriggerHelper nf = new NF_CaseTriggerHelper();
        nf.handleAfterUpdate((Map<Id, Case>)newMap, (Map<Id, Case>)oldMap);
        /*if (utilityClass.triggerEnabled(String.valueOf(this).substring(0, String.valueOf(this).indexOf(':')))){
            if (PrivacyCaseTriggerHandler.isFirstRun){
                PrivacyCaseTriggerHandler.isFirstRun = False;
                PrivacyCaseTriggerHandler.sendEmailsIfNecessary();
            }
        }*/
    }

}