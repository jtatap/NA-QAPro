/*
 * @Author: Puru
 *
 * Purpose: Test class for 'Batch_SAPStoreCodeUpdate'
 *
 * JIRA NO       UPDATE DATE     UPDATED BY      UPDATE DESCRIPTION
 * -------       -----------     ----------      ------------------
 * NGCSI-1926    Sep-29-2021     Puru            New Class created
 */
@isTest
public class Batch_SAPStoreCodeUpdate_Test{
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestAccount');
        insert acc;

        List<Contact> lstConts = new List<Contact>();
        SAP_Store_Codes__mdt TestStoreCode = new SAP_Store_Codes__mdt(MasterLabel = 'T0123', New_StoreUniqueId__c = 'T123');
        //update TestStoreCode;
        for (integer i = 0; i <= 200; i++){
            Contact cont = new Contact(FirstName = 'fName_' + i, LastName = 'lName_' + i, Email = 'testemail_' + i + '@test.com', LoyaltyID__c = 'TH4005340161_' + i, Brand_Id__c = '1', HomeStore__c = 'T0123');
            lstConts.add(cont);
        }

        upsert lstConts;
    }

    static testMethod void testData(){
        List<Contact> lstConts = [Select Id, FirstName, LastName, Email, LoyaltyID__c, Brand_Id__c, HomeStore__c
                                   FROM Contact];
        Test.startTest();
        Batch_SAPStoreCodeUpdate cb = New Batch_SAPStoreCodeUpdate();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null, lstConts);
        cb.Finish(null);
        Test.stopTest();
    }

}