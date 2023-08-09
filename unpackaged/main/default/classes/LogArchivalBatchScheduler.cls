/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: June'16, 2020
* @Description: Scheduler class for LogArchivalBatch.
*/
public with sharing class LogArchivalBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('LogArchivalBatchScheduler');
        Database.executeBatch(new LogArchivalBatch(),Integer.valueOf(batchMeta.Batch_Size__c));
    }
}