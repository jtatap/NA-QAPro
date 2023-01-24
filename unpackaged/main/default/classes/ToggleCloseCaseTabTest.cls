/**
 * Created by bryananderson on 11/14/19.
 */

@IsTest
private class ToggleCloseCaseTabTest {
    @isTest
    static void createCaseTestPos()
    {
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