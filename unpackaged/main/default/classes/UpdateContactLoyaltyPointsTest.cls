@isTest
public class UpdateContactLoyaltyPointsTest {

    @isTest static void testdoSignup(){
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        List<Contact> conList = new List<Contact>();
        for(Integer i=1;i<=5;i++){
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
            con.Email = 'testemail@nomail.com'+i;
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
            con.LoyaltyID__c = 'C0000001'+i;
            conList.add(con);
        }
        insert conList;
        Set<String> emailIds = new Set<String>();
        integer J = 1;
        List<ContactStaging2__c> cs2List = new  List<ContactStaging2__c>();
        for(contact con: conList){
            ContactStaging2__c objContStg =new ContactStaging2__c();
            objContStg.Loyalty_ID__c = con.LoyaltyID__c;
            objContStg.Point_Balance__c = j;
            objContStg.Brand_ID__c = '2';
            objContStg.IsProcessed__c = false;
            objContStg.ForPointBalance__c = true;
            j = j+1;
			cs2List.add(objContStg);
        }
        
        insert cs2List;
        
        Test.startTest();
        UpdateContactLoyaltyPoints uclp = new UpdateContactLoyaltyPoints();
		database.executeBatch(uclp);
        Test.stopTest();
    }
}