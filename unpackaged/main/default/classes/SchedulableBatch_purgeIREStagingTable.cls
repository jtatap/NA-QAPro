/* 
 * Story No : NASSC-1133 
 *  Class: SchedulableBatch_purgeIREStagingTable
 *  Description : Schedulable class to call Batch class Batch_PurgeTrackerEvents.
 */
global class SchedulableBatch_purgeIREStagingTable implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('SchedulableBatch_purgeIREStagingTable'); 
        Batch_purgeIREStagingTable TrackerEvents = new Batch_purgeIREStagingTable();
        Database.executeBatch(TrackerEvents,Integer.valueOf(batchMeta.Batch_Size__c));
    }
}