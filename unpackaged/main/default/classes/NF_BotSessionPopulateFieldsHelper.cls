public class NF_BotSessionPopulateFieldsHelper {
    public static void handleAfterInsert(Map<id,ebotdata__Bot_Session__c> botSessions){
        try {
            Set<Id> liveChatTranscriptIds = new Set<Id>();
            Map<Id, LiveChatTranscript> transcripts = new Map<Id, LiveChatTranscript>();
            
            List<ebotdata__Bot_Session__c> sessionList = [SELECT Id, Brand__c,ebotdata__Live_Chat_Transcript__c
                                                          FROM ebotdata__Bot_Session__c
                                                          WHERE Id IN :botSessions.keySet()];
            
            //First, get all the transcript IDs we need from the sessions
            List<ebotdata__Bot_Session__c> sessionsToUpdate = new List<ebotdata__Bot_Session__c>();
            //for (Id sessionId : botSessions.keySet()) {
            for(ebotdata__Bot_Session__c session : sessionList){
                //ebotdata__Bot_Session__c session = botSessions.get(sessionId);
                Log.push('>>NF_BotSessionPopulateFields.updateFields: session=' + session);
                liveChatTranscriptIds.add(session.ebotdata__Live_Chat_Transcript__c);
            }
            //Get all the transcripts
            transcripts = new Map<Id, LiveChatTranscript>([SELECT Id, ChatKey, Brand__c
                                                           FROM LiveChatTranscript
                                                           WHERE Id IN :liveChatTranscriptIds]);
            Log.push('>>NF_BotSessionPopulateFields.updateFields: transcripts=' + transcripts);
            
            //Go through the sessions again, and update with the corresponding transcript fields
            //for (Id sessionId : botSessions.keySet()) {
            //    ebotdata__Bot_Session__c session = botSessions.get(sessionId);
            for(ebotdata__Bot_Session__c session : sessionList){
                Log.push('>>NF_BotSessionPopulateFields.updateFields: session=' + session);
                if (session.ebotdata__Live_Chat_Transcript__c != null) {
                    LiveChatTranscript transcript = transcripts.get(session.ebotdata__Live_Chat_Transcript__c);
                    Log.push('>>NF_BotSessionPopulateFields.updateFields: retrieved transcript=' + session);
                    
                    if (session != null && transcript != null && String.isNotEmpty(transcript.Brand__c)) {
                        Log.push('>>NF_BotSessionPopulateFields.updateFields: updating Brand__c');
                        session.Brand__c = transcript.Brand__c;
                    }
                    sessionsToUpdate.add(session);
                }
            }
            
            Log.push('>>NF_BotSessionPopulateFields.updateFields: sessionsToUpdate=' + sessionsToUpdate);
            
            if (sessionsToUpdate.size() > 0) {
                
                update sessionsToUpdate;
            }
            Logger.logDebug();
        }
        catch(Exception e){
            Logger.logException(e);
        }
    }
}