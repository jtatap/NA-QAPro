/**
This class calls the batch jobs that will send emails and update cases based on time passed
 */

global class SchedulableBatch_PrivacyIntervalActions implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        Log.push('===executing schedulable');
        Logger.logDebug();

        // This batch class could send reminders on the parent case. We could not decide on the email or type of email but it is functional and tested in PrivacyCaseTests.
        //Batch_PrivacyConfirmedCaseReminders privacyConfirmedReminderer = new Batch_PrivacyConfirmedCaseReminders();
        //Database.executeBatch(privacyConfirmedReminderer);

        NF_Batch_Control__mdt batchMeta1 = NF_Batch_Control__mdt.getInstance('Batch_PrivacyCaseHardCloser');
        NF_Batch_Control__mdt batchMeta2 = NF_Batch_Control__mdt.getInstance('Batch_PrivacyUnconfirmedCaseArchiver');
        NF_Batch_Control__mdt batchMeta3 = NF_Batch_Control__mdt.getInstance('Batch_PrivacyStalledCaseArchiver');
        NF_Batch_Control__mdt batchMeta4 = NF_Batch_Control__mdt.getInstance('Batch_PrivacyDataOwnerCaseReminders');

        Batch_PrivacyDataOwnerCaseReminders dataOwnerReminderer = new Batch_PrivacyDataOwnerCaseReminders();
        Database.executeBatch(dataOwnerReminderer,Integer.valueOf(batchMeta4.Batch_Size__c));

        Batch_PrivacyCaseHardCloser hardCloser = new Batch_PrivacyCaseHardCloser();
        Database.executeBatch(hardCloser,Integer.valueOf(batchMeta1.Batch_Size__c));

        Batch_PrivacyUnconfirmedCaseArchiver unconfirmedArchiver = new Batch_PrivacyUnconfirmedCaseArchiver();
        Database.executeBatch(unconfirmedArchiver,Integer.valueOf(batchMeta2.Batch_Size__c));

        Batch_PrivacyStalledCaseArchiver stalledCaseArchiver = new Batch_PrivacyStalledCaseArchiver();
        Database.executeBatch(stalledCaseArchiver,Integer.valueOf(batchMeta3.Batch_Size__c));
    }
}