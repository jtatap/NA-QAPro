global class Schedule_invalidContactEmailBatchDesc implements Schedulable{

 global void execute(SchedulableContext ctx){
        invalidContactEmailBatchDesc invalidateContact= new invalidContactEmailBatchDesc ();
        Database.executeBatch(invalidateContact,200);
        }


}