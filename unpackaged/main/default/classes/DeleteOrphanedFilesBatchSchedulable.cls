/**
 * Created by bryananderson on 10/11/19.
 */

global class DeleteOrphanedFilesBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext ctx){
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('DeleteOrphanedFilesBatch');
        DeleteOrphanedFilesBatch deleteOrphans = new DeleteOrphanedFilesBatch();
        Database.executeBatch(deleteOrphans,Integer.valueOf(batchMeta.Batch_Size__c));
    }
}