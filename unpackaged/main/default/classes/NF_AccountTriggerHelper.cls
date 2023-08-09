public class NF_AccountTriggerHelper{
    public static void handleBeforeDelete(Map<Id, Account> oldMap){
        String brandRecId = Constants.brandRecordTypeId;
        for(Account acc : oldMap.values()){
            if (acc.RecordTypeId == brandRecId) {
                if (!FeatureManagement.checkPermission(Constants.modifyBrandPermission)){
                    acc.addError(SYSTEM.LABEL.You_must_have_the_modify_Brand_Permission_enabled_to_edit_or_delete_brand_record);
                }
            }
        }
        GenericRecords__c genericAccountRecord = GenericRecords__c.getValues(Constants.AccountGenericRecordSettingName);
        Account genericAccount = [Select Id
                                  from Account
                                  where Id = :genericAccountRecord.recordId__c];

        List<SObject> recordsToDisassociate = new List<SObject>();
        Set<Id> accountIds = Trigger.oldMap.keySet();

        //Disassociate Cases
        for (Contact con : [Select Id, AccountId
                            from Contact
                            where AccountId in:accountIds]){
            con.AccountId = genericAccount.Id;
            recordsToDisassociate.add(con);
        }

        //Disassociate Cases
        for (Case c : [Select Id, AccountId
                       from Case
                       where AccountId in:accountIds]){
            c.AccountId = null;
            recordsToDisassociate.add(c);
        }

        //Reassociate Opportunities
        for (Opportunity o : [Select Id, AccountId
                              from Opportunity
                              where AccountId in:accountIds]){
            o.AccountId = null;
            recordsToDisassociate.add(o);
        }

        //Disassociate Contracts
        for (Contract ct : [Select Id, AccountId
                            from Contract
                            where AccountId in:accountIds]){
            ct.AccountId = genericAccount.Id;
            recordsToDisassociate.add(ct);
        }
        update recordsToDisassociate;
    }

    public static void handleAfterUpdate(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        List<String> updatedOWABrandNames = new List<String>();
        Map<String, String> updatedBrandOWAMap = new Map<String, String>();
        for (SObject so : Trigger.New ){
            Account acc = (Account) so;
            Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
            if (acc.RecordTypeId == Constants.brandRecordTypeId && acc.Brand_Privacy_OWA_Name__c != oldAcc.Brand_Privacy_OWA_Name__c){
                String brandPickVal;

                List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
                for (Schema.Picklistentry ple : fieldResult){
                    if (ple.getLabel() == acc.Name){
                        brandPickVal = ple.getValue();
                    }
                }
                if (String.isBlank(brandPickVal)){
                    Log.push('Brand account without brand picklist value on case' + acc.Name + acc);
                    Logger.logDebug();
                    continue;
                }
                updatedBrandOWAMap.put(brandPickVal, acc.Brand_Privacy_OWA_Name__c);
                updatedOWABrandNames.add(brandPickVal);
            }

        }
        if (updatedOWABrandNames.size() > 0){
            List<Case> relatedCases = [Select Id, Brand_Privacy_OWA_Name__c, Brand__c
                                       From Case
                                       Where Type = :Constants.privacyCaseType And Brand__c In:updatedOWABrandNames And Status Not In:Constants.privacyCaseCompletedStatuses];
            if (relatedCases.size() > 0){
                for (Case relatedCase : relatedCases){
                    relatedCase.Brand_Privacy_OWA_Name__c = updatedBrandOWAMap.get(relatedCase.Brand__c);
                }
                update relatedCases;
            }
        }
    }

    public static void handleBeforeUpdate(Map<Id,Account> oldMap, Map<Id,Account> newMap){
        String brandRecId = Constants.brandRecordTypeId;
        for (Account acc : newMap.values()){
            if (acc.RecordTypeId == brandRecId){
                if (!FeatureManagement.checkPermission(Constants.modifyBrandPermission)){
                    acc.addError(SYSTEM.LABEL.You_must_have_the_modify_Brand_Permission_enabled_to_edit_or_delete_brand_record);
                }
            }
        }
    }

}