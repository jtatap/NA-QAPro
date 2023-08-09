trigger DirectMailUndeliverablesStagingTrigger on DirectMailUndeliverablesStaging__c (after insert) {
	TriggerDispatcher.run(new NF_DirectMailUndeliverableTriggerHandler());
}