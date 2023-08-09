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

    /*@isTest static void TestDeleteAccount() {
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
    }*/
    
    @testSetup
    public static void testData() {
        List<Account> accLst = TestDataFactory.createAccount(1);
        accLst[0].Name = 'Generic Account';
        insert accLst;
        List<Contact> conLst = TestDataFactory.createContact(1);
        conLst[0].AccountId = accLst[0].Id;
        conLst[0].email = 'test@test.com';
        conLst[0].lastName = 'generic contact ' + Math.random();
        conLst[0].Brand_Id__c = '1';
        insert conLst;
        
        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = conLst[0].Id
        );
        insert genRec;
        
        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = accLst[0].Id
        );
        insert genRecAcct;
        
        List<Account> accLstNew = TestDataFactory.createAccount(1);
        accLstNew[0].Brand_Privacy_OWA_Name__c = 'Test';
        accLstNew[0].RecordTypeId = Constants.brandRecordTypeId;
        insert accLstNew;
        List<Contact> conLstNew = TestDataFactory.createContact(1);
        conLstNew[0].AccountId = accLstNew[0].Id;
        conLstNew[0].lastName = 'generic contact ' + Math.random();
        conLstNew[0].Brand_Id__c = '1';
        conLstNew[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert conLstNew;
        
        Opportunity o = new Opportunity(
                AccountId=accLstNew[0].Id,
                Name='Opportunity ' + Math.random(),
                StageName='IsWon',
                CloseDate=Date.today()
        );
        insert o;
        
        List<Case> cseLst = TestDataFactory.createCases(1);
        cseLst[0].ContactId = conLstNew[0].Id;
        cseLst[0].AccountId = accLstNew[0].Id;
        cseLst[0].RecordTypeId=Constants.supportCaseRecordTypeId;
        cseLst[0].Brand__c = '10';
        cseLst[0].Type = Constants.privacyCaseType; 
        insert cseLst;
        
        Contract ct = new Contract(
                CustomerSignedId=conLstNew[0].Id,
                AccountId=accLstNew[0].Id
        );
        insert ct;
        
        
    }
    
    @isTest
    public static void testDeleteAccount() {
        Account acc = [SELECT id FROM Account WHERE NAME LIKE '%Test Account%' LIMIT 1];
        Account genAcc = [SELECT id FROM Account WHERE NAME LIKE '%Generic Account%'];
        Test.startTest();
        Database.DeleteResult result = Database.delete(acc, false);
        Test.stopTest();
        
        Opportunity opp = [SELECT id,AccountId FROM Opportunity];
        Contract contract = [SELECT id,AccountId FROM Contract];
        
        System.assertEquals(true,opp.AccountId == null);
        System.assertEquals(true, contract.AccountId == genAcc.Id);
    }
    
    @isTest
    public static void testUpdateAccount() {
        Account acc = [SELECT id,RecordTypeId FROM Account WHERE NAME LIKE '%Test Account%' LIMIT 1];
        
        Account accUpd = new Account();
        accUpd.Id = acc.Id;
        accUpd.RecordTypeId = Constants.brandRecordTypeId;
        accUpd.Brand_Privacy_OWA_Name__c = 'Test New';
        accUpd.Name = 'Olga';
        update accUpd;
        
        Case cse = [SELECT id,AccountId,Brand_Privacy_OWA_Name__c FROM Case WHERE AccountId =: acc.Id];
        System.assertEquals(true,cse.Brand_Privacy_OWA_Name__c == 'Test New');
    }
}