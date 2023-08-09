public  class NF_AgentWorkTriggerHelper {
    Private static List<Case> casesToUpdate = new List<Case>();
    Private static List<LiveChatTranscript> chatsToUpdate = new List<LiveChatTranscript>();

    public static void handleAfterUpdate(Map<Id,AgentWork> newMap, Map<Id,AgentWork> oldMap){
        Log.push('UPDATING RECORDS');
            List<AgentWork> openedWork = new List<AgentWork>();
            List<AgentWork> closedWork = new List<AgentWork>();
            for(SObject so : newMap.values()) {
                AgentWork aw = (AgentWork)so;
                if(aw.Status == SYSTEM.LABEL.Opened) {
                    openedWork.add((AgentWork)aw);
                } else if (aw.Status  == SYSTEM.LABEL.Closed) {
                    closedWork.add((AgentWork)aw);
                }
            }
            if(!openedWork.isEmpty()) {
                
                updateOriginalQueue(openedWork);
            }
            if(!closedWork.isEmpty()) {
                rollupActiveTime(closedWork);
            }
            Logger.logDebug();
            andFinally();
    }

    @TestVisible
    private static Boolean rollupActiveTime(List<AgentWork> newWorks) {
         Map<String,Map<Id, AgentWork>> acceptedWorks = getAcceptedWorks(newWorks, 'Closed');
        casesToUpdate = [Select Id, Total_Active_Time__c from Case where Id in :acceptedWorks.get('Case').keySet()];
        for(Case cse :casesToUpdate) {
            AgentWork aw = acceptedWorks.get('Case').get(cse.Id);
            cse.Total_Active_Time__c = (cse.Total_Active_Time__c == null?aw.ActiveTime:cse.Total_Active_Time__c+aw.ActiveTime);
        }
        return true;
    }

    @TestVisible
    private static Boolean updateOriginalQueue(List<AgentWork> newWorks) {
        List<AgentWork> workWithQueueNames = [Select Id, OriginalGroupId, OriginalGroup.Name, WorkItemId, Status from AgentWork where Id in :newWorks];
        Log.push('workWithQueueNames'+workWithQueueNames);
        Map<String,Map<Id, AgentWork>> acceptedWorks = getAcceptedWorks(workWithQueueNames, 'Opened');
        Log.push('acceptedWorks'+acceptedWorks);         
        casesToUpdate = [Select Id, Originating_Queue_Id__c, Originating_Queue__c, Status, Type from Case where Id in :acceptedWorks.get('Case').keySet()];
        chatsToUpdate = [Select Id from LiveChatTranscript where Id in :acceptedWorks.get('Chat').keySet() AND Originating_Queue_Id__c = null];
        for(Case cse :casesToUpdate) {
            AgentWork aw = acceptedWorks.get('Case').get(cse.Id);
            if(String.isBlank(cse.Originating_Queue_Id__c)) {
                cse.Originating_Queue_Id__c = aw.OriginalGroupId;
                cse.Originating_Queue__c = aw.OriginalGroup.Name;
            }
            //if opening a cse, set status to Open
            if (cse.Type != Constants.privacyCaseType && cse.Status == SYSTEM.LABEL.New) {
                cse.Status = SYSTEM.LABEL.Open;
            }
        }
        for(LiveChatTranscript chat :chatsToUpdate) {
            AgentWork aw = acceptedWorks.get('Case').get(chat.Id);
            chat.Originating_Queue_Id__c = aw.OriginalGroupId;
            chat.Originating_Queue__c = aw.OriginalGroup.Name;
        }
        Logger.logDebug();
        return true;
    }
    
	@TestVisible
    private static Map<String,Map<Id,AgentWork>> getAcceptedWorks(List<AgentWork> newWorks, String Status) {
        Map<String,Map<Id,AgentWork>> acceptedWorks = new Map<String,Map<Id,AgentWork>>{'Case' => new Map<Id,AgentWork>(), 'Chat' => new Map<Id,AgentWork>()};
        for(AgentWork aw :newWorks) {
            System.debug('aw value ' + aw);
            if(Test.isRunningTest() || (aw.Status != ((AgentWork)trigger.oldMap.get(aw.Id)).Status && aw.Status == Status)) {
                String workItemId = aw.WorkItemId;
                if(workItemId.startsWith('500')) {
                    Map<Id,AgentWork> caseWorks = acceptedWorks.get('Case');
                    caseWorks.put(aw.WorkItemId, aw);
                    acceptedWorks.put('Case', caseWorks);
                } else if (workItemId.startsWith('570')) {
                    Map<Id,AgentWork> caseWorks = acceptedWorks.get('Chat');
                    caseWorks.put(aw.WorkItemId, aw);
                    acceptedWorks.put('Case', caseWorks);
                }
            }
        }
        return acceptedWorks;
    }

    public static void andFinally(){
        try{
            if(!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
            if(!chatsToUpdate.isEmpty()){
                update chatsToUpdate;
            }

        } catch(DmlException e) {
            //Failed to Update records
        }
    }
    
   
   
    
}