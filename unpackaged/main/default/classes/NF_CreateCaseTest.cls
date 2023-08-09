/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_CreateCaseTest {
    
    @testSetup
    public static void setupData() {
        List<Account> genAcc = TestDataFactory.createAccount(1);
        genAcc[0].Name = 'generic Account' + Math.random();
        insert genAcc;
        
        List<Contact> genCon = TestDataFactory.createContact(1);
        genCon[0].email = 'foo@example.com';
        genCon[0].lastName = 'generic contact ' + Math.random();
        genCon[0].AccountId = genAcc[0].id;
        genCon[0].Brand_Id__c='9';
        insert genCon;
        
        TestDataFactory.createGenericRecords(genAcc[0].Id);
        TestDataFactory.createGenericRecords(genCon[0].Id);
        
        List<Account> accLst = TestDataFactory.createAccount(1);
        insert accLst;
        
        List<Contact> conLst = TestDataFactory.createContact(1);
        conLst[0].AccountId = accLst[0].Id;
        conLst[0].email = 'test@test.com';
        conLst[0].lastName = 'generic contact ' + Math.random();
        conLst[0].Brand_Id__c = '1';
        insert conLst;
        
        List<Case> parentCaseLst = TestDataFactory.createCases(1);
        parentCaseLst[0].Type = 'Support';
        parentCaseLst[0].Status = 'New';
        parentCaseLst[0].ContactId=conLst[0].id;
        parentCaseLst[0].AccountId=accLst[0].id;
        parentCaseLst[0].Brand__c='1';
        parentCaseLst[0].SuppliedEmail='test@gmail.com';
        insert parentCaseLst;
        
        LiveChatTranscript liveChatTranscript = TestDataFactory.createLiveChatTranscript('Calvin Klein','someChatKey');
        liveChatTranscript.CaseId = parentCaseLst[0].Id;
        liveChatTranscript.ContactId = conLst[0].Id;
        liveChatTranscript.AccountId = accLst[0].Id;
        insert liveChatTranscript;
        
        
        
    }
    
    public static List<NF_CreateCase.Input> createInput() {
        List<NF_CreateCase.Input> inputs = new List<NF_CreateCase.Input>();
        NF_CreateCase.Input input = new NF_CreateCase.Input();
       
        input.chatKey = 'someChatKey';
        input.email='testemail1@email.com';
        input.brand='Calvin Klein';
        input.firstName = 'test';
        input.lastName = 'test';
        input.agentAvailable=false;
        input.reason = 'just a test';
        input.existingCase = true;
        inputs.add(input);
        return inputs;
    }

    @IsTest
    static void test1GetRamdomResponse() {
        List<NF_CreateCase.Output> outputs = NF_CreateCase.createCase(NF_CreateCaseTest.createInput());
        System.assertEquals(false,outputs[0].newCase);
    }
    
    @isTest
    public static void testNewCaseCreate() {
         List<NF_CreateCase.Input> createCaseInput = NF_CreateCaseTest.createInput();
         createCaseInput[0].existingCase = null;
         createCaseInput[0].orderNumber = 'We know it';
         List<NF_CreateCase.Output> outputs = NF_CreateCase.createCase(createCaseInput);
         System.assertEquals(true,outputs[0].newCase);
    }
}