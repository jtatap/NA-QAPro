/**
This class calls the batch jobs that will send emails and update cases based on time passed
 */

global class SchedulableBatch_PrivacyIntervalActions implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        System.debug('===executing schedulable');
        // This batch class could send reminders on the parent case. We could not decide on the email or type of email but it is functional and tested in PrivacyCaseTests.
        //Batch_PrivacyConfirmedCaseReminders privacyConfirmedReminderer = new Batch_PrivacyConfirmedCaseReminders();
        //Database.executeBatch(privacyConfirmedReminderer);

        Batch_PrivacyDataOwnerCaseReminders dataOwnerReminderer = new Batch_PrivacyDataOwnerCaseReminders();
        Database.executeBatch(dataOwnerReminderer);

        Batch_PrivacyCaseHardCloser hardCloser = new Batch_PrivacyCaseHardCloser();
        Database.executeBatch(hardCloser);

        Batch_PrivacyUnconfirmedCaseArchiver unconfirmedArchiver = new Batch_PrivacyUnconfirmedCaseArchiver();
        Database.executeBatch(unconfirmedArchiver);

        Batch_PrivacyStalledCaseArchiver stalledCaseArchiver = new Batch_PrivacyStalledCaseArchiver();
        Database.executeBatch(stalledCaseArchiver);
    }
}