/* 
 * Jira No : NASSC-3317
 *  Class: SchedulableBatch_deleteextracttarget
 *  Description : Schedulable class to call Batch class Batch_deleteextracttarget.
 */
global class SchedulableBatch_deleteextracttarget implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        Batch_deleteextracttarget TrackerExtract= new Batch_deleteextracttarget();
        Database.executeBatch(TrackerExtract);
    }
}