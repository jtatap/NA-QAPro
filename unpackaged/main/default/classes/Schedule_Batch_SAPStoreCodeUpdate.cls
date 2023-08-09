global class Schedule_Batch_SAPStoreCodeUpdate implements Schedulable{

   global void execute(SchedulableContext ctx){
        Batch_SAPStoreCodeUpdate sapstoreContact= new Batch_SAPStoreCodeUpdate ();
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('Schedule_Batch_SAPStoreCodeUpdate'); 
        Database.executeBatch(sapstoreContact,Integer.valueOf(batchMeta.Batch_Size__c));
        }
}