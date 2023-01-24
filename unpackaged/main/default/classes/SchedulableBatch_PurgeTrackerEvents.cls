/*  Class: SchedulableBatch_PurgeTrackerEvents
 *  Description : Schedulable class to call Batch class Batch_PurgeTrackerEvents.
 */
global class SchedulableBatch_PurgeTrackerEvents implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        Batch_PurgeTrackerEvents TrackerEvents = new Batch_PurgeTrackerEvents();
        Database.executeBatch(TrackerEvents);
    }
}