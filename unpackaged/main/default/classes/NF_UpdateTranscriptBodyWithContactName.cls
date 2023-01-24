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
            System.debug('chatTranscriptId>>>' + chatTranscriptId);
            LiveChatTranscript transcript = [
                SELECT Id, Status, Body, OwnerId, CaseId, ContactId, CreatedById
                FROM LiveChatTranscript
                WHERE Id = :chatTranscriptId
                LIMIT 1
            ];

            if (transcript?.Status == 'Completed') {
                // If the transcript is complete, update the body to include the visitor's name
                Contact contactToDrawNameFrom = [
                    SELECT FirstName, LastName
                    FROM Contact
                    WHERE Id =: transcript.ContactId
                    LIMIT 1
                ];

                if (contactToDrawNameFrom != null & transcript.Body.contains('Visitor: ')) {
                    transcript.Body = transcript.Body.replaceAll('Visitor: ', contactToDrawNameFrom.FirstName + ': ');
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
                System.debug('>>> Exception occurred trying to update transcript body: ' + e.getStackTraceString());
            }
        }
        return false;
    }
}