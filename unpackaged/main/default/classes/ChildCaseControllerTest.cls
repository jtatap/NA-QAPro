/**
 * @description       : test class for ChildCaseController
 * @author            :Hemadri Ravilla
 * @last modified on  : 06-10-2021
 * @last modified by  : Hemadri Ravilla
**/
@isTest
public class ChildCaseControllerTest {
    private static testmethod void getCasesTest()
    {
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
        Case c = new Case(
            ContactId=con.Id,
            AccountId=acc.Id,
            Origin='Chat',
            Brand__c='2',
            Status='Open',
            RecordTypeId=Constants.supportCaseRecordTypeId
        );
        insert c;
        test.startTest();
        ChildCaseController.getCases(c.Id);
        test.stopTest();
    }
    private static testmethod void saveCaseTest()
    {
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
        Case c = new Case(
            ContactId=con.Id,
            AccountId=acc.Id,
            Origin='Chat',
            Brand__c='2',
            Status='Open',
            RecordTypeId=Constants.supportCaseRecordTypeId
        );
        insert c;
        test.startTest();
        ChildCaseController.saveCase(c.Id,'','','',con.Id);
        test.stopTest();
    }
    
}