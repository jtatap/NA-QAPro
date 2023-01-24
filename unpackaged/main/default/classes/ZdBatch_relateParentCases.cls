global class ZdBatch_relateParentCases implements Database.Batchable <sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, ZdPVHTicketId__c, ZdParentTicketId__c  FROM Case WHERE ZdPVHTicketId__c != null AND ZdParentTicketId__c != null AND ParentId = null ORDER BY ZdParentTicketId__c');
    }
    global void execute(Database.BatchableContext bc, List<Case> scope){


        Set<String> PVHParentIds = new Set<String>();

        Map<String,Id> PVHParentIdToParentCaseIdMap = new Map<String,Id>();

        List<Case> childCasesforUpdate = new List<Case>();

        for(Case curCase : scope){

            PVHParentIds.add(curCase.ZdParentTicketId__c);

        }

        for(Case parCase : [SELECT Id, ZdPVHTicketId__c FROM Case WHERE ZdPVHTicketId__c =: PVHParentIds]){
       		PVHParentIdToParentCaseIdMap.put(parCase.ZdPVHTicketId__c, parCase.id);
        }
        for(Case curCase : scope){
            if (PVHParentIdToParentCaseIdMap.containsKey(curCase.ZdParentTicketId__c)) {
                curCase.ParentId = PVHParentIdToParentCaseIdMap.get(curCase.ZdParentTicketId__c);
                childCasesforUpdate.add(curCase);
            }
        }

        if (childCasesforUpdate.size()>0) update childCasesforUpdate;
    }
    global void finish(Database.BatchableContext bc){}
}