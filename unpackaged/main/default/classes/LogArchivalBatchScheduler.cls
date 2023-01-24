/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: June'16, 2020
* @Description: Scheduler class for LogArchivalBatch.
*/
public with sharing class LogArchivalBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new LogArchivalBatch());
    }
}