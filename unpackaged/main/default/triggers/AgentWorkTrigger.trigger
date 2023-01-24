/**
 * Created by dimitrisavelieff on 2019-09-25.
 */

trigger AgentWorkTrigger on AgentWork (before insert, before update,before delete,after update, after insert, after delete, after undelete) {
    TriggerFactory.createAndExecuteHandler(AgentWorkTriggerHandler.class);
}