/**
* @author Magnet360
*
* @date 2019
*
* @description Test Class for AccountTriggerHandler
* @see AccountTriggerHandler
*/
@isTest
private class AccountTriggerTest {

    @isTest static void TestDeleteAccount() {
        // Test data setup
        Account acc = new Account();
        acc.Name = 'generic Account' + Math.random();
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='1';
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = con.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = acc.Id
        );
        insert genRecAcct;

        Account acct = new Account(
                Name='Test Account ' + Math.random()
        );
        insert acct;
        Contact cont = new Contact(
                LastName='contact ' + Math.random(),
                AccountId=acct.Id,
                RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId(),
            	Brand_Id__c='1'
        );
        insert cont;
        Opportunity o = new Opportunity(
                AccountId=acct.Id,
                Name='Opportunity ' + Math.random(),
                StageName='IsWon',
                CloseDate=Date.today()
        );
        insert o;
        Case c = new Case(
                ContactId=cont.Id,
                AccountId=acct.Id,
                Origin='Chat',
                Brand__c='2',
                Status='Open',
                RecordTypeId=Constants.supportCaseRecordTypeId
        );
        insert c;
        Contract ct = new Contract(
                CustomerSignedId=cont.Id,
                AccountId=acct.Id
        );
        insert ct;

        // Perform test
        Test.startTest();
        Database.DeleteResult result = Database.delete(acct, false);
        Test.stopTest();

        System.assert(result.isSuccess());
    }
}