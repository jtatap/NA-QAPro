/**
 * Created by apoorvrajput on 10/21/20.
 */

trigger NF_BotSessionPopulateFields on ebotdata__Bot_Session__c (after insert) {
    System.debug('NF_BotSessionPopulateFields');
    if(trigger.isAfter && trigger.isInsert) {
        NF_BotSessionPopulateFields.updateFields(Trigger.newMap);
    }

}