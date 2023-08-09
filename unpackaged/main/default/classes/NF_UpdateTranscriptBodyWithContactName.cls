/**
 * Created by samuel on 12/23/21.
 */

public with sharing class NF_UpdateTranscriptBodyWithContactName {
    public static boolean updateBodyWithName(Map<Id, LiveChatTranscript> liveChatTranscripts) {

        if (liveChatTranscripts == null || liveChatTranscripts.size() == 0) {
            return false;
        }

        List<LiveChatTranscript> transcriptsToUpdate = new List<LiveChatTranscript>{};
        for (Id chatTranscriptId : liveChatTranscripts.keySet()) {
            Log.push('chatTranscriptId>>>' + chatTranscriptId);
            LiveChatTranscript transcript = [
                SELECT Id, Status, Body, OwnerId, CaseId, ContactId, CreatedById
                FROM LiveChatTranscript
                WHERE Id = :chatTranscriptId
                LIMIT 1
            ];

            if (transcript?.Status == SYSTEM.LABEL.Completed) {
                // If the transcript is complete, update the body to include the visitor's name
                Contact contactToDrawNameFrom = [
                    SELECT FirstName, LastName
                    FROM Contact
                    WHERE Id =: transcript.ContactId
                    LIMIT 1
                ];

                if (contactToDrawNameFrom != null & transcript.Body.contains(SYSTEM.LABEL.Visitor)) {
                    transcript.Body = transcript.Body.replaceAll(SYSTEM.LABEL.Visitor, contactToDrawNameFrom.FirstName + ': ');
                    transcriptsToUpdate.add(transcript);
                }
            }
        }

        if (transcriptsToUpdate.size() > 0) {
            try {
                update transcriptsToUpdate;
                return true;
            }
            catch (Exception e) {
                Logger.logException(e);
            }
        }
        Logger.logDebug();
        return false;
    }
}