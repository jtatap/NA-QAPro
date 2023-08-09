/**
 * Created by apoorvrajput on 10/21/20.
 */

trigger NF_BotSessionPopulateFields on ebotdata__Bot_Session__c (after insert) {
    Log.push('NF_BotSessionPopulateFields');
    /*if(trigger.isAfter && trigger.isInsert) {
        NF_BotSessionPopulateFields.updateFields(Trigger.newMap);
    }*/
    TriggerDispatcher.run(new NF_BotSessionPopulateFieldsHandler());
    Logger.logDebug();

}