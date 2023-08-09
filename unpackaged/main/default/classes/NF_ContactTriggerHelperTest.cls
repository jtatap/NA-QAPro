@isTest
public class NF_ContactTriggerHelperTest {

   @isTest
   public static void handleBeforeUpdateTest(){
       Account acc = new Account();
        acc.Name = 'generic Account11' + Math.random();
        
        insert acc;
      // acc.Customer_Id__c = 'C04013020814';
       update acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='1';
       	con.Customer_Id__c = 'C04013020812';
        
        insert con;
       Map<Id,Contact> oldMap = new Map<Id,Contact>{con.Id => con};
       con.email = 'foo1@example.com';
       
       update con;
        
    }
}