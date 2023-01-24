@isTest
private class SchedulableBatchCloseResolvedCaseTest {
    
    @testsetup
    static void setup(){
        List<Case> caselist = new List<Case>();
        List<Case> updatedcaselist = new List<Case>();
        Map<String,Schema.RecordTypeInfo> RecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        //Id PrivacyRecordId = RecordTypes.get('Privacy_Request').getRecordTypeId();
        //Id PrivacyReadOnlyRecordId = RecordTypes.get('Privacy_Request_Read_Only').getRecordTypeId();
        Id SupportRecordId = RecordTypes.get('Support_Case').getRecordTypeId();
        Id SupportReadOnlyRecordId = RecordTypes.get('Support_Case_Read_Only').getRecordTypeId();
        Integer GenericCaseClosedDays = Integer.valueOf(System.Label.GeneralCase_ClosedDays);
        //Integer PrivacyCaseClosedDays = Integer.valueOf(System.Label.PrivacyCase_ClosedDays);
        
        Account acc = new Account(name='Account Name');
        Insert acc;
        
        Contact con = new Contact(Firstname='first '+ acc.Name, Lastname='last ', Brand_Id__c = '1', Email = 'firstname.lastname@nomail.com', AccountId = acc.Id);
        Insert con;
        
        for(Integer i=0;i<10;i++){
            Case testcase = new Case();
            testcase.Origin = 'Email';
            testcase.Status = 'Resolved';
            testcase.ContactId = con.Id;
            testcase.Brand__c = '1';
            testcase.Subject = 'Test Case'+i;
            testcase.Description = 'Test Description'+i;
            testcase.SuppliedEmail = con.Email;
            testcase.SuppliedName = con.FirstName + con.LastName;
            testcase.Priority = 'Medium';
           // testcase.Reason_Code__c='Corporate';
            //testcase.Reason_Code_Details__c='Accepted Forms of Payment';
            if(math.mod(i,2)==0){
                testcase.Type = 'Product';
                testcase.RecordTypeId = SupportRecordId;   
                //testcase.Type = 'Privacy';
                //testcase.RecordTypeId = PrivacyRecordId;
            } else{
                testcase.Type = 'Product';
                testcase.RecordTypeId = SupportRecordId;               
            }
            caselist.add(testcase) ;
        }
        insert caselist;
    }
    
    
    @isTest
    static void scheduleTest(){
        //Dummy CRON expression: midnight on July 25.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 25 7 ? 2022';
        Test.startTest();
        String jobId = System.schedule('ScheduleBatchCloseResolved',  CRON_EXP, new SchedulableBatchCloseResolvedCase());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest(); 
        ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.debug('Ct times triggered.: '+ct.NextFireTime);
        System.assertEquals('2022-07-25 00:00:00', String.valueOf(ct.NextFireTime));
    }
    
}