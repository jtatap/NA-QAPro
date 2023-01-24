trigger AccountTrigger on Account (before insert, before update,before delete,after update, after insert, after delete, after undelete) {
    TriggerFactory.createAndExecuteHandler(AccountTriggerHandler.class);
}