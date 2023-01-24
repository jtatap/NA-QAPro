/**
 * Created by bryananderson on 10/11/19.
 */

global class DeleteOrphanedFilesBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext ctx){
        DeleteOrphanedFilesBatch deleteOrphans = new DeleteOrphanedFilesBatch();
        Database.executeBatch(deleteOrphans);
    }
}