trigger CallDetailsTrigger on CallDetail__c (after insert) {

     //After call details are captured, clear call details from parent case object
      List<CallDetail__c> newCallDetails = Trigger.new;
      if(CallDetailsTriggerHandler.RUN_ONCE == true){
         CallDetailsTriggerHandler.clearCallDetailsOnCase(newCallDetails);
         CallDetailsTriggerHandler.RUN_ONCE = false;
      }
}