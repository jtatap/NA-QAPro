@isTest
public class SFMCUtilityTest {
    static Map<String, String> responseHeaders = new Map<String, String>();
    
    //@isTest(SeeAllData=true) 
    public static void setMockResponse(){
        
        responseHeaders.put('Content-Type','application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(400,
                                                 'Complete',
                                                 '{"errors":["1785551212 is incorrect for us country"]}',
                                                 responseHeaders);
        
        System.debug('*** fake response = '+fakeResponse);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        
    }
    
    private static void testdata1(){
        //Test Data for account and contact
        //Not used test setup as some method don't need existing account and contact data
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Source_System__c = 'POS';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '2';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.MailingStreet = 'c mailing street';
        con.MailingCity = 'ccity';
        con.MailingState = 'cstate';
        con.MailingPostalCode = 'c1234';
        con.MailingCountry = 'ccity';
        con.Email = 'testemail5@nomail.com';
        con.Phone = '5555555555';
        con.HomePhone = '0987654321';
        con.LoyaltyID__c='testing';
        con.MobilePhone = '7777777775';
        con.Birthdate = Date.newInstance(1990, 12, 30);       
        con.HomeStore__c = 'cLoc';
        con.LoyaltyFlag__c = false;
        con.EmailOptInStatus__c = 'N';
        con.EmailOptOutDate__c=system.now();//false;
        con.SMSOptinStatus__c = 'N'; //false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
        con.SMSNumber__c='2345678902';
        
        insert con;
        
    }
    
    @isTest
    public static void postToSFMCQueueMOAPITest_chargeIt(){
        setMockResponse();
        List<SFMCUtility.QueueMOData> ListData = new List<SFMCUtility.QueueMOData>();
        SFMCUtility.QueueMOData obj = new SFMCUtility.QueueMOData();
        obj.KeywordType = 'chargeIt';
        obj.BrandId = '1';
        obj.SmsNumber = '1785551212';
        obj.ContactId = '0038A00000Impo1QAB';
        obj.Email = 'noemailcontact@test.com';
        obj.Country='US';
        obj.SMSLocale = 'en_US';
        ListData.add(obj);
        SFMCUtility.invocableTargetSMSAPI(ListData);
        String jsonString = json.serialize(ListData);
        SFMCUtility.postToSFMCQueueMOAPI(jsonString);
        
    }
    
    @isTest
    public static void postToSFMCQueueMOAPITest_stop(){
        setMockResponse();
        List<SFMCUtility.QueueMOData> ListData = new List<SFMCUtility.QueueMOData>();
        SFMCUtility.QueueMOData obj = new SFMCUtility.QueueMOData();
        obj.KeywordType = 'stop';
        obj.BrandId = '1';
        obj.SmsNumber = '1785551212';
        obj.ContactId = '0038A00000Impo1QAB';
        obj.Email = 'noemailcontact@test.com';
        obj.Country='US';
        obj.SMSLocale = 'en_US';
        ListData.add(obj);
        SFMCUtility.invocableTargetSMSAPI(ListData);
        String jsonString = json.serialize(ListData);
        SFMCUtility.postToSFMCQueueMOAPI(jsonString);
        
    }
    
    @isTest
    public static void postToWaterfallSMSAPI_preferenceCenter(){
        setMockResponse();
        List<SFMCUtility.QueueMOData> ListData = new List<SFMCUtility.QueueMOData>();
        SFMCUtility.QueueMOData obj = new SFMCUtility.QueueMOData();
        obj.KeywordType = 'preferenceCenter';
        obj.BrandId = '1';
        obj.SmsNumber = '1785551212';
        obj.ContactId = '0038A00000Impo1QAB';
        obj.Email = 'noemailcontact@test.com';
        obj.Country='US';
        obj.SMSLocale = 'en_US';
        ListData.add(obj);
        SFMCUtility.invocableTargetSMSAPI(ListData);
        String jsonString = json.serialize(ListData);
        SFMCUtility.postToWaterfallSMSAPI(jsonString);
        
    }
    
    @isTest
    public static void postToWaterfallSMSAPI_chargeIt(){
        setMockResponse();
        List<SFMCUtility.QueueMOData> ListData = new List<SFMCUtility.QueueMOData>();
        SFMCUtility.QueueMOData obj = new SFMCUtility.QueueMOData();
        obj.KeywordType = 'chargeIt';
        obj.BrandId = '1';
        obj.SmsNumber = '1785551212';
        obj.ContactId = '0038A00000Impo1QAB';
        obj.Email = 'noemailcontact@test.com';
        obj.Country='US';
        obj.SMSLocale = 'en_US';
        ListData.add(obj);
        SFMCUtility.invocableTargetSMSAPI(ListData);
        String jsonString = json.serialize(ListData);
        SFMCUtility.postToWaterfallSMSAPI(jsonString);
        
    }
    
    @isTest
    public static void postToWaterfallSMSAPI_stop(){
        setMockResponse();
        List<SFMCUtility.QueueMOData> ListData = new List<SFMCUtility.QueueMOData>();
        SFMCUtility.QueueMOData obj = new SFMCUtility.QueueMOData();
        obj.KeywordType = 'stop';
        obj.BrandId = '1';
        obj.SmsNumber = '1785551212';
        obj.ContactId = '0038A00000Impo1QAB';
        obj.Email = 'noemailcontact@test.com';
        obj.Country='US';
        obj.SMSLocale = 'en_US';
        ListData.add(obj);
        SFMCUtility.invocableTargetSMSAPI(ListData);
        String jsonString = json.serialize(ListData);
        SFMCUtility.postToWaterfallSMSAPI(jsonString);
        
    }
    @isTest static void searchSMSBrandContact(){
        //Test for Contact existing in the System BrandID 81.
        testdata1();
        list<Contact> con2 = [SELECT Id, LoyaltyID__c,Email,Brand_Id__c,SMSNumber__c FROM Contact WHERE Brand_Id__c='2' AND SMSNumber__c='2345678902'];
        //System.debug('con2 size'+con2.size());
        //system.debug('loyaltyId******'+con2[0].LoyaltyID__c);
        List<SFMCUtility.QueueMOData> ListData = new List<SFMCUtility.QueueMOData>();
        SFMCUtility.QueueMOData obj = new SFMCUtility.QueueMOData();
        obj.KeywordType = 'chargeIt';
        obj.BrandId = '2';
        obj.SmsNumber = '1785551212';
        obj.ContactId = '0038A00000Impo1QAB';
        obj.Email = 'noemailcontact@test.com';
        obj.Country='US';
        obj.SMSLocale = 'en_US';
        ListData.add(obj);
        SFMCUtility.searchSMSBrandContact('2' , '2345678902');
        SFMCUtility.searchEmailBrandContact('2','testemail5@nomail.com');
        SFMCUtility.getSiblingAccountId('2','testemail5@nomail.com');
        SFMCUtility.validateEmail('testemail5@nomail.com');
       
        //SFMCUtility.setContactSMSOptin(con2[0],true);
        
        String jsonString = json.serialize(ListData);
        SFMCUtility.postToWaterfallSMSAPI(jsonString);
       
    }
}