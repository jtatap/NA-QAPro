/******************************************************************************
* @Description: Test Class to test A1_RewardsDataApexController
* @Author	  : Rounak P
* @Date		  : 26:12.2019
* @JIRA		  : NASSC-1176,1178,1180
*
******************************************************************************/ 
@isTest
public class A1_RewardsDataApexControllerTest {
    
    @isTest 
    static void checkOnContact() 
    {	
        List<Reward__c> listRewards = TestDataFactory.createRewards(1);
        List<Reward__c> listRewardsUpdated = new List<Reward__c>();
        for(Reward__c rew : listRewards){
            rew.ExpireDate__c = System.now();
            listRewardsUpdated.add(rew);
        }
        insert listRewardsUpdated;
 
        List<Contact> listContact = TestDataFactory.createContact(1);
        List<Contact> listUpdateContact = new List<Contact>();
        for(Contact con : listContact){
            con.LoyaltyID__c = 'C0021733313';
            con.Brand_Id__c = '2';
            listUpdateContact.add(con);
        }
        
        insert listUpdateContact;
        
        Contact getContact = [Select Id,LoyaltyID__c,Brand_Id__c from Contact];
    
        A1_RewardsDataApexController.getLoyaltyId(getContact.Id);
        
    }
    
    @isTest 
    static void checkOnCase() 
    {	
        List<Contact> listContact = TestDataFactory.createContact(1);
        List<Contact> listUpdateContact = new List<Contact>();
        for(Contact con : listContact){
            con.LoyaltyID__c = 'C0021733313';
            con.Brand_Id__c = '2';
            listUpdateContact.add(con);
        }
        
        insert listUpdateContact;
        
        Contact getContact = [Select Id,LoyaltyID__c,Brand_Id__c from Contact];
        List<Case> listCases = TestDataFactory.createCases(1);
        listCases[0].contactId = getContact.Id;
        insert listCases;
        
        Case getCase = [Select Id from Case];
        A1_RewardsDataApexController.getLoyaltyId(getCase.Id);
        
    }
    
}