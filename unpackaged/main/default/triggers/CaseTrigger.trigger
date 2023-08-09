/*
* @author 	    : n/a
* @date 	    : 04/11/2021
* @description 	: This class handles updating the Affirm lookup on accounts that have a matching ARI, so that when using the sharing set rule
* ShopifyToAffirmAccountAccess will kick and give access to the "child" accounts. 
*===========================================================
* Ver    Date          Author			Modification
*===========================================================
* 1.0    ---			n/a				Initial Version
* 2.0	08/05/2021		Luis Rocha		Removed add errors and replaced them with validation rules. 
*/
trigger CaseTrigger on Case (before insert, before update,before delete,after update, after insert, after delete, after undelete) {
    //TriggerFactory.createAndExecuteHandler(CaseTriggerHandler.class);
    TriggerDispatcher.run(new NF_CaseTriggerHandler());
    if (utilityClass.triggerEnabled( String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')))) {
        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
            if(PrivacyCaseTriggerHandler.isFirstRun){
                PrivacyCaseTriggerHandler.isFirstRun = False;
                PrivacyCaseTriggerHandler.sendEmailsIfNecessary();
            }
        }
    }
    
}