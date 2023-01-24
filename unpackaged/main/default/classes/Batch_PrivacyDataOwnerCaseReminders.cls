/**
* @author Magnet360
* @date 2019
*
* @group Case
* @group-content ../../ApexDocContent/Case.htm
*
* @description Batch class to send data owner reminder emails once they have
* been open longer than the time set in custom settings
* Called hourly from SchedulableBatch_PrivacyIntervalActions
*/
global class Batch_PrivacyDataOwnerCaseReminders implements Database.Batchable <sObject>{

    global List<Case> start(Database.BatchableContext bc){
        System.debug('===starting data owners?');
        Privacy_Intervals__c orgInterval;
        Integer dataOwnerReminderIntervalHours;
        List<Integer> dataOwnerReminderIntervalMatchingValues = new List<Integer>();

        orgInterval = Privacy_Intervals__c.getValues(Constants.privacyIntervalSettingName);
        dataOwnerReminderIntervalHours = Integer.valueOf(orgInterval.reminderDataOwnerInterval__c);
        Double totalReminders = Math.floor(Integer.valueOf(orgInterval.maxDataOwnerTime__c) / dataOwnerReminderIntervalHours);
        for (Integer i = 1; i <= totalReminders; i++) {
            dataOwnerReminderIntervalMatchingValues.add(dataOwnerReminderIntervalHours*i);
        }
        System.debug('===batch settings' + dataOwnerReminderIntervalMatchingValues + dataOwnerReminderIntervalMatchingValues + dataOwnerReminderIntervalHours);

        return [Select Id, Status, Brand__c, SuppliedEmail, ContactId, Data_Owner__r.Email, Data_Owner__r.Additional_Email_1__c, Data_Owner__r.Additional_Email_2__c,Data_Owner__r.Additional_Email_3__c,Data_Owner__r.Additional_Email_4__c, Hours_Since_Creation__c, Brand_Privacy_OWA_Name__c, Parent.Sub_Type__c, Privacy_Escalation_Email__c From Case Where Type = :Constants.privacyCaseType And Sub_Type__c = :Constants.dataOwnerRequestSubType And Hours_Since_Creation__c In :dataOwnerReminderIntervalMatchingValues And Status Not In :Constants.privacyCaseCompletedStatuses];
    }

    global void execute(Database.BatchableContext bc, List<Case> cases){
        PrivacyEmailHandler emailHandler = new PrivacyEmailHandler();
        Integer escalationHours = Integer.valueOf(Privacy_Intervals__c.getValues(Constants.privacyIntervalSettingName).CaseEscalationHours__c);

        System.debug('===dataOwnerReminderCases' + cases);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (Case cse : cases) {
            List<String> ccAddresses = new List<String>();
            if (String.isNotBlank(cse.Data_Owner__r.Additional_Email_1__c)) ccAddresses.add(cse.Data_Owner__r.Additional_Email_1__c);
            if (String.isNotBlank(cse.Data_Owner__r.Additional_Email_2__c)) ccAddresses.add(cse.Data_Owner__r.Additional_Email_2__c);
            if (String.isNotBlank(cse.Data_Owner__r.Additional_Email_3__c)) ccAddresses.add(cse.Data_Owner__r.Additional_Email_3__c);
            if (String.isNotBlank(cse.Data_Owner__r.Additional_Email_4__c)) ccAddresses.add(cse.Data_Owner__r.Additional_Email_4__c);
            if (cse.Hours_Since_Creation__c >= escalationHours) {
                String emailTemplate;
                if (cse.Parent.Sub_Type__c == Constants.deletionRequestSubType) {
                    emailTemplate = Constants.deletionDataOwnerEscalationEmail;
                }else if (cse.Parent.Sub_Type__c == Constants.rectifyRequestSubType) {
                    emailTemplate = Constants.updationDataOwnerEscalationEmail;
                }else if (cse.Parent.Sub_Type__c == Constants.doNotSellorShare) {//added as part of GCT-772
                    emailTemplate = Constants.doNotSellorShareDataOwnerEscalationEmail;
                }else {
                    emailTemplate = Constants.accessDataOwnerEscalationEmail;
                }
                Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, emailTemplate, cse.Data_Owner__r.Email);
                if (email == null) {
                    continue;
                }
                ccAddresses.add(cse.Privacy_Escalation_Email__c);
                email.setCcAddresses(ccAddresses);
                emailsToSend.add(email);
            } else {
                String emailTemplate;
                if (cse.Parent.Sub_Type__c == Constants.deletionRequestSubType) {
                    emailTemplate = Constants.deletionDataOwnerReminderEmail;
                }else if (cse.Parent.Sub_Type__c == Constants.rectifyRequestSubType) {
                    emailTemplate = Constants.updationDataOwnerReminderEmail;
                }else if (cse.Parent.Sub_Type__c == Constants.doNotSellorShare) {//added as part of GCT-772
                    emailTemplate = Constants.doNotSellorShareDataOwnerReminderEmail;
                }else {
                    emailTemplate = Constants.accessDataOwnerReminderEmail;
                }
                Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, emailTemplate, cse.Data_Owner__r.Email);
                if (email == null) {
                    continue;
                }
                if (ccAddresses.size() > 0) {
                    email.setCcAddresses(ccAddresses);
                }
                emailsToSend.add(email);

            }
        }
        System.debug('===emails to send' + emailsToSend);
        emailHandler.sendEmails(emailsToSend);

    }

    global void finish(Database.BatchableContext BC){}

}