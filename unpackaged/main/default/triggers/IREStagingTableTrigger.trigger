trigger IREStagingTableTrigger on IRE_StagingTable__c (after insert) {
    /*List<String> subscriberKeyList = new List<String>();
    Map<String,IRE_StagingTable__c> subkeyToIREMap = new Map<String,IRE_StagingTable__c>();
    List<Contact> contactToUpdateList = new List<Contact>();
  //  Map<String,List<Contact>> subscriberKeyContactMap = new Map<String,List<Contact>>();
    
    for(IRE_StagingTable__c ireRecord : trigger.new){
        if (ireRecord.SubscriberKey__c!=null) {
            subscriberKeyList.add(ireRecord.SubscriberKey__c);
            subkeyToIREMap.put(ireRecord.SubscriberKey__c, ireRecord);

        }
    }
    System.debug('***subscriberKeyList: '+subscriberKeyList);
    
    List<Contact> contactList = new List<Contact>();
    if (subscriberKeyList.size()>0) {
        contactList = [
                SELECT Id, LoyaltyID__c, Loyalty_Optin_Date__c
                FROM Contact
                WHERE Id IN:subscriberKeyList
        ];
    }
    System.debug('***contactList:'+contactList);
 /**
    for(Contact con : contactList){
        if(subscriberKeyContactMap.containsKey(con.Id)){
            subscriberKeyContactMap.get(con.Id).add(con);
        }else{
            subscriberKeyContactMap.put(con.Id, new List<Contact> {con});
        }
    }
    System.debug('***subscriberKeyContactMap:'+subscriberKeyContactMap);
    
    for(IRE_StagingTable__c ireRecord : trigger.new){
        List<Contact> conlist = new List<Contact>();
        if (subscriberKeyContactMap.containsKey(ireRecord.SubscriberKey__c)) conList = subscriberKeyContactMap.get(ireRecord.SubscriberKey__c);
        if(conlist.size()>0){
            for(Contact con :conlist){
                con.LoyaltyID__c = ireRecord.MasterCustomerId__c;
                if(String.isBlank(String.valueOf(ireRecord.IREDeactivationDate__c)) && String.isNotBlank(String.valueOf(ireRecord.IREReactivationDate__c))){
                    con.LoyaltyMergeDate__c = ireRecord.IREReactivationDate__c;
                }
                if(String.isBlank(String.valueOf(ireRecord.IREReactivationDate__c)) && String.isNotBlank(String.valueOf(ireRecord.IREDeactivationDate__c))){
                    con.LoyaltyMergeDate__c = ireRecord.IREDeactivationDate__c;
                }
                if(String.isNotBlank(String.valueOf(ireRecord.IREReactivationDate__c)) && String.isNotBlank(String.valueOf(ireRecord.IREDeactivationDate__c))){
                    if(ireRecord.IREDeactivationDate__c > ireRecord.IREReactivationDate__c){
                        con.LoyaltyMergeDate__c = ireRecord.IREDeactivationDate__c;
                    } else {
                        con.LoyaltyMergeDate__c = ireRecord.IREReactivationDate__c;   
                    }
                }                
                contactToUpdateList.add(con);
            }
        }
    }
    **/

    /*if (contactList.size()>0) {
        for (Contact con : contactList) {
            IRE_StagingTable__c ireRecord = subkeyToIREMap.get(con.Id);
            con.LoyaltyID__c = ireRecord.MasterCustomerId__c;
            if(String.isBlank(String.valueOf(ireRecord.IREDeactivationDate__c)) && String.isNotBlank(String.valueOf(ireRecord.IREReactivationDate__c))){
                con.LoyaltyMergeDate__c = ireRecord.IREReactivationDate__c;
            }
            if(String.isBlank(String.valueOf(ireRecord.IREReactivationDate__c)) && String.isNotBlank(String.valueOf(ireRecord.IREDeactivationDate__c))){
                con.LoyaltyMergeDate__c = ireRecord.IREDeactivationDate__c;
            }
            if(String.isNotBlank(String.valueOf(ireRecord.IREReactivationDate__c)) && String.isNotBlank(String.valueOf(ireRecord.IREDeactivationDate__c))){
                if(ireRecord.IREDeactivationDate__c > ireRecord.IREReactivationDate__c){
                    con.LoyaltyMergeDate__c = ireRecord.IREDeactivationDate__c;
                } else {
                    con.LoyaltyMergeDate__c = ireRecord.IREReactivationDate__c;
                }
            }
            contactToUpdateList.add(con);



        }
    }


    System.debug('***contactToUpdateList:'+contactToUpdateList);
    if(contactToUpdateList.size()>0){
        Database.SaveResult[] srList = Database.update(contactToUpdateList, false);
        ContactUtility.createErrorLogRecords(srList,'IRE',trigger.new[0].FileName__c);
    }*/
    TriggerDispatcher.run(new NF_IREStagingTableTriggerHandler());
}