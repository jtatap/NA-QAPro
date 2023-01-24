/* Story No : NASSC-1135
   *  Class: SchedulableBatchDirectMS
 *  Description : Schedulable class to call Batch class Batch_DirectMailUndeliverableStaging.
 */
global class Schedule_purgeMailUndeliverableST implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        Batch_purgeMailUndeliverableST DMstaging = new Batch_purgeMailUndeliverableST();
        Database.executeBatch(DMstaging);
    }
}