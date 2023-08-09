/**
 * @class:       BrandFormApexControllerTest
 * @JIRA:        NASSC-25, NASSC-354
 * @description: Test Class for BrandFormApexController class.
 */ 

@isTest
public class BrandFormApexControllerTest 
{
	BrandFormApexController.CaseWrapper obj = new BrandFormApexController.CaseWrapper();    

    @TestSetup
    static void makeData(){
        Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'generic Account';
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact';
        con.AccountId = acc.id;
        con.Brand_Id__c = '1';
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = con.Id
        );
        insert genRec;
       List<Case> getCaseList = TestDataFactory.createCases(1);
       /*Case getCaseList  = new Case();
        getCaseList.origin='Web';
        getCaseList.SuppliedEmail='abc@gmail.com'; 
        getCaseList.SuppliedPhone='9988998899';
        getCaseList.Is_Existing_Purchase__c='Yes';
		getCaseList.Type='Product';
		getCaseList.Description='Test Cases';*/
        
        getCaseList[0].origin='Web';
        getCaseList[0].SuppliedEmail='abc@gmail.com'; 
        getCaseList[0].SuppliedPhone='9988998899';
        getCaseList[0].Is_Existing_Purchase__c='Yes';
		getCaseList[0].Type='Product';
		getCaseList[0].Description='Test Cases';
        insert getCaseList;
        
    }
    
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
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                         'Complete',
                                         '[{"ResponseMessage":"NEW CUSTOMER","EmailAddress":"test@test.com"}]',
                                         null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        //Setting the API Name for Calvin Klein Brand
        String brandName='2';
        
        BrandFormApexController.CaseWrapper cwObj = new BrandFormApexController.CaseWrapper();
        Test.startTest();
        List<Case> getCaseList = [SELECT Id,Supplied_First_Name__c,Supplied_Last_Name__c,SuppliedName,SuppliedEmail,SuppliedPhone,Is_Existing_Purchase__c,Channel__c,Type,Reason_Code__c,Description,Brand__c,Tommy_Adaptive__c,Origin,Order_Number__c FROM Case];
        cwObj =BrandFormApexController.createCase(getCaseList[0],'test_firstname','test_secondname','testname',brandName);
        List<string> files = new List<string>();
        BrandFormApexController.assignFilesToCase(files, getCaseList[0].Id);
         Id caseIds = Id.valueOf(cwObj.caseId);
      //  Test.stopTest();
       
       
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
            
        }
      */
       Test.stopTest();
    }

}