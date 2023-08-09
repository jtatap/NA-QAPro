/**
* @description       : test class for searchAllContactsController
* @author            :Hemadri Ravilla
* @last modified on  : 06-10-2021
* @last modified by  : Hemadri Ravilla
**/
@isTest
public class searchAllContactsControllerTest {
    private static testmethod void fetchContactTest()
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
        Test.startTest();
        List<Contact> conList = searchAllContactsController.fetchContact(con.lastName);
        Test.stopTest();
        System.assert(conList.size() == 1);
    }
}