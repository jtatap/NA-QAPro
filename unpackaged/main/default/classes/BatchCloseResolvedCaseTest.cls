@isTest
private class BatchCloseResolvedCaseTest {
    
    @testsetup
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
            //testcase.Reason_Code__c='Corporate';
            //testcase.Reason_Code_Details__c='Accepted Forms of Payment';
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
        insert caselist;
        
     /*   for(case c: caselist){
            c.State_of_Residence__c='Resolved';
            updatedcaselist.add(c);
        } */
        
      //  update updatedcaselist;
    }
    
    @istest
    private static void testmethod1(){
        List<case> caselist = [SELECT Id, RecordTypeId, Type from case];
        System.debug('caselist size: '+caselist.size());
        System.debug('caselist: '+caselist);
        Test.startTest();
        BatchCloseResolvedCase mybc = new BatchCloseResolvedCase();
        Id batchId =  Database.executeBatch(mybc);
        Test.stopTest();
    }
}