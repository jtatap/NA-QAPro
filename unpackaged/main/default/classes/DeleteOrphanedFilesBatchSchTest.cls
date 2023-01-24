/**
 * Created by bryananderson on 10/11/19.
 */

@isTest
public class DeleteOrphanedFilesBatchSchTest {
    @isTest static void executeTest(){
        SchedulableContext sc = null;
        DeleteOrphanedFilesBatchSchedulable tsc = new DeleteOrphanedFilesBatchSchedulable();
        tsc.execute(sc);
    }
}