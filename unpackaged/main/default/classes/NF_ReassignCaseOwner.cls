//used for Bot Cases
public with sharing class NF_ReassignCaseOwner {
    public static boolean reassignCaseOwner(Map<Id, LiveChatTranscript> liveChatTranscripts){

        if(liveChatTranscripts == null || liveChatTranscripts.size() == 0){
            return false;
        }
        User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();
        try{
            List<Case> cases = new List<Case>();
            for (Id chatTranscriptId : liveChatTranscripts.keySet()) {
                System.debug('chatTranscriptId>>>' + chatTranscriptId);
                LiveChatTranscript[] transcripts = [SELECT Id, Status, OwnerId,CaseId,CreatedById,Brand__c FROM LiveChatTranscript WHERE Id = :chatTranscriptId limit 1];
                LiveChatTranscript transcript = transcripts[0];
                Case c = new Case();
                if(transcript.Status == 'Missed' || transcript.Status == 'Completed' || transcript.Status == 'Dropped') {
                    String queueDevName;
                    //RC 7.13 Updating to assign to brand specific queue
                    if(transcript.Brand__c == 'Calvin Klein'){
                        queueDevName = 'Calvin_Klein_Ecomm';
                    }
                    if(transcript.Brand__c == 'Tommy Hilfiger'){
                        queueDevName = 'Tommy_Hilfiger_eComm';
                    }
                    Group caseQueue = NF_Util.getQueue(queueDevName);
                    System.debug('Case Queue is :'+ caseQueue);
                    if (transcript.CaseId != null) {
                        c = [SELECT CaseNumber, OwnerId FROM Case WHERE Id = :transcript.CaseId];
                        System.debug('case is :'+ c);
                        User[] platUser = [SELECT Id, Name FROM User WHERE Name = 'Platform Integration User' LIMIT 1];
                        if(caseQueue != null && c.OwnerId == platUser[0].Id){
                            System.debug('assining casequeue :'+ caseQueue);
                            c.OwnerId = caseQueue.Id;
                            cases.add(c);
                        }
                    }
                }
                else {
                    if (transcript.CreatedById != transcript.OwnerId) {
                        Id createdById = transcript.CreatedById;
                        System.debug('createdById, platformIntId>>>' + createdById + ',' +platformIntegrationUser.Id);
                        if (createdById == platformIntegrationUser.Id) {
                            System.debug('liveChatTranscripts.get(chatTranscriptId).CaseId>>>'+liveChatTranscripts.get(chatTranscriptId).CaseId + ',' +liveChatTranscripts.get(chatTranscriptId).OwnerId);
                            if (liveChatTranscripts.get(chatTranscriptId).CaseId != null) {
                                c.Id = liveChatTranscripts.get(chatTranscriptId).CaseId;
                                c.OwnerId = liveChatTranscripts.get(chatTranscriptId).OwnerId;
                                cases.add(c);
                            }
                        }
                    }
                }

            }
            if (cases.size() > 0) {
                try {
                    update cases;
                    return true;
                }
                catch(Exception e){
                    System.debug('Exception occured while updating the case>>>>'+e.getStackTraceString());
                }

            }
        }
        catch(Exception e){
            System.debug('Exception occured>>>>'+e.getStackTraceString());
        }

        return false;
    }
}