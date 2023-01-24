@isTest
public class A1CustomerProfileUpdateTest {
    private static String getRendomNumber(Integer iDigit){
        return string.valueOf(Math.abs(Crypto.getRandomInteger())).leftPad(iDigit, '0');
    }
    private static List<A1CustomerProfileUpdate.Subscriber> generateSubscribesData(){
        List<A1CustomerProfileUpdate.Subscriber> subData = new List<A1CustomerProfileUpdate.Subscriber>();
        A1CustomerProfileUpdate.Subscriber subscribeReq1 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq2 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq3 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq4 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq5 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq6 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq7 = new A1CustomerProfileUpdate.Subscriber();
        A1CustomerProfileUpdate.Subscriber subscribeReq8 = new A1CustomerProfileUpdate.Subscriber();

        //Subscriber data for brand 2, create new contact
        subscribeReq1.brandId = '2';
        subscribeReq1.firstName = 'fname' + getRendomNumber(10);
        subscribeReq1.lastName = 'Lname' + '1';
        subscribeReq1.Street = 'Address 1';
        subscribeReq1.city = 'City1';
        subscribeReq1.state = 'State1';
        subscribeReq1.ZIP = '1234';
        subscribeReq1.country = 'country1';
        subscribeReq1.email = 'subreq'+getRendomNumber(5)+'@nomail.com';
        subscribeReq1.PrimaryPhone = getRendomNumber(10);//'1234567891';
        subscribeReq1.HomeStore = 'CO601';
        subscribeReq1.StoreOfCapture = 'any';
        subscribeReq1.SourceSystem = 'Aquia';
        subscribeReq1.LoyaltyId = 'CK31031293225';
        subData.add(subscribeReq1);

        //Subscriber data for brand 2, create new contact
        subscribeReq2.brandId = '2';
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
        subscribeReq2.HomeStore = 'CO601';
        subscribeReq2.StoreOfCapture = 'other';
        subscribeReq2.SourceSystem = 'Aquia';
        subscribeReq2.LoyaltyId = 'CK31041293225';

        subData.add(subscribeReq2);

        //Subscriber data for brand Id 1, create new contact
        subscribeReq3.brandId = '1';
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
        subscribeReq3.HomeStore = 'CO601';
        subscribeReq3.StoreOfCapture = 'other';
        subscribeReq3.SourceSystem = 'POS';
        subscribeReq3.LoyaltyId = 'TH31031293225';

        subData.add(subscribeReq3);


        return subData;
    }
    public static Contact createContact(A1CustomerProfileUpdate.Subscriber sub){
        Contact newCon = new Contact();
        newCon.LoyaltyId__c = sub.LoyaltyId;
        newCon.Brand_Id__c = sub.BrandId;
        newCon.FirstName = sub.FirstName;
        newCon.LastName = sub.LastName;
        newCon.MailingStreet = sub.Street;
        newCon.MailingCity = sub.City;
        newCon.MailingState = sub.State;
        newCon.MailingPostalCode = sub.ZIP;
        newCon.MailingCountry = sub.Country;
        newCon.Email = sub.Email;
        newCon.Phone = sub.PrimaryPhone;
        newCon.HomeStore__c = (sub.HomeStore);
        newCon.StoreOfCapture__c = (sub.StoreOfCapture);
        newCon.Source_System__c = (sub.SourceSystem);
        newCon.LoyaltyID__c = (sub.LoyaltyId);

        return newCon;
    }
    @isTest
    static void testUtilDateMethod(){
        String strDate = '20120323';
        Date dtDate = null;
        Test.startTest();
        dtDate = UtilityClass.strYYYMMDDtoDate(strDate);
        Test.stopTest();

        //System.assertEquals(Date.newInstance(2021,3,23),dtDate);
    }
    @isTest
    static void testA1CustomerProfileUpdateWithoutBrandvalue(){
        List<A1CustomerProfileUpdate.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        subData[0].BrandId = null;
        A1CustomerProfileUpdate.SubRequest subReq = new A1CustomerProfileUpdate.SubRequest();
        subReq.Count = '1';
        subReq.Subscribers = new List<A1CustomerProfileUpdate.Subscriber>{subData[0]};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String JsonMsg=JSON.serialize(subReq);

        req.requestURI = '/services/apexrest/A1subscribers/Update';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        A1CustomerProfileUpdate.SubResponse response =  A1CustomerProfileUpdate.doUpdate();
        Test.stopTest();
        system.assertNotEquals(null, response);
        system.assertEquals('INVALID_QUERY', response.Code);
        system.assertEquals('Missing required parameters:  BrandId or email', response.Message);
    }
    @isTest
    static void testA1CustomerProfileUpdateWithSubKey(){
        List<A1CustomerProfileUpdate.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[0].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[0]));
        insert contacts;
        subData[0].SubscriberKey = contacts[0].Id;
        subData[0].FirstName = 'test';

        A1CustomerProfileUpdate.SubRequest subReq = new A1CustomerProfileUpdate.SubRequest();
        subReq.Count = '1';
        subReq.Subscribers = new List<A1CustomerProfileUpdate.Subscriber>{subData[0]};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String JsonMsg=JSON.serialize(subReq);

        req.requestURI = '/services/apexrest/A1subscribers/Update';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        A1CustomerProfileUpdate.SubResponse response =  A1CustomerProfileUpdate.doUpdate();
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT FirstName FROM Contact WHERE Id=:subData[0].SubscriberKey];
        system.assertNotEquals(null, updatedContacts);
        system.assertEquals(1, updatedContacts.size());
        system.assertEquals('test', updatedContacts[0].FirstName);
    }
    @isTest
    static void testA1CustomerProfileUpdateWithBnE(){
        List<A1CustomerProfileUpdate.Subscriber> subData = generateSubscribesData();
        system.assertNotEquals(null, subData);
        system.assertEquals(null, subData[1].SubscriberKey);
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact(subData[1]));
        insert contacts;
        subData[1].FirstName = 'test';
        A1CustomerProfileUpdate.SubRequest subReq = new A1CustomerProfileUpdate.SubRequest();
        subReq.Count = '1';
        subReq.Subscribers = new List<A1CustomerProfileUpdate.Subscriber>{subData[1]};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String JsonMsg=JSON.serialize(subReq);

        req.requestURI = '/services/apexrest/A1subscribers/Update';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        A1CustomerProfileUpdate.SubResponse response =  A1CustomerProfileUpdate.doUpdate();
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT FirstName FROM Contact WHERE Brand_Id__c=:subData[1].BrandId AND Email=:subData[1].Email];
        system.assertNotEquals(null, updatedContacts);
        system.assertEquals(1, updatedContacts.size());
        system.assertEquals('test', updatedContacts[0].FirstName);
    }
    @isTest
    static void testA1CustomerProfileUpdate(){
        List<A1CustomerProfileUpdate.Subscriber> subData = generateSubscribesData();
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
        A1CustomerProfileUpdate.SubRequest subReq = new A1CustomerProfileUpdate.SubRequest();
        subReq.Count = '1';
        subReq.Subscribers = subData;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String JsonMsg=JSON.serialize(subReq);

        req.requestURI = '/services/apexrest/A1subscribers/Update';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.debug('res :'+res);
        A1CustomerProfileUpdate.SubResponse response =  A1CustomerProfileUpdate.doUpdate();
        system.debug('****res1: ' + response);
        Test.stopTest();
        system.assertEquals('OK',response.Code);
    }

}