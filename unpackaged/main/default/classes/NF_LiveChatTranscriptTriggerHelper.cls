public class NF_LiveChatTranscriptTriggerHelper {
	public static void handleAfterUpdate(Map<Id,LiveChatTranscript> newMap){
        NF_ReassignCaseOwner.reassignCaseOwner(newMap);
        NF_UpdateTranscriptBodyWithContactName.updateBodyWithName(newMap);
    }
}