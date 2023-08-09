/**
 * @class:       PersonalDataFormApexControllerTest
 * @JIRA:        NASSC-98 Privacy (CCPA) Forms
 * @description: Test Class for PersonalDataFormApexController class.
 */ 
 
@isTest
public class PersonalDataFormApexControllerTest 
{
	@isTest 
    static void getDependentMapTest() 
    {	
            String brandNames = '2';
        	String sourceCountry = 'US';
            Case caseObj = new Case();
        	PersonalDataFormApexController.getDependentMap(caseObj,'Country_of_Residence__c','State_of_Residence__c',brandNames,sourceCountry);
    }
    
    @isTest 
    static void createCaseTestWithUnsubscribe() 
    {	
        PrivacyCaseTests.makeData();
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                         'Complete',
                                         '[{"ResponseMessage":"NEW CUSTOMER","EmailAddress":"test@test.com"}]',
                                         null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        String brandName='2';
        String Country='US';
        
        
         contact con = new Contact();
        con.lastName = 'Test';
        con.Email = 'mrfoobar@example.com';
        con.Brand__c = '2';
        insert con;
        
        List<Case> getCaseList = TestDataFactory.createCases(1);
        getCaseList[0].origin='Web';
        getCaseList[0].Country_of_Residence__c='Canada';
        getCaseList[0].State_of_Residence__c=null;
        getCaseList[0].Type='Unsubscribe';
		getCaseList[0].SuppliedEmail='mrfoobar@example.com';       
        getCaseList[0].SuppliedPhone='9988998899';
        getCaseList[0].Brand__c='2';   
        
        PersonalDataFormApexController.createCase(getCaseList[0], 'test name' , brandName, Country);
       
    }
    
    @isTest 
    static void createCaseTestWithOther() 
    {	
        PrivacyCaseTests.makeData();

        Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        String brandName='2';
        String Country='US';
        
        contact con = new Contact();
        con.lastName = 'Test';
        con.Email = 'foo@example.com';
        con.Brand__c = '2';
        insert con;
        
        List<Case> getCaseList = TestDataFactory.createCases(1);
        getCaseList[0].origin='Email';
        getCaseList[0].Country_of_Residence__c='Canada';
        getCaseList[0].State_of_Residence__c=null;
        getCaseList[0].suppliedName = 'test';
        getCaseList[0].Type='Access My Data';
		getCaseList[0].SuppliedEmail='foo@example.com';       
        getCaseList[0].SuppliedPhone='9988998899';
        getCaseList[0].SuppliedPhone='9988998899';
        
        
        
        PersonalDataFormApexController.createCase(getCaseList[0], 'test name' , brandName,Country);
       
    }
    
    @isTest 
    static void createCaseForRectifiedDataTest() 
    {	
        PrivacyCaseTests.makeData();

        String brandName='2';
        
        String jsonData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17"}';
        String changedData = 'First Name: testsek Last Name: testbar= Address: test 234 Apartment/Suite/Unit: 111 City: germantown State: Maryland Country: United States of America Zip Code: 20874 Phone: 1234561234 Gender: Male Birthday (Month-Day): 5-17';
        PersonalDataFormApexController.createCaseForDataRectified(changedData, brandName,'foo@example.com' , true, jsonData);
       
    }
    
    
     @isTest 
    static void createCaseForRectifiedDataTest2() 
    {	
        PrivacyCaseTests.makeData();

        Contact con = new contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.email = 'foo@example.com';
        con.Brand__c = 'Calvin Klein';
        insert con;
        
        String brandName='2';
        
        String jsonData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17"}';
        String changedData = 'First Name: testsek Last Name: testbar= Address: test 234 Apartment/Suite/Unit: 111 City: germantown State: Maryland Country: United States of America Zip Code: 20874 Phone: 1234561234 Gender: Male Birthday (Month-Day): 5-17';
        PersonalDataFormApexController.createCaseForDataRectified(changedData, brandName,'foo@example.com' , true, jsonData);
       
    }
    
