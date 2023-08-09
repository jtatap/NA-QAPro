@isTest
public class TestCaseCreatorController {
    
    @isTest
    public static void testCreateSupportCase(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Contact contact = new Contact();
        contact.FirstName = 'testFirst';
        contact.LastName = 'testLast';
        contact.Phone = '8884324322';
        contact.Email= 'test@gmail.com';
        contact.AccountId = acc.id;
        contact.Brand_Id__c='1';
		insert contact;
        GenericRecords__c gr = new GenericRecords__c();
        gr.recordId__c = contact.Id;
        gr.Name ='privacyContact';
        insert gr;
        ApexPages.StandardController sdc = new ApexPages.StandardController(contact);
        CaseCreatorController caseCreatorController = new CaseCreatorController(sdc);
        CaseCreatorController.createSupportCase();//create new case for this contact id
        Case createdCase = [select id from case where ContactId = :contact.id];
        System.assert(createdCase != null);
    }
    
    /*@isTest
    public static void testCreatePrivacyCase(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Contact contact = new Contact();
        contact.FirstName = 'testFirst';
        contact.LastName = 'testLast';
        contact.Phone = '8884324322';
        contact.Email= 'test@gmail.com';
        contact.AccountId = acc.id;
		insert contact;
        ApexPages.StandardController sdc = new ApexPages.StandardController(contact);
        PrivacyCaseCreatorController caseCreatorController = new PrivacyCaseCreatorController(sdc);
        caseCreatorController.createPrivacyCase();//create new case for this contact id
        Case createdCase = [select id from case where ContactId = :contact.id];
        System.assert(createdCase != null);
    }*/

}