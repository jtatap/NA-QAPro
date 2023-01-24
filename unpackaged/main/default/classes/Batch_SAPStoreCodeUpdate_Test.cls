/*
* @Author: Puru
*
* Purpose: Test class for 'Batch_SAPStoreCodeUpdate'
*
* JIRA NO		UPDATE DATE		UPDATED BY		UPDATE DESCRIPTION
* -------		-----------		----------		------------------
* NGCSI-1926	Sep-29-2021	    Puru			New Class created
*/

@isTest
public class Batch_SAPStoreCodeUpdate_Test {
    static testMethod void testBatch() {
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
        List<Contact> lstConts = new List<Contact>();
        
        for (integer i=0; i<=199; i++) {
            Contact cont = new Contact(FirstName='fName_' + i, LastName='lName_' + i, Email='testemail_'+i+'@test.com', LoyaltyID__c='TH4005340161_'+i, Brand_Id__c='1', HomeStore__c='Test123');
            lstConts.add(cont);
        }
        
        insert lstConts;
        
        System.assertEquals(200, lstConts.size());
        
        Test.startTest();
        Batch_SAPStoreCodeUpdate obj = new Batch_SAPStoreCodeUpdate();
        Database.executeBatch(obj);
        Test.stopTest();        
    }
}