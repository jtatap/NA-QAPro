@isTest
public class BulkSignUpTest {
    private static String getRendomNumber(Integer iDigit){
        return string.valueOf(Math.abs(Crypto.getRandomInteger())).leftPad(iDigit, '0');
    }
    private static List<BulkSignUp.Subscriber> generateSubscribesData(){
        List<BulkSignUp.Subscriber> subData = new List<BulkSignUp.Subscriber>();
        BulkSignUp.Subscriber subscribeReq1 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq2 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq3 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq4 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq5 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq6 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq7 = new BulkSignUp.Subscriber();
        BulkSignUp.Subscriber subscribeReq8 = new BulkSignUp.Subscriber();
        
        //Subscriber data for brand 1, create new contact
        subscribeReq1.brandId = '1';
        subscribeReq1.Zeta_Email_Id = getRendomNumber(12);//'128005800';
        subscribeReq1.Zeta_Customer_Id = getRendomNumber(12);//'43707697';
        //subscribeReq1.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq1.firstName = 'fname' + getRendomNumber(10);
        subscribeReq1.firstName = 'mname' + getRendomNumber(10);
        subscribeReq1.lastName = 'Lname' + '1';
        subscribeReq1.Street = 'Address 1';
        subscribeReq1.city = 'City1';
        subscribeReq1.state = 'State1';
        subscribeReq1.ZIP = '1234';
        subscribeReq1.country = 'country1';
        subscribeReq1.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq1.PrimaryPhone = getRendomNumber(10);//'1234567891';
        subscribeReq1.HomePhone = getRendomNumber(10);//'2345678911';
        subscribeReq1.SMSPhone = getRendomNumber(10);//'3456789011';
        subscribeReq1.BirthDate = '19771122';
        subscribeReq1.Gender ='M';
        subscribeReq1.CompanyCode = 'TX';
        subscribeReq1.HomeStore = 'CO601';
        subscribeReq1.StoreOfCapture = 'any';
        subscribeReq1.SourceSystem = 'WiFi';
        subscribeReq1.LoyaltyId = 'E031031293225';
        subscribeReq1.LoyaltyOptinFlag = 'true';
        subscribeReq1.LoyaltyOptInDate = '20190812';
        subscribeReq1.EmailOptInFlag = 'true';
        subscribeReq1.EmailSignUpDate = '20190802';
        subscribeReq1.TransactionDate = '20190812';

        subData.add(subscribeReq1);
        
        //Subscriber data for brand 9, create new contact
        subscribeReq2.brandId = '9';
        subscribeReq2.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq2.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq2.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq2.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq2.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq2.lastName = 'Lname1'+'2';
        subscribeReq2.Street = 'Address 1';
        subscribeReq2.city = 'City1';
        subscribeReq2.state = 'State1';
        subscribeReq2.ZIP = '1234';
        subscribeReq2.country = 'country1';
        subscribeReq2.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq2.PrimaryPhone = getRendomNumber(10);
        subscribeReq2.HomePhone = getRendomNumber(10);
        subscribeReq2.SMSPhone = getRendomNumber(10);
        subscribeReq2.BirthDate = '20010122';
        subscribeReq2.Gender ='M';
        subscribeReq2.CompanyCode = 'TX';
        subscribeReq2.HomeStore = 'CO601';
        subscribeReq2.StoreOfCapture = 'other';
        subscribeReq2.SourceSystem = 'POS';
        subscribeReq2.LoyaltyId = 'E031031293225';
        subscribeReq2.LoyaltyOptinFlag = 'true';
        subscribeReq2.LoyaltyOptInDate = '20190812';
        subscribeReq2.EmailOptInFlag = 'false';
        subscribeReq2.EmailSignUpDate = '20190802';
        subscribeReq2.TransactionDate = '20190812';

        subData.add(subscribeReq2);
        
        //Subscriber data for brand Id 81, create new contact
        subscribeReq3.brandId = '81';
        subscribeReq3.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq3.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq3.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq3.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq3.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq3.lastName = 'Lname13';
        subscribeReq3.Street = 'Address 1';
        subscribeReq3.city = 'City1';
        subscribeReq3.state = 'State1';
        subscribeReq3.ZIP = '1234';
        subscribeReq3.country = 'country1';
        subscribeReq3.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq3.PrimaryPhone = getRendomNumber(10);
        subscribeReq3.HomePhone = getRendomNumber(10);
        subscribeReq3.SMSPhone = getRendomNumber(10);
        subscribeReq3.BirthDate = '20010122';
        subscribeReq3.Gender ='M';
        subscribeReq3.CompanyCode = 'TX';
        subscribeReq3.HomeStore = 'CO601';
        subscribeReq3.StoreOfCapture = 'other';
        subscribeReq3.SourceSystem = 'POS';
        subscribeReq3.LoyaltyId = 'E031031293225';
        subscribeReq3.LoyaltyOptinFlag = 'true';
        subscribeReq3.LoyaltyOptInDate = '20190812';
        subscribeReq3.EmailOptInFlag = 'true';
        subscribeReq3.EmailSignUpDate = '20190812';
        subscribeReq3.TransactionDate = '20190812';

        subData.add(subscribeReq3);
        
        //Subscriber data for brand 1, create new contact
        subscribeReq4.brandId = '1';
        subscribeReq4.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq4.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq4.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq4.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq4.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq4.lastName = 'Lname1'+getRendomNumber(10);
        subscribeReq4.Street = 'Address 1';
        subscribeReq4.city = 'City1';
        subscribeReq4.state = 'State1';
        subscribeReq4.ZIP = '1234';
        subscribeReq4.country = 'country1';
        subscribeReq4.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq4.PrimaryPhone = getRendomNumber(10);
        subscribeReq4.HomePhone = getRendomNumber(10);
        subscribeReq4.SMSPhone = getRendomNumber(10);
        subscribeReq4.BirthDate = '20010122';
        subscribeReq4.Gender ='M';
        subscribeReq4.CompanyCode = 'TX';
        subscribeReq4.HomeStore = 'CO601';
        subscribeReq4.StoreOfCapture = 'any';
        subscribeReq4.SourceSystem = 'WiFi';
        subscribeReq4.LoyaltyId = 'E031031293225';
        subscribeReq4.LoyaltyOptinFlag = 'true';
        subscribeReq4.LoyaltyOptInDate = '20190812';
        subscribeReq4.EmailOptInFlag = 'true';
        subscribeReq4.EmailSignUpDate = '20190812';
        subscribeReq4.TransactionDate = '20190812';

        subData.add(subscribeReq4);
        
        //Subscriber data for brand 1, update existing contact
        subscribeReq5.brandId = '1';
        subscribeReq5.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq5.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq5.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq5.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq5.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq5.lastName = 'Lname1'+getRendomNumber(10);
        subscribeReq5.Street = 'Address 1';
        subscribeReq5.city = 'City1';
        subscribeReq5.state = 'State1';
        subscribeReq5.ZIP = '1234';
        subscribeReq5.country = 'country1';
        subscribeReq5.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq5.PrimaryPhone = getRendomNumber(10);
        subscribeReq5.HomePhone = getRendomNumber(10);
        subscribeReq5.SMSPhone = getRendomNumber(10);
        subscribeReq5.BirthDate = '20010122';
        subscribeReq5.Gender ='M';
        subscribeReq5.CompanyCode = 'TX';
        subscribeReq5.HomeStore = 'CO601';
        subscribeReq5.StoreOfCapture = '601';
        subscribeReq5.SourceSystem = 'POS';
        subscribeReq5.LoyaltyId = 'E031031293225';
        subscribeReq5.LoyaltyOptinFlag = 'true';
        subscribeReq5.LoyaltyOptInDate = '20190812';
        subscribeReq5.EmailOptInFlag = 'true';
        subscribeReq5.EmailSignUpDate = '20190812';
        subscribeReq5.TransactionDate = '20190812';

        subData.add(subscribeReq5);
        
        //Subscriber data for brand 2, update existing contact
        subscribeReq6.brandId = '1';
        subscribeReq6.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq6.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq6.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq6.firstName = '';
        subscribeReq6.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq6.lastName = '';
        subscribeReq6.Street = 'Address 1';
        subscribeReq6.city = 'City1';
        subscribeReq6.state = 'State1';
        subscribeReq6.ZIP = '1234';
        subscribeReq6.country = 'country1';
        subscribeReq6.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq6.PrimaryPhone = getRendomNumber(10);
        subscribeReq6.HomePhone = getRendomNumber(10);
        subscribeReq6.SMSPhone = getRendomNumber(10);
        subscribeReq6.BirthDate = '20010122';
        subscribeReq6.Gender ='M';
        subscribeReq6.CompanyCode = 'TX';
        subscribeReq6.HomeStore = 'CO601';
        subscribeReq6.StoreOfCapture = 'CO601';
        subscribeReq6.SourceSystem = 'OutSideLists';
        subscribeReq6.LoyaltyId = 'E031031293225';
        subscribeReq6.LoyaltyOptinFlag = 'true';
        subscribeReq6.LoyaltyOptInDate = '20190812';
        subscribeReq6.EmailOptInFlag = 'true';
        subscribeReq6.EmailSignUpDate = '20190812';
        subscribeReq6.TransactionDate = '20190812';

        subData.add(subscribeReq6);
        
        //Subscriber data for brand 1, create new contact
        subscribeReq7.brandId = '1';
        subscribeReq7.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq7.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq7.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq7.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq7.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq7.lastName = 'Lname1'+getRendomNumber(10);
        subscribeReq7.Street = 'Address 1';
        subscribeReq7.city = 'City1';
        subscribeReq7.state = 'State1';
        subscribeReq7.ZIP = '1234';
        subscribeReq7.country = 'country1';
        subscribeReq7.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq7.PrimaryPhone = getRendomNumber(10);
        subscribeReq7.HomePhone = getRendomNumber(10);
        subscribeReq7.SMSPhone = getRendomNumber(10);
        subscribeReq7.BirthDate = '20010122';
        subscribeReq7.Gender ='M';
        subscribeReq7.CompanyCode = 'TX';
        subscribeReq7.HomeStore = 'CO601';
        subscribeReq7.StoreOfCapture = 'CO601';
        subscribeReq7.SourceSystem = 'OutSideLists';
        subscribeReq7.LoyaltyId = 'E031031293225';
        subscribeReq7.LoyaltyOptinFlag = 'false';
        subscribeReq7.LoyaltyOptInDate = '20190812';
        subscribeReq7.EmailOptInFlag = 'true';
        subscribeReq7.EmailSignUpDate = '20190812';
        subscribeReq7.TransactionDate = '20190812';

        subData.add(subscribeReq7);
        
        //Subscriber data for brand 5, with sourceSystem = 'WiFi'create new contact
        subscribeReq8.brandId = '5';
        subscribeReq8.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq8.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq8.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq8.firstName = '';//'fname1'+getRendomNumber(10);
        subscribeReq8.firstName = '';//'mname1'+getRendomNumber(10);
        subscribeReq8.lastName = 'Lname1'+getRendomNumber(10);
        subscribeReq8.Street = 'Address 1';
        subscribeReq8.city = 'City1';
        subscribeReq8.state = 'State1';
        subscribeReq8.ZIP = '1234';
        subscribeReq8.country = 'country1';
        subscribeReq8.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq8.PrimaryPhone = getRendomNumber(10);
        subscribeReq8.HomePhone = getRendomNumber(10);
        subscribeReq8.SMSPhone = getRendomNumber(10);
        subscribeReq8.BirthDate = '20010122';
        subscribeReq8.Gender ='M';
        subscribeReq8.CompanyCode = 'TX';
        subscribeReq8.HomeStore = 'CO601';
        subscribeReq8.StoreOfCapture = '601';
        subscribeReq8.SourceSystem = 'WiFi';
        subscribeReq8.LoyaltyId = 'E031031293225';
        subscribeReq8.LoyaltyOptinFlag = 'false';
        subscribeReq8.LoyaltyOptInDate = '20190812';
        subscribeReq8.EmailOptInFlag = 'true';
        subscribeReq8.EmailSignUpDate = '';
        subscribeReq8.TransactionDate = '20190812';
        
        subData.add(subscribeReq8);
        
        return subData;
    }
    
