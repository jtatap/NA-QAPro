global class Schedule_invalidContactEmailBatchASC implements Schedulable{

 global void execute(SchedulableContext ctx){
        invalidContactEmailBatch invalidateContact= new invalidContactEmailBatch ();
        Database.executeBatch(invalidateContact,200);
        }


}