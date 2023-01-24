/* 
 * Story No : NASSC-1133 
 *  Class: SchedulableBatch_purgeIREStagingTable
 *  Description : Schedulable class to call Batch class Batch_PurgeTrackerEvents.
 */
global class SchedulableBatch_purgeIREStagingTable implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        Batch_purgeIREStagingTable TrackerEvents = new Batch_purgeIREStagingTable();
        Database.executeBatch(TrackerEvents);
    }
}