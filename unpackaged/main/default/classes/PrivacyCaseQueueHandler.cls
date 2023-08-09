/**
 * @author Magnet360
 * @date 2019
 *
 * @group Case
 * @group-content ../../ApexDocContent/Case.htm
 *
 * @description Class responsible for adding Privacy cases to their respective queues.
 * Extracted to a class so it could also be called from Process Builder.
 */
public class PrivacyCaseQueueHandler{
    /***********************************************************************************************
     * @description Invocable Method to Add Privacy Cases to their Omni Queues
     * @param cases List of cases to process
     */
    @InvocableMethod(label = 'Assign Privacy Case To Omni Queue')
    public static void invocablePrivacyQueueAssignment(List<Case> cases){
        Log.push('===calling invocable ' + cases);
        if (cases.size() > 0){
            cases = sendCasesToOmni(cases);
            update cases;
        }
        Logger.logDebug();
    }

    /***********************************************************************************************
     * @description Updates OwnerId of Privacy Cases to their respective omni queues
     * @param cases List of cases to update
     * @return The list of cases with ownerId updated (not saved yet)
     */
    public static List<Case> sendCasesToOmni(List<Case> cases){
        Log.push('===sending to omni ' + cases);
        Map<String, Id> queueNameMap = new Map<String, Id>();
        List<Group> possibleQueues = [Select Id, DeveloperName
                                      from Group
                                      where Type =: SYSTEM.LABEL.Queue And DeveloperName In:Constants.privacyCaseQueueNames];
        for (Group q : possibleQueues){
            queueNameMap.put(q.DeveloperName, q.Id);
        }
        Log.push('===queueNameMap ' + queueNameMap);
        for (Case cse : cases){
            if ((cse.RecordTypeId == Constants.dataOwnerCaseRecordTypeId && (String.isNotBlank(cse.ParentId) || cse.ParentId!=Null)) || (cse.RecordTypeId == Constants.supportCaseRecordTypeId && cse.Sub_Type__c != Constants.unsubscribeRequestSubType && cse.Sub_Type__c=='')){
                Log.push('continue@@@');
                 system.debug('continue@@@');
                continue;
            }
            if (String.isNotBlank(cse.Originating_Queue_Id__c)){
                Log.push('Setting Originating Queue from PrivacyCaseQueueHandler');
                  system.debug('Setting Originating Queue from PrivacyCaseQueueHandler');
                cse.OwnerId = cse.Originating_Queue_Id__c;
            } else{
                if ((cse.Sub_Type__c == Constants.unsubscribeRequestSubType && (!Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)))||
                    (cse.Sub_Type__c == Constants.accessRequestSubType && (!Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)))||
                    (cse.Sub_Type__c == Constants.deletionRequestSubType && (!Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)))
                   ){
                    Log.push('unsubscribeCase to lowPriorityPrivacyCaseQueue@@@');
                     system.debug('unsubscribeCase to lowPriorityPrivacyCaseQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.lowPriorityPrivacyCaseQueue);
                } else if (
                    (cse.Sub_Type__c == Constants.unsubscribeRequestSubType && (Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)))||
                    (cse.Sub_Type__c == Constants.accessRequestSubType && (Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)))||
                    (cse.Sub_Type__c == Constants.deletionRequestSubType && (Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)))
                   ){
                    Log.push('highPriorityPrivacyCaseQueue@@@');
                     system.debug('highPriorityPrivacyCaseQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.highPriorityPrivacyCaseQueue);
                } else if (cse.Sub_Type__c == Constants.privacyEmailSubType){
                    Log.push('unassignedPrivacyQueue@@@');
                     system.debug('unassignedPrivacyQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.unassignedPrivacyQueue);
                } else if((cse.Sub_Type__c ==Null && cse.Sub_Type__c =='') && (cse.Type ==Null && cse.Type =='')&& (cse.Brand__c==Null && cse.Brand__c=='')){
                    cse.OwnerId =queueNameMap.get(Constants.spamQueue);
                }
                /*else if(cse.OwnerId==Null){
                    Log.push('Default_Case_Queue@@@');
                     system.debug('Default_Case_Queue@@@');
                    cse.OwnerId =queueNameMap.get(Constants.defaultQueue);
                }*/
            }
            Log.push('===OwnerId ' + cse.OwnerId);
                                system.debug('===OwnerId ' + cse.OwnerId);
        }
        Logger.logDebug();
        return cases;
    }

}