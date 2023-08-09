/*  Class: Batch_PurgeTrackerEvents
 *  Description : Batch class to Delete TrackerEvents__c  records  with CreatedDate > (Today - 21)
 */
global class Batch_PurgeTrackerEvents implements Database.Batchable<sObject>, Database.Stateful{
    String QueryString = Null;
    // Static list<TrackerEvents__c> TrackerEvents = [select createdDate ,Id ,Type__c,Customer__c from TrackerEvents__c];
    global Database.QueryLocator start(Database.BatchableContext bc){
        Log.push('Started');

        NF_Batch_Control__mdt batchMeta = NF_Batch_Control__mdt.getInstance('Batch_PurgeTrackerEvents');
        QueryString = batchMeta.Query_String__c;

        Log.push('QueryString: ' + QueryString);
        Logger.logDebug();
        return Database.getQueryLocator(QueryString);
    }

    global void execute(Database.BatchableContext bc, List<TrackerEvents__c> records){
        Log.push('execute');

        List<TrackerEvents__c> TrackerEventsList = new List<TrackerEvents__c>();

        if (records != NULL && records.size() > 0){
            Log.push('###### ' + records.size());

            for (TrackerEvents__c T : records){
                Log.push('execute1');
                Date createdDate = date.valueOf(T.CreatedDate);
                Log.push('execute### ' + CreatedDate);
                Log.push(('' + createdDate.daysBetween(date.today())));

                //Checking condition For CreatedDate >Today() - 21
                if ((createdDate.daysBetween(date.today())) > 21){
                    Log.push('inside if ');
                    TrackerEventsList.add(T);
                }
            }
        }

        Log.push('TrackerEvents List size: ' + TrackerEventsList.size());

        if (TrackerEventsList.size() > 0){
            List<database.DeleteResult> results = Database.delete (TrackerEventsList, false);

            for (Database.DeleteResult result : results){
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                        Log.push('Error: ' + err.getStatusCode() + ' ' + err.getMessage());
                    }
                }
            }
            Logger.logDebug();
        }
    }

    global void finish(Database.BatchableContext bc){
        Log.push('finish');
    }

}