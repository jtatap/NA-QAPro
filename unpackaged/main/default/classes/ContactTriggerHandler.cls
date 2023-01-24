/* * 
* NASSC-1114 
* NASSC-1250
* NASSC-1253
* NASSC-1311
* NASSC-1412
* NASSC-1463
*/
public without sharing class ContactTriggerHandler implements ITrigger {
    
    public static Set<String> parentBrandIdSet = new Set<String>(); 
    public static Set<Id> parentContactIdSet = new Set<Id>();
    public static boolean isExecuted;
    public static Map<String,Set<String>> brandMap = new Map<String,Set<String>>();
    public static Id emailRecordTypeId;
    public static Map<String,StoreMaster__c> storeMasterMap = new Map<String,StoreMaster__c>();
    
    public ContactTriggerHandler(){       
        isExecuted = false;
        emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId(); 
        Map<id,LoyaltySettings__mdt> listLoyaltySettingMap=new Map<id,LoyaltySettings__mdt>([Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt]);
        //List<LoyaltySettings__mdt> LoyaltySettingList = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt];
        List<LoyaltySettings__mdt> LoyaltySettingList=listLoyaltySettingMap.values();
        //Creates map of Parentlevel brans and subbrands 
        if(! LoyaltySettingList.isEmpty()){        
            for(LoyaltySettings__mdt loyalRecord : LoyaltySettingList){
                if(loyalRecord.Parent_Brand__c != null){
                    parentBrandIdSet.add(loyalRecord.Parent_Brand__c);  
                    if(brandMap.containsKey(loyalRecord.Parent_Brand__c)){
                        brandMap.get(loyalRecord.Parent_Brand__c).add(loyalRecord.BrandId__c);
                    }else{
                        Set<String> subBrandIdSet = new Set<String>();
                        subBrandIdSet.add(loyalRecord.BrandId__c);
                        brandMap.put(loyalRecord.Parent_Brand__c,subBrandIdSet);  
                    }    
                } 
            }
        }         
        if(! LoyaltySettingList.isEmpty()){        
            for(LoyaltySettings__mdt loyalRecord : LoyaltySettingList){
                if(loyalRecord.Parent_Brand__c == null && ! brandMap.containsKey(loyalRecord.BrandId__c) ){
                    brandMap.put(loyalRecord.BrandId__c,new Set<String>());  
                }
            }
        } 
        
    }
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
* 
* NASSC-1114
* NASSC-1250
*/
    public void bulkBefore() {        
       
        if(trigger.isInsert) {
            Map<Contact, SObject> sequenceObjMap = new Map<Contact, SObject>();
            Set<String> subBrandEmail = new Set<String>();
            Set<String> subBrand = new Set<String>(); 
            List<Contact> subBrandcontacts = new List<Contact>();
            Map <String,Contact> searchParentEmailContactMap = new Map <String,Contact>();
            List<Contact> parentBrandContact = new List<Contact>();
            List<Contact> subBrandContactList = new List<Contact>();
            
            Set<String> conStoreofCaptureSet = new Set<String>();
            
            for(sObject insertRec :Trigger.New) {
                Contact con = (Contact)insertRec;
                //NASSC-1463
                if(String.isNotEmpty(con.StoreOfCapture__c)) conStoreofCaptureSet.add(con.StoreOfCapture__c);           
                
                if(con.AccountId == null && con.Source_System__c!='SFSC'){
                    if(brandMap.containskey(con.Brand_Id__c)){//parent level contact);
                        parentBrandContact.add(con);  
                    }else if (con.Source_System__c!='SFSC'){//subbrand level contact
                        subBrandContactList.add(con);
                    }
                }
                
                if(String.isNotEmpty(con.Brand_Id__c) && String.isEmpty(con.LoyaltyID__c)){      
                    LoyaltySettings__mdt loyaltySetting;
                    Map<id,LoyaltySettings__mdt> listLoyaltySettingMap=new Map<id,LoyaltySettings__mdt>([Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where BrandId__c = :con.Brand_Id__c ]);
                   // List<LoyaltySettings__mdt> listLoyaltySettingList = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where BrandId__c = :con.Brand_Id__c ];
                   List<LoyaltySettings__mdt> listLoyaltySettingList=listLoyaltySettingMap.values();
                    if(listLoyaltySettingList.size()>0) 
                        for (Integer i = 0;i<listLoyaltySettingList.size();i++) {
                                   loyaltySetting = listLoyaltySettingList[i];
                           }
                       //  loyaltySetting = listLoyaltySettingList[0];
                       
                    
                    if(loyaltySetting != null){
                       
                        
                        if(String.isNotEmpty(loyaltySetting.BrandId__c )  && String.isEmpty(con.LoyaltyID__c) && loyaltySetting.IsLoyaltyApplicable__c == true){
                            if(String.isEmpty(loyaltySetting.Parent_Brand__c)){
                                //BrandId__c is a Parent Brand                            
                                LoyaltyID_Sequence__c sObj = new LoyaltyID_Sequence__c();
                                sequenceObjMap.put(con,sObj);
                            } else if(String.isNotEmpty(loyaltySetting.Parent_Brand__c)){
                                // Check if Parent Brand Exists for this sub brand contact
                                if(String.isNotBlank(con.Email)) subBrandEmail.add(con.Email);
                                if(String.isNotBlank(loyaltySetting.Parent_Brand__c)) subBrand.add(loyaltySetting.Parent_Brand__c);
                                subBrandcontacts.add(con);
                            }
                        } 
                    }                    
                }
            }            
            if(sequenceObjMap.values().size() > 0){
                ContactUtility.assignLoyaltyId(sequenceObjMap); // NASSC-1066    
            }
            if(subBrandEmail.size()>0){
                List<Contact> parentContactList = [SELECT ID, Brand_Id__c, Email, LoyaltyID__c, LoyaltyFlag__c, Loyalty_Optin_Date__c
                                                   FROM Contact 
                                                   WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c IN :subBrand AND Email = :subBrandEmail AND LoyaltyID__c!=null];
                
                if(parentContactList.size()>0){
                    //set Parent.Loyalty id as loyalty id
                    for(Contact c : parentContactList){
                        searchParentEmailContactMap.put(c.Email, c);
                    }
                    if(searchParentEmailContactMap.values().size()>0){
                        for(Contact subBrandContact: subBrandcontacts){
                            Contact parentContact = searchParentEmailContactMap.get(subBrandContact.Email);
                            if(parentContact !=null) {  // NACDT-3457
                                if (parentContact.LoyaltyID__c != null) subBrandContact.LoyaltyID__c = parentContact.LoyaltyID__c;
                                if (parentContact.LoyaltyFlag__c != null) subBrandContact.LoyaltyFlag__c = parentContact.LoyaltyFlag__c;
                                if (parentContact.Loyalty_Optin_Date__c != null) subBrandContact.Loyalty_Optin_Date__c = parentContact.Loyalty_Optin_Date__c;
                            }

                        }
                    }                    
                } 
            }       
            if(! parentBrandContact.isEmpty()){
                checkExistingContacts(parentBrandContact);
            }
            if(! subBrandContactList.isEmpty()){
                searchParentBrandContact(subBrandContactList);  
            }
            
            List<StoreMaster__c> storeMasterList = [SELECT StoreUniqueId__c, Brand__c, StoreNumber__c, Status__c, Country__c, ChainId__c FROM StoreMaster__c 
                                WHERE StoreUniqueId__c in :conStoreofCaptureSet  ];
            
            if(storeMasterList.size()>0){
            for(StoreMaster__c s : storeMasterList) {

                    storeMasterMap.put(s.StoreUniqueId__c, s);

            }
            }

            // set countryOfCapture and Channel based on StoreMaster map
            List <Contact> emailPrefsContacts = new List<Contact>();
            for(sObject insertRec :Trigger.New) {
                Contact con = (Contact) insertRec;


                if (storeMasterMap.size() > 0) { //NASSC-1463
                    if (String.isNotEmpty(con.StoreOfCapture__c)) {

                        if (storeMasterMap.containsKey(con.StoreOfCapture__c)) {
                            if (storeMasterMap.get(con.StoreOfCapture__c).Country__c != null) con.CountryOfCapture__c = storeMasterMap.get(con.StoreOfCapture__c).Country__c;
                           if(storeMasterMap.get(con.StoreOfCapture__c).ChainId__c!=Null){
                            if (con.Brand_Id__c == '1' && String.isEmpty(con.Channel__c) && Integer.valueOf(storeMasterMap.get(con.StoreOfCapture__c).ChainId__c) == 2) {
                                con.Channel__c = '1';
                            }
                           }
                        }
                    }
                }
                if (con.Source_System__c!=null && con.Brand_Id__c!=null) emailPrefsContacts.add(con);
            }
            if (emailPrefsContacts.size()>0) setEmailPreference(emailPrefsContacts);

        }
        
        if(Trigger.isDelete) {
            GenericRecords__c genericContactRecord = GenericRecords__c.getValues(Constants.privacyContactGenericRecordSettingName);
            Contact genericContact = [Select Id, AccountId from Contact where Id = :genericContactRecord.recordId__c];
            
            List<SObject> recordsToDisassociate = new List<SObject>();
            Set<Id> contactIds = Trigger.oldMap.keySet();
            
            //Disassociate Cases
            for(Case c :[Select Id, ContactId from Case where ContactId in :contactIds]) {
                c.ContactId = null;
                recordsToDisassociate.add(c);
            }
            
            //Reassociate Assets
            for(Asset a :[Select Id, ContactId from Asset where ContactId in :contactIds AND Id in (Select AssetId from Case where AssetId != null)]) {
                a.ContactId = genericContact.Id;
                recordsToDisassociate.add(a);
            }
            
            //Disassociate Contracts
            for(Contract ct :[Select Id, CustomerSignedId from Contract where CustomerSignedId in :contactIds]) {
                ct.CustomerSignedId = null;
                recordsToDisassociate.add(ct);
            }
            
            update recordsToDisassociate;
        }
    }
    
    /**
* bulkAfter
*
* This method is called prior to execution of an AFTER trigger. Use this to cache
* any data required into maps prior execution of the trigger.
* NASSC-1253
*/
    public void bulkAfter() {
       
        Map<Id,Contact> oldMap = (Map<Id,Contact>)trigger.oldMap;       
        List<Contact> conList = (List<Contact>) Trigger.New;
        if(trigger.isUpdate ) {
            for(Contact newCon :(List<Contact>) Trigger.New) {
                Contact oldCon = oldMap.get(newCon.id);
                //check if update is for parent brand
                if(parentBrandIdSet.contains(newCon.Brand_Id__c)){
                    if(newCon.EmailOptInStatus__c == 'Y' && oldCon.EmailOptInStatus__c != 'Y' ){
                        parentContactIdSet.add(newCon.id);
                        isExecuted = true;
                    }
                }
            }
        }  
    }
    
    
    /**
* beforeInsert
*
* This method is called iteratively for each record to be inserted during a BEFORE
* trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
*/
    public void beforeInsert(SObject obj) {                        
   //     Contact con = (Contact)obj;
   //     system.debug('### storeMasterMap' + storeMasterMap);


        
     //   if(con.Source_System__c =='eComm')  setEmailPreference(con);     //NASSC-1250
    }
    
    /**
* beforeUpdate
*
* This method is called iteratively for each record to be updated during a BEFORE
* trigger.
*/
    public void beforeUpdate(SObject oldSo, SObject so) {
        Contact con = (Contact)so;
        if (con.RecordTypeId == Constants.dataOwnerContactRecordTypeId) {
            if (!FeatureManagement.checkPermission(Constants.modifyDataOwnerPermission)){
                con.addError('You must have the Modify Data Owner Permission enabled to edit or delete data owner records. If you believe you need this permission, please contact your system administrator.');
            }
        }
        
    }
    
    /**
* beforeDelete
*
* This method is called iteratively for each record to be deleted during a BEFORE
* trigger.
*/
    public void beforeDelete(SObject so) {
        Contact con = (Contact)so;
        if (con.RecordTypeId == Constants.dataOwnerContactRecordTypeId) {
            if (!FeatureManagement.checkPermission(Constants.modifyDataOwnerPermission)){
                con.addError('You must have the Modify Data Owner Permission enabled to edit or delete data owner records. If you believe you need this permission, please contact your system administrator.');
            }
        }
        
    }
    
    /**
* afterInsert
*
* This method is called iteratively for each record inserted during an AFTER
* trigger. Always put field validation in the 'After' methods in case another trigger
* has modified any values. The record is 'read only' by this point.
*/
    public void afterInsert(SObject so) {
        
         
        
    }
    
    /**
* afterUpdate
*
* This method is called iteratively for each record updated during an AFTER
* trigger.
*/
    public void afterUpdate(SObject oldSo, SObject so) {
    }
    
    
    
    /**
* afterDelete
*
* This method is called iteratively for each record deleted during an AFTER
* trigger.
*/
    public void afterDelete(SObject so) {
        
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this 
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally() {
       
        /*** @Date: 01:15.2020
@JIRA: NASSC-1253 - upsertChildContactOnParentupdate*/
        
        if(isExecuted){
            
            if(parentContactIdSet != null)
                ContactFuture.upsertChildContactOnParentupdate(parentContactIdSet); 
        }
        
    }
    //This method checks if any contact exists with matching email 
    public static void checkExistingContacts(List<Contact> parentBrandContactlist){
        Set<String> emailIdSet = new Set<String>();
        Set<Contact> parentContactSet = new Set<Contact>();
        List<Contact> parentContacts = new List<Contact>();
        String status = 'ACTIVE';
        if(!parentBrandContactlist.isEmpty()){
            for(Contact cnt :parentBrandContactlist){
                if(String.isNotBlank(cnt.Email))
                    emailIdSet.add(cnt.Email);
            }            
        }
        Set<String> parentLevelBrandSet =new Set<String>();
        parentLevelBrandSet = brandMap.keySet();
        List<Contact> searchedContactList =[select id,Name,Email,Brand_Id__c,AccountId,Account.Name from Contact where Email =:emailIdSet 
                                            AND Status__c =:status AND AccountId != null AND Brand_Id__c IN: parentLevelBrandSet
                                            AND RecordTypeId = :emailRecordTypeId AND Account.Name!='Dummy Parent Account'];
        
        parentContactSet.addAll(parentBrandContactlist);        
        if(! searchedContactList.isEmpty()){
            for(Contact existingCnt : searchedContactList){
                for(Contact newCon :parentBrandContactlist){
                    if(newCon.Email == existingCnt.Email){
                        parentContactSet.remove(newCon);
                        newCon.AccountId = existingCnt.AccountId;  
                    
                  }
                  
                }
            }      
            parentContacts.addAll(parentContactSet);
            
           
            createNewAccount(parentContacts);
        }else{
            createNewAccount(parentBrandContactlist);
        }
    }
    //This method search parent brands for subbrands and associate accountId of parent to it
    public static void searchParentBrandContact(List<Contact> subBrandContactList){
        Set<String> emailIdSet = new Set<String>();
        if(!subBrandContactList.isEmpty()){
            for(Contact cnt :subBrandContactList){
                if(cnt.Email != null)
                    emailIdSet.add(cnt.Email);
            }            
        }
        List<Contact> parentBrandContact =[select id,Name,Brand_Id__c,Email,AccountId,Account.Name from Contact where 
                                           Email IN:emailIdSet AND Brand_Id__c IN: parentBrandIdSet
                                           AND RecordTypeId = :emailRecordTypeId ];
        Map<String,String> emailAndAccountId = new Map<String,String>();
        if(!parentBrandContact.isEmpty()){
            for(Contact parentBrand :parentBrandContact){
                if(parentBrand.Account.Name != 'Dummy Parent Account')
                    emailAndAccountId.put(parentBrand.Email, parentBrand.AccountId);
            }  
        }
        List<Contact> createNewAcc = new List<Contact>();
        //Associate subbrand contact AccountId to parentbrand Contact Account Id
        for(Contact newCon : subBrandContactList){    
            if(emailAndAccountId.containsKey(newCon.Email))
                newCon.AccountId = emailAndAccountId.get(newCon.Email);
            else
                createNewAcc.add(newCon);
        }   
        //create new account for subbrand which parent has dummy account
        createNewAccount(createNewAcc);
    }
    //NASSC-1412 : Creates new Customer type account and associate it to contacts
    public static void createNewAccount(list<Contact> newContactList){        
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Set<Account> accList = new Set<Account>();
        List<Account> aList = new List<Account>();
        Set<Id> setAccountId = new Set<Id>();        
        Map<String,Account> emailAndAccountMap = new Map<String,Account>();
        Set<Contact> contactWithNomatchingEmail = new Set<Contact>();
        Set<String> emailIdSet = new Set<String>();
        Set<String> accountEmailSet = new Set<String>();
        for(Contact cnt : newContactList){
            if(cnt.Email != null)
                emailIdSet.add(cnt.Email);  
        }
        //NASSC-1412 : check if any account exists with same email id
        List<Account> accountList =[select id,Name,AccountEmail__c from Account where AccountEmail__c IN:emailIdSet 
                                    AND Name != 'Dummy Parent Account'];
        if(!accountList.isEmpty()){
            for(Account acc :accountList ){              
                emailAndAccountMap.put(acc.AccountEmail__c, acc); 
            }            
        }
        
        
        //if any account email matches with contact email associate the account
        for(Contact cnt :newContactList){
            if(emailAndAccountMap.containsKey(cnt.Email)){
                cnt.AccountId =  emailAndAccountMap.get(cnt.Email).id;
            }else{
                contactWithNomatchingEmail.add(cnt);
            }
        } 
        
        //create new account if no match for email in contacts and accounts
        for(Contact cnt :contactWithNomatchingEmail){
            if(!accountEmailSet.contains(cnt.Email)){
                String firstname, lastname, gender;
                if (cnt.FirstName!=null) firstname = cnt.FirstName; else firstname = 'Unknown';
                if (cnt.LastName!=null) lastname = cnt.LastName; else lastname = 'Unknown';
                
                //NASSC-1704
                if (cnt.SelfClaimedGender__c!=null) gender = cnt.SelfClaimedGender__c; else gender = null;
                String Accname = firstname+' '+lastname;                
                Account acc = new account(Name=Accname.toUpperCase(),Status__c ='Active',RecordTypeId = customerRecordTypeId, FirstName__c = firstname, LastName__c = lastname,AccountEmail__c=cnt.Email,Gender__c = gender);
                accList.add(acc);
                accountEmailSet.add(cnt.Email);
            }            
        }
       
        aList.addAll(accList);        
        if(! aList.isEmpty()){
            insert aList;
        }       
        //Associate newly created account to contacts
        if(!aList.isEmpty()){
            for(Account acc :aList ){
                emailAndAccountMap.put(acc.AccountEmail__c, acc); 
            }    
            
            for(Contact cnt :contactWithNomatchingEmail){
                if(emailAndAccountMap.containsKey(cnt.Email)){
                    cnt.AccountId =  emailAndAccountMap.get(cnt.Email).id;
                }
            }     
        }        
    }
    // Set email Preference on Contact based on combination of values from "Email Preferences" metadata type
    public void setEmailPreference(List<Contact> conList){

        

        Set <String> BrandIds = new Set<String>();
        Set <String> SourceSystems = new Set<String>();
        for (Contact con: conList){
            BrandIds.add(con.Brand_Id__c);
            if (con.Source_System__c!=null) SourceSystems.add(con.Source_System__c);

        }
        List<Email_Preferences__mdt> emailPreferences = [SELECT SourceSystem__c, BrandId__c,  WelcomeSource__c, Location__c, PrefCenterInterests__c
        FROM Email_Preferences__mdt
        WHERE SourceSystem__c in :SourceSystems  and BrandId__c in :BrandIds];

        // WelcomeSource to Location to email prefs map for eComm
        Map<String, Map<String, Email_Preferences__mdt>> wsToLocToPrefsMap = new Map<String, Map<String, Email_Preferences__mdt>>();



        // Location to email prefs map for other sources
        Map<String, Email_Preferences__mdt> nonEcommLocToPrefsMap = new Map<String, Email_Preferences__mdt>();

        if (emailPreferences.size()>0){
            for (Email_Preferences__mdt prefRec: emailPreferences){
                if (prefRec.SourceSystem__c=='eComm'){
                    if (wsToLocToPrefsMap.containsKey(prefRec.WelcomeSource__c)) {
                        wsToLocToPrefsMap.get(prefRec.WelcomeSource__c).put(prefRec.Location__c,prefRec);
                       
                    }
                    else {
                        // Location to email prefs map for ecomm sources
                        Map<String, Email_Preferences__mdt> eCommLocToPrefsMap = new Map<String, Email_Preferences__mdt>();
                        ecommLocToPrefsMap.put(prefRec.Location__c,prefRec);
                        wsToLocToPrefsMap.put(prefRec.WelcomeSource__c,ecommLocToPrefsMap);
                        
                    }
                } else {
                    nonEcommLocToPrefsMap.put(prefRec.Location__c,prefRec);

                }
            }
        }
        

        for (Contact con: conList){
            String defaultStore = 'other';
            String prefValue;
            Map<String, Email_Preferences__mdt> eCommLocToPrefsMap = new Map<String, Email_Preferences__mdt>();
            if (con.Source_System__c=='eComm'){
                if (con.WelcomeSource__c!=null &&  wsToLocToPrefsMap.containsKey(con.WelcomeSource__c)) eCommLocToPrefsMap =  wsToLocToPrefsMap.get(con.WelcomeSource__c);
               
                if (con.StoreOfCapture__c!=null && eCommLocToPrefsMap.containsKey(con.StoreOfCapture__c)) prefValue = eCommLocToPrefsMap.get(con.StoreOfCapture__c).PrefCenterInterests__c;
                else if (eCommLocToPrefsMap.containsKey(defaultStore)) prefValue = eCommLocToPrefsMap.get(defaultStore).PrefCenterInterests__c;
                
                if (prefValue!=null) con.PrefCenterInterests__c = prefValue;

            } else {

                if (con.StoreOfCapture__c!=null && nonEcommLocToPrefsMap.containsKey(con.StoreOfCapture__c)) prefValue = nonEcommLocToPrefsMap.get(con.StoreOfCapture__c).PrefCenterInterests__c;
                else if (nonEcommLocToPrefsMap.containsKey(defaultStore)) prefValue = nonEcommLocToPrefsMap.get(defaultStore).PrefCenterInterests__c;
                if (prefValue!=null) con.PrefCenterInterests__c = prefValue;

            }
        }
    }
    
    //Firing a platform event to change the user context to SFCC Integration User from Mulesoft API User
    /*public static void publishPlatfromEvent(List<Contact> contactList){
        System.debug('Entered here');
        List<ExecuteAsSFCCIntegrationUser__e> publishEvents = new List<ExecuteAsSFCCIntegrationUser__e>();
        for(Contact c : contactList){
            ExecuteAsSFCCIntegrationUser__e eve = new ExecuteAsSFCCIntegrationUser__e();
            eve.ContactId__c = c.Id ;
            publishEvents.add(eve);            
        }
        System.debug('Entered here');
        if(publishEvents.size()>0){
            System.debug('Entered here');
            EventBus.publish(publishEvents);
        }
    }*/
}