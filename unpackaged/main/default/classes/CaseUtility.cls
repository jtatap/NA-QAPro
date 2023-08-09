/**
 * @author Magnet360
 *
 * @date 2019
 *
 * @description
 * Utility class for Cases
 *
 */
public class CaseUtility{
    public static void updateCaseContactdetails(List<Case> caseList, List<Contact> contactList){
        updateCaseContactdetails(caseList, contactList, true);
    }

    /*******************************************************************************************************
     * @description
     * Search for brand specific Contact first:
     * o    Search for the brand-specific Contact on Brand and Email if email is supplied in Case.  (Brand field on Contact is BrandId__c)
     * o    If you don’t find a result, or email is not supplied, but only phone is supplied in case, then search on Brand and Phone (Contact.Phone field)
     * o    If you find the brand specific Contact in either of above searches, link the Case to above contact, and Case.AccountId to above Contact’s AccountId.
     * •    If you don’t find a matching brand specific contact:
     * o    Search for generic Contact on Email if email is supplied in Case.
     * o    If you don’t find a result, or email is not supplied, but only phone is supplied in case, then search on Phone (Contact.Phone field)
     * o    If the generic Contact is found, then the Account is this Contact’s Account.  This is an Existing Account in the system.
     *     Now create a new Contact record using the Brand, Email and/or Phone, and other information supplied in the Case.
     *     Account for this new Contact is above existing Account.
     *     Link the case to this new contact and account.
     * o    If no generic contact is found:
     *     Create new Account and new Contact using the information provided in the case.
     *     If first name and last name are not provided in Case, set these as ‘Unknown’ on Contact/account.
     *
     * For any new Contact or Account records you create during above process, set ‘Source_System__c’ field on that record to ‘SFSC’.
     * @param caseList
     * @param contactList
     * @return void
     * @example
     */
    public static void updateCaseContactdetails(List<Case> caseList, List<Contact> contactList, Boolean callFuture){
        Boolean contactFound = false;
        List<Id> caseId = new List<Id>();
        List<Contact> updateContactList = new List<Contact>();
        List<Account> updateAccountList = new List<Account>();

        List<Contact> createContactList = new List<Contact>();
        Set<Id> caseContactNotFound = new Set<Id>();

        Map<Id, Case> caseMap = new Map<Id, Case>();
        //Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<Id, Id> caseContactBrandMap = new Map<Id, Id>();
        Map<Id, Id> caseContactGenericMap = new Map<Id, Id>();
        Map<Id, Id> caseWithExistingContact = new Map<Id, Id>();

        for (Case cas : caseList){
            caseMap.put(cas.Id, cas);
        }

        /*for(Contact con : contactList){
         contactMap.put(con.Id,con);
         }*/

        Log.push('>>caseMap :' + caseMap);

        //Log.push('>>contactMap :'+contactMap);

        //Iterating throught list of cases passed through trigger to relate to contact and account
        for (Case cas : caseList){
            if (cas.Type == Constants.privacyCaseType || cas.Sub_Type__c == Constants.unsubscribeRequestSubType)
                continue;
            //contactFound = false;

            contactPriorityWrapper cpw = new contactPriorityWrapper(cas.Id);


            //Since the contactList returned record order is not in prefered order as below
            //    1. Brand and Email
            //    2. Brand and Phone
            //    3. Only Email
            //    4. Only Phone
            //we have to use multiple for loops to find the exact matching contact

            //TODO - remove case sensitivity on email
            //TODO - is the phone input/match format standardized? Do we need to remove punctuation to do a match?
            //Creating Map for Case created via chat and having contact email
            if (cas.ContactEmail != Null && cas.SuppliedEmail == Null){
                Log.push('>>Case with Contact present');
                cpw.contactId = cas.ContactId;
                cpw.priority = 5;
                //caseWithExistingContact.put(cas.Id,cas.ContactId);
            }
            if (cpw.contactId == null){

                for (Contact con : contactList){
                    //Match on Brand, Email
                    Log.push('***Checking Contact');
                    Log.push(cas.Brand__c);
                    Log.push(cas.SuppliedEmail);
                    Log.push(con.Brand_Id__c);
                    Log.push(con.Email);
                    if (cas.Brand__c != Null && cas.Brand__c == con.Brand_Id__c && cas.SuppliedEmail != Null && String.valueOf(cas.SuppliedEmail) == String.valueOf(con.Email)){
                        //Case having Brand and Email present, searching for matching contact based on Brand and Email
                        Log.push('>>Brand and Email present');
                        //caseContactBrandMap.put(cas.Id, con.Id);
                        cpw.contactId = con.Id;
                        cpw.priority = 1; //Highest match priority
                        break; //Found the highest match, no need to keep searching
                    }

                    //Match on Brand, Phone
                    if (cas.Brand__c != Null && cas.Brand__c == con.Brand_Id__c && cas.SuppliedPhone != Null && String.valueOf(cas.SuppliedPhone) == String.valueOf(con.Phone) && (cpw.priority < 0 || cpw.priority > 2)){
                        //Case having Brand and Phone present, searching for matching contact based on Brand and Phone
                        Log.push('>>Brand and Phone present');
                        //caseContactBrandMap.put(cas.Id, con.Id);
                        cpw.contactId = con.Id;
                        cpw.priority = 2;

                    }

                    //Match on Email
                    if (cas.SuppliedEmail != Null && String.valueOf(cas.SuppliedEmail) == String.valueOf(con.Email) && (cpw.priority < 0 || cpw.priority > 3)){
                        //Case having Email present, searching for matching generic contact based on Email
                        Log.push('>>Email present');
                        //caseContactGenericMap.put(cas.Id, con.Id);
                        cpw.contactId = con.Id;
                        cpw.priority = 3;
                    }

                    //Match on Phone
                    if (cas.SuppliedPhone != Null && String.valueOf(cas.SuppliedPhone) == String.valueOf(con.Phone) && cpw.priority < 0){
                        //Case having Phone present, searching for matching generic contact based on Phone
                        Log.push('>>Phone present');
                        //caseContactGenericMap.put(cas.Id, con.Id);
                        cpw.contactId = con.Id;
                        cpw.priority = 4;
                    }
                }
            }

            if (cpw.contactId == null && (cas.SuppliedPhone != Null || cas.SuppliedEmail != Null)){
                Log.push('>>No Matching Contact found');
                //Create a new contact as long as Origin is not phone
                cpw.priority = 0;
                //caseContactNotFound.add(cas.Id);
            }
            if (cpw.priority == 1 || cpw.priority == 2){
                caseContactBrandMap.put(cpw.caseId, cpw.contactId);
            } else if (cpw.priority == 3 || cpw.priority == 4){
                caseContactGenericMap.put(cpw.caseId, cpw.contactId);
            } else if (cpw.priority == 5){
                caseWithExistingContact.put(cpw.caseId, cpw.contactId);
            } else if (cpw.priority == 0){
                caseContactNotFound.add(cpw.caseId);
            }


        }

        Log.push('>>caseContactBrandMap :' + caseContactBrandMap);
        Log.push('>>caseContactGenericMap :' + caseContactGenericMap);
        Log.push('>>caseWithExistingContact :' + caseWithExistingContact);
        Log.push('>>caseContactNotFound :' + caseContactNotFound);

        //Update Case with Contact & Account, found using Brand and Email/Phone.

        if (caseContactBrandMap.size() > 0){
            ContactFuture.updateCaseContactAndAccount(caseContactBrandMap, callFuture);
        }

        //Update Case with generic Contact's Account and create new Contact with Supplied Email, Brand & Phone details and relate to case

        if (caseContactGenericMap.size() > 0){
            ContactFuture.updateCaseAccountAndCreateNewContact(caseContactGenericMap, callFuture);
        }


        //Creating New Contact and Account for Case where no generic Contact was found
        if (caseContactNotFound.size() > 0){
            ContactFuture.createNewContactAndAccountForCase(caseContactNotFound, callFuture);
        }
        Logger.logDebug();
    }

