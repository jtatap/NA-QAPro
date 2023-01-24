global class Batch_PrivacyUnconfirmedCaseArchiver implements Database.Batchable <sObject>{
    global List<Case> start(Database.BatchableContext bc){
        System.debug('===starting archiver');
        // and status in list of statuses
        Privacy_Intervals__c orgInterval;
        Integer archiveElapsedHours;

        orgInterval = Privacy_Intervals__c.getValues(Constants.privacyIntervalSettingName);
        archiveElapsedHours = Integer.valueOf(orgInterval.MaxBeforeConfirm__c);

        System.debug('===archiveElapsedHours' + archiveElapsedHours);

        List<String> selectedSubTypes = new List<String>(Constants.parentPrivacyCaseSubTypes);
        selectedSubTypes.add(Constants.unsubscribeRequestSubType);
        List<String> selectedTypes = new List<String>{Constants.privacyCaseType, Constants.marketingCaseType};

        return [Select Id, Status, Sub_Type__c, Brand__c, SuppliedEmail, ContactId, Brand_Privacy_OWA_Name__c From Case Where Type IN :selectedTypes AND Sub_Type__c In :selectedSubTypes And Hours_Since_Creation__c >= :archiveElapsedHours And Status = :Constants.newPrivacyStatus];
    }

    global void execute(Database.BatchableContext bc, List<Case> cases){
        for (Case cse : cases) {
            cse.Status = Constants.resolved;
            cse.Resolution_Code__c = Constants.privacyResolvedNoResponse;
        }
        update cases;
    }

    global void finish(Database.BatchableContext BC){}

}