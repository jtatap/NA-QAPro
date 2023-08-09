/*  Class: SchedulableBatchCloseResolvedCase
 *  Description : Schedulable class to call Batch class BatchCloseResolvedCase.
 */
global class SchedulableBatchCloseResolvedCase implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('SchedulableBatchCloseResolvedCase'); 
        BatchCloseResolvedCase closeCase = new BatchCloseResolvedCase();
        Database.executeBatch(closeCase,Integer.valueOf(batchMeta.Batch_Size__c));
    }
}