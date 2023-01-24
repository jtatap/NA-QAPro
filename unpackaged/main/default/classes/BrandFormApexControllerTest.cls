/**
 * @class:       BrandFormApexControllerTest
 * @JIRA:        NASSC-25, NASSC-354
 * @description: Test Class for BrandFormApexController class.
 */ 

@isTest
public class BrandFormApexControllerTest 
{
	BrandFormApexController.CaseWrapper obj = new BrandFormApexController.CaseWrapper();    
    
	@isTest 
    static void getDataTest() 
    {	
            // Setting the brandName with API Name for Calvin Klein
        	String brandName='2';
        	String sourceCountry = 'US';
            BrandFormApexController.getData(brandName,sourceCountry);
        
    }
    
    @isTest
    static void createCaseTest() 
    {	
        system.debug('inside create case***');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                         'Complete',
                                         '[{"ResponseMessage":"NEW CUSTOMER","EmailAddress":"test@test.com"}]',
                                         null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        //Setting the API Name for Calvin Klein Brand
        String brandName='2';
        List<Case> getCaseList = TestDataFactory.createCases(1);
        getCaseList[0].origin='Web';
        getCaseList[0].SuppliedEmail='abc@gmail.com'; 
        getCaseList[0].SuppliedPhone='9988998899';
        getCaseList[0].Is_Existing_Purchase__c='Yes';
		getCaseList[0].Type='Product';
		getCaseList[0].Description='Test Cases';
        
        BrandFormApexController.CaseWrapper cwObj = new BrandFormApexController.CaseWrapper();
        Test.startTest();
        system.debug('getCaseList[0]***'+getCaseList[0]);
        cwObj = BrandFormApexController.createCase(getCaseList[0],'test_firstname','test_secondname','test name',brandName);
          system.debug('cwObj***'+cwObj);
        List<string> files = new List<string>();
        BrandFormApexController.assignFilesToCase(files, getCaseList[0].Id);
         Id caseIds = Id.valueOf(cwObj.caseId);
      //  Test.stopTest();
       
       
        System.debug('***Test Case Created = '+caseIds);
       //Testing the fileUpload functionality
       //Blob fileBody = Blob.valueOf('testContent');
       //Id attachmentId = BrandFormApexController.saveChunk(caseIds, 'testfile','fileBody','image/jpeg','');
       
       
       // inserting attachment
      /* 	String TestData = 'Test';
        TestData = EncodingUtil.urlDecode(TestData, 'UTF-8');
    	
    	Attachment attachment = new Attachment();
    	attachment.ParentId = caseIds;
    	attachment.Name = 'Test Attachment for Parent';
    	attachment.Body = EncodingUtil.base64Decode(TestData);
        try{
            insert attachment;
        }
    	catch(Exception e)
        {
            System.debug('Error in Attachment = '+e.getMessage());
        }
      */
       Test.stopTest();
    }

}