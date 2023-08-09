/**
 * Created by bryananderson on 11/14/19.
 */

@IsTest
private class ToggleCloseCaseTabTest {
    @TestSetup
    static void makeData(){
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c='9';
        insert genCon;
    }

    @isTest
    static void createCaseTestPos()
    {
        Account genAcc = [select id from Account LIMIT 1];
        Contact genCon = [SELECT Id FROM Contact WHERE Brand_Id__c = '9'];
        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = genAcc.Id
        );
        insert genRecAcct;
        
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        //Setting the API Name for Calvin Klein Brand
        List<Case> getCaseList = TestDataFactory.createCases(1);
        getCaseList[0].origin='Web';
        getCaseList[0].SuppliedEmail='abc@gmail.com';
        getCaseList[0].SuppliedPhone='9988998899';
        getCaseList[0].Is_Existing_Purchase__c='Yes';
        getCaseList[0].Type='Product';
        getCaseList[0].Description='Test Cases';
        getCaseList[0].Status='Open';
		getCaseList[0].Brand__c='1';
        Test.startTest();
        insert getCaseList;
        Boolean isDisabled = ToggleCloseCaseTab.getDisableStatus(getCaseList[0].Id);
        String ownerId = ToggleCloseCaseTab.doCaseRouting(getCaseList[0].Id);
        Test.stopTest();

        system.assertEquals(isDisabled, true);
    }

    @isTest
    static void createCaseTestNeg()
    {
        Account genAcc = [select id from Account LIMIT 1];
        Contact genCon = [SELECT Id FROM Contact WHERE Brand_Id__c = '9'];
        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = genAcc.Id
        );
        insert genRecAcct;
        
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        //Setting the API Name for Calvin Klein Brand
        List<Case> getCaseList = TestDataFactory.createCases(1);
        getCaseList[0].origin='Web';
        getCaseList[0].SuppliedEmail='abc@gmail.com';
        getCaseList[0].SuppliedPhone='9988998899';
        getCaseList[0].Is_Existing_Purchase__c='Yes';
        getCaseList[0].Type='Product';
        getCaseList[0].Description='Test Cases';
        getCaseList[0].Status='New';
		getCaseList[0].Brand__c='1';
        Test.startTest();
        insert getCaseList;
        Boolean isDisabled = ToggleCloseCaseTab.getDisableStatus(getCaseList[0].Id);
        String ownerId = ToggleCloseCaseTab.doCaseRouting(getCaseList[0].Id);
        Test.stopTest();

        system.assertEquals(isDisabled, false);
    }
}