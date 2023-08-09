global class Batch_PrivacyStalledCaseArchiver implements Database.Batchable <sObject>{
    global List<Case> start(Database.BatchableContext bc){
        Log.push('===starting archiver');
        Privacy_Intervals__c orgInterval;
        Integer archiveElapsedHours;

        orgInterval = Privacy_Intervals__c.getValues(Constants.privacyIntervalSettingName);

        archiveElapsedHours = Integer.valueOf(orgInterval.maxStalledHours__c);

        Log.push('===archiveElapsedHours' + archiveElapsedHours);
        Logger.logDebug();

        return [Select Id, Status, Sub_Type__c, Brand__c, SuppliedEmail, ContactId, Brand_Privacy_OWA_Name__c From Case Where Type = :Constants.privacyCaseType AND Sub_Type__c In :Constants.parentPrivacyCaseSubTypes And Hours_Since_Consumer_Last_Contacted__c >= :archiveElapsedHours And Status = :Constants.waitingForResponse];
    }

    global void execute(Database.BatchableContext bc, List<Case> cases){
        Log.push('===iterating cases' + cases);
        for (Case cse : cases) {
            cse.Status = Constants.resolved;
            cse.Resolution_Code__c = Constants.privacyResolvedStalled;
        }
        update cases;
        Logger.logDebug();
    }

    global void finish(Database.BatchableContext BC){}

}