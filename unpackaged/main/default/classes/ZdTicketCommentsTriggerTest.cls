@isTest
public class ZdTicketCommentsTriggerTest {

    @isTest
    static void testPVHComment(){

        Id zdPVHRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdPVH').getRecordTypeId();
        Id zdTnCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdTnC').getRecordTypeId();

        Case c1 = new Case();
        c1.ZdPVHTicketId__c = 'PVHTicket111';
        c1.RecordTypeId = zdPVHRecordTypeId;
        insert c1;

        Case c2 = new Case();
        c2.ZdTnCTicketId__c = 'TnCTicket111';

        c2.RecordTypeId = zdTnCRecordTypeId;
        insert c2;

        List<ZdTicketComment__c> tcList = new List<ZdTicketComment__c>();
        Test.startTest();
        ZdTicketComment__c tc2 = new ZdTicketComment__c();
        tc2.ZdTnCParentTicketId__c = 'TnCTicket111';
        tc2.CommentBody__c = 'some body text';
        tc2.ZdTnCCommentId__c = 'for TnCTicket111';
        tc2.created_at__c = System.now();
        tcList.add(tc2);

        ZdTicketComment__c tc1 = new ZdTicketComment__c();
        tc1.ZdPVHParentTicketId__c = 'PVHTicket111';
        tc1.CommentBody__c = 'some body text';
        tc1.ZdPVHCommentId__c = 'for PVHTicket111';
        tc1.created_at__c = System.now();
        tcList.add(tc1);
        insert tcList;
        Test.stopTest();
        List<CaseComment> CaseCommentList = [select id, ParentId from CaseComment];
        System.assertEquals(c2.id, CaseCommentList[0].ParentId);

        System.assertEquals(c1.id, CaseCommentList[1].ParentId);


    }


}