    //This subclass is used to store the contact id while the list is looped to find the correct match
    private class contactPriorityWrapper{
        Id caseId;
        Id contactId;
        //Priority is the match level that was done. 1 - Brand and Email, 2 - Brand and Phone, 3 - only email, 4 - only phone, 5 - created via chat, 0 no match
        Integer priority;
        public contactPriorityWrapper(Id caseId){
            this.caseId = caseId;
            this.priority = -1;
        }

    }

    /*
     public static void assignLoyaltyId(Map<Contact, SObject> sequenceObjMap) {
     //Log.push('### sequenceObjMap ' + sequenceObjMap);
     Set<Id> seqTHList = new Set<Id>();
     Set<Id> seqCKList = new Set<Id>();
     Set<Id> seqHerList = new Set<Id>();
     SObjectType SObjectType;

     Savepoint sp = Database.setSavepoint();
     insert sequenceObjMap.values();

     for(SObject sobj: sequenceObjMap.values()){
     SObjectType = sobj.Id.getsobjecttype();
     Log.push('### sobj ' + sobj.Id); Log.push('### SObjectType ' + SObjectType);

     if(String.valueOf(SObjectType) == 'LoyaltyID_TH__c') seqTHList.add(sobj.Id);
     if(String.valueOf(SObjectType) == 'LoyaltyID_CK__c') seqCKList.add(sobj.Id);
     if(String.valueOf(SObjectType) == 'LoyaltyID_Heritage__c') seqHerList.add(sobj.Id);
     }

     String queryTH = 'Select Id, Name from LoyaltyID_TH__c WHERE Id in :seqTHList';
     String queryCK = 'Select Id, Name from LoyaltyID_CK__c WHERE Id in :seqCKList';
     String queryHer = 'Select Id, Name from LoyaltyID_Heritage__c WHERE Id in :seqHerList';

     //Log.push('### seqTHList' + seqTHList); Log.push('### seqCKList' + seqCKList); Log.push('### seqHerList' + seqHerList);
     List<SObject> thLoyaltyList =  Database.Query(queryTH);
     List<SObject> ckLoyaltyList =  Database.Query(queryCK);
     List<SObject> herLoyaltyList =  Database.Query(queryHer);

     setLoyaltyID(thLoyaltyList, sequenceObjMap, 'LoyaltyID_TH__c');
     setLoyaltyID(ckLoyaltyList, sequenceObjMap, 'LoyaltyID_CK__c');
     setLoyaltyID(herLoyaltyList, sequenceObjMap, 'LoyaltyID_Heritage__c');

     Database.rollback(sp);

     }

     public static void setLoyaltyID(List<SObject> sequenceLoyaltyList, Map<Contact, SObject> sequenceObjMap, String sObjectType) {
     //Log.push('### sObjectType setLoyaltyID' + sObjectType); Log.push('### sequenceLoyaltyList' + sequenceLoyaltyList); Log.push('### sequenceObjMap' + sequenceObjMap);

     for(SObject l: sequenceLoyaltyList){
     for(Contact c: sequenceObjMap.keySet()){
     LoyaltyID_TH__c seqTHObj;
     LoyaltyID_CK__c seqCKObj;
     LoyaltyID_Heritage__c seqHerObj;

     if(String.isEmpty(c.LoyaltyID__c)) {
     if(sObjectType == 'LoyaltyID_TH__c' && String.valueOf(c.Brand_Id__c) == '1') {
     seqTHObj = (LoyaltyID_TH__c) l;
     c.LoyaltyID__c = seqTHObj.Name;
     break;
     }
     if(sObjectType == 'LoyaltyID_CK__c'  && String.valueOf(c.Brand_Id__c) == '2') {
     seqCKObj = (LoyaltyID_CK__c) l;
     c.LoyaltyID__c = seqCKObj.Name;
     break;
     }
     if(sObjectType == 'LoyaltyID_Heritage__c'  && String.valueOf(c.Brand_Id__c) == '9') {
     seqHerObj = (LoyaltyID_Heritage__c) l;
     c.LoyaltyID__c = seqHerObj.Name;
     break;
     }
     }
     Log.push('### c.LoyaltyID__c' + c.LoyaltyID__c);
     }
     }
     }
     */
}