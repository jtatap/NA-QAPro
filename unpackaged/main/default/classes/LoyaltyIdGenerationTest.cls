@isTest
public class LoyaltyIdGenerationTest {

  @isTest public static void TestLoyaltyId() {
        // Test data setup
        Account acc = new Account();
        acc.Name = 'LoyaltyAccount';
        insert acc;

        Contact con = new Contact();
        Test.startTest();
        con.email = 'LoyaltyId@example.com';
        con.lastName = 'Loyaltycontact';
        con.AccountId = acc.id;
        con.LoyaltyID__c='';
        con.Brand_Id__c='1';
        insert con;
        con.LoyaltyID__c='';
        update con;
        con.Brand_Id__c='5';
        update con;
        Test.stopTest();
 }
    
}