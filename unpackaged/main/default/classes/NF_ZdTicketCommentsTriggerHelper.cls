public class NF_ZdTicketCommentsTriggerHelper {
    public static void handleBeforeInsert(List<ZdTicketComment__c> newList){
        List <String> PVHTicketIds = new List<String>();
        List <String> TnCTicketIds = new List<String>();
        List <Case> PVHParentCases = new List<Case>();   
        List <Case> TnCParentCases = new List<Case>();
        Map <string,Id> PVHCaseIdMap = new Map<string,Id>();
        Map <string,Id> TnCCaseIdMap = new Map<string,Id>();
        List <CaseComment> CaseCommentList = new List<CaseComment>();
        for (ZdTicketComment__c tc: newList){
            if (tc.ZdPVHParentTicketId__c!=null) PVHTicketIds.add(tc.ZdPVHParentTicketId__c);
            else if (tc.ZdTnCParentTicketId__c!=null) TnCTicketIds.add(tc.ZdTnCParentTicketId__c);
        }
        PVHParentCases = [select id, ZdPVHTicketId__c, ZdTnCTicketId__c  from Case where ZdPVHTicketId__c in :PVHTicketIds or ZdTnCTicketId__c in :TnCTicketIds];
        for(Case c: PVHParentCases){
            if (c.ZdPVHTicketId__c!=null) PVHCaseIdMap.put(c.ZdPVHTicketId__c, c.id);
            else if (c.ZdTnCTicketId__c!=null) TnCCaseIdMap.put(c.ZdTnCTicketId__c, c.id);
        }   
        for (ZdTicketComment__c tc: newList){
            CaseComment newCaseComment = new CaseComment();
            newCaseComment.CommentBody = tc.CommentBody__c;
            newCaseComment.isPublished = true;
            newCaseComment.CreatedDate = tc.created_at__c;
            if (tc.ZdPVHParentTicketId__c!=null) newCaseComment.ParentId = PVHCaseIdMap.get(tc.ZdPVHParentTicketId__c);
            else if (tc.ZdTnCParentTicketId__c!=null) newCaseComment.ParentId = TnCCaseIdMap.get(tc.ZdTnCParentTicketId__c);
            if (newCaseComment.ParentId!=null) CaseCommentList.add(newCaseComment);
        }
        if (CaseCommentList.size()>0) insert CaseCommentList;
        
    }
}