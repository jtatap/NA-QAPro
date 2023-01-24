/*
* @author       : n/a
* @date         : 04/11/2021
* @description  : Case Trigger
*===========================================================
* Ver    Date          Author           Modification
*===========================================================
* 1.0    ---            n/a             Initial Version
* 2.0   08/05/2021      Luis Rocha      Removed add errors and replaced them with validation rules. 
*/
trigger CaseTrigger on Case (before insert, before update,before delete,after update, after insert, after delete, after undelete) {
    TriggerFactory.createAndExecuteHandler(CaseTriggerHandler.class);
    if (utilityClass.triggerEnabled( String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')))) {
        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
            if(PrivacyCaseTriggerHandler.isFirstRun){
                PrivacyCaseTriggerHandler.isFirstRun = False;
                PrivacyCaseTriggerHandler.sendEmailsIfNecessary();
            }
        }
         if((Trigger.isAfter && Trigger.isUpdate)){
        /*set<id>setConId=new set<id>();
        for (case cas : trigger.new) {
            if(cas.CSRMailUpdateonContact__c==true){
                setConId.add(cas.contactId);
            }
        }
        if(setConId.size()>0){
            List<contact> lstcontact=[select id,Email_Updated_by_CSR__c from contact where id in :setConId];
            for(contact objCon:lstcontact){
                objCon.Email_Updated_by_CSR__c=true;
                }
            update lstcontact;
        }*/
    }
    }
}