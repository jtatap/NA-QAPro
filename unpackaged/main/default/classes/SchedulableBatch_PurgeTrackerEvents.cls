/*  Class: SchedulableBatch_PurgeTrackerEvents
 *  Description : Schedulable class to call Batch class Batch_PurgeTrackerEvents.
 */
global class SchedulableBatch_PurgeTrackerEvents implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('SchedulableBatch_PurgeTrackerEvents'); 
        Batch_PurgeTrackerEvents TrackerEvents = new Batch_PurgeTrackerEvents();
        Database.executeBatch(TrackerEvents,Integer.valueOf(batchMeta.Batch_Size__c));
    }
}