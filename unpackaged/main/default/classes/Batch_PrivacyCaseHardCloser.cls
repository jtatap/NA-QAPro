global class Batch_PrivacyCaseHardCloser implements Database.Batchable <sObject>{

    global List<Case> start(Database.BatchableContext bc){
        Log.push('===starting hard closer');

        Privacy_Intervals__c orgInterval = Privacy_Intervals__c.getValues(Constants.privacyIntervalSettingName);
        Integer hardCloseElapsedHours = Integer.valueOf(orgInterval.hardCloseHours__c);

        Log.push('===hardCloseElapsedHours' + hardCloseElapsedHours);

        List<String> selectedSubTypes = new List<String>(Constants.parentPrivacyCaseSubTypes);
        selectedSubTypes.add(Constants.privacyEmailSubType);
        selectedSubTypes.add(Constants.unsubscribeRequestSubType);
        List<String> selectedTypes = new List<String>{Constants.privacyCaseType, Constants.marketingCaseType};
        Logger.logDebug();
        return [Select Id, Status From Case Where Type IN :selectedTypes And Hours_Since_Resolved__c >= :hardCloseElapsedHours And Status = :Constants.resolved and Sub_Type__c IN :selectedSubTypes];
    }

    global void execute(Database.BatchableContext bc, List<Case> cases){
        Log.push('===iterating cases' + cases);
        List<Id> parentCaseIds = new List<Id>();
        for (Case cse : cases) {
            cse.Status = Constants.closed;
            cse.RecordTypeId = Constants.privacyReadOnlyRecordTypeId;
            parentCaseIds.add(cse.Id);
        }
        List<Case> allChildCases = [Select Id, Status From Case Where ParentId In :parentCaseIds];
        for (Case childCase : allChildCases) {
            childCase.Status = Constants.closed;
            childCase.RecordTypeId = Constants.privacyReadOnlyRecordTypeId;
            cases.add(childCase);
        }
        Logger.logDebug();
        update cases;
    }

    global void finish(Database.BatchableContext BC){}

}