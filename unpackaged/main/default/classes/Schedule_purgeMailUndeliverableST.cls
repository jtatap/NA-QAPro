/* Story No : NASSC-1135
   *  Class: SchedulableBatchDirectMS
 *  Description : Schedulable class to call Batch class Batch_DirectMailUndeliverableStaging.
 */
global class Schedule_purgeMailUndeliverableST implements Schedulable{ 
    global void execute(SchedulableContext ctx){
        NF_Batch_Control__mdt batchMeta =  NF_Batch_Control__mdt.getInstance('Schedule_purgeMailUndeliverableST'); 
        Batch_purgeMailUndeliverableST DMstaging = new Batch_purgeMailUndeliverableST();
        Database.executeBatch(DMstaging,Integer.valueOf(batchMeta.Batch_Size__c));
    }
}