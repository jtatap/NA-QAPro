public with sharing class NF_ReasonCodeController {
   @AuraEnabled(cacheable=true)
        public static Case getCase(String recordId) {
            return [
                SELECT NFCaseScenario__c,
                Reason_Sub_detail__c,
                Reason_Code_Product_Category__c,
                Reason_Code_Product_Sub_Categories_Widge__c,
                Reason_Code_Manufacturers__c,
                Sku_Style_Number__c,
                ZdPVHStoreNumber__c,
                ZdPVHDistrictNumber__c,
                ZdPVHDateofServiceIssue__c,
                ZdPVHUpdateAccountInfoReason__c
                FROM Case
                WHERE Id =: recordId
                LIMIT 1
            ];
        }
    }