      @isTest 
    static void createCaseForRectifiedDataTest3() 
    {	
        PrivacyCaseTests.makeData();

        Contact con = new contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.email = 'foo@example.com';
        con.Brand__c = 'Calvin Klein';
        insert con;
        
        Contact con2 = new contact();
        con2.firstname = 'test22';
        con2.lastname = 'contact';
        con2.email = 'foo@example.com';
        con2.Brand__c = 'Calvin Klein';
        con2.Ecomm_Connected__c = true;
        insert con2;
        
        String brandName='2';
        
        String jsonData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17"}';
        String changedData = 'First Name: testsek Last Name: testbar= Address: test 234 Apartment/Suite/Unit: 111 City: germantown State: Maryland Country: United States of America Zip Code: 20874 Phone: 1234561234 Gender: Male Birthday (Month-Day): 5-17';
        PersonalDataFormApexController.createCaseForDataRectified(changedData, brandName,'foo@example.com' , true, jsonData);
       
    }
    
      @isTest 
    static void createCaseForRectifiedDataTest4() 
    {	
        PrivacyCaseTests.makeData();

        Contact con = new contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.email = 'foo@example.com';
        con.Brand__c = 'Calvin Klein';
        insert con;
        
        Contact con2 = new contact();
        con2.firstname = 'test22';
        con2.lastname = 'contact';
        con2.email = 'foo@example.com';
        con2.Brand__c = 'Calvin Klein';
        con2.Ecomm_Connected__c = true;
        insert con2;
        
        String brandName='2';
        
        String jsonData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17"}';
        String changedData = 'First Name: testsek Last Name: testbar= Address: test 234 Apartment/Suite/Unit: 111 City: germantown State: Maryland Country: United States of America Zip Code: 20874 Phone: 1234561234 Gender: Male Birthday (Month-Day): 5-17';
        PersonalDataFormApexController.createCaseForDataRectified(changedData, brandName,'foo@example.com' , true, jsonData);
        
        Case cse = [Select id from case limit 1];
        cse.status = 'Resolved';
        cse.Sub_Type__c = 'Rectify My Data';
        cse.Resolution_Code__c = 'User Data Provided';
        cse.R2R_Email_UserConfirmation__c = 'Confirmed';
        Test.startTest();
        update cse;
        Test.stopTest();
       
    }
    
        @isTest 
    static void createCaseForDonotSellShareTest() 
    {	
        PrivacyCaseTests.makeData();

        Contact con = new contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.email = 'foo@example.com';
        con.Brand__c = 'Calvin Klein';
        insert con;
        
        Contact con2 = new contact();
        con2.firstname = 'test22';
        con2.lastname = 'contact';
        con2.email = 'foo@example.com';
        con2.Brand__c = 'Calvin Klein';
        con2.Ecomm_Connected__c = true;
        insert con2;
        
        String brandName='2';
        
        String jsonData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17"}';
        String changedData = 'First Name: testsek Last Name: testbar= Address: test 234 Apartment/Suite/Unit: 111 City: germantown State: Maryland Country: United States of America Zip Code: 20874 Phone: 1234561234 Gender: Male Birthday (Month-Day): 5-17';
        PersonalDataFormApexController.createCaseForDonotSellShare(brandName,'foo@example.com',false);
       
    }
    
            @isTest 
    static void createCaseForDonotSellShareTestContactNotFound() 
    {	
        PrivacyCaseTests.makeData();

        Contact con = new contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.email = 'foo@example.com';
        con.Brand__c = 'Calvin Klein';
        insert con;
        
        Contact con2 = new contact();
        con2.firstname = 'test22';
        con2.lastname = 'contact';
        con2.email = 'foo@example.com';
        con2.Brand__c = 'Calvin Klein';
        con2.Ecomm_Connected__c = true;
        insert con2;
        
        String brandName='2';
        
        String jsonData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17"}';
        String changedData = 'First Name: testsek Last Name: testbar= Address: test 234 Apartment/Suite/Unit: 111 City: germantown State: Maryland Country: United States of America Zip Code: 20874 Phone: 1234561234 Gender: Male Birthday (Month-Day): 5-17';
        PersonalDataFormApexController.createCaseForDonotSellShare(brandName,'foo@example.comm',false);
       
    }
    
     @isTest 
    static void checkIfContactExistWithEmailIdTest() 
    {	
     	 Contact con = new contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.email = 'foo1@example.com';
        con.Brand__c = 'Calvin Klein';
        insert con;
        
        PersonalDataFormApexController.CaseWrapper wrap =  PersonalDataFormApexController.checkIfContactExistWithEmailId('2', 'foo1@example.com');
        Test.startTest();
        System.assertEquals(true, wrap.error);
        Test.stopTest();
    }

    
}