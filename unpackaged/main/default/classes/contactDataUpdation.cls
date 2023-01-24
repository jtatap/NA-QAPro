global class contactDataUpdation implements Database.Batchable<sObject>, Database.Stateful {
    
    Private String fileName;
    
    global contactDataUpdation(String fileName1){
        fileName = fileName1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Create a field CustomerId__c in contact staging objecta and include it in the below query
        return Database.getQueryLocator([SELECT id,Email__c, Subscriber_Key__c, UpdatePointBalance__c, CustomerNumber__c, SFSC_Contact_Id__c     
                                          FROM Contact_Staging__c WHERE FileName__c =:fileName AND IsProcessed__c = true]); 
    }
    
    global void execute(Database.BatchableContext bc, List<Contact_Staging__c> conStgList) {
        set<Id> conIdSet = new set<Id>();
        Set<String> conStgEmailSet = new Set<String>();
        Map<String, String> subKeyCustomerListMap = new Map<String, String>();
        map<string,contact> mapContactId=new map<string,contact>();
        map<string,Contact_Staging__c> mapConStag=new map<string,Contact_Staging__c>();
        for(Contact_Staging__c contStaging:conStgList){
            //System.debug('contStaging.Subscriber_Key__c'+contStaging.Subscriber_Key__c);
            //conIdSet.add(contStaging.Subscriber_Key__c);//SFSC_Contact_Id__c
            System.debug('contStaging.SFSC_Contact_Id__c'+contStaging.SFSC_Contact_Id__c);
            conIdSet.add(contStaging.SFSC_Contact_Id__c);//SFSC_Contact_Id__c
            String emailAndId = contStaging.Email__c+contStaging.SFSC_Contact_Id__c;
            System.debug('emailAndId : '+emailAndId);
            mapConStag.put(emailAndId,contStaging);
            system.debug('conIdSet>>>'+conIdSet);
        }
        B2CCRMSyncDefaults__mdt b2cSyncDefaults = [SELECT B2C_CustomerList_ID__c, B2C_CustomerList__c, B2C_Disable_Integration__c, B2C_Instance__c, B2C_Is_Enabled__c, B2C_Integration_Status__c 
                                                   FROM B2CCRMSyncDefaults__mdt WHERE DeveloperName =  'B2CSyncData'];
        List<Contact> conListToUpdate = new List<Contact>();
        
        for(contact objCont:[SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c 
                             FROM contact WHERE ID IN :conIdSet]){
            List<Contact> contactListForEmailOptin = new List<Contact>();
            List<Contact> conListToAdd = new List<Contact>();
            Contact conToAdd = new Contact();
            //get the B2C data form custom metadata
            //Assigning the B2C values and point balence to contact object
            conToAdd.Id = objCont.Id;
			String emailAndId = objCont.Email+objCont.Id;
			System.debug('emailAndId : '+emailAndId);
            System.debug('mapConStag.get(emailAndId).CustomerNumber__c : '+mapConStag.get(emailAndId).CustomerNumber__c);
			conToAdd.B2C_Customer_No__c = mapConStag.get(emailAndId).CustomerNumber__c;
			//conToAdd.B2C_CustomerId__c = mapConStag.get(emailAndId).CustomerId__c; // will be provided later by SFCC, enable this to update the CustomerId__c
            conToAdd.B2C_CustomerList_ID__c = b2cSyncDefaults.B2C_CustomerList_ID__c;
			conToAdd.B2C_CustomerList__c = b2cSyncDefaults.B2C_CustomerList__c;
			conToAdd.B2C_Disable_Integration__c = b2cSyncDefaults.B2C_Disable_Integration__c;
			conToAdd.B2C_Is_Enabled__c = b2cSyncDefaults.B2C_Is_Enabled__c;
			conToAdd.B2C_Integration_Status__c = b2cSyncDefaults.B2C_Integration_Status__c;
            //conToAdd.Point_Balance__c = mapConStag.get(objCont.Email).UpdatePointBalance__c;
            conListToUpdate.add(conToAdd);
            System.debug('conListToUpdate'+conListToUpdate);
        }
        if(conListToUpdate.size()>0){
            update conListToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC){} 
}