trigger EmailMessageTrigger on EmailMessage (before insert, before update,before delete,after update, after insert, after delete, after undelete) {
    TriggerFactory.createAndExecuteHandler(EmailMessageTriggerHandler.class); 
}