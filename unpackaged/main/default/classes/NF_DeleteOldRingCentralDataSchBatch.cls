/**
 * @description       : Batch class to delete old/obsolete Ring Central data
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 09-10-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
global class NF_DeleteOldRingCentralDataSchBatch implements Database.Batchable<SObject>, Schedulable{

    @TestVisible private String objectName = '';
    @TestVisible private Integer index = 0;
    @TestVisible private List<String> objectsToDelete = new List<String>();

    @TestVisible private Final Integer BATCH_SIZE = 2000;
    @TestVisible private Final String FIELD_TO_CONSIDER = LABEL.NF_RC_FIELD_TO_CONSIDER_FOR_DELETION;
    @TestVisible private Final DateTime CUT_OFF_DATE = Date.today().addMonths(
        -1 * Integer.valueOf(LABEL.NF_RC_CUTOFF_MONTHS_FOR_DATA_DELETION)
    );

    /**
    * @description Override execute method of schedulable interface
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    * @param SC
    **/
    global void execute(SchedulableContext SC) {
        for(
            NF_Nice_InContact_API_Config__mdt eachMetaRecord :
            NF_Nice_InContact_API_Config__mdt.getAll().values()
        ){
            if(
                eachMetaRecord.Delete_Obsolete_Records__c &&
                String.isNotBlank(eachMetaRecord.Object_to_Create__c)
            ){
                objectsToDelete.add(eachMetaRecord.Object_to_Create__c);
            }
        }

        Log.push('objectsToDelete :: ' + objectsToDelete);
        Logger.logDebug();
        if(!objectsToDelete.isEmpty()){
            NF_DeleteOldRingCentralDataSchBatch batchable =
                new NF_DeleteOldRingCentralDataSchBatch(objectsToDelete, index);
            Database.executeBatch(batchable, BATCH_SIZE);
        }
    }

    /**
    * @description Default Constructor
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    **/
    public NF_DeleteOldRingCentralDataSchBatch(){}

    /**
    * @description Custom Constructor for setting class variables
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    * @param objectAPINames
    * @param indexToSet
    **/
    public NF_DeleteOldRingCentralDataSchBatch(List<String> objectAPINames, Integer indexToSet){
        objectsToDelete = objectAPINames;
        index = indexToSet;
        objectName = objectsToDelete[index];
    }

    /**
    * @description Override start method of batchable interface
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    * @param ctx
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        DateTime futureDate = Date.today().addYears(1);
        String query = String.isNotBlank(objectName) ?
            ('SELECT Id FROM ' + objectName + ' WHERE ' + FIELD_TO_CONSIDER + ' <: CUT_OFF_DATE') :
            'SELECT Id FROM Account WHERE CreatedDate >: futureDate AND IsDeleted = true';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Override execute method of batchable interface
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    * @param BC
    * @param recordsToDelete
    **/
    public void execute(Database.BatchableContext ctx, List<SObject> recordsToDelete){
        Integer deleteSize = recordsToDelete != null && !recordsToDelete.isEmpty() ? recordsToDelete.size() : 0;
        Log.push(
            'Deleting ' + deleteSize + ' records of ' + objectName +
            ' object whose ' + FIELD_TO_CONSIDER + ' < ' + CUT_OFF_DATE
        );
        Logger.logDebug();
        Database.delete(recordsToDelete);
    }

    /**
    * @description Override finish method of batchable interface
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    * @param BC
    **/
    public void finish(Database.BatchableContext ctx){
        if(++index < objectsToDelete.size()){
            NF_DeleteOldRingCentralDataSchBatch batchable =
                new NF_DeleteOldRingCentralDataSchBatch(objectsToDelete, index);
            if(!Test.isRunningTest()){
                Database.executeBatch(batchable, BATCH_SIZE);
            }
        }
    }
}