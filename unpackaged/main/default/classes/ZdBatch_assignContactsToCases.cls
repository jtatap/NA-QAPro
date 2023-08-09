/**
 * Created by venkatpenukonda on 2019-10-31.
 */

global class ZdBatch_assignContactsToCases implements Database.Batchable <sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, ZdPVHTicketId__c, ZdTnCTicketId__c, ZdTnCUserId__c, ZdPVHUserId__c  FROM Case WHERE ContactId = null AND (ZdPVHTicketId__c != null OR ZdTnCTicketId__c!=null)  ORDER BY ZdTnCUserId__c, ZdPVHUserId__c');
    }
    global void execute(Database.BatchableContext bc, List<Case> scope){



        List <Case> noParentCases = new List<Case>();


        Map<String, Contact> ZdTnCContactMap = new Map<String, Contact>();
        Map<String, Contact> ZdPVHContactMap = new Map<String, Contact>();
        Set<String> setCaseZdTnCUserIds = new Set<String>();
        Set<String> setCaseZdPVHUserIds = new Set<String>();


        for(Case noParentCase : scope) {
            if (noParentCase.ZdTnCTicketId__c != null ) {
                setCaseZdTnCUserIds.add(noParentCase.ZdTnCUserId__c) ;

            }
            if (noParentCase.ZdPVHTicketId__c != null ) {
                setCaseZdPVHUserIds.add(noParentCase.ZdPVHUserId__c) ;


            }

        }

        if (setCaseZdPVHUserIds.size()>0 || setCaseZdTnCUserIds.size() > 0) {

            for (Contact c : [
                    SELECT Id, AccountId, ZdTnCUserId__c, ZdPVHUserId__c
                    FROM Contact
                    WHERE ZdTnCUserId__c IN :setCaseZdTnCUserIds OR ZdPVHUserId__c IN :setCaseZdPVHUserIds
            ]) {
                if (c.ZdTnCUserId__c != null) ZdTnCContactMap.put(c.ZdTnCUserId__c, c);
                if (c.ZdPVHUserId__c != null) ZdPVHContactMap.put(c.ZdPVHUserId__c, c);


            }
        }


        for(Case noParentCase : scope) {
            Contact con;
            if(noParentCase.ZdTnCUserId__c !=null && ZdTnCContactMap.containsKey(noParentCase.ZdTnCUserId__c)){
                con = ZdTnCContactMap.get(noParentCase.ZdTnCUserId__c);
            } else if(noParentCase.ZdPVHUserId__c !=null && ZdPVHContactMap.containsKey(noParentCase.ZdPVHUserId__c )!=null){
                con = ZdPVHContactMap.get(noParentCase.ZdPVHUserId__c);
            }



            if(con != null) {
                noParentCase.ContactId = con.id;
                noParentCase.AccountId = con.AccountId;
                noParentCases.add(noParentCase);
            }

        }
        if (noParentCases.size()> 0) update noParentCases;

    }
    global void finish(Database.BatchableContext bc){

        
    }
}