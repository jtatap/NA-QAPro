@isTest
public class ZetaCustomerCaptureTest {
    public static List<Id> contactlist = new List<Id>();
    
    public static testmethod void testAccountCallout() {
    
        Id accountId;
        Id contactId;
        Contact contactObject;
        
        List<Account> accs = TestDataFactory.createAccount(1);
        for(Account acc : accs) {
           accountId  = acc.Id;
        }
        
        List<Contact> cons = TestDataFactory.createContact(2);
        for(Contact con : cons) {
            contactObject = con;
            
            contactObject.AccountId = accountId;
            contactObject.Channel__c = '1';
            contactObject.Source__c = 'manual';
            contactObject.Brand_Id__c = '1';
            contactObject.Channel__c = '1';
            contactObject.Source__c = 'manual';
            contactObject.Salutation__c = 'Mr.';
            contactObject.FirstName = 'TestFirstName';
            contactObject.MiddleName = 'TestMiddleName';
            contactObject.LastName = 'TestLastName';
            contactObject.MailingStreet = 'Test street \n test \n test';
            contactObject.MailingCity = 'TestCity';
            contactObject.MailingState = 'testSate';
            contactObject.MailingPostalCode = '90002';
            contactObject.MailingCountry = 'USA';
            contactObject.Email = 'test@test.com';
            contactObject.HomePhone = '1234512345';
            contactObject.MobilePhone = '1234567890';
            contactObject.EmailOptInStatus__c = 'Y';
            contactObject.SMSOptinStatus__c = 'Y';
            contactObject.HomeStore__c = 'abcd';
            contactObject.LoyaltyFlag__c = true;
            contactObject.DirectMailOptin__c = true;
            contactObject.Language__c = 'E';
            contactObject.StoreOfCapture__c = 'test';
            contactObject.Birthdate = date.ValueOf('1987-05-05');
            //contactObject.CreatedByMethod__c = 'UI';
            
            Insert contactObject;
            contactObject.CreatedByMethod__c = 'UI'; 
            contactlist.add(contactObject.Id);           
        }
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"ResponseMessage":"NEW CUSTOMER","EmailAddress":"test@test.com"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        ZetaCustomerCapture.sendCustomerData(contactlist);
    }
}