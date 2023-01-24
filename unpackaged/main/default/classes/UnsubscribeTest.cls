@isTest
private class UnsubscribeTest {

    @TestSetup
    private static void TestData(){
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        list<Contact> conList = new list<Contact>();
        
        //Creating Test data, 3 contact with 2 brand with EmailOptInStatus__c = true
        //--Brand 10 - contact1@nomail.com,contact2@nomail.com
        //--Brand 1 - contact2@nomail.com
        
        for(Integer i=1;i<=3;i++) {

            Contact cont = new Contact();
            cont.FirstName = 'Contact';
            cont.LastName = 'lname ' + i;
            cont.Brand_Id__c = '10';
            cont.Email = 'contact' + i + '@nomail.com';
            cont.HasOptedOutOfEmail = false;
            cont.EmailOptInStatus__c = 'Y'; // true;
            cont.AccountId = acct.Id;
            conList.add(cont);
        }
            conList[2].Brand_Id__c = '1';
            conList[2].Email = 'contact2@nomail.com';

        insert conList;
    }
    
    @isTest static void testUnsubscribe(){
        Unsubscribe.UnSubRequest unReq = new Unsubscribe.UnSubRequest();
        String requestString = '{"Count":"2","Unsubscribes":[{"BrandId":"10","Email":"contact1@nomail.com"},{"BrandId":"10","Email":"contact2@nomail.com"}]}';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/subscribers/Unsubscribe';  //Request URL
        req.httpMethod = 'POST';                            //HTTP Request Type
        req.requestBody = Blob.valueof(requestString);
        RestContext.request = req;
        RestContext.response= res;

        Unsubscribe.doUnsubscribe();
        

        
        Contact con1Updated = [SELECT Id, EmailOptInStatus__c FROM Contact WHERE Email = 'contact1@nomail.com'];
        
        System.assertEquals(con1Updated.EmailOptInStatus__c,'N');

        Contact con2Updated = [SELECT Id, EmailOptInStatus__c FROM Contact WHERE Email = 'contact2@nomail.com' AND Brand_Id__c = '10' ];
        
        System.assertEquals(con2Updated.EmailOptInStatus__c,'N');

        Contact con3Updated = [SELECT Id, EmailOptInStatus__c FROM Contact WHERE Email = 'contact2@nomail.com' AND Brand_Id__c = '1' ];
        
        System.assertEquals(con3Updated.EmailOptInStatus__c,'Y');
        
        Test.stopTest();

    }

    
}