global class CSRSchduleBatchClass implements Schedulable{

    global void execute(SchedulableContext sc){
        CSREmailUpdate batch = new CSREmailUpdate();
        Database.executeBatch(batch,1);
    }
}