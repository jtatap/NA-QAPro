@isTest
public class TestCallDetailsTrigger {
    
    @testSetup
    static void testDataSetup(){
       List<NF_CreateCase.Input> inputs = new List<NF_CreateCase.Input>();
        NF_CreateCase.Input input = new NF_CreateCase.Input();
        List<NF_CreateCase.Output> outputs;
       	Account acc = new Account();
        acc.Name = 'generic Account';
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact';
        con.AccountId = acc.id;
        con.Brand_Id__c = '1';
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = con.Id
        );
        insert genRec;
       
       input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.email='testemail1@email.com';
        input.brand='Calvin Klein';
        input.firstName = 'test';
        input.lastName = 'test';
        input.agentAvailable=false;
        input.reason = 'just a test';
        inputs.add(input);
        GenericRecords__c genericContactRecord = GenericRecords__c.getValues(Constants.privacyContactGenericRecordSettingName);
        outputs = NF_CreateCase.createCase(inputs);
       	
    }
    
   @isTest
   public static void testCallDetailTrigger(){
        
       Case testCase = [Select Id from Case LIMIT 1 ]; 
        CallDetail__C callDetail = new CallDetail__C();
        callDetail.Case__c = testCase.id;//associate case with call detail
       Test.startTest();
        insert callDetail;//after call detail is inserted, trigger should clear call details on case
        Case updatedCase =[select id,SkillName__c,CallDirection__c from Case where id = :testCase.id];
        
        System.assert(updatedCase.SkillName__c == null);
        System.assert(updatedCase.CallDirection__c == null);
       Test.stopTest();
    }

}