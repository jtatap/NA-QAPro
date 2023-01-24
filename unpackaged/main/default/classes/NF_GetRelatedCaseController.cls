/**
 * @File Name          : NF_GetRelatedCaseController.cls
 * @Description        : This class will create a basic case.
 * @Author             : Manishi Kalra
 * @Created By         : NeuraFlash, LLC
**/
public class NF_GetRelatedCaseController {

    @AuraEnabled
    public static OutputWrapper getRelatedCase(String transId) {
        String recentCaseId = '';
        OutputWrapper out = new OutputWrapper();
        try{
            if(String.isNotBlank(transId)) {
                //get recent related case.
//                List<Case> caseList = [SELECT ID, CaseNumber, Subject//, Chat_Transcript__c
//                FROM Case
//                //WHERE Chat_Transcript__c =:transId
//                ORDER BY CreatedDate DESC
//                LIMIT 1];
//                if(!caseList.isEmpty()) {
//                    out.recentCaseId = caseList[0].Id;
//
//                }

                List<LiveChatTranscript> chatTranscriptList = [SELECT ID, ContactId, CaseId
                FROM LiveChatTranscript
                WHERE Id =: transId
                LIMIT 1];
                if(!chatTranscriptList.isEmpty()) {
                    out.recentCaseId = chatTranscriptList[0].CaseId;
                    out.recentContactId = chatTranscriptList[0].ContactId;
                }

            }
        }catch(Exception e) {
            throw new AuraHandledException('Exception caught:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');
        }
        return out;

    }

    public class OutputWrapper {
        @AuraEnabled
        public string recentCaseId;

        @AuraEnabled
        public string recentContactId;

    }
}