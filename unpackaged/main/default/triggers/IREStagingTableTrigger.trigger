trigger IREStagingTableTrigger on IRE_StagingTable__c (after insert) {
    List<String> subscriberKeyList = new List<String>();
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
                SELECT Id, Email,Brand_Id__c,LoyaltyID__c, Loyalty_Optin_Date__c,Ecomm_Connected__c
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

    if (contactList.size()>0) {
        for (Contact conResult : contactList) {
            	List<Contact> initialUpdateList = new List<Contact>();
                IRE_StagingTable__c ireRecord = subkeyToIREMap.get(conResult.Id);
            	//MGDCTH-442- check if Loyalty id is same-START
            if((ireRecord.MasterCustomerId__c != null) & (conResult.LoyaltyID__c != null)){
                 if (!(((ireRecord.MasterCustomerId__c.toUpperCase()).equals(conResult.LoyaltyID__c)) || (ireRecord.MasterCustomerId__c.equals(conResult.LoyaltyID__c)))){
                    System.debug('contact will be updated with MasterCustomerId__c');
                    initialUpdateList.add(conResult);
                    
                    /**
                       check if the given conatct is ecomm connected.
                       If not search ecomm connected record with same Email + Brand ID
					**/
                    
                    if(!(conResult.Ecomm_Connected__c)){
                        List<Contact> contactListForEcomm = new List<Contact>();
                    contactListForEcomm = [
                        SELECT Id, Email, Brand_Id__c,LoyaltyID__c, Loyalty_Optin_Date__c,Ecomm_Connected__c
                        FROM Contact
                        WHERE Email = :conResult.Email AND Brand_Id__c = :conResult.Brand_Id__c AND Ecomm_Connected__c = True
                ];
                if (contactListForEcomm.size()>0) {
                    for (Contact ecomContact : contactListForEcomm) {

                        initialUpdateList.add(ecomContact);
                    }  

                }
                    }
				//MGDCTH-442- check if Loyalty id is same-END
                    for (Contact con : initialUpdateList) {
                    con.LoyaltyID__c = ireRecord.MasterCustomerId__c.toUpperCase();
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
          
                 }}
        }
    }


    System.debug('***contactToUpdateList:'+contactToUpdateList);
    if(contactToUpdateList.size()>0){
        Database.SaveResult[] srList = Database.update(contactToUpdateList, false);
        ContactUtility.createErrorLogRecords(srList,'IRE',trigger.new[0].FileName__c);
    }
}