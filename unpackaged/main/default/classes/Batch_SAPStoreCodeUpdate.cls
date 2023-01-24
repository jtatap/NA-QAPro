/*
* @Author: PVH
*
* Purpose: Batch Apex to update Contacts
*
* JIRA NO		UPDATE DATE		UPDATED BY		UPDATE DESCRIPTION
* -------		-----------		----------		------------------
* NGCSI-1926	Sep-29-2021	    PVH			New Class created
*/

global class Batch_SAPStoreCodeUpdate implements Database.Batchable <sObject> {
    
    set<String> storeUniqIds=new set<String>();
    set<String> oldStoreUniqIds=new set<String>();
    set<String> signupStoreIds=new set<String>();
    
    global  Batch_SAPStoreCodeUpdate() {  
        List<SAP_Store_Codes__mdt> storeCodeList=[Select MasterLabel,New_StoreUniqueId__c from SAP_Store_Codes__mdt];
        for(SAP_Store_Codes__mdt str:storeCodeList){
            storeUniqIds.add(str.New_StoreUniqueId__c);
            oldStoreUniqIds.add(str.MasterLabel);
        } 
    }   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<Contact> consinstart = new List<Contact>([Select Id,Name,Brand_Id__c,Email,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact where ((HomeStore__c In:oldStoreUniqIds) OR (StoreOfCapture__c In:oldStoreUniqIds) OR (SignupStore__c In:oldStoreUniqIds)) AND Brand_Id__c='1' ORDER By LoyaltyID__c,LastModifiedDate Desc limit 40000]);
        
        return Database.getQueryLocator( [Select Id,Name,Brand_Id__c,Email,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact where ((HomeStore__c In:oldStoreUniqIds) OR (StoreOfCapture__c In:oldStoreUniqIds) OR (SignupStore__c In:oldStoreUniqIds)) AND Brand_Id__c='1' ORDER By LoyaltyID__c limit 40000]);    
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> conList) {
        Map<String,SAP_Store_Codes__mdt> storeIDsmap=new  Map<String,SAP_Store_Codes__mdt>();
        
        List<Contact> updatedSingConList=new List<Contact>();
        List<Contact> contList=new List<Contact>();
        List<Contact> multipleContactRecord=new List<Contact>();
        map<id,Contact> updatedConMap= new map<id,Contact>();
        map<id,Contact> Singconmap = new map<id,Contact>();
        
        for(SAP_Store_Codes__mdt sapMtd:[Select MasterLabel,New_StoreUniqueId__c from SAP_Store_Codes__mdt]){
            storeIDsmap.put(sapMtd.MasterLabel,sapMtd);
        }        
        
        set<Id> conIdSet = new set<Id>();
        Map<String,Contact> contactsMap = new Map<String,Contact>();
        
        
        for(Contact cont:conList)
        {
            conIdSet.add(cont.Id);
        }
        Map<String, Contact> loyalandcons = new Map<String, Contact>();
        for(Contact conta: [Select Id,Name,Email,Brand_Id__c,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact where Brand_Id__c='1' AND Id IN:conIdSet order by LastModifiedDate ])
        {
            if(!contactsMap.containsKey(conta.Id) && !loyalandcons.containskey(conta.LoyaltyID__c))
            {
                contactsMap.put(conta.Id, conta);
                loyalandcons.put(conta.LoyaltyID__c, conta);                
            }  
        }
        System.debug('*contactsMap*'+contactsMap);
        
        if(contactsMap.values().size()>0 && storeIDsmap.values().size()>0) {
            for(Contact contMap:contactsMap.values()){
                if(storeIDsmap.containsKey(contMap.HomeStore__c)) {
                    contMap.HomeStore__c=storeIDsmap.get(contMap.HomeStore__c).New_StoreUniqueId__c;
                }
                if(storeIDsmap.containsKey(contMap.StoreOfCapture__c)) {
                    contMap.StoreOfCapture__c=storeIDsmap.get(contMap.StoreOfCapture__c).New_StoreUniqueId__c;
                }
                if(storeIDsmap.containsKey(contMap.SignupStore__c)) {
                    contMap.SignupStore__c=storeIDsmap.get(contMap.SignupStore__c).New_StoreUniqueId__c;
                }
                
                updatedConMap.put(contMap.Id,contMap); 
            } 
        }
        
        System.Debug('updatedConMap.size'+ updatedConMap.size());
        if(updatedConMap.size()>0) {
            update updatedConMap.values();
        }                
    }
    global void finish(Database.BatchableContext BC){}     
}