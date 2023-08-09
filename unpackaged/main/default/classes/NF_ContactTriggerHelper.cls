public without sharing class NF_ContactTriggerHelper{
    public static Set<String> parentBrandIdSet = new Set<String>();
    public static Set<Id> parentContactIdSet = new Set<Id>();
    public static boolean isExecuted;
    public static Map<String, Set<String>> brandMap = new Map<String, Set<String>>();
    public static Id emailRecordTypeId;
    public static Map<String, StoreMaster__c> storeMasterMap = new Map<String, StoreMaster__c>();

    public NF_ContactTriggerHelper(){
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
    public void handleBeforeInsert(List<Contact> newList){
        //code from get_AccountIdTrigger
        Set<String> custIds = new Set<String>();
        List<Account> newAccountList = new List<Account>();
        Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        for (Contact cont : newList){
            if (cont.Customer_Id__c != null)
                custIds.add(cont.Customer_Id__c);
        }


        if (custIds.size() > 0){
            Map<String, Id> accMap = new Map<String, Id>();

            for (Account acc : [Select Name, Customer_Id__c, Id
                                from Account
                                Where Customer_Id__c in:custIds]){
                accMap.put(acc.Customer_Id__c, acc.id);
            }
            Set<String> accCustomerIdsSet = new Set<String>();
            for (Contact myContact : newList){
                if ((myContact.Customer_Id__c != null) && (accMap.get(myContact.Customer_Id__c) == null) && (!accCustomerIdsSet.contains(myContact.Customer_Id__c))){
                    Account acc = new Account();

                    if (myContact.FirstName != null)
                        acc.FirstName__c = myContact.FirstName;
                    else
                        acc.FirstName__c = SYSTEM.LABEL.Unknown;
                    if (myContact.LastName != null)
                        acc.LastName__c = myContact.LastName;
                    else
                        acc.LastName__c = SYSTEM.LABEL.Unknown;
                    acc.Name = acc.FirstName__c + ' ' + acc.LastName__c;
                    acc.Status__c = SYSTEM.LABEL.ACTIVE;
                    acc.RecordTypeId = customerAccountRecordTypeId;
                    acc.Customer_Id__c = myContact.Customer_Id__c;

                    newAccountList.add(acc);
                    accCustomerIdsSet.add(myContact.Customer_Id__c);


                }

            }
            if (newAccountList.size() > 0){
                insert newAccountList;
                for (Account a : newAccountList){
                    accMap.put(a.Customer_Id__c, a.id);
                }
            }

            for (Contact myContact : newList){

                if ((myContact.Customer_Id__c != null) && (accMap.get(myContact.Customer_Id__c) != null)){
                    myContact.AccountId = accMap.get(myContact.Customer_Id__c);

                }

            }


        }
    }

    public void handleBeforeInsertConTrigger(List<Contact> newList){
        String ptformIntUser = System.Label.PlatformIntegrationUser;

        map<string, SubscriberDataSources__mdt> mapDataSource = new map<string, SubscriberDataSources__mdt>();
        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                           FROM SubscriberDataSources__mdt];
        if (listDataSource.size() > 0){
            for (SubscriberDataSources__mdt objData : listDataSource){
                string brandandWelcomeSource = objData.Brand__c + objData.WelcomeSource__c;
                if (!mapDataSource.containskey(brandandWelcomeSource) && string.isNotBlank(brandandWelcomeSource)){
                    mapDataSource.put(brandandWelcomeSource, objData);
                }
            }
        }
        If (UserInfo.getLastName() != ptformIntUser && UserInfo.getName() != 'System' && UserInfo.getName() != 'Automated Process' && UserInfo.getName() != 'Ringcentral API User'){
            List<Profile> profileList = [SELECT Id, Name
                                         FROM Profile
                                         WHERE Id = :userinfo.getProfileId()
                                         LIMIT 1];
            List<User> userList = [SELECT Id, Name
                                   FROM User
                                   WHERE Id = :UserInfo.getUserId()
                                   LIMIT 1];
            String userName = userList[0].Name;
            String profileName = profileList[0].Name;
            for (Contact objCon : newList){
                if (objCon.B2C_Customer_No__c != null && objCon.Ecomm_Connected__c == false){
                    objCon.Ecomm_Connected__c = true;
                }
                objCon.Zenkraft_Mailing_Street__c = (String.isNotBlank(objCon.mailingstreet) ? objCon.mailingstreet : '') + (String.isNotBlank(objCon.mailingstreet) ? ',' : '') + (String.isNotBlank(objCon.suite__c) ? ' ' + objCon.suite__c : '');
                if (objCon.LoyaltyFlag__c == true && userName != SYSTEM.LABEL.MuleSoft_APIUser){
                    objcon.Loyalty_Optin_Date__c = System.now();
                }
                if (userName != SYSTEM.LABEL.MuleSoft_APIUser){
                    if (objCon.EmailOptInStatus__c == SYSTEM.LABEL.Y){
                        objCon.EmailOptInDate__c = system.now();
                    } else if (objCon.EmailOptInStatus__c == SYSTEM.LABEL.N){
                        objCon.EmailOptOutDate__c = system.now();
                        objCon.HasOptedOutOfEmail = true;
                    }
                }
                if (mapDataSource.containsKey(objCon.Brand_Id__c + objCon.WelcomeSource__c)){
                    objCon.EmailOrigSource__c = mapDataSource.get(objCon.Brand_Id__c + objCon.WelcomeSource__c).DataSource__c;
                }
            }
        }
    }

    public void handleBeforeInsertConTriggerHandler(List<Contact> newList){
        Map<Contact, SObject> sequenceObjMap = new Map<Contact, SObject>();
        Set<String> subBrandEmail = new Set<String>();
        Set<String> subBrand = new Set<String>();
        List<Contact> subBrandcontacts = new List<Contact>();
        Map<String, Contact> searchParentEmailContactMap = new Map<String, Contact>();
        List<Contact> parentBrandContact = new List<Contact>();
        List<Contact> subBrandContactList = new List<Contact>();

        Set<String> conStoreofCaptureSet = new Set<String>();

        for (sObject insertRec : Trigger.New ){
            Contact con = (Contact) insertRec;
            //NASSC-1463
            if (String.isNotEmpty(con.StoreOfCapture__c))
                conStoreofCaptureSet.add(con.StoreOfCapture__c);
            if (con.AccountId == null && con.Source_System__c != 'SFSC'){
                if (brandMap.containskey(con.Brand_Id__c)){
                    //parent level contact);
                    parentBrandContact.add(con);
                } else if (con.Source_System__c != 'SFSC'){
                    //subbrand level contact
                    subBrandContactList.add(con);
                }
            }

            if (String.isNotEmpty(con.Brand_Id__c) && String.isEmpty(con.LoyaltyID__c)){
                LoyaltySettings__mdt loyaltySetting;
                Map<id, LoyaltySettings__mdt> listLoyaltySettingMap = new Map<id, LoyaltySettings__mdt>([Select Id, BrandId__c, IsLoyaltyApplicable__c, Parent_Brand__c
                                                                                                         from LoyaltySettings__mdt
                                                                                                         where BrandId__c = :con.Brand_Id__c]);
                // List<LoyaltySettings__mdt> listLoyaltySettingList = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where BrandId__c = :con.Brand_Id__c ];
                List<LoyaltySettings__mdt> listLoyaltySettingList = listLoyaltySettingMap.values();
                if (listLoyaltySettingList.size() > 0)
                    for (Integer i = 0;
                i < listLoyaltySettingList.size(); i++){
                    loyaltySetting = listLoyaltySettingList[i];
                }
                //  loyaltySetting = listLoyaltySettingList[0];


                if (loyaltySetting != null){


                    if (String.isNotEmpty(loyaltySetting.BrandId__c) && String.isEmpty(con.LoyaltyID__c) && loyaltySetting.IsLoyaltyApplicable__c == true){
                        if (String.isEmpty(loyaltySetting.Parent_Brand__c)){
                            //BrandId__c is a Parent Brand
                            LoyaltyID_Sequence__c sObj = new LoyaltyID_Sequence__c();
                            sequenceObjMap.put(con, sObj);
                        } else if (String.isNotEmpty(loyaltySetting.Parent_Brand__c)){
                            // Check if Parent Brand Exists for this sub brand contact
                            if (String.isNotBlank(con.Email))
                                subBrandEmail.add(con.Email);
                            if (String.isNotBlank(loyaltySetting.Parent_Brand__c))
                                subBrand.add(loyaltySetting.Parent_Brand__c);
                            subBrandcontacts.add(con);
                        }
                    }
                }
            }
        }
        if (sequenceObjMap.values().size() > 0){
            ContactUtility.assignLoyaltyId(sequenceObjMap); // NASSC-1066
        }
        if (subBrandEmail.size() > 0){
            List<Contact> parentContactList = [SELECT ID, Brand_Id__c, Email, LoyaltyID__c, LoyaltyFlag__c, Loyalty_Optin_Date__c
                                               FROM Contact
                                               WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c IN:subBrand AND Email = :subBrandEmail AND LoyaltyID__c != null];

            if (parentContactList.size() > 0){
                //set Parent.Loyalty id as loyalty id
                for (Contact c : parentContactList){
                    searchParentEmailContactMap.put(c.Email, c);
                }
                if (searchParentEmailContactMap.values().size() > 0){
                    for (Contact subBrandContact : subBrandcontacts){
                        Contact parentContact = searchParentEmailContactMap.get(subBrandContact.Email);
                        if (parentContact != null){
                            // NACDT-3457
                            if (parentContact.LoyaltyID__c != null)
                                subBrandContact.LoyaltyID__c = parentContact.LoyaltyID__c;
                            if (parentContact.LoyaltyFlag__c != null)
                                subBrandContact.LoyaltyFlag__c = parentContact.LoyaltyFlag__c;
                            if (parentContact.Loyalty_Optin_Date__c != null)
                                subBrandContact.Loyalty_Optin_Date__c = parentContact.Loyalty_Optin_Date__c;
                        }

                    }
                }
            }
        }
        if (!parentBrandContact.isEmpty()){
            checkExistingContacts(parentBrandContact);
        }
        if (!subBrandContactList.isEmpty()){
            searchParentBrandContact(subBrandContactList);
        }

        List<StoreMaster__c> storeMasterList = [SELECT StoreUniqueId__c, Brand__c, StoreNumber__c, Status__c, Country__c, ChainId__c
                                                FROM StoreMaster__c
                                                WHERE StoreUniqueId__c in:conStoreofCaptureSet];

        if (storeMasterList.size() > 0){
            for (StoreMaster__c s : storeMasterList){

                storeMasterMap.put(s.StoreUniqueId__c, s);

            }
        }

        // set countryOfCapture and Channel based on StoreMaster map
        List<Contact> emailPrefsContacts = new List<Contact>();
        for (sObject insertRec : Trigger.New ){
            Contact con = (Contact) insertRec;


            if (storeMasterMap.size() > 0){
                //NASSC-1463
                if (String.isNotEmpty(con.StoreOfCapture__c)){

                    if (storeMasterMap.containsKey(con.StoreOfCapture__c)){
                        if (storeMasterMap.get(con.StoreOfCapture__c).Country__c != null)
                            con.CountryOfCapture__c = storeMasterMap.get(con.StoreOfCapture__c).Country__c;
                        if (storeMasterMap.get(con.StoreOfCapture__c).ChainId__c != Null){
                            if (con.Brand_Id__c == '1' && String.isEmpty(con.Channel__c) && Integer.valueOf(storeMasterMap.get(con.StoreOfCapture__c).ChainId__c) == 2){
                                con.Channel__c = '1';
                            }
                        }
                    }
                }
            }
            if (con.Source_System__c != null && con.Brand_Id__c != null)
                emailPrefsContacts.add(con);
        }
        if (emailPrefsContacts.size() > 0)
            setEmailPreference(emailPrefsContacts);
    }

    public void handleBeforeUpdate(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        Set<String> custIds = new Set<String>();
        List<Account> newAccountList = new List<Account>();
        Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        for (Contact cont : newMap.values()){
            if (cont.Customer_Id__c != null)
                custIds.add(cont.Customer_Id__c);
        }


        if (custIds.size() > 0){
            Map<String, Id> accMap = new Map<String, Id>();

            for (Account acc : [Select Name, Customer_Id__c, Id
                                from Account
                                Where Customer_Id__c in:custIds]){
                accMap.put(acc.Customer_Id__c, acc.id);
            }
            Set<String> accCustomerIdsSet = new Set<String>();
            for (Contact myContact : newMap.values()){
                System.debug('XXXXXXX' + myContact.Customer_Id__c + ' ' + accMap.get(myContact.Customer_Id__c));
                if (((myContact.Customer_Id__c != null) && (accMap.get(myContact.Customer_Id__c) == null) && (!accCustomerIdsSet.contains(myContact.Customer_Id__c)))){
                    Account acc = new Account();

                    if (myContact.FirstName != null)
                        acc.FirstName__c = myContact.FirstName;
                    else
                        acc.FirstName__c = SYSTEM.LABEL.Unknown;
                    if (myContact.LastName != null)
                        acc.LastName__c = myContact.LastName;
                    else
                        acc.LastName__c = SYSTEM.LABEL.Unknown;
                    acc.Name = acc.FirstName__c + ' ' + acc.LastName__c;
                    acc.Status__c = SYSTEM.LABEL.ACTIVE;
                    acc.RecordTypeId = customerAccountRecordTypeId;
                    acc.Customer_Id__c = myContact.Customer_Id__c;

                    newAccountList.add(acc);
                    accCustomerIdsSet.add(myContact.Customer_Id__c);


                }

            }
            if (newAccountList.size() > 0){
                insert newAccountList;
                for (Account a : newAccountList){
                    accMap.put(a.Customer_Id__c, a.id);
                }
            }

            for (Contact myContact : newMap.values()){

                if ((myContact.Customer_Id__c != null) && (accMap.get(myContact.Customer_Id__c) != null)){
                    myContact.AccountId = accMap.get(myContact.Customer_Id__c);

                }

            }


        }
    }

    public void handleBeforeUpdateConTrigger(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        String ptformIntUser = System.Label.PlatformIntegrationUser;

        map<string, SubscriberDataSources__mdt> mapDataSource = new map<string, SubscriberDataSources__mdt>();
        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                           FROM SubscriberDataSources__mdt];
        if (listDataSource.size() > 0){
            for (SubscriberDataSources__mdt objData : listDataSource){
                string brandandWelcomeSource = objData.Brand__c + objData.WelcomeSource__c;
                if (!mapDataSource.containskey(brandandWelcomeSource) && string.isNotBlank(brandandWelcomeSource)){
                    mapDataSource.put(brandandWelcomeSource, objData);
                }
            }
        }
        //NASSC-3183,NASSC-3184,NASSC-3210 & NASSC-1929
        If (UserInfo.getLastName() != ptformIntUser && UserInfo.getName() != 'System' && UserInfo.getName() != 'Automated Process' && UserInfo.getName() != 'Ringcentral API User'){
            List<Profile> profileList = [SELECT Id, Name
                                         FROM Profile
                                         WHERE Id = :userinfo.getProfileId()
                                         LIMIT 1];
            List<User> userList = [SELECT Id, Name
                                   FROM User
                                   WHERE Id = :UserInfo.getUserId()
                                   LIMIT 1];
            String userName = userList[0].Name;
            String profileName = profileList[0].Name;

            if (profileName == SYSTEM.LABEL.Ops_Quality || profileName == SYSTEM.LABEL.Tier_1_TEMP || profileName == SYSTEM.LABEL.Tier_I_CSR_CCPA || profileName == SYSTEM.LABEL.Tier_I_CSR_PVH || profileName == SYSTEM.LABEL.Tier_I_CSR_Wholesale || profileName == SYSTEM.LABEL.Tier_II_CSR || profileName == SYSTEM.LABEL.Tier_III_CSR_Supervisor || profileName == SYSTEM.LABEL.Tier_III_CSR_Supervisor){


                Set<Id> conId = new Set<Id>();
                List<Contact> conList = new List<Contact>();

                for (Contact con : newMap.values()){
                    if (oldMap.get(con.id).HasOptedOutOfEmail != con.HasOptedOutOfEmail){
                        conList.add(con);
                    }

                }

                if (conList.size() > 0){

                    for (Contact con : conList){
                        if (con.HasOptedOutOfEmail == True && con.EmailOptInStatus__c != SYSTEM.LABEL.N){
                            con.EmailOptInStatus__c = SYSTEM.LABEL.N;
                            con.EmailOptOutDate__c = system.now();

                        } else if (con.HasOptedOutOfEmail == False && con.EmailOptInStatus__c != SYSTEM.LABEL.Y){
                            con.EmailOptInStatus__c = SYSTEM.LABEL.Y;
                            con.EmailOptInDate__c = system.now();
                        }
                    }
                }
            }
            //NASSC-3318
            List<Contact> mcConList = new List<Contact>();
            List<Contact> keyWordConList = new List<Contact>();
            if (userName == SYSTEM.LABEL.MC_Integration){
                log.push('userName***' + userName);
                for (Contact con : newMap.values()){
                    if ((oldMap.get(con.id).HasOptedOutOfEmail != con.HasOptedOutOfEmail) && con.HasOptedOutOfEmail == True){
                        log.push('con.HasOptedOutOfEmail***' + con.HasOptedOutOfEmail);
                        mcConList.add(con);
                    }


                }
            }
            for (Contact con : mcConList){
                log.push('userName***' + userName);
                if (userName == SYSTEM.LABEL.MC_Integration){
                    if (con.HasOptedOutOfEmail == True && con.EmailOptInStatus__c != SYSTEM.LABEL.N){
                        log.push('con.HasOptedOutOfEmail***' + con.HasOptedOutOfEmail);
                        con.EmailOptInStatus__c = SYSTEM.LABEL.N;
                        con.EmailOptOutDate__c = system.now();
                        con.UnsubReason__c = SYSTEM.LABEL.Native_Unsubscribe;
                        log.push('HasOptedOutOfEmail***' + con.HasOptedOutOfEmail);
                        log.push('EmailOptInStatus__c***' + con.EmailOptInStatus__c);
                        log.push('EmailOptOutDate__c***' + con.EmailOptOutDate__c);
                    }


                }
            }
            /**End**/

            for (Contact objCon : newMap.values()){
                if (String.isNotBlank(objCon.SMSLocale__c) && objCon.SMSLocale__c.length() == 5){
                    objCon.CountryOfCapture__c = objCon.SMSLocale__c.right(2).toUpperCase();
                    // log.push('con.CountryOfCapture__c****'+con.CountryOfCapture__c);
                }
                if (objCon.B2C_Customer_No__c != null){
                    objCon.Ecomm_Connected__c = true;
                    if(userName == 'SFCC Integration User' && objCon.B2C_Is_Enabled__c == false){
                        objCon.B2C_Is_Enabled__c = true; 
                     }
                }
                if (objCon.suite__c != oldMap.get(objCon.Id).suite__c || objCon.mailingstreet != oldMap.get(objCon.Id).mailingstreet){
                    objCon.Zenkraft_Mailing_Street__c = (String.isNotBlank(objCon.mailingstreet) ? objCon.mailingstreet : '') + (String.isNotBlank(objCon.mailingstreet) ? ',' : '') + (String.isNotBlank(objCon.suite__c) ? ' ' + objCon.suite__c : '');
                }
                if ((profileName == 'Ops/Quality' || profileName == 'Tier 1 TEMP' || profileName == 'Tier I CSR CCPA' || profileName == 'Tier I CSR PVH' || profileName == 'Tier I CSR Wholesale' || profileName == 'Tier II CSR' || profileName == 'Tier III CSR/Supervisor' || profileName == 'Tier III CSR/Supervisor') && oldMap.get(objCon.Id).Bulk_Buyer__c == false && objCon.Bulk_Buyer__c == true && objCon.LoyaltyFlag__c == false){
                    objCon.Bulk_Buyer_Update_Reason__c = 'RC01-CDP Diagnosed Fraud Prevention';
                    objCon.Bulk_Buyer_Update_Date__c = System.now();
                }
                if (oldMap.get(objCon.Id).LoyaltyFlag__c != objCon.LoyaltyFlag__c && objCon.LoyaltyFlag__c == true && userName != 'MuleSoft APIUser'){
                    objcon.Loyalty_Optin_Date__c = System.now();
                }
                if (userName != 'MuleSoft APIUser'){
                    if ((objCon.EmailOptInStatus__c == 'Y' && objCon.EmailOptInStatus__c != oldMap.get(objCon.Id).EmailOptInStatus__c) || (objCon.HasOptedOutOfEmail == false && objCon.HasOptedOutOfEmail != oldMap.get(objCon.Id).HasOptedOutOfEmail)){
                        objCon.EmailOptInDate__c = system.now();
                        objCon.EmailOptInStatus__c = 'Y';
                        objCon.HasOptedOutOfEmail = false;
                        // objCon.EmailOptOutDate__c=system.now();
                    } else if ((objCon.EmailOptInStatus__c == 'N' && objCon.EmailOptInStatus__c != oldMap.get(objCon.Id).EmailOptInStatus__c) || (objCon.HasOptedOutOfEmail == true && objCon.HasOptedOutOfEmail != oldMap.get(objCon.Id).HasOptedOutOfEmail)){
                        // objCon.EmailOptInDate__c=system.now();
                        objCon.EmailOptInStatus__c = 'N';
                        objCon.HasOptedOutOfEmail = true;
                        objCon.EmailOptOutDate__c = system.now();
                    }
                }
                
                if ((oldMap.get(objCon.Id).Brand_Id__c != objCon.Brand_Id__c || oldMap.get(objCon.Id).WelcomeSource__c != objCon.WelcomeSource__c) && mapDataSource.containsKey(objCon.Brand_Id__c + objCon.WelcomeSource__c) && oldMap.get(objCon.Id).EmailOrigSource__c!=SYSTEM.LABEL.WE_CAMPAIGN){
                    objCon.EmailOrigSource__c = mapDataSource.get(objCon.Brand_Id__c + objCon.WelcomeSource__c).DataSource__c;
                }
                system.debug(' objCon.Latest_Campaigns__c**'+objCon.Latest_Campaigns__c);
                if(oldMap.get(objCon.Id).WelcomeSource__c== SYSTEM.LABEL.X07 && oldMap.get(objCon.Id).EmailOrigSource__c==SYSTEM.LABEL.WE_CAMPAIGN && objCon.Latest_Campaigns__c =='Project Blue'){
                    objCon.EmailOrigSource__c =SYSTEM.LABEL.WE_CAMPAIGN;
                    objCon.WelcomeSource__c =SYSTEM.LABEL.X07;
                }
                if(objCon.Source__c=='REFERAFRIEND' && userName !='SFCC Integration User'){
                    objCon.EmailOrigSource__c ='REFERAFRIEND';
                    objCon.WelcomeSource__c ='06';
                    objCon.Latest_Source__c='Extole';
                }
            }

        }
        Logger.logDebug();
    }

    public void handleBeforeDeleteConTriggerHandler(Map<Id, Contact> oldMap){
        GenericRecords__c genericContactRecord = GenericRecords__c.getValues(Constants.privacyContactGenericRecordSettingName);
        Contact genericContact = [Select Id, AccountId
                                  from Contact
                                  where Id = :genericContactRecord.recordId__c];

        List<SObject> recordsToDisassociate = new List<SObject>();
        Set<Id> contactIds = Trigger.oldMap.keySet();

        //Disassociate Cases
        for (Case c : [Select Id, ContactId
                       from Case
                       where ContactId in:contactIds]){
            c.ContactId = null;
            recordsToDisassociate.add(c);
        }

        //Reassociate Assets
        for (Asset a : [Select Id, ContactId
                        from Asset
                        where ContactId in:contactIds AND Id in (Select AssetId
                                                                 from Case
                                                                 where AssetId != null)]){
            a.ContactId = genericContact.Id;
            recordsToDisassociate.add(a);
        }

        //Disassociate Contracts
        for (Contract ct : [Select Id, CustomerSignedId
                            from Contract
                            where CustomerSignedId in:contactIds]){
            ct.CustomerSignedId = null;
            recordsToDisassociate.add(ct);
        }

        update recordsToDisassociate;
    }

    public void handleBeforeDeleteConTriggerHandler2(Map<Id, Contact> oldMap){
        for (Contact con : oldMap.values()){
            if (con.RecordTypeId == Constants.dataOwnerContactRecordTypeId){
                if (!FeatureManagement.checkPermission(Constants.modifyDataOwnerPermission)){
                    con.addError('You must have the Modify Data Owner Permission enabled to edit or delete data owner records. If you believe you need this permission, please contact your system administrator.');
                }
            }
        }
    }

    public void handleAfterInsertConTrigger(Map<Id, Contact> newMap){
        Organization org = [Select isSandbox
                            from Organization
                            LIMIT 1];
        if (!org.IsSandbox || Test.isRunningTest()){
            List<LoyaltySettings__mdt> TSEnabledList = new List<LoyaltySettings__mdt>();
            TSEnabledList = [select BrandId__c
                             from LoyaltySettings__mdt
                             where EnableTriggeredSend__c = true];
            Set<String> TSEnabledBrandsSet = new Set<String>();
            if (TSEnabledList.size() > 0){
                for (LoyaltySettings__mdt LS : TSEnabledList){
                    TSEnabledBrandsSet.add(LS.BrandId__c);
                }
            }

            Boolean callSFMCConnector = false;
            for (Contact c : newMap.values()){
                if ((c.External_Id__c == null) && (TSEnabledBrandsSet.contains(c.Brand_Id__c)) && (c.Source_System__c == 'WiFi' || c.Source_System__c == 'ChargeItSpot') && (c.EmailOptInStatus__c == SYSTEM.LABEL.Y)){
                    //          if (newMap.values()et4ae5.triggerUtility.automate('Contact');
                    //         else if (newMap.values()& Trigger.oldMap.get(c.Id).EmailOptInStatus__c != SYSTEM.LABEL.Y) et4ae5.triggerUtility.automate('Contact');
                    if (!callSFMCConnector)
                        callSFMCConnector = true;
                }
            }
            if (callSFMCConnector)
                et4ae5.triggerUtility.automate('Contact');
        }
    }

    public void handeAfterUpdateConTrigger(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        if (LoyaltyIdGeneration.runFlag){
            Map<Id, Contact> conId = new Map<Id, Contact>();
            set<String> brandSet = new Set<String>();
            String conLoyaltyId;
            String brandCodes = '1,2,4,5,9,81,82,84';
            boolean isLoyaltyBrand = false;


            for (Contact con : newMap.values()){
                if (!Test.isRunningTest()){
                    conLoyaltyId = String.valueof(con.LoyaltyID__c);
                    if (con.Brand_Id__c != Null && brandCodes.contains(con.Brand_Id__c) != Null){
                        isLoyaltyBrand = True;
                    }

                    if (UserInfo.getLastName() != SYSTEM.LABEL.Platform_Integration_User && con.LoyaltyID__c == Null && isLoyaltyBrand == True){

                        conId.put(con.Id, con);
                        brandSet.add(con.Brand_Id__c);
                    }
                }
            }
            if (conId.size() > 0){

                LoyaltyIdGeneration.runFlag = false;
                LoyaltyIdGeneration.loyaltyIdGenHandler(conId, brandSet);
            }
        }
    }

    public void handleAfterUpdateConTrigger2(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        Organization org = [Select isSandbox
                            from Organization
                            LIMIT 1];
        if (!org.IsSandbox){
            List<LoyaltySettings__mdt> TSEnabledList = new List<LoyaltySettings__mdt>();
            TSEnabledList = [select BrandId__c
                             from LoyaltySettings__mdt
                             where EnableTriggeredSend__c = true];
            Set<String> TSEnabledBrandsSet = new Set<String>();
            if (TSEnabledList.size() > 0){
                for (LoyaltySettings__mdt LS : TSEnabledList){
                    TSEnabledBrandsSet.add(LS.BrandId__c);
                }
            }

            Boolean callSFMCConnector = false;
            for (Contact c : newMap.values()){
                if ((c.External_Id__c == null) && (TSEnabledBrandsSet.contains(c.Brand_Id__c)) && (c.Source_System__c == 'WiFi' || c.Source_System__c == 'ChargeItSpot') && (c.EmailOptInStatus__c == SYSTEM.LABEL.Y)){
                    //          if (newMap.values()et4ae5.triggerUtility.automate('Contact');
                    //         else if (newMap.values()& Trigger.oldMap.get(c.Id).EmailOptInStatus__c != SYSTEM.LABEL.Y) et4ae5.triggerUtility.automate('Contact');
                    if (!callSFMCConnector)
                        callSFMCConnector = true;
                }
            }
            if (callSFMCConnector)
                et4ae5.triggerUtility.automate('Contact');
        }
    }

    public void handleAfterUpdateConTriggerHandler(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        for (Contact newCon : newMap.values()){
            Contact oldCon = oldMap.get(newCon.id);
            //check if update is for parent brand
            if (parentBrandIdSet.contains(newCon.Brand_Id__c)){
                if (newCon.EmailOptInStatus__c == 'Y' && oldCon.EmailOptInStatus__c != 'Y'){
                    parentContactIdSet.add(newCon.id);
                    isExecuted = true;
                    andFinally();
                }
            }
        }
        
    }

    public void andFinally(){
        if (isExecuted){
            if (parentContactIdSet != null){
                ContactFuture.upsertChildContactOnParentupdate(parentContactIdSet);
            }
        }
    }

    //This method checks if any contact exists with matching email
    public static void checkExistingContacts(List<Contact> parentBrandContactlist){
        Set<String> emailIdSet = new Set<String>();
        Set<Contact> parentContactSet = new Set<Contact>();
        List<Contact> parentContacts = new List<Contact>();
        Map<String,List<Contact>> searchEmailContactMap = new Map<String,List<Contact>>();
        String status = 'ACTIVE';
        if (!parentBrandContactlist.isEmpty()){
            for (Contact cnt : parentBrandContactlist){
                if (String.isNotBlank(cnt.Email))
                    emailIdSet.add(cnt.Email);
            }
        }
        Set<String> parentLevelBrandSet = new Set<String>();
        parentLevelBrandSet = brandMap.keySet();
        List<Contact> searchedContactList = [select id, Name, Email, Brand_Id__c, AccountId, Account.Name
                                             from Contact
                                             where Email = :emailIdSet AND Status__c = :status AND AccountId != null AND Brand_Id__c IN:parentLevelBrandSet AND RecordTypeId = :emailRecordTypeId AND AccountId != :System.Label.DummyAccountId];
        parentContactSet.addAll(parentBrandContactlist); 
        
        if (!searchedContactList.isEmpty()){
        for(Contact cnt : searchedContactList){
            if(searchEmailContactMap.get(cnt.Email) == Null){
                searchEmailContactMap.put(cnt.Email,new List<Contact>());
            }
            searchEmailContactMap.get(cnt.Email).add(cnt);
        }
           for (Contact newCon : parentBrandContactlist){
                 
                   if((searchEmailContactMap.keySet()).contains(newCon.Email)){
                       parentContactSet.remove(newCon);
                      String existingAccId =  (searchEmailContactMap.get(newCon.Email)).get(0).AccountId;
                       newCon.AccountId = existingAccId;
                       
                   }
            
                   
                   /* if (newCon.Email == existingCnt.Email){
                        parentContactSet.remove(newCon);
                        newCon.AccountId = existingCnt.AccountId;

                    } */

                }
            
            parentContacts.addAll(parentContactSet);


            createNewAccount(parentContacts);
        } else{
            createNewAccount(parentBrandContactlist);
        }
    }

    //This method search parent brands for subbrands and associate accountId of parent to it
    public static void searchParentBrandContact(List<Contact> subBrandContactList){
        Set<String> emailIdSet = new Set<String>();
        if (!subBrandContactList.isEmpty()){
            for (Contact cnt : subBrandContactList){
                if (cnt.Email != null)
                    emailIdSet.add(cnt.Email);
            }
        }
        List<Contact> parentBrandContact = [select id, Name, Brand_Id__c, Email, AccountId, Account.Name
                                            from Contact
                                            where Email IN:emailIdSet AND Brand_Id__c IN:parentBrandIdSet AND RecordTypeId = :emailRecordTypeId];
        Map<String, String> emailAndAccountId = new Map<String, String>();
        if (!parentBrandContact.isEmpty()){
            for (Contact parentBrand : parentBrandContact){
                if (parentBrand.AccountId != System.Label.DummyAccountId)
                    emailAndAccountId.put(parentBrand.Email, parentBrand.AccountId);
            }
        }
        List<Contact> createNewAcc = new List<Contact>();
        //Associate subbrand contact AccountId to parentbrand Contact Account Id
        for (Contact newCon : subBrandContactList){
            if (emailAndAccountId.containsKey(newCon.Email))
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
        Map<String, Account> emailAndAccountMap = new Map<String, Account>();
        Set<Contact> contactWithNomatchingEmail = new Set<Contact>();
        Set<String> emailIdSet = new Set<String>();
        Set<String> accountEmailSet = new Set<String>();
        for (Contact cnt : newContactList){
            if (cnt.Email != null)
                emailIdSet.add(cnt.Email);
        }
        //NASSC-1412 : check if any account exists with same email id
        List<Account> accountList = [select id, Name, AccountEmail__c
                                     from Account
                                     where AccountEmail__c IN:emailIdSet AND id != :System.Label.DummyAccountId];
        if (!accountList.isEmpty()){
            for (Account acc : accountList){
                emailAndAccountMap.put(acc.AccountEmail__c, acc);
            }
        }


        //if any account email matches with contact email associate the account
        for (Contact cnt : newContactList){
            if (emailAndAccountMap.containsKey(cnt.Email)){
                cnt.AccountId = emailAndAccountMap.get(cnt.Email).id;
            } else{
                contactWithNomatchingEmail.add(cnt);
            }
        }

        //create new account if no match for email in contacts and accounts
        for (Contact cnt : contactWithNomatchingEmail){
            if (!accountEmailSet.contains(cnt.Email)){
                String firstname, lastname, gender;
                if (cnt.FirstName != null)
                    firstname = cnt.FirstName;
                else
                    firstname = 'Unknown';
                if (cnt.LastName != null)
                    lastname = cnt.LastName;
                else
                    lastname = 'Unknown';
                //NASSC-1704
                if (cnt.SelfClaimedGender__c != null)
                    gender = cnt.SelfClaimedGender__c;
                else
                    gender = null;
                String Accname = firstname + ' ' + lastname;
                Account acc = new account(Name = Accname.toUpperCase(), Status__c = 'Active', RecordTypeId = customerRecordTypeId, FirstName__c = firstname, LastName__c = lastname, AccountEmail__c = cnt.Email, Gender__c = gender);
                accList.add(acc);
                accountEmailSet.add(cnt.Email);
            }
        }

        aList.addAll(accList);
        if (!aList.isEmpty()){
            insert aList;
        }
        //Associate newly created account to contacts
        if (!aList.isEmpty()){
            for (Account acc : aList){
                emailAndAccountMap.put(acc.AccountEmail__c, acc);
            }

            for (Contact cnt : contactWithNomatchingEmail){
                if (emailAndAccountMap.containsKey(cnt.Email)){
                    cnt.AccountId = emailAndAccountMap.get(cnt.Email).id;
                }
            }
        }
    }

    // Set email Preference on Contact based on combination of values from "Email Preferences" metadata type
    public void setEmailPreference(List<Contact> conList){


        Set<String> BrandIds = new Set<String>();
        Set<String> SourceSystems = new Set<String>();
        for (Contact con : conList){
            BrandIds.add(con.Brand_Id__c);
            if (con.Source_System__c != null)
                SourceSystems.add(con.Source_System__c);
        }
        List<Email_Preferences__mdt> emailPreferences = [SELECT SourceSystem__c, BrandId__c, WelcomeSource__c, Location__c, PrefCenterInterests__c
                                                         FROM Email_Preferences__mdt
                                                         WHERE SourceSystem__c in:SourceSystems and BrandId__c in:BrandIds];

        // WelcomeSource to Location to email prefs map for eComm
        Map<String, Map<String, Email_Preferences__mdt>> wsToLocToPrefsMap = new Map<String, Map<String, Email_Preferences__mdt>>();


        // Location to email prefs map for other sources
        Map<String, Email_Preferences__mdt> nonEcommLocToPrefsMap = new Map<String, Email_Preferences__mdt>();

        if (emailPreferences.size() > 0){
            for (Email_Preferences__mdt prefRec : emailPreferences){
                if (prefRec.SourceSystem__c == 'eComm'){
                    if (wsToLocToPrefsMap.containsKey(prefRec.WelcomeSource__c)){
                        wsToLocToPrefsMap.get(prefRec.WelcomeSource__c).put(prefRec.Location__c, prefRec);

                    } else{
                        // Location to email prefs map for ecomm sources
                        Map<String, Email_Preferences__mdt> eCommLocToPrefsMap = new Map<String, Email_Preferences__mdt>();
                        ecommLocToPrefsMap.put(prefRec.Location__c, prefRec);
                        wsToLocToPrefsMap.put(prefRec.WelcomeSource__c, ecommLocToPrefsMap);

                    }
                } else{
                    nonEcommLocToPrefsMap.put(prefRec.Location__c, prefRec);

                }
            }
        }


        for (Contact con : conList){
            String defaultStore = 'other';
            String prefValue;
            Map<String, Email_Preferences__mdt> eCommLocToPrefsMap = new Map<String, Email_Preferences__mdt>();
            if (con.Source_System__c == 'eComm'){
                if (con.WelcomeSource__c != null && wsToLocToPrefsMap.containsKey(con.WelcomeSource__c))
                    eCommLocToPrefsMap = wsToLocToPrefsMap.get(con.WelcomeSource__c);
                if (con.StoreOfCapture__c != null && eCommLocToPrefsMap.containsKey(con.StoreOfCapture__c))
                    prefValue = eCommLocToPrefsMap.get(con.StoreOfCapture__c).PrefCenterInterests__c;
                else if (eCommLocToPrefsMap.containsKey(defaultStore))
                    prefValue = eCommLocToPrefsMap.get(defaultStore).PrefCenterInterests__c;
                if (prefValue != null)
                    con.PrefCenterInterests__c = prefValue;
            } else{

                if (con.StoreOfCapture__c != null && nonEcommLocToPrefsMap.containsKey(con.StoreOfCapture__c))
                    prefValue = nonEcommLocToPrefsMap.get(con.StoreOfCapture__c).PrefCenterInterests__c;
                else if (nonEcommLocToPrefsMap.containsKey(defaultStore))
                    prefValue = nonEcommLocToPrefsMap.get(defaultStore).PrefCenterInterests__c;
                if (prefValue != null)
                    con.PrefCenterInterests__c = prefValue;
            }


        }
    }

}