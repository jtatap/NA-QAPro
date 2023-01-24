/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'10, 2020
* @TestClass: LoggerTest
*/ 

trigger LogEventTrigger on Log_Event__e (after insert) {
    new LogEventTriggerHandler().createLogs(trigger.new);
}