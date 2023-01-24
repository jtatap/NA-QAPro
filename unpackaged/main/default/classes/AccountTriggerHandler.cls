/**
* @author Magnet360
* @date 2019
*
* @group Account
* @group-content ../../ApexDocContent/Account.htm
*
* @description Trigger Handler on Accounts.
*/
public without sharing class AccountTriggerHandler implements ITrigger {
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
        if(Trigger.isDelete) {
            GenericRecords__c genericAccountRecord = GenericRecords__c.getValues(Constants.AccountGenericRecordSettingName);
            Account genericAccount = [Select Id from Account where Id = :genericAccountRecord.recordId__c];

            List<SObject> recordsToDisassociate = new List<SObject>();
            Set<Id> accountIds = Trigger.oldMap.keySet();

            //Disassociate Cases
            for(Contact con :[Select Id, AccountId from Contact where AccountId in :accountIds]) {
                con.AccountId = genericAccount.Id;
                recordsToDisassociate.add(con);
            }

            //Disassociate Cases
            for(Case c :[Select Id, AccountId from Case where AccountId in :accountIds]) {
                c.AccountId = null;
                recordsToDisassociate.add(c);
            }

            //Reassociate Opportunities
            for(Opportunity o :[Select Id, AccountId from Opportunity where AccountId in :accountIds]) {
                o.AccountId = null;
                recordsToDisassociate.add(o);
            }

            //Disassociate Contracts
            for(Contract ct :[Select Id, AccountId from Contract where AccountId in :accountIds]) {
                ct.AccountId = genericAccount.Id;
                recordsToDisassociate.add(ct);
            }

            update recordsToDisassociate;
        }
    }
    
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
        if (Trigger.isUpdate) {
            List<String> updatedOWABrandNames = new List<String>();
            Map<String, String> updatedBrandOWAMap = new Map<String, String>();
            for (SObject so : Trigger.New) {
                Account acc = (Account)so;
                Account oldAcc = (Account)Trigger.oldMap.get(acc.Id);
                if (acc.RecordTypeId == Constants.brandRecordTypeId && acc.Brand_Privacy_OWA_Name__c != oldAcc.Brand_Privacy_OWA_Name__c) {
                    String brandPickVal;

                    List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
                    for (Schema.Picklistentry ple: fieldResult) {
                        if(ple.getLabel() == acc.Name) {
                            brandPickVal = ple.getValue();
                        }
                    }
                    if (String.isBlank(brandPickVal)) {
                        System.debug('Brand account without brand picklist value on case' + acc.Name + acc);
                        continue;
                    }
                    updatedBrandOWAMap.put(brandPickVal, acc.Brand_Privacy_OWA_Name__c);
                    updatedOWABrandNames.add(brandPickVal);
                }

            }
            if (updatedOWABrandNames.size() > 0) {
                List<Case> relatedCases = [Select Id, Brand_Privacy_OWA_Name__c, Brand__c From Case Where Type = :Constants.privacyCaseType And Brand__c In :updatedOWABrandNames And Status Not In :Constants.privacyCaseCompletedStatuses];
                if (relatedCases.size() > 0) {
                    for (Case relatedCase : relatedCases) {
                        relatedCase.Brand_Privacy_OWA_Name__c = updatedBrandOWAMap.get(relatedCase.Brand__c);
                    }
                    update relatedCases;
                }
            }

        }
        
    }
    
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject obj) {

        
    }
    
    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
        Account acc = (Account)so;
        if (acc.RecordTypeId == Constants.brandRecordTypeId) {
            if (!FeatureManagement.checkPermission(Constants.modifyBrandPermission)){
                acc.addError('You must have the modify Brand Permission enabled to edit or delete brand records. If you believe you need this permission, please contact your system administrator.');
            }
        }
        
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so) {
        Account acc = (Account)so;
        if (acc.RecordTypeId == Constants.brandRecordTypeId) {
            if (!FeatureManagement.checkPermission(Constants.modifyBrandPermission)){
                acc.addError('You must have the modify Brand Permission enabled to edit or delete brand records. If you believe you need this permission, please contact your system administrator.');
            }
        }
        
    }

    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so) {
        
    }

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {}

    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so) {

    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
        
    }
}