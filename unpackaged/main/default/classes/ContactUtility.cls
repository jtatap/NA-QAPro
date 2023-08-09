/*
 * NASSC-1066
 NASSC-1114
 */
public class ContactUtility{
    public static void assignLoyaltyId(Map<Contact, SObject> sequenceObjMap){
        //Log.push('### sequenceObjMap ' + sequenceObjMap);
        Set<Id> seqList = new Set<Id>();

        Savepoint sp = Database.setSavepoint();
        insert sequenceObjMap.values();

        for (SObject sobj : sequenceObjMap.values()){
            seqList.add(sobj.Id);
        }

        List<LoyaltyID_Sequence__c> loyaltylList = [Select Id, Name
                                                    from LoyaltyID_Sequence__c
                                                    WHERE Id in:seqList];

        for (LoyaltyID_Sequence__c l : loyaltylList){
            for (Contact c : sequenceObjMap.keySet()){
                if (String.isEmpty(c.LoyaltyID__c)){
                    LoyaltySettings__mdt listLoyaltySetting = [Select Id, BrandId__c, IsLoyaltyApplicable__c, Parent_Brand__c, LoyaltyPrefix__c
                                                               from LoyaltySettings__mdt
                                                               where BrandId__c = :c.Brand_Id__c];
                    if (listLoyaltySetting != null){
                        c.LoyaltyID__c = (String.isNotEmpty(listLoyaltySetting.LoyaltyPrefix__c) ? listLoyaltySetting.LoyaltyPrefix__c + l.Name : l.Name);
                        break;
                    }
                }
            }
        }

        Database.rollback(sp);
    }

    public static void createErrorLogRecords(Database.SaveResult[] dmlList, String sourceSystem, String fileName){
        Log.push('***inside createErrorLogRecords');
        Log.push('***dmlList ' + dmlList);
        List<ErrorLog__c> listErrorLog = new List<ErrorLog__c>();
        String stackTrace;
        Integer maxSize = 131072;
        for (Database.SaveResult sr : dmlList){
            if (!sr.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : sr.getErrors()){
                    Log.push('***The following error has occurred.');
                    Log.push(err.getStatusCode() + ': ' + err.getMessage());
                    Log.push('***Fields that affected this error: ' + err.getFields());
                    ErrorLog__c logObject = new ErrorLog__c();
                    logObject.Message__c = String.valueOf(err.getStatusCode()).left(255);
                    stackTrace = err.getMessage();
                    //checking and truncating if size of stacktrace is more than 131072
                    if (stackTrace.length() > maxSize){
                        stackTrace = stackTrace.substring(0, maxSize);
                    }
                    logObject.StackTrace__c = stackTrace;
                    logObject.Type__c = SYSTEM.LABEL.Error;
                    //logObject.User__c = UserInfo.getUserId();
                    if (!String.isBlank(sourceSystem))
                        logObject.SourceSystem__c = sourceSystem;
                    if (!String.isBlank(fileName))
                        logObject.FileName__c = fileName;
                    listErrorLog.add(logObject);
                }
            }
        }
        Log.push('***listErrorLog' + listErrorLog);
        Logger.logDebug();
        insert listErrorLog;
    }

}