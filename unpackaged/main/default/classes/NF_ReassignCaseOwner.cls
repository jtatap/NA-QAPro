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
             If (UserInfo.getName()!='MuleSoft APIUser'){        
                Log.push('chatTranscriptId>>>' + chatTranscriptId);
                LiveChatTranscript[] transcripts = [SELECT Id, Status, OwnerId,CaseId,CreatedById,Brand__c FROM LiveChatTranscript WHERE Id = :chatTranscriptId limit 1];
                LiveChatTranscript transcript = transcripts[0];
                Case c = new Case();
                if(transcript.Status == SYSTEM.LABEL.Missed || transcript.Status == SYSTEM.LABEL.Completed || transcript.Status == SYSTEM.LABEL.Dropped) {
                    String queueDevName;
                    //RC 7.13 Updating to assign to brand specific queue. Related to defect NASSC#3370
                    if(transcript.Brand__c == SYSTEM.LABEL.Calvin_Klein){
                        queueDevName = SYSTEM.LABEL.Calvin_Klein_Ecomm;
                    }
                    if(transcript.Brand__c == SYSTEM.LABEL.Tommy_Hilfiger){
                        queueDevName = SYSTEM.LABEL.Tommy_Hilfiger_eComm;
                    }
                    Group caseQueue = NF_Util.getQueue(queueDevName);
                    Log.push('Case Queue is :'+ caseQueue);
                    if (transcript.CaseId != null) {
                        c = [SELECT CaseNumber,Status, OwnerId FROM Case WHERE Id = :transcript.CaseId];
                        Log.push('case is :'+ c);
                        User[] platUser = [SELECT Id, Name FROM User WHERE Name =:SYSTEM.LABEL.Platform_Integration_User  LIMIT 1];
                        if(caseQueue != null && c.OwnerId == platUser[0].Id){
                            Log.push('assining casequeue :'+ caseQueue);
                            c.OwnerId = caseQueue.Id;
                            cases.add(c);
                        }
                    }
                }
                else {
                    if (transcript.CreatedById != transcript.OwnerId) {
                        Id createdById = transcript.CreatedById;
                        Log.push('createdById, platformIntId>>>' + createdById + ',' +platformIntegrationUser.Id);
                        if (createdById == platformIntegrationUser.Id) {
                            Log.push('liveChatTranscripts.get(chatTranscriptId).CaseId>>>'+liveChatTranscripts.get(chatTranscriptId).CaseId + ',' +liveChatTranscripts.get(chatTranscriptId).OwnerId);
                            if (liveChatTranscripts.get(chatTranscriptId).CaseId != null) {
                                c.Id = liveChatTranscripts.get(chatTranscriptId).CaseId;
                                c.OwnerId = liveChatTranscripts.get(chatTranscriptId).OwnerId;
                                cases.add(c);
                            }
                        }
                    }
                }
            }
            }
            Logger.logDebug();
            if (cases.size() > 0) {
                try {
                    update cases;
                    return true;
                }
                catch(Exception e){
                    Logger.logException(e);
                }

            }
        }
      
        catch(Exception e){
            Logger.logException(e);
        }

     
        return false;
    }
  
}