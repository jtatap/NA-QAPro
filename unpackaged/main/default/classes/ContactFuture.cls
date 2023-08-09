/**
 * @author Magnet360
 *
 * @date 2019
 *
 * @description Future methods for Contact Creation. Called when cases are created from Web or Email
 *
 */
public without sharing class ContactFuture{
    /*******************************************************************************************************
     * @description Called when a direct contact match is found for a case. Will associate the contact and account to the case.
     * @param caseContactBrandMap - mao of Cases to matched Contact
     * @return void
     * @example
     */
    public static void updateCaseContactAndAccount(Map<Id, Id> caseContactBrandMap){
        updateCaseContactAndAccount(caseContactBrandMap, true);
    }
    

    /*******************************************************************************************************
     * @description Called when a direct contact match is found for a case. Will associate the contact and account to the case.
     * @param caseContactBrandMap - map of Cases to matched Contact
     * @param isFuture - allows contact method to be run immediately instead of future
     * @return void
     * @example
     */
    public static void updateCaseContactAndAccount(Map<Id, Id> caseContactBrandMap, Boolean isFuture){
        if (isFuture){
            updateCaseContactAndAccountFuture(caseContactBrandMap);
        } else{
            runUpdateCaseContactAndAccount(caseContactBrandMap);
        }
    }

    @future
    private static void updateCaseContactAndAccountFuture(Map<Id, Id> caseContactBrandMap){
        runUpdateCaseContactAndAccount(caseContactBrandMap);
    }

    @future
    private static void updatePOSContactFuture(List<Id> recordIds){
       runUpdatePOSContact(recordIds);
    }

    /*******************************************************************************************************
     * @description Called when a direct contact match is found for a case. Will associate the contact and account to the case.
     * @param caseContactBrandMap - mao of Cases to matched Contac
     * @return void
     * @example
     */
    private static void runUpdateCaseContactAndAccount(Map<Id, Id> caseContactBrandMap){

        List<Case> updatedCaseList = new List<Case>();
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CaseNumber, AccountId, ContactId, Brand__c, SuppliedEmail, Supplied_First_Name__c, Supplied_Last_Name__c, SuppliedName, SuppliedPhone, Origin, SourceId, Type
                                                   FROM Case 
                                                   WHERE Id IN:caseContactBrandMap.keySet()]);


        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email, Brand_Id__c, AccountId, Phone
                                                            FROM Contact
                                                            WHERE Id IN:caseContactBrandMap.values()]);
        List<Contact> updatedContactList = new List<Contact>();
        for (Id casId : caseContactBrandMap.keySet()){
            Case cas = caseMap.get(casId);
            Contact con = contactMap.get(caseContactBrandMap.get(casId));
            cas.ContactId = con.Id;
            cas.AccountId = con.AccountId;
            if (con.Phone == null && cas.SuppliedPhone != null){
                con.Phone = cas.SuppliedPhone;
            }
            updatedCaseList.add(cas);
            updatedContactList.add(con);
        }

        Log.push('>>>updatedCaseList :' + updatedCaseList);
        update updatedCaseList;
        Log.push('>>>updatedContactList :' + updatedContactList);
        Logger.logDebug();
        update updatedContactList;
    }

    /*******************************************************************************************************
     * @description Called when an account is found, but not a contact. The contact is created, associated to the case and the account.
     * @param caseContactGenericMap - a map of CaseIds to Account Ids
     * @return void
     * @example
     */
    public static void updateCaseAccountAndCreateNewContact(Map<Id, Id> caseContactGenericMap){
        updateCaseAccountAndCreateNewContact(caseContactGenericMap, true);
    }

    /*******************************************************************************************************
     * @description Called when an account is found, but not a contact. The contact is created, associated to the case and the account.
     * @param caseContactGenericMap - a map of CaseIds to Account Ids
     * @param isFuture - allows contact future method to be run immediately instead of future
     * @return void
     * @example
     */
    public static void updateCaseAccountAndCreateNewContact(Map<Id, Id> caseContactGenericMap, Boolean isFuture){
        if (isFuture){
            updateCaseAccountAndCreateNewContactFuture(caseContactGenericMap);
        } else{
            runUpdateCaseAccountAndCreateNewContact(caseContactGenericMap);
        }
    }

    @future
    private static void updateCaseAccountAndCreateNewContactFuture(Map<Id, Id> caseContactGenericMap){
        runUpdateCaseAccountAndCreateNewContact(caseContactGenericMap);
    }

    private static void runUpdateCaseAccountAndCreateNewContact(Map<Id, Id> caseContactGenericMap){
        Log.push('>>caseContactGenericMap :' + caseContactGenericMap);
        List<Case> updatedCaseList = new List<Case>();
        List<Contact> createContactList = new List<Contact>();

        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CaseNumber, AccountId, ContactId, Brand__c, SuppliedEmail, SuppliedName, Supplied_First_Name__c, Supplied_Last_Name__c, SuppliedPhone, Origin, SourceId, Type
                                                   FROM Case 
                                                   WHERE Id IN:caseContactGenericMap.keySet()]);


        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email, Brand_Id__c, AccountId, Phone
                                                            FROM Contact
                                                            WHERE Id IN:caseContactGenericMap.values()]);

        for (Id casId : caseContactGenericMap.keySet()){
            Log.push('>>>casId :' + casId);
            Case cas = caseMap.get(casId);
            Log.push('>>>cas :' + cas);
            Log.push('>>>caseContactGenericMap.get(casId) :' + caseContactGenericMap.get(casId));
            Contact con = contactMap.get(caseContactGenericMap.get(casId));
            Log.push('>>>con :' + con);
            cas.AccountId = con.AccountId;
            Contact cont = new Contact();
            cont.Email = cas.SuppliedEmail;
            cont.AccountId = con.AccountId;
            cont.Phone = cas.SuppliedPhone;
            cont.Brand_Id__c = cas.Brand__c;
            cont.Source_System__c = 'SFSC';
            Log.push('updateCaseAccountAndCreateNewContact cas.Supplied_First_Name__c: ' + cas.Supplied_First_Name__c);
            Log.push('updateCaseAccountAndCreateNewContact cas.Supplied_Last_Name__c: ' + cas.Supplied_Last_Name__c);
            if (cas.Supplied_First_Name__c != null && cas.Supplied_Last_Name__c != null){
                cont.FirstName = cas.Supplied_First_Name__c;
                cont.LastName = cas.Supplied_Last_Name__c;
            } else if (cas.SuppliedName != Null){
                cont.LastName = cas.SuppliedName;
            } else{
                cont.FirstName = con.FirstName;
                cont.LastName = con.LastName;
            }
            createContactList.add(cont);
        }

        insert createContactList;
        Log.push('>>>createContactList :' + createContactList);

        for (Id casId : caseContactGenericMap.keySet()){
            Log.push('>>>casId :' + casId);
            Case cas = caseMap.get(casId);
            for (Contact con : createContactList){
                Log.push('>>>con :' + con);
                if (cas.SuppliedEmail == con.Email || cas.SuppliedPhone == con.Phone){
                    cas.AccountId = con.AccountId;
                    cas.ContactId = con.Id;
                    updatedCaseList.add(cas);
                }
            }
        }

        update updatedCaseList;
        Logger.logDebug();
    }

    public static void createNewContactAndAccountForCase(Set<Id> caseContactNotFound){
        createNewContactAndAccountForCase(caseContactNotFound, true);
    }

    public static void createNewContactAndAccountForCase(Set<Id> caseContactNotFound, Boolean isFuture){
        if (isFuture){
            createNewContactAndAccountForCaseFuture(caseContactNotFound);
        } else{
            runCreateNewContactAndAccountForCase(caseContactNotFound);
        }
    }

    @future
    public static void createNewContactAndAccountForCaseFuture(Set<Id> caseContactNotFound){
        runCreateNewContactAndAccountForCase(caseContactNotFound);
    }

    /*******************************************************************************************************
     * @description Called when neither an account, nor a contact is found for the case. A new account and contact is created and then associated to the case
     * @param caseContactNotFound - a set of case ids
     * @return void
     * @example
     */
    public static void runCreateNewContactAndAccountForCase(Set<Id> caseContactNotFound){
        Log.push('>>caseContactNotFound :' + caseContactNotFound);
        List<Case> updatedCaseList = new List<Case>();

        Map<Id, Account> caseToAccount = new Map<Id, Account>();
        Map<Id, Contact> caseToContact = new Map<Id, Contact>();

        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CaseNumber, AccountId, ContactId, Brand__c, SuppliedEmail, SuppliedName, Supplied_First_Name__c, Supplied_Last_Name__c, SuppliedPhone, Origin, SourceId, Type
                                                   FROM Case 
                                                   WHERE Id IN:caseContactNotFound]);
        for (Id casId : caseContactNotFound){
            Case cas = caseMap.get(casId);
            System.debug('cas'+cas);
			//Create new Account list to insert
            Account acc = new Account();
            System.debug('cas.Supplied_Last_Name__c'+cas.Supplied_Last_Name__c);
            System.debug('cas.SuppliedName'+cas.SuppliedName);
            String accName = (String.isBlank(cas.Supplied_Last_Name__c) ? cas.SuppliedName : cas.Supplied_First_Name__c + ' ' + cas.Supplied_Last_Name__c);
            
            if (accName != Null){
                acc.Name = accName;
                acc.LastName__c = (String.isBlank(cas.Supplied_Last_Name__c) ? cas.SuppliedName : cas.Supplied_Last_Name__c);
            } else{
                acc.Name = SYSTEM.LABEL.Unknown;
                acc.LastName__c = SYSTEM.LABEL.Unknown;
            }
            //acc.FirstName__c = cas.Id;
            caseToAccount.put(cas.Id, acc);
            //createNewAccountList.add(acc);

            //Create new contact list to insert
            Contact cont = new Contact();

            Log.push('createNewContactAndAccountForCase cas.Supplied_First_Name__c: ' + cas.Supplied_First_Name__c);
            Log.push('createNewContactAndAccountForCase cas.Supplied_Last_Name__c: ' + cas.Supplied_Last_Name__c);

            if (cas.Supplied_First_Name__c != null && cas.Supplied_Last_Name__c != null){
                Log.push('first name and last name');
                cont.FirstName = cas.Supplied_First_Name__c;
                cont.LastName = cas.Supplied_Last_Name__c;
            } else if (cas.SuppliedName != Null){
                Log.push('suppliedname not null');
                cont.LastName = cas.SuppliedName;
            } else{
                cont.LastName = SYSTEM.LABEL.Unknown;
            }
            cont.Email = cas.SuppliedEmail;
            cont.Phone = cas.SuppliedPhone;
            cont.Brand_Id__c = cas.Brand__c;
            cont.Source_System__c = SYSTEM.LABEL.SFSC;
            cont.Channel__c = SYSTEM.LABEL.X6;//Per instructions from NASSC-938
            cont.Source__c = SYSTEM.LABEL.Service_Desk;//Per instructions from NASSC-938
            //setting record type due to process builder error for NASSC-841
            cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
            //cont.FirstName = cas.Id;
            caseToContact.put(cas.Id, cont);
            //createNewContactList.add(cont);
        }

        insert caseToAccount.values();
        insert caseToContact.values();

        for (case cas : caseMap.values()){
            if (caseToAccount.containsKey(cas.Id)){
                cas.AccountId = caseToAccount.get(cas.Id).Id;
            }

            if (caseToContact.containsKey(cas.Id)){
                cas.ContactId = caseToContact.get(cas.Id).Id;
            }
            updatedCaseList.add(cas);
        }

        update updatedCaseList;

        for (String caseId : caseToContact.keySet()){
            if (caseToAccount.containsKey(caseId)){
                caseToContact.get(caseId).AccountId = caseToAccount.get(caseId).Id;
            }
        }

        update caseToContact.values();
        Logger.logDebug();
    }

    @future
    public static void processNewPrivacyCases(List<Id> newCaseIds){

        List<Case> cases = [Select Id, SuppliedName, Brand__c, SuppliedEmail, ContactId
                            From Case
                            Where Id In:newCaseIds];
        List<String> caseEmails = new List<String>();
        List<String> brands = new List<String>();
        List<Case> matchedCases = new List<Case>();

        for (Case cse : cases){
            if (String.isNotBlank(cse.SuppliedEmail) && !caseEmails.contains(cse.SuppliedEmail)){
                caseEmails.add(cse.SuppliedEmail.toLowerCase());
            }
            if (String.isNotBlank(cse.Brand__c) && !brands.contains(cse.Brand__c)){
                brands.add(cse.Brand__c);
            }
        }
        Log.push('===emails ' + caseEmails);
        Log.push('===brands ' + brands);
        ///CODE updations FOR  PVH Jira - 2781
        List<Contact> cons = [Select Id, FirstName, LastName, Email, Brand_Id__c
                              From Contact
                              Where Brand_ID__c In:brands AND Email In:caseEmails
                              Order By Brand_ID__c, Email
                              LIMIT 10000];
        for (Contact con : cons){
            String conFullName;
            if (String.isBlank(con.FirstName)){
                conFullName = con.LastName;
            } else{
                conFullName = con.FirstName + con.LastName;
            }
            conFullName = conFullName.replace(' ', '').toLowerCase();
            String conEmail = con.Email.toLowerCase();
            ///CODE updations FOR  PVH Jira - 2781
            for (Case cse : cases){
                if (String.isBlank(cse.ContactId) && cse.Brand__c == con.Brand_Id__c && cse.SuppliedEmail.toLowerCase() == conEmail){
                    Log.push('===matched case ' + cse);
                    Log.push('===matched contact ' + con);
                    cse.ContactId = con.Id;
                    matchedCases.add(cse);
                }
            }
        }
        if (matchedCases.size() > 0){
            Log.push('===updating matched cases ' + matchedCases.size());
            update matchedCases;
        }
        Logger.logDebug();
    }

    @future
    public static void upsertChildContactOnParentupdate(Set<Id> parentContactIdSet){

        Map<Contact, list<Contact>> parentAndSubBrandContactMap = new Map<Contact, List<Contact>>();
        Map<String, Set<String>> parentAndSubBrandMap = new Map<String, Set<String>>();

        List<LoyaltySettings__mdt> LoyaltySettingList = [Select Id, BrandId__c, IsLoyaltyApplicable__c, Parent_Brand__c
                                                         from LoyaltySettings__mdt];
        if (!LoyaltySettingList.isEmpty()){
            for (LoyaltySettings__mdt loyalRecord : LoyaltySettingList){
                if (loyalRecord.Parent_Brand__c != null){
                    if (parentAndSubBrandMap.containsKey(loyalRecord.Parent_Brand__c)){
                        parentAndSubBrandMap.get(loyalRecord.Parent_Brand__c).add(loyalRecord.BrandId__c);
                    } else{
                        Set<String> subBrandIdSet = new Set<String>();
                        subBrandIdSet.add(loyalRecord.BrandId__c);
                        parentAndSubBrandMap.put(loyalRecord.Parent_Brand__c, subBrandIdSet);
                    }
                }
            }
        }
        Log.push('Parent and sub brand map ' + parentAndSubBrandMap);

        List<Contact> parentContactList = [select id, FirstName, MiddleName, LastName, Brand_Id__c, AccountId, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, EmailOptInStatus__c, EmailOptInDate__c, Email, Phone, HomePhone, OtherPhone, MobilePhone, HomeStore__c, Source_System__c, Source__c, LoyaltyFlag__c, Loyalty_Optin_Date__c, LoyaltyID__c, Company_Code__c, StorePreference__c, StoreOfCapture__c, WelcomeSource__c, Birthdate
                                           from Contact
                                           where Id IN:parentContactIdSet];

        List<Contact> contactListToUpsert = searchContacts(parentContactList, parentAndSubBrandMap);
        if (!contactListToUpsert.isEmpty()){
            upsert contactListToUpsert;
        }
    }

    //This method wil check if subbrands contacts exists-
    //if exists update  StoreOfCapture__c,WelcomeSource__c else create new one
    public static List<Contact> searchContacts(List<Contact> parentContactlist, Map<String, Set<String>> parentAndSubBrandMap){
        Map<Contact, List<Contact>> emailAndContactMap = new Map<Contact, List<Contact>>();
        Set<String> parentEmailIdSet = new Set<String>();
        Set<String> subBrandIdSet = new Set<String>();
        Map<Contact, List<Contact>> parentAndChildContactMap = new Map<Contact, List<Contact>>();
        List<Contact> updateContactList = new List<Contact>();
        Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();

        if (parentContactlist != null){
            for (Contact parentCon : parentContactlist){
                parentEmailIdSet.add(parentCon.Email);
                subBrandIdSet.addAll(parentAndSubBrandMap.get(parentCon.Brand_Id__c));
            }
        }

        List<Contact> searchedContactList = [SELECT Id, FirstName, MiddleName, LastName, Email, Brand_Id__c
                                             FROM Contact
                                             WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c IN:subBrandIdSet AND Email = :parentEmailIdSet];

        if (!searchedContactList.isEmpty()){
            for (Contact cnt : searchedContactList){
                for (Contact parentCon : parentContactlist){
                    if (!parentAndChildContactMap.containsKey(parentCon)){
                        List<Contact> subBrandContactList = new List<Contact>();
                        if (parentCon.Email == cnt.Email){
                            subBrandContactList.add(cnt);
                            parentAndChildContactMap.put(parentCon, subBrandContactList);
                        }
                    } else{
                        if (parentCon.Email == cnt.Email){
                            parentAndChildContactMap.get(parentCon).add(cnt);
                        }
                    }
                }
            }
        } else{
            for (Contact parentCon : parentContactlist){
                List<Contact> emptyCnt = new list<Contact>();
                parentAndChildContactMap.put(parentCon, emptyCnt);
            }
        }
        //check if searched contact list is empty
        if (parentAndChildContactMap != null){
            for (Contact con : parentAndChildContactMap.keySet()){
                Set<String> subBrandSet = parentAndSubBrandMap.get(con.Brand_Id__c);
                if (parentAndChildContactMap.get(con) != null){
                    for (Contact childCon : parentAndChildContactMap.get(con)){
                        if (subBrandSet.contains(childCon.Brand_Id__c)){
                            Contact updateCon = new Contact(id = childCon.id); //copy 2 fields from parent contact
                            updateCon.StoreOfCapture__c = con.StoreOfCapture__c;
                            updateCon.WelcomeSource__c = con.WelcomeSource__c;
                            updateCon.EmailOptinStatus__c = con.EmailOptinStatus__c;
                            updateCon.LoyaltyFlag__c = con.LoyaltyFlag__c;
                            updateContactList.add(updateCon);
                            subBrandSet.remove(childCon.Brand_Id__c);
                        }
                    }
                }
                if (subBrandSet != null){
                    //create new contacts if not exists for any subbrands
                    for (String subbrandId : subBrandSet){
                        Contact newCon = con.clone(false, true, false, false);
                        newCon.Brand_Id__c = subbrandId;
                        newCon.Status__c = SYSTEM.LABEL.ACTIVE;
                        updateContactList.add(newCon);
                    }
                }
            }
        }
        Logger.logDebug();
        return updateContactList;
    }

    private static void runUpdatePOSContact(List<Id> recordIds){
        
        
    }

}