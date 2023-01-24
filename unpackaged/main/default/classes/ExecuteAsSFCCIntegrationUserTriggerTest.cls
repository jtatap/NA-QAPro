@isTest
public class ExecuteAsSFCCIntegrationUserTriggerTest {
	
    @isTest
    public static void testPlatformEvent(){
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Source_System__c = 'eComm';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '2';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.MailingStreet = 'c mailing scteet';
        con.MailingCity = 'ccity';
        con.MailingState = 'cstate';
        con.MailingPostalCode = 'c1234';
        con.MailingCountry = 'ccity';
        con.Email = 'testemail@nomail.com';
        con.Phone = '5555555555';
        con.HomePhone = '0987654321';
        con.MobilePhone = '7777777775';
        con.Birthdate = Date.newInstance(1990, 12, 30);       
        con.HomeStore__c = 'cLoc';
        con.LoyaltyFlag__c = false;
        con.EmailOptInStatus__c = 'N'; //false;
        con.SMSOptinStatus__c = 'N'; //false;
        con.WelcomeSource__c = '01';
        con.StoreOfCapture__c = 'cLoc';
        insert con;
        List<ExecuteAsSFCCIntegrationUser__e> publishEvents = new List<ExecuteAsSFCCIntegrationUser__e>();
        ExecuteAsSFCCIntegrationUser__e eve = new ExecuteAsSFCCIntegrationUser__e();
        eve.ContactId__c = con.Id ;
        publishEvents.add(eve);            
        System.debug('Entered here');
        if(publishEvents.size()>0){
            System.debug('Entered here');
            Test.startTest();
            	EventBus.publish(publishEvents);
            Test.stopTest();
        }
    }
    
}