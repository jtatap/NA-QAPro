/**
* @author Magnet360
*
* @date 2019
*
* @description Test Clas for EmailMessageTriggerHandler
*
* @see EmailMessageTriggerHandler
*/
@isTest
public class EmailMessageTriggerHandlerTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name='Test Account ABC');
        insert acc;

        Entitlement testEntitlement = new entitlement(name='Test Entilement',accountid=acc.id,type='Gateway Support', StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert testEntitlement;

        Entitlement testEntitlement1 = new entitlement(name='Test Entilement',accountid=acc.id,type='Gateway Support', StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert testEntitlement1;

        /*DML operation cannot be performed on SLAProcess Object (i.e. Entitlement Process).
        Need to rely on organization data. Retrieve the entry from organization and associate it to Entitlement.*/
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='1 Day (24 Hour Reply)' and IsActive = true LIMIT 1];
        if (lstEntitlementProcess.size()>0)
        {
            testEntitlement.SlaProcessId = lstEntitlementProcess[0].id;
            update testEntitlement;
        }


        //List<SlaProcess> lstEntitlementProcess1 = [SELECT Id, Name FROM SlaProcess WHERE Name='2 Day (48 Hour Reply)' and IsActive = true LIMIT 1];
        // if (lstEntitlementProcess1.size()>0)//
        {
            //  testEntitlement1.SlaProcessId = lstEntitlementProcess1[0].id;
            //  update testEntitlement1;
        }//

        contact con =new contact(LastName='TestName',Email='abc@gmail.com',Brand_Id__c='1');
        insert con;

        Case testCase = new Case(EntitlementId=testEntitlement.Id, SlaStartDate = System.now().addDays(-1), Subject='Test Milestome completion', Origin = 'Email' , suppliedEmail = 'testCase1@gmail.com' , ZdTnCUserId__c = '230000',ZdTnCTicketId__c = '3333999',Brand__c='1');
        insert testCase;

        Case testCase1 = new Case(EntitlementId=testEntitlement.Id, SlaStartDate = System.now().addDays(-1), Subject='Test Milestome completion', Origin = 'Email' , suppliedEmail = 'testCase2@gmail.com' ,parentid=testcase.id,Brand__c='1');
        insert testCase1;
    }


    private static testMethod void testCompleteMilestone()
    {

        Case testCase = [Select Id from Case where SuppliedEmail = 'testCase1@gmail.com'];
        Case testCase1 = [Select Id from Case where SuppliedEmail = 'testCase2@gmail.com'];


        //CaseMilestone testCaseMilestone = new CaseMilestone(CaseId = testCase.Id);
        //insert testCaseMilestone;mwec v

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'abc@gmail.com';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = testCase.Id;
        insert email;



        //For Child Case
        EmailMessage email1 = new EmailMessage();
        email1.FromAddress = 'abc@gmail.com';
        email1.Incoming = true;
        email1.ToAddress= 'test@abc.org';
        email1.Subject = 'Test email';
        email1.HtmlBody = 'Test email body';
        email1.ParentId = testCase1.Id;
        insert email1;


    }
    private static testMethod void testUpdateEmail()
    {

        Case testCase = [Select Id from Case where SuppliedEmail = 'testCase1@gmail.com'];


        //CaseMilestone testCaseMilestone = new CaseMilestone(CaseId = testCase.Id);
        //insert testCaseMilestone;mwec v

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'abc@gmail.com';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = testCase.Id;
        email.status = '0';
        insert email;

        email.subject = 'Update Email';
        email.status = '3';
        update email;




    }
    private static testMethod void testIncomingEmail()
    {

        Case testCase = [Select Id from Case where SuppliedEmail = 'testCase1@gmail.com'];


        //CaseMilestone testCaseMilestone = new CaseMilestone(CaseId = testCase.Id);
        //insert testCaseMilestone;mwec v

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'abc@gmail.com';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = testCase.Id;
        email.Incoming = true;
        email.status = '0';
        insert email;

        email.status = '3';
        update email;




    }
}