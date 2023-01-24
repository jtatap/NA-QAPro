global class ContactDataExtraction implements Database.Batchable <sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( [select id,Brand_ID__c,IsProcessed__c,Subscriber_Key__c, Email__c 
                                          from Contact_Staging__c where IsProcessed__c=false AND (Subscriber_Key__c != null OR Email__c != null) limit 50000]); 
    }
    global void execute(Database.BatchableContext bc, List<Contact_Staging__c> conStgList) {
        set<Id> conStgIdSet = new set<Id>();
        set<string> conStgEmailSetFromInput = new set<string>();
        set<string> conStgEmailSet = new set<string>();
        map<string,contact> mapContactId=new map<string,contact>();
        map<string,contact> mapContactEmail=new map<string,contact>();
        map<string,Contact_Staging__c> mapConStag=new map<string,Contact_Staging__c>();
        //map<string,contact> mapContact=new map<string,contact>();
        map<string,contact>mapMasterCont=new  map<string,contact>();
        List<Contact_Staging__c> lstContStg=new List<Contact_Staging__c>();
        List<Contact_Staging__c> lstContStgNoSubKey=new List<Contact_Staging__c>();
        //looping to add Staging contact Id
        //system.debug('conStgList>>'+conStgList);
        Map<String,Boolean> emailNoSubKey = new Map<String,Boolean>();
        Map<String,Id> emailCSId = new Map<String,Id>();
        Map<String,Id> emailCSIdForDuplicate = new Map<String,Id>();
        for(Contact_Staging__c cont:conStgList){
            emailCSId.put(cont.Email__c,cont.Id);
            if(cont.Subscriber_Key__c != null){
                conStgIdSet.add(cont.Subscriber_Key__c);
                emailNoSubKey.put(cont.Email__c,false);
                //system.debug('conStgIdSet>>>'+conStgIdSet);
                system.debug('emailNoSubKey>>>'+emailNoSubKey);
            }
            else{
                conStgEmailSetFromInput.add(cont.Email__c);
                emailNoSubKey.put(cont.Email__c,true);
                //system.debug('conStgEmailSetFromInput>>>'+conStgEmailSetFromInput);
                system.debug('emailNoSubKey>>>'+emailNoSubKey);
            }
		}
        //Fetching the unique email and adding the master contact records
        for(contact objCont:[SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId 
                             FROM contact WHERE Id IN :conStgIdSet AND Brand_Id__c='2' ORDER BY lastmodifieddate DESC]){
            conStgEmailSet.add(objCont.Email);
            if(!mapContactId.containskey(objCont.id)){
                
                mapContactId.put(objCont.Id,objCont);
            } 
            system.debug('mapContactId>>>'+mapContactId);
        }
        for(contact objCont:[SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId 
                             FROM contact WHERE Email IN :conStgEmailSetFromInput AND Brand_Id__c='2' ORDER BY lastmodifieddate DESC]){
            conStgEmailSet.add(objCont.Email);
            if(!mapContactId.containskey(objCont.id)){
                
                mapContactId.put(objCont.Id,objCont);
            } 
            system.debug('mapContactId>>>'+mapContactId);
        }
        B2CCRMSyncDefaults__mdt b2cSyncDefaults = [SELECT B2C_CustomerList_ID__c, B2C_CustomerList__c, B2C_Disable_Integration__c, B2C_Instance__c, B2C_Is_Enabled__c, B2C_Integration_Status__c 
                                                   FROM B2CCRMSyncDefaults__mdt WHERE DeveloperName =  'B2CSyncData'];
        Map<String,Boolean> emailDeceasedMap = new Map<String,Boolean>();
        Map<String,Boolean> emailFraudMap = new Map<String,Boolean>();
        Map<String,Boolean> emailBulkBuyerMap = new Map<String,Boolean>();
        Map<String,String> emailOptinStatus = new Map<String,String>();
        Map<String,DateTime> emailOptinDate = new Map<String,DateTime>();
        Map<String,DateTime> emailOptoutDate = new Map<String,DateTime>();
        List<Contact> allContacts = [SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,
                                     Bulk_Buyer_Update_Date__c, Fraud__c,Loyalty_Optin_Date__c,WelcomeSource__c,
                                     LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, 
                                     Latest_Source__c 
                                     FROM contact 
                                     WHERE EMAIL IN :conStgEmailSet AND Brand_Id__c='2' 
                                     ORDER BY lastmodifieddate DESC];
        //Fetching the latest contacts based on the  email and filtering the contacts based on Staging contactid if no match found then adding the contact key as email
        System.debug('allContacts size '+allContacts.size());
        List<Contact> allContactsToCheck = new List<Contact>();
        allContactsToCheck.addAll(allContacts);
        System.debug('allContactsToCheck size '+allContactsToCheck.size());
        for(contact objCont: allContactsToCheck){//[SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,Loyalty_Optin_Date__c,WelcomeSource__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId FROM contact WHERE EMAIL IN :conStgEmailSet AND Brand_Id__c='2' ORDER BY lastmodifieddate DESC]
            emailDeceasedMap.put(objCont.Email,false);
            emailFraudMap.put(objCont.Email,false);
            emailBulkBuyerMap.put(objCont.Email,false);
            List<Contact> contactListForEmailOptin = new List<Contact>();
            List<Contact> conListToAdd = new List<Contact>();
            Contact conToAdd = new Contact();
            //added this logic to get the Deceased, Fraud and Bulk buyer
            for(String email: conStgEmailSet){
                for(Contact con: allContacts){
                    if(email == objCont.Email){
                        conListToAdd.add(con);
                        if(con.Deceased__c == true && emailDeceasedMap.get(objCont.Email) != true){
                			emailDeceasedMap.put(objCont.Email,true);
                		}
                		if(con.Fraud__c == true && emailFraudMap.get(objCont.Email) != true){
                			emailFraudMap.put(objCont.Email,true);
                		}
                        /*if(con.Bulk_Buyer__c == true && con.Bulk_Buyer_Update_Date__c != null){
                            system.debug('objCont.Email : '+objCont.Email+'con.Bulk_Buyer__c : '+con.Bulk_Buyer__c);
                			emailBulkBuyerMap.put(objCont.Email,con.Bulk_Buyer__c);
                		}*/
                	}
                }
                //added this logic to get leatest email optin/optout status
                Map<DateTime, String> emailOptinMap = new Map<DateTime, String>();
                Map<DateTime, String> emailOptoutMap = new Map<DateTime, String>();
                List<DateTime> emailOptinDates = new List<DateTime>();
                List<DateTime> emailOptoutDates = new List<DateTime>();
                DateTime maxEmailOptinDate;
				DateTime maxEmailOptoutDate;
                for(Contact con: conListToAdd){
                    emailOptinDates.add(con.EmailOptInDate__c);
                    emailOptoutDates.add(con.EmailOptOutDate__c);
                    emailOptinMap.put(con.EmailOptInDate__c, con.EmailOptInStatus__c);
                    emailOptoutMap.put(con.EmailOptOutDate__c, con.EmailOptInStatus__c);
                }
                if(emailOptinDates.size()>0){
                    emailOptinDates.sort();
                    maxEmailOptinDate = emailOptinDates[emailOptinDates.size() - 1];
                }
                if(emailOptoutDates.size()>0){
                    emailOptoutDates.sort();
                    maxEmailOptoutDate = emailOptoutDates[emailOptoutDates.size() - 1];
                }
                emailOptinDate.put(objCont.Email, maxEmailOptinDate);
                emailOptoutDate.put(objCont.Email, maxEmailOptoutDate);
                if(maxEmailOptinDate != null && maxEmailOptoutDate != null){
                    if(maxEmailOptinDate > maxEmailOptoutDate){
                    
                    emailOptinStatus.put(objCont.Email,emailOptinMap.get(maxEmailOptinDate));
                }
                else{
                    emailOptinStatus.put(objCont.Email,emailOptoutMap.get(maxEmailOptoutDate));
                	}
                }
                
            }
            system.debug('objCont>>>'+objCont);
            if(!mapContactEmail.containskey(objCont.Email)){
            	mapContactEmail.put(objCont.Email,objCont);
            }
            system.debug('mapContactEmail>>>'+mapContactEmail);
        }
                
        for(contact objCont:mapContactId.values()){
            Contact_Staging__c objConStg=new Contact_Staging__c();
            system.debug('mapContactEmail>>>'+mapContactEmail);
            if(mapContactEmail.containskey(objCont.Email)){
                
                objConStg.Subscriber_Key__c=objCont.id;
                objConStg.SFSC_Contact_Id__c=mapContactEmail.get(objCont.Email).id;
                objConStg.Welcome_source__c=objCont.WelcomeSource__c;
                objConStg.Loyalty_Flag__c=objCont.LoyaltyFlag__c;
                objConStg.Loyalty_ID__c=objCont.LoyaltyID__c;
                objConStg.Point_Balance__c=objCont.Point_Balance__c;
                objConStg.Loyalty_Optin_Date__c=objCont.Loyalty_Optin_Date__c;
                if(objCont.Loyalty_Optin_Date__c != null){
                    String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'.\'SSS';
                    String dateString = objCont.Loyalty_Optin_Date__c.format(dateFormat)+'-0000';
                    System.debug(dateString); 
                    objConStg.LoyaltyOptInDate__c = dateString;
                }
                /*if(emailBulkBuyerMap.get(objCont.Email) == true){
                    objConStg.Bulk_Buyer__c = emailBulkBuyerMap.get(objCont.Email);
                }
                else{
                    objConStg.Bulk_Buyer__c= mapContactEmail.get(objCont.Email).Bulk_Buyer__c;
                }*/
                objConStg.Bulk_Buyer__c= mapContactEmail.get(objCont.Email).Bulk_Buyer__c;
                objConStg.Fraud__c= emailFraudMap.get(objCont.Email);
                objConStg.Deceased__c= emailDeceasedMap.get(objCont.Email);
                if(emailOptinStatus.get(objCont.Email) != null){
                    objConStg.Email_Optin_Status__c = emailOptinStatus.get(objCont.Email);
                }
                else{
                    objConStg.Email_Optin_Status__c=objCont.EmailOptInStatus__c;
                }
                
                objConStg.Email__c=objCont.Email;
                objConStg.Latest_Source__c=objCont.Latest_Source__c;
                objConStg.SFSCAccountId__c=objCont.AccountId;
                //objConStg.B2C_CustomerList_ID__c  = b2cSyncDefaults.B2C_CustomerList_ID__c;
                //objConStg.B2C_CustomerList__c = b2cSyncDefaults.B2C_CustomerList__c;
                //objConStg.B2C_Disable_Integration__c = b2cSyncDefaults.B2C_Disable_Integration__c;
                //objConStg.B2C_Is_Enabled__c = b2cSyncDefaults.B2C_Is_Enabled__c;
                //objConStg.B2C_Integration_Status__c = b2cSyncDefaults.B2C_Integration_Status__c;
                objConStg.b2ccrm_syncStatus__c = 'exported';
				objConStg.IsProcessed__c=true;
                if(emailNoSubKey.get(objCont.Email) == false || objCont.Id == emailCSId.get(objCont.Email) ){
                	lstContStg.add(objConStg);
                }
                else if(emailNoSubKey.get(objCont.Email) == true || objCont.Id != emailCSId.get(objCont.Email)){
                    lstContStgNoSubKey.add(objConStg);
                    System.debug('lstContStgNoSubKey'+lstContStgNoSubKey);
                }
                system.debug('lstContStg>>>'+lstContStg);
                for(Contact_Staging__c cs:lstContStg){
                    System.debug('email, Id and Subscriber_Key__c : '+cs.Email_Optin_Status__c+' '+cs.Subscriber_Key__c+' '+cs.Email__c+' '+cs.Id);
                }
            }
        }
        System.debug('lstContStg.size() '+lstContStg.size());
        if(lstContStg.size()>0){
            //Update lstContStg;
            upsert lstContStg Subscriber_Key__c;
        }
        System.debug('lstContStgNoSubKey.size() '+lstContStgNoSubKey.size());
        List<Contact_Staging__c> listCSNoSubKeyToUpdate = new List<Contact_Staging__c>();
        Map<String, String> checkDuplicateIds = new Map<String, String>();
        if(lstContStgNoSubKey.size()>0){
            for(Contact_Staging__c cs1: lstContStgNoSubKey){
                if(!checkDuplicateIds.containsKey(cs1.Email__c)){
                	cs1.Id = emailCSId.get(cs1.Email__c);
                	System.debug('cs1 '+cs1);
                	listCSNoSubKeyToUpdate.add(cs1);
                    checkDuplicateIds.put(cs1.Email__c,cs1.Id);
                }
            }
            System.debug('listCSNoSubKeyToUpdate '+listCSNoSubKeyToUpdate.size());
            if(listCSNoSubKeyToUpdate.size() >0){
                for(Contact_Staging__c cs2: listCSNoSubKeyToUpdate){
                    System.debug('cs2 Id: '+cs2.Id);
                }
                database.update(listCSNoSubKeyToUpdate , false);
            }
        }
    }
    global void finish(Database.BatchableContext BC){} 
}