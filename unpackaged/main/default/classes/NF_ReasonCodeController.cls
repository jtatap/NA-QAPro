/**
* @author 	     : NeuraFlash, LLC
* @date 	     : 08/20/21
* @description   : controller for nfReasonCode that retreives case values.
*===========================================================
* Ver    Date          Modification
*===========================================================
* 1.0    08/20/21    Initial Version.
*/

public with sharing class NF_ReasonCodeController {
   @AuraEnabled(cacheable=true)
        /**
         * @description getCase retreives case fields from the provided case Id
         * @param  recordId recordId the case Id to retreive
         * @return          return the case that matches the provided case
         */
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