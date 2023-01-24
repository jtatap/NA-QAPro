/******************************************************************************
* @Description: Test Class for A1_MergeLoyaltyAccApexController
* @Author	  : Rounak P
* @Date		  : 25 Feb 2020
* @JIRA		  : NASSC-1472
*
******************************************************************************/ 
@isTest
public class A1_MergeLoyaltyAccApexControllerTest {
	@isTest 
    static void checkLoyalty() 
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
        listCases[0].Brand__c = '2';
        insert listCases;
        
        Case getCase = [Select Id from Case];
        A1_MergeLoyaltyAccApexController.checkIsLoyaltyApplicable(getCase.Id);
    }
}