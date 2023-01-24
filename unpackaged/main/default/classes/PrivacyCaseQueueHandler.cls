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
public class PrivacyCaseQueueHandler {

    /***********************************************************************************************
    * @description Invocable Method to Add Privacy Cases to their Omni Queues
    * @param cases List of cases to process
    */
    @InvocableMethod(label='Assign Privacy Case To Omni Queue')
    public static void invocablePrivacyQueueAssignment(List<Case> cases) {
        System.debug('===calling invocable ' + cases);
        if (cases.size() > 0) {
            cases = sendCasesToOmni(cases);
            update cases;
        }

    }

    /***********************************************************************************************
    * @description Updates OwnerId of Privacy Cases to their respective omni queues
    * @param cases List of cases to update
    * @return The list of cases with ownerId updated (not saved yet)
    */
    public static List<Case> sendCasesToOmni(List<Case> cases) {
        System.debug('===sending to omni ' + cases);
        Map<String, Id> queueNameMap = new Map<String, Id>();
        List<Group> possibleQueues = [Select Id, DeveloperName from Group where Type = 'Queue' And DeveloperName In :Constants.privacyCaseQueueNames];
        for (Group q : possibleQueues) {
            queueNameMap.put(q.DeveloperName, q.Id);
        }
        System.debug('===queueNameMap ' + queueNameMap);
        for (Case cse : cases) {
            if((cse.RecordTypeId == Constants.dataOwnerCaseRecordTypeId && String.isNotBlank(cse.ParentId)) || (cse.RecordTypeId == Constants.supportCaseRecordTypeId && cse.Sub_Type__c != Constants.unsubscribeRequestSubType)) {
                system.debug('continue@@@');
                continue;
            }
            if (String.isNotBlank(cse.Originating_Queue_Id__c)) {
                system.debug('Setting Originating Queue from PrivacyCaseQueueHandler');
                cse.OwnerId = cse.Originating_Queue_Id__c;
            } else {
                if (cse.Sub_Type__c == Constants.unsubscribeRequestSubType) {
                    system.debug('unsubscribeCase to lowPriorityPrivacyCaseQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.lowPriorityPrivacyCaseQueue);
                } else if (Constants.privacyHighPriorityStates.contains(cse.State_of_Residence__c)) {
                    system.debug('highPriorityPrivacyCaseQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.highPriorityPrivacyCaseQueue);
                } else if (cse.Sub_Type__c == Constants.privacyEmailSubType) {
                    system.debug('unassignedPrivacyQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.unassignedPrivacyQueue);
                } else {
                    system.debug('lowPriorityPrivacyCaseQueue@@@');
                    cse.OwnerId = queueNameMap.get(Constants.lowPriorityPrivacyCaseQueue);
                }
            }
            System.debug('===OwnerId ' + cse.OwnerId);
        }
        return cases;
    }

}