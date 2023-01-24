@isTest
public class TestCallDetailsTrigger {
    
   @isTest
   public static void testCallDetailTrigger(){
        
        Case testCase = new Case();
        testCase.SkillName__c = 'test';
        testCase.CallDirection__c = 'Inbound';
        testCase.CallDurationInSeconds__c = 10;
        testCase.CallStartTime__c = System.now();
        testCase.CallEndTime__c = System.now();
        insert testCase;
        CallDetail__C callDetail = new CallDetail__C();
        callDetail.Case__c = testCase.id;//associate case with call detail
        insert callDetail;//after call detail is inserted, trigger should clear call details on case
        Case updatedCase =[select id,SkillName__c,CallDirection__c from Case where id = :testCase.id];
        System.debug('updatedCase details :'+updatedCase);
        System.assert(updatedCase.SkillName__c == null);
        System.assert(updatedCase.CallDirection__c == null);
    }

}