    public static Contact createContact(BulkSignUp.Subscriber sub){
        Contact newCon = new Contact();
 
        newCon.External_Id__c = sub.Zeta_Email_Id;
        newCon.Customer_Id__c = sub.Zeta_Customer_Id;
        newCon.LoyaltyId__c = sub.LoyaltyId;
        newCon.Brand_Id__c = sub.BrandId;
        newCon.FirstName = sub.FirstName;
        newCon.MiddleName = sub.MiddleName;
        newCon.LastName = sub.LastName;
        newCon.MailingStreet = sub.Street;
        newCon.MailingCity = sub.City;
        newCon.MailingState = sub.State;
        newCon.MailingPostalCode = sub.ZIP;
        newCon.MailingCountry = sub.Country;
        newCon.Email = sub.Email;
        newCon.Phone = sub.PrimaryPhone;
        newCon.HomePhone = sub.HomePhone;
        newCon.MobilePhone = sub.SMSPhone;
        newCon.Birthdate = UtilityClass.strYYYMMDDtoDate(sub.BirthDate);
        newCon.HomeStore__c = (sub.HomeStore);
        newCon.StoreOfCapture__c = (sub.StoreOfCapture);
        newCon.Source_System__c = (sub.SourceSystem);
        newCon.LoyaltyID__c = (sub.LoyaltyId);
        newCon.LoyaltyFlag__c = Boolean.valueOf(sub.LoyaltyOptinFlag);
        //if(sub.LoyaltyOptinDate!=null) newCon. = Date.valueOf(sub.LoyaltyOptinDate); //Field not specified to map to in contact
        newCon.EmailOptInStatus__c = (Boolean.valueOf(sub.EmailOptinFlag))?'Y':'N';
        newCon.EmailOptInDate__c = UtilityClass.strYYYMMDDtoDate(sub.EmailSignupDate);
       
        
        return newCon;
    }
    @isTest
    static void testUtilDateMethod(){
        String strDate = '20120323';
        Date dtDate = null;
        Test.startTest();
            dtDate = UtilityClass.strYYYMMDDtoDate(strDate);
        Test.stopTest();

        System.assertEquals(Date.newInstance(2012,3,23),dtDate);
    }

    
    @isTest
    static void testBulkSignupWithoutBvalue(){
        List<BulkSignUp.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        subData[0].BrandId = null;
        BulkSignUp.SubRequest subReq = new BulkSignUp.SubRequest();
        subReq.Count = '1';
        subReq.Subscribes = new List<BulkSignUp.Subscriber>{subData[0]};
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(subReq);
        
        req.requestURI = '/services/apexrest/subscribers/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        BulkSignUp.SubResponse response =  BulkSignUp.doSignUp();
        Test.stopTest();        
        system.assertNotEquals(null, response);
        //system.assertEquals('INVALID_QUERY', response.Code);
        //system.assertEquals('Missing required parameters:  BrandId or email', response.Message);
    }
    
