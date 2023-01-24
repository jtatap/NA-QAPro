@isTest
private class R2RProcessResponseAPITest {
    
    @testSetup
    static void R2RProcessResponseTestData(){
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
        caseList[0].origin='Email';
        caseList[0].Country_of_Residence__c='United States of America (USA)';
        caseList[0].State_of_Residence__c='MD';
        caseList[0].Type='Unsubscribe';
        caseList[0].SuppliedEmail='mrfoobar@example.com';       
        caseList[0].SuppliedPhone='9988998899';
        caseList[0].suppliedName='test';
        caseList[0].Brand__c='2';  
        caseList[0].recordTypeId = recordTypeIdPrivacyRequest;
        caseList[0].Rectified_JSON_Data__c = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test99","newUnit":"1","newCountry":"USA","newState":"maryland","newZipCode":"20988","newPhone":"7676767671","newGender":"Male","newMonth":"12","newDate":"1"}';
        caseList[0].R2R_Email_UserConfirmation__c = 'Started';
        caseList[0].accountId = acc.Id;
        insert caseList;
    }
    
    @isTest
    static void R2RProcessOpenResponseTest(){
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 64,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 32,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Case caseObj = [SELECT Id,VerificationHash__c FROM Case LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/apexrest/services/public/v1/r2rProcesss/';
        req.addParameter('in_response','Open');
        req.addParameter('in_verificationCode',caseObj.VerificationHash__c);
        req.addParameter('in_caseid',caseObj.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        R2RProcessResponseAPI.restGet();
        Test.stopTest();
    }
    
    @isTest
    static void R2RProcessResolvedResponseTest(){
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 64,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 32,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Case caseObj = [SELECT Id,VerificationHash__c FROM Case LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/apexrest/services/public/v1/r2rProcesss/';
        req.addParameter('in_response','Resolved');
        req.addParameter('in_verificationCode',caseObj.VerificationHash__c);
        req.addParameter('in_caseid',caseObj.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        R2RProcessResponseAPI.restGet();
        Test.stopTest();
    }
    
}