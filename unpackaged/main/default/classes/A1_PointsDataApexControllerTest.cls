/******************************************************************************
* @Description: Test Class to test A1_PointsDataApexController
* @Author	  : Rounak P
* @Date		  : 09 JAN 2019
* @JIRA		  : NASSC-1146
*
******************************************************************************/ 
@isTest
public class A1_PointsDataApexControllerTest {
    @isTest 
    static void checkPendingPointsStatusANDCaseRecordTest() 
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
        listCases[0].PendingPointsAdjustment__c = false;
        listCases[0].Brand__c = '2';
        insert listCases;
        
        Case getCase = [Select Id,PendingPointsAdjustment__c from Case];
        A1_PointsDataApexController.checkPendingPointsStatus(getCase.Id);
        A1_PointsDataApexController.getPoints(getCase.Id);
    }
    
    @isTest 
    static void checkContactRecordTest() 
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
        A1_PointsDataApexController.getPoints(getContact.Id);
    }
}