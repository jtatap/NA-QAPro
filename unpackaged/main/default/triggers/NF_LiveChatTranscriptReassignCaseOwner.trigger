/**
 * Created by apoorvrajput on 10/6/20.
 */
trigger NF_LiveChatTranscriptReassignCaseOwner on LiveChatTranscript (after update) {
    Log.push('Entered in trigger>>');
    /*NF_ReassignCaseOwner.reassignCaseOwner(Trigger.newMap);

    //NASSC-3223 - Display visitor name after conversation close
    NF_UpdateTranscriptBodyWithContactName.updateBodyWithName(Trigger.newMap);*/
    TriggerDispatcher.run(new NF_LiveChatTranscriptTriggerHandler());
    Logger.logDebug();
}