    @isTest
    static void testBulkSignupWithSubKey(){
        List<BulkSignUp.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[0]));
        insert contacts;
        subData[0].SubscriberKey = contacts[0].Id;
        subData[0].FirstName = 'test';
        subData[0].EmailOptinFlag = 'true';
        subData[0].EmailSignupDate = null;
        subData[0].EmailOptinFlag = 'false';
        BulkSignUp.SubRequest subReq = new BulkSignUp.SubRequest();
        subReq.Count = '1';
        subReq.Subscribes = new List<BulkSignUp.Subscriber>{subData[0]};
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(subReq);
        
        req.requestURI = '/services/apexrest/subscribers/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        BulkSignUp.SubResponse response =  BulkSignUp.doSignUp();
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT FirstName FROM Contact WHERE Id=:subData[0].SubscriberKey];
        system.assertNotEquals(null, updatedContacts);
        system.assertEquals(1, updatedContacts.size());
        system.assertEquals('test', updatedContacts[0].FirstName);
    }
    
    @isTest
    static void testBulkSignupWithBnE(){
        List<BulkSignUp.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[1].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[1]));
        insert contacts;
        subData[1].FirstName = 'test';
        subData[1].EmailOptinFlag = 'true';
        BulkSignUp.SubRequest subReq = new BulkSignUp.SubRequest();
        subReq.Count = '1';
        subReq.Subscribes = new List<BulkSignUp.Subscriber>{subData[1]};
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(subReq);
        
        req.requestURI = '/services/apexrest/subscribers/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        BulkSignUp.SubResponse response =  BulkSignUp.doSignUp();
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT FirstName FROM Contact WHERE Brand_Id__c=:subData[1].BrandId AND Email=:subData[1].Email];
        system.assertNotEquals(null, updatedContacts);
        system.assertEquals(1, updatedContacts.size());
        system.assertEquals('test', updatedContacts[0].FirstName);
    }
    
    @isTest
    static void testBulkSignup(){
        List<BulkSignUp.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[0]));
        System.debug('Con brand'+contacts[0].Source_System__c);
        System.debug('Con brand'+contacts[0].Brand_Id__c);
        System.debug('Con brand'+contacts[0].StoreOfCapture__c);
   //     contacts.add(createContact(subData[3]));
        insert contacts;
        subData[0].SubscriberKey = contacts[0].Id;
        subData[0].EmailOptinFlag = 'true';
        BulkSignUp.SubRequest subReq = new BulkSignUp.SubRequest();
        subReq.Count = '1';
        subReq.Subscribes = subData;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(subReq);
        
        req.requestURI = '/services/apexrest/subscribers/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.debug('res :'+res);        
        BulkSignUp.SubResponse response =  BulkSignUp.doSignUp();
        system.debug('****res1: ' + response);
        Test.stopTest();
        system.assertEquals('OK',response.Code);
    //    system.assertEquals('6',response.Count);
     //   system.assertEquals(6, [SELECT COUNT() FROM Contact]);

    }
    
     @isTest
    static void testBulkSignupParent(){
        //List<BulkSignUp.Subscriber> subData = generateSubscribesData();
         //Subscriber data for brand 2, create new contact
        BulkSignUp.Subscriber subscribeReq2 = new BulkSignUp.Subscriber();
        subscribeReq2.brandId = '9';
        subscribeReq2.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq2.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq2.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq2.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq2.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq2.lastName = 'Lname1'+'2';
        subscribeReq2.Street = 'Address 1';
        subscribeReq2.city = 'City1';
        subscribeReq2.state = 'State1';
        subscribeReq2.ZIP = '1234';
        subscribeReq2.country = 'country1';
        subscribeReq2.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq2.PrimaryPhone = getRendomNumber(10);
        subscribeReq2.HomePhone = getRendomNumber(10);
        subscribeReq2.SMSPhone = getRendomNumber(10);
        subscribeReq2.BirthDate = '20010122';
        subscribeReq2.Gender ='M';
        subscribeReq2.CompanyCode = 'TX';
        subscribeReq2.HomeStore = '601';
        subscribeReq2.StoreOfCapture = 'CO601';
        subscribeReq2.SourceSystem = 'POS';
        subscribeReq2.LoyaltyId = 'E031031293225';
        subscribeReq2.LoyaltyOptinFlag = 'true';
        subscribeReq2.LoyaltyOptInDate = '20190812';
        subscribeReq2.EmailOptInFlag = 'false';
        subscribeReq2.EmailSignUpDate = '20190802';
        subscribeReq2.TransactionDate = '20190812';
        subscribeReq2.EmailOptInForSubBrands='5|81|83|84';

        
        List<BulkSignUp.Subscriber> subData = new List<BulkSignUp.Subscriber>();
		subData.add(subscribeReq2);
        
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[0]));
        subData[0].EmailOptinFlag = 'true';
        BulkSignUp.SubRequest subReq = new BulkSignUp.SubRequest();
        subReq.Count = '1';
        subReq.Subscribes = subData;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(subReq);
        
        req.requestURI = '/services/apexrest/subscribers/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.debug('res :'+res);        
        BulkSignUp.SubResponse response =  BulkSignUp.doSignUp();
        system.debug('****res1: ' + response);
        Test.stopTest();
        system.assertEquals('OK',response.Code);
    //    system.assertEquals('6',response.Count);
     //   system.assertEquals(6, [SELECT COUNT() FROM Contact]);

    }
    @isTest
    static void testBulkSignupBulkBuyer(){
        Contact newCon = new Contact();
 
        newCon.External_Id__c = '12345';
        newCon.Customer_Id__c = 'abcd1234';
        newCon.LoyaltyId__c = 'E031031293225';
        newCon.Brand_Id__c = '2';
        newCon.FirstName = 'Test';
        newCon.MiddleName = 'Test';
        newCon.LastName = 'Test123';
        newCon.MailingStreet = 'James street';
        newCon.MailingCity = 'NY';
        newCon.MailingState = 'NY';
        newCon.MailingPostalCode = '12345';
        newCon.MailingCountry = 'US';
        newCon.Email = 'test@test.com';
        newCon.Source_System__c = 'eComm';
        newCon.LoyaltyID__c = 'E031031293225';
        newCon.LoyaltyFlag__c = true;
        //if(sub.LoyaltyOptinDate!=null) newCon. = Date.valueOf(sub.LoyaltyOptinDate); //Field not specified to map to in contact
        newCon.EmailOptInStatus__c = 'Y';
        newCon.EmailOptInDate__c = System.today();
        insert newCon;
        //List<BulkSignUp.Subscriber> subData = generateSubscribesData();
         //Subscriber data for brand 2, create new contact
        BulkSignUp.Subscriber subscribeReq2 = new BulkSignUp.Subscriber();
        subscribeReq2.brandId = '9';
        subscribeReq2.Zeta_Email_Id = getRendomNumber(12);
        subscribeReq2.Zeta_Customer_Id = getRendomNumber(12);
        //subscribeReq2.SubscriberKey = '0031800000bSZDJAA4';
        subscribeReq2.firstName = 'fname1'+getRendomNumber(10);
        subscribeReq2.firstName = 'mname1'+getRendomNumber(10);
        subscribeReq2.lastName = 'Lname1'+'2';
        subscribeReq2.Street = 'Address 1';
        subscribeReq2.city = 'City1';
        subscribeReq2.state = 'State1';
        subscribeReq2.ZIP = '1234';
        subscribeReq2.country = 'country1';
        subscribeReq2.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq2.PrimaryPhone = getRendomNumber(10);
        subscribeReq2.HomePhone = getRendomNumber(10);
        subscribeReq2.SMSPhone = getRendomNumber(10);
        subscribeReq2.BirthDate = '20010122';
        subscribeReq2.Gender ='M';
        subscribeReq2.CompanyCode = 'TX';
        subscribeReq2.HomeStore = '601';
        subscribeReq2.StoreOfCapture = 'CO601';
        subscribeReq2.SourceSystem = 'POS';
        subscribeReq2.LoyaltyId = 'E031031293225';
        subscribeReq2.LoyaltyOptinFlag = 'true';
        subscribeReq2.LoyaltyOptInDate = '20190812';
        subscribeReq2.EmailOptInFlag = 'false';
        subscribeReq2.EmailSignUpDate = '20190802';
        subscribeReq2.TransactionDate = '20190812';
        subscribeReq2.EmailOptInForSubBrands='5|81|83|84';
        subscribeReq2.BulkBuyer='Yes';

        
        List<BulkSignUp.Subscriber> subData = new List<BulkSignUp.Subscriber>();
		subData.add(subscribeReq2);
        
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[0]));
        subData[0].EmailOptinFlag = 'true';
        BulkSignUp.SubRequest subReq = new BulkSignUp.SubRequest();
        subReq.Count = '1';
        subReq.Subscribes = subData;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(subReq);
        
        req.requestURI = '/services/apexrest/subscribers/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.debug('res :'+res);        
        BulkSignUp.SubResponse response =  BulkSignUp.doSignUp();
        system.debug('****res1: ' + response);
        Test.stopTest();
        system.assertEquals('OK',response.Code);
    //    system.assertEquals('6',response.Count);
     //   system.assertEquals(6, [SELECT COUNT() FROM Contact]);

    }
   
}