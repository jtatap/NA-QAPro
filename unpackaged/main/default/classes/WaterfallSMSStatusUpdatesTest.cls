/******************************************************************************
* @Description: Test class for WaterfallSMSStatusUpdatesTest
* @Date		  : April 27, 2020
* @JIRA		  : NASSC-1614
*
******************************************************************************/
@isTest
public class WaterfallSMSStatusUpdatesTest {

    @testSetup
    static void dataSetup() {
        List<Contact> listTestContacts = new List<Contact>();
        Account accOne = new Account(Name = 'Testing', Gender__c='M');
        insert accOne;
        
        Contact conOne = new Contact(LastName='TestConOne', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555551',Email='emailone@doamin.com');
        listTestContacts.add(conOne);
        
        Contact conTwo = new Contact(LastName='TestConTwo', AccountId=accOne.Id,
                                     Brand_Id__c='1',Email='emailtwo@doamin.com');
        listTestContacts.add(conTwo);
        
        Contact conThree = new Contact(LastName='TestConThree', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555559',Email='notmatched@doamin.com');
        listTestContacts.add(conThree);
        
        Contact conFour = new Contact(LastName='TestConFour', AccountId=accOne.Id,
                                     Brand_Id__c='1',Email='emailfour@doamin.com');
        listTestContacts.add(conFour);
        
        Contact conFive = new Contact(LastName='TestConFive', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555557');
        listTestContacts.add(conFive);
        
        Contact conSix = new Contact(LastName='TestConSix', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555558',Email='emailsix@doamin.com');
       	listTestContacts.add(conSix);
        
        insert listTestContacts;
        
    }

	
    @isTest
    static void doSignUpTest_SMSOptOut(){
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Subscribers/SMSOptin/Waterfall';
        req.httpMethod = 'POST';
        String reqBody = '{"Count":"2","Subscribes":[{"BrandId":"1","Country":"US","ProcessedTimeStamp":"2019-03-26T12:00:00Z","SMSNumber":"15555555551","ShortCode":"20000101","Keyword":"JOIN","SMSFlag":"1","Email":"TH1@waterfall.com","SourceSystem":"Waterfall"},{"BrandId":"1","Country":"US","ProcessedTimeStamp":"2019-03-26T11:00:00Z","SMSNumber":"15555555552","ShortCode":"20000101","Keyword":"STOP","SMSFlag":"2","Email":"TH2@waterfall.com","SourceSystem":"Waterfall"}],"FileName":"CK-US_OptInOut_20200404050010.csv"}';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        WaterfallSMSStatusUpdates.SubResponse subResponse = new WaterfallSMSStatusUpdates.SubResponse();
		subResponse = WaterfallSMSStatusUpdates.doSignUp();
        System.debug('***Response 1 = '+subResponse);
    }
   
    
    @isTest
    static void doSignUpTest_SMSOptInOne_SMSOptInTwo(){
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Subscribers/SMSOptin/Waterfall';
        req.httpMethod = 'POST';
        String reqBody = '{"Count":"2","Subscribes":[{"BrandId":"1","Country":"US","ProcessedTimeStamp":"2019-03-26T12:00:00Z","SMSNumber":"15555555556","ShortCode":"20000101","Keyword":"JOIN","SMSFlag":"0","Email":"emailthree@doamin.com","SourceSystem":"Waterfall"},{"BrandId":"1","Country":"US","ProcessedTimeStamp":"2019-03-26T11:00:00Z","SMSNumber":"15555555554","ShortCode":"20000101","Keyword":"STOP","SMSFlag":"0","Email":"emailfour@doamin.com","SourceSystem":"Waterfall"}],"FileName":"CK-US_OptInOut_20200404050010.csv"}';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        WaterfallSMSStatusUpdates.SubResponse subResponse = new WaterfallSMSStatusUpdates.SubResponse();
		subResponse = WaterfallSMSStatusUpdates.doSignUp();
        System.debug('***Response 2 = '+subResponse);
    }
    
    @isTest
    static void doSignUpTest_SMSOptInFive_Above(){
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Subscribers/SMSOptin/Waterfall';
        req.httpMethod = 'POST';
        String reqBody = '{"Count":"2","Subscribes":[{"BrandId":"1","Country":"US","ProcessedTimeStamp":"2019-03-26T12:00:00Z","SMSNumber":"15555555557","ShortCode":"20000101","Keyword":"JOIN","SMSFlag":"0","Email":"noemailfive@domain.com","SourceSystem":"Waterfall"},{"BrandId":"1","Country":"US","ProcessedTimeStamp":"2019-03-26T11:00:00Z","SMSNumber":"15555555558","ShortCode":"20000101","Keyword":"STOP","SMSFlag":"0","Email":"randomemail@domain.com","SourceSystem":"Waterfall"}],"FileName":"CK-US_OptInOut_20200404050010.csv"}';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        WaterfallSMSStatusUpdates.SubResponse subResponse = new WaterfallSMSStatusUpdates.SubResponse();
		subResponse = WaterfallSMSStatusUpdates.doSignUp();
        System.debug('***Response 3 = '+subResponse);
    }
	
}