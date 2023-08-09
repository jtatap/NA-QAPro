global class Batch_SAPStoreCodeUpdate implements Database.Batchable <sObject>,Database.Stateful{
    
    set<String> storeUniqIds=new set<String>();
    set<String> oldStoreUniqIds=new set<String>();
    set<String> signupStoreIds=new set<String>();
    public integer count = 0;  
    public List<Id> lstId=new List<Id>();  
    global  Batch_SAPStoreCodeUpdate(){  
        List<SAP_Store_Codes__mdt> storeCodeList=[Select MasterLabel,New_StoreUniqueId__c from SAP_Store_Codes__mdt];
        for(SAP_Store_Codes__mdt str:storeCodeList){
            storeUniqIds.add(str.New_StoreUniqueId__c);
            oldStoreUniqIds.add(str.MasterLabel);
        } 
    }   
    global Database.QueryLocator start(Database.BatchableContext bc){
        //List<Contact> consinstart = new List<Contact>([Select Id,Name,Brand_Id__c,Email,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact where ((HomeStore__c In:oldStoreUniqIds) OR (StoreOfCapture__c In:oldStoreUniqIds) OR (SignupStore__c In:oldStoreUniqIds)) AND Brand_Id__c='1' ORDER By LoyaltyID__c,LastModifiedDate Desc limit 5000]);
        return Database.getQueryLocator( [SELECT HomeStore__c, SignupStore__c, StoreOfCapture__c, Brand_Id__c FROM Contact 
                                          WHERE ((HomeStore__c IN ('0212TO','0209TO','0229TO','0026TO','TO187','0192TO','TO888','0113TO','0757TC','TO002','TO179','TO156','TO060','0072TO','0013TO','TO065',
                                                                   '0998TC','TO228','0733TC','0206TO','TC758','0081TO','TO068','0593TX','TO265','TC992','0160TO','0255TO','0748TC','TC713','TO116','TO254','TO264','0021TO','0023TO','0992TO',
                                                                   '0118TO','TC759','TO012','TO043','TC733','0224TO','0132TO','TO239','0156TO','TO066','TO022','TC730','0758TC','0717TC','TC998','TO218','TC711','TO230','TO207','TO305',
                                                                   'TO121','0131TO','0180TO','0207TO','0254TO','0230TO','0039TO','TO244','0732TC','0235TO','TC863','0706TC','TO215','0171TO','TO073','0188TO','0704TC','TO139','0217TO','TO119',
                                                                   'TO071','TO009','0173TO','0084TO','TC704','0998TO','0265TO','0751TC','TO040','TO245','0108TO','0179TO','TO039','TO210','0044TO','TC999','0248TO','TC723','TO201','0900TO','TO196',
                                                                   'TO112','TC708','TO058','0999TO','0151TO','0195TO','0701TC','0737TC','0079TO','TO063','0759TC','TO153','0061TO') OR StoreOfCapture__c IN ('0212TO','0209TO','0229TO','0026TO','TO187','0192TO','TO888','0113TO','0757TC','TO002','TO179','TO156','TO060','0072TO','0013TO','TO065',
                                                                                                                                                                                                             '0998TC','TO228','0733TC','0206TO','TC758','0081TO','TO068','0593TX','TO265','TC992','0160TO','0255TO','0748TC','TC713','TO116','TO254','TO264','0021TO','0023TO','0992TO',
                                                                                                                                                                                                             '0118TO','TC759','TO012','TO043','TC733','0224TO','0132TO','TO239','0156TO','TO066','TO022','TC730','0758TC','0717TC','TC998','TO218','TC711','TO230','TO207','TO305',
                                                                                                                                                                                                             'TO121','0131TO','0180TO','0207TO','0254TO','0230TO','0039TO','TO244','0732TC','0235TO','TC863','0706TC','TO215','0171TO','TO073','0188TO','0704TC','TO139','0217TO','TO119',
                                                                                                                                                                                                             'TO071','TO009','0173TO','0084TO','TC704','0998TO','0265TO','0751TC','TO040','TO245','0108TO','0179TO','TO039','TO210','0044TO','TC999','0248TO','TC723','TO201','0900TO','TO196',
                                                                                                                                                                                                             'TO112','TC708','TO058','0999TO','0151TO','0195TO','0701TC','0737TC','0079TO','TO063','0759TC','TO153','0061TO') OR SignupStore__c IN ('0212TO','0209TO','0229TO','0026TO','TO187','0192TO','TO888','0113TO','0757TC','TO002','TO179','TO156','TO060','0072TO','0013TO','TO065',
                                                                                                                                                                                                                                                                                                                                                    '0998TC','TO228','0733TC','0206TO','TC758','0081TO','TO068','0593TX','TO265','TC992','0160TO','0255TO','0748TC','TC713','TO116','TO254','TO264','0021TO','0023TO','0992TO',
                                                                                                                                                                                                                                                                                                                                                    '0118TO','TC759','TO012','TO043','TC733','0224TO','0132TO','TO239','0156TO','TO066','TO022','TC730','0758TC','0717TC','TC998','TO218','TC711','TO230','TO207','TO305',
                                                                                                                                                                                                                                                                                                                                                    'TO121','0131TO','0180TO','0207TO','0254TO','0230TO','0039TO','TO244','0732TC','0235TO','TC863','0706TC','TO215','0171TO','TO073','0188TO','0704TC','TO139','0217TO','TO119',
                                                                                                                                                                                                                                                                                                                                                    'TO071','TO009','0173TO','0084TO','TC704','0998TO','0265TO','0751TC','TO040','TO245','0108TO','0179TO','TO039','TO210','0044TO','TC999','0248TO','TC723','TO201','0900TO','TO196',
                                                                                                                                                                                                                                                                                                                                                    'TO112','TC708','TO058','0999TO','0151TO','0195TO','0701TC','0737TC','0079TO','TO063','0759TC','TO153','0061TO'))) AND Brand_Id__c ='1' Limit 50000]); 
        // return Database.getQueryLocator( [Select Id,Name,Brand_Id__c,Email,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact  where ((HomeStore__c In:oldStoreUniqIds) OR (StoreOfCapture__c In:oldStoreUniqIds) OR (SignupStore__c In:oldStoreUniqIds) ) Limit 5000]); 
        // return Database.getQueryLocator( [Select Id,Name,Brand_Id__c,Email,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact Limit 50000]);    
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> conList){
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
        List<Contact> orderedLoyaltyList=new List<Contact>();
        // orderedLoyaltyList=[Select Id,Name,Email,Brand_Id__c,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact where Brand_Id__c='1' AND Id IN:conIdSet order by LoyaltyID__c];
        for(Contact conta: [Select Id,Name,Email,Brand_Id__c,HomeStore__c,LastModifiedDate,LoyaltyID__c,StoreOfCapture__c,SignupStore__c from Contact where Brand_Id__c='1' AND Id IN:conIdSet order by LoyaltyID__c,LastModifiedDate])
        {
            Log.push('*contactsMap inside for*'+contactsMap);
            if(!contactsMap.containsKey(conta.Id) && !loyalandcons.containskey(conta.LoyaltyID__c))
            { 
                // Log.push('*contactsMap inside if*'+contactsMap);
                contactsMap.put(conta.Id, conta);
                loyalandcons.put(conta.LoyaltyID__c, conta);
                
            }
            
            
            
        }
        //Log.push('*contactsMap*'+contactsMap);
        
        if(contactsMap.values().size()>0 && storeIDsmap.values().size()>0){
            for(Contact contMap:contactsMap.values()){
                // Log.push('*contacts Brand *'+contMap.id);
                if(storeIDsmap.containsKey(contMap.HomeStore__c)){
                    //  Log.push('*contacts Brand before*'+contMap.HomeStore__c);
                    contMap.HomeStore__c=storeIDsmap.get(contMap.HomeStore__c).New_StoreUniqueId__c;
                    // Log.push('*contacts Brand after *'+contMap.HomeStore__c);
                }
                if(storeIDsmap.containsKey(contMap.StoreOfCapture__c)){
                    //  Log.push('*contacts Brand before*'+contMap.StoreOfCapture__c);
                    contMap.StoreOfCapture__c=storeIDsmap.get(contMap.StoreOfCapture__c).New_StoreUniqueId__c;
                    //  Log.push('*contacts Brand after*'+contMap.StoreOfCapture__c);
                }
                if(storeIDsmap.containsKey(contMap.SignupStore__c)){
                    //  Log.push('*contacts Brand before*'+contMap.SignupStore__c);
                    contMap.SignupStore__c=storeIDsmap.get(contMap.SignupStore__c).New_StoreUniqueId__c;
                    // Log.push('*contacts Brand after*'+contMap.SignupStore__c);
                }
                
                updatedConMap.put(contMap.Id,contMap); 
                lstId.add(contMap.id);
            } 
        }
        
        //Log.push('updatedConMap.size'+ updatedConMap.size());
        if(updatedConMap.size()>0){
            count=count + updatedConMap.size();
            
            update updatedConMap.values();
            
        }
        Logger.logDebug();
        
        
    }
    global void finish(Database.BatchableContext BC){
        //Log.push(count);
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'jayaseelatatapudi@pvh.com','hemadri@stabilistech.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job is done');
        mail.setPlainTextBody('Total' +'  '+ count +'  '+ 'Records updated sucessfully' +lstId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }  
    
    
    
}