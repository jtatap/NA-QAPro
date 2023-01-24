/*  Class: SchedulableBatchCloseResolvedCase
 *  Description : Schedulable class to call Batch class BatchCloseResolvedCase.
 */
global class SchedulableBatchCloseResolvedCase implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        BatchCloseResolvedCase closeCase = new BatchCloseResolvedCase();
        Database.executeBatch(closeCase);
    }
}