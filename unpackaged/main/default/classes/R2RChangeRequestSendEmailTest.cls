@isTest
private class R2RChangeRequestSendEmailTest {
    
    @testSetup
    static void R2RChangeRequestTestData(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'TestFirst';
        con.LastName = 'TestLast';
        con.Email = UserInfo.getUserEmail();
        con.AccountId = acc.Id;
        insert con;
        GenericRecords__c genericRecords = new GenericRecords__c();
        genericRecords.Name = 'privacyContact';
        genericRecords.recordId__c = con.Id;
        insert genericRecords; 
        Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        String brandName='2';
        String Country='US';
        List<Case> caseList = TestDataFactory.createCases(1);
        caseList[0].origin='Web';
        caseList[0].Country_of_Residence__c='Canada';
        caseList[0].State_of_Residence__c=null;
        caseList[0].Type='Unsubscribe';
		caseList[0].SuppliedEmail='mrfoobar@example.com';       
        caseList[0].SuppliedPhone='9988998899';
        caseList[0].Brand__c='2';  
        caseList[0].recordTypeId = recordTypeIdPrivacyRequest;
        caseList[0].R2R_Email_UserConfirmation__c = 'Started';
        insert caseList;
      
    }

    @isTest
    static void R2RChangeRequestTest(){
        Contact contactObj = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        List<R2RChangeRequestSendEmail.flowInputs> finpList = new List<R2RChangeRequestSendEmail.flowInputs>();
        R2RChangeRequestSendEmail.flowInputs finp = new R2RChangeRequestSendEmail.flowInputs();
        finp.contactId = contactObj.Id;
        finp.caseId = caseObj.Id;
        finp.brandName= '2';
        finpList.add(finp);
        Test.startTest();
        R2RChangeRequestSendEmail.mailChangeRequest(finpList);
        Test.stopTest();
    }
    
}