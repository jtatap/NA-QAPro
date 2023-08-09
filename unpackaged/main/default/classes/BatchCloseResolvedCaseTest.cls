@isTest
private class BatchCloseResolvedCaseTest {
    
    /*@testsetup
    static void setup(){
        List<Case> caselist = new List<Case>();
        List<Case> updatedcaselist = new List<Case>();
        Map<String,Schema.RecordTypeInfo> RecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Id SupportRecordId = RecordTypes.get('Support_Case').getRecordTypeId();
        Id SupportReadOnlyRecordId = RecordTypes.get('Support_Case_Read_Only').getRecordTypeId();
        Integer GenericCaseClosedDays = Integer.valueOf(System.Label.GeneralCase_ClosedDays);
        
        Account acc = new Account(name='Account Name');
        Insert acc;
        
        Contact con = new Contact(Firstname='first '+ acc.Name, Lastname='last ', Brand_Id__c = '1', Email = 'firstname.lastname@nomail.com', AccountId = acc.Id);
        Insert con;
        
        GenericRecords__c genericContactRecord = new GenericRecords__c();
        genericContactRecord.Name = 'privacyContact';
        genericContactRecord.recordId__c = con.Id;
        insert genericContactRecord;
        
        for(Integer i=0;i<1;i++){
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
            testcase.Reason_Code__c='Corporate';
            testcase.Reason_Code_Details__c='Accepted Forms of Payment';
            if(math.mod(i,2)==0){
                //testcase.Type = 'Privacy';
                //testcase.RecordTypeId = PrivacyRecordId;
                testcase.Type = 'Product';
                testcase.RecordTypeId = SupportRecordId;  
            } else{
                testcase.Type = 'Product';
                testcase.RecordTypeId = SupportRecordId;               
            }
            caselist.add(testcase) ;
        }
        insert caselist;*/
        
     /*   for(case c: caselist){
            c.State_of_Residence__c='Resolved';
            updatedcaselist.add(c);
        } */
        
      //  update updatedcaselist;
    //}
    
    @testsetup
    public static void testSetup() {
        Map<String,Schema.RecordTypeInfo> RecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Id SupportRecordId = RecordTypes.get('Support_Case').getRecordTypeId();
        Integer GenericCaseClosedDays = Integer.valueOf(System.Label.GeneralCase_ClosedDays);
        
        List<Account> accLst = TestDataFactory.createAccount(1);
        Insert accLst;
        
        List<Contact> conLst = TestDataFactory.createContact(1);
        conLst[0].email = 'foo@example.com';
        conLst[0].lastName = 'generic contact ' + Math.random();
        conLst[0].AccountId = accLst[0].id;
        conLst[0].Brand_Id__c='9';
        conLst[0].FirstName = 'First';
        conLst[0].LastName = 'Last';
        Insert conLst;
        
        TestDataFactory.createGenericRecords(conLst[0].Id);
        
         List<Case> cseLst = TestDataFactory.createCases(1);
        
            cseLst[0].Origin = 'Email';
            cseLst[0].Status = 'Resolved';
            cseLst[0].ContactId = conLst[0].Id;
            cseLst[0].Brand__c = '1';
            cseLst[0].Subject = 'Test Case';
            cseLst[0].Description = 'Test Description';
            cseLst[0].SuppliedEmail = conLst[0].Email;
            cseLst[0].SuppliedName = conLst[0].FirstName + conLst[0].LastName;
            cseLst[0].Priority = 'Medium';
            cseLst[0].Reason_Code__c='Corporate';
            cseLst[0].Reason_Code_Details__c='Accepted Forms of Payment'; 
         	cseLst[0].Type = 'Product';
			cseLst[0].RecordTypeId = SupportRecordId;
        
        insert cseLst;
    }
    
    @istest
    private static void testmethod1(){
        Id SupportReadOnlyRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case_Read_Only').getRecordTypeId();
        Test.startTest();
        BatchCloseResolvedCase mybc = new BatchCloseResolvedCase();
        
        Id batchId =  Database.executeBatch(mybc);
        Test.stopTest();
        List<case> caselist = [SELECT Id, RecordTypeId, Status, Type from case];
        System.assertEquals(true, caselist[0].Status == 'Closed');
        System.assertEquals(true, caselist[0].RecordTypeId == SupportReadOnlyRecordId);
    }
    
}