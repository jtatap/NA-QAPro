/**
 * @description       : Test class for NF_DeleteOldRingCentralDataSchBatch
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 09-10-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
@isTest(seeAllData = false)
public class NF_DeleteOldRingCentralDataSchBatchTest {
    /**
    * @description Inserts data for testing deletion
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    **/
    @TestSetup
    static void setupData(){
        List<String> objectsToCreate = new List<String>();
        for(
            NF_Nice_InContact_API_Config__mdt eachMetaRecord :
            NF_Nice_InContact_API_Config__mdt.getAll().values()
        ){
            if(
                eachMetaRecord.Delete_Obsolete_Records__c &&
                String.isNotBlank(eachMetaRecord.Object_to_Create__c)
            ){
                objectsToCreate.add(eachMetaRecord.Object_to_Create__c);
            }
        }

        if(!objectsToCreate.isEmpty()){
            DateTime dt = Date.today().addMonths(
                -1 * (Integer.valueOf(LABEL.NF_RC_CUTOFF_MONTHS_FOR_DATA_DELETION) + 1)
            );
            List<SObject> recordsToInsert = new List<SObject>();
            for(String eachSObjectAPIName : objectsToCreate){
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(eachSObjectAPIName);
                SObject newSObject = targetType.newSObject();
                newSobject.put('Start_Date__c', dt);
                newSobject.put('End_Date__c', dt);
                recordsToInsert.add(newSobject);
            }
            insert recordsToInsert;

            for(SObject eachRecord : recordsToInsert){
                Test.setCreatedDate(Id.valueOf(String.valueOf(eachRecord.get('Id'))), dt);
            }
        }
    }

    /**
    * @description Tests scheduling of batch class and immediate execution of it too.
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @return testMethod
    **/
    public static testMethod void testDeletion(){
        List<String> objectNames = new List<String>();
        List<SObject> insertedRecords = new List<SObject>();
        List<SObject> recordsInDB = new List<SObject>();

        for(
            NF_Nice_InContact_API_Config__mdt eachMetaRecord :
            NF_Nice_InContact_API_Config__mdt.getAll().values()
        ){
            if(
                eachMetaRecord.Delete_Obsolete_Records__c &&
                String.isNotBlank(eachMetaRecord.Object_to_Create__c)
            ){
                objectNames.add(eachMetaRecord.Object_to_Create__c);
                insertedRecords.addAll(Database.query('SELECT Id FROM ' + eachMetaRecord.Object_to_Create__c));
            }
        }
        if(!objectNames.isEmpty()){
            NF_DeleteOldRingCentralDataSchBatch schedulable = new NF_DeleteOldRingCentralDataSchBatch();
            String cronExp = '0 30 0 1 * ?';

            Test.startTest();
            String jobId = System.schedule('testDeletion', cronExp, schedulable);
            CronTrigger ct = [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals(30, ct.NextFireTime.minute());
            Database.executeBatch(new NF_DeleteOldRingCentralDataSchBatch(objectNames, 0));
            Test.stopTest();

            for(String eachObjectName : objectNames){
                recordsInDB.addAll(Database.query('SELECT Id FROM ' + eachObjectName));
            }

            System.assert(recordsInDB.size() < insertedRecords.size());
        }
    }
}