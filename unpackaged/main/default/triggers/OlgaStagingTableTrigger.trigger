trigger OlgaStagingTableTrigger on OlgaStagingTable__c (before insert) {

    List<Contact> newContactList = new List<Contact>();
    List<Account> newAccountList = new List<Account>();


    Set<String> EmailSet = new Set<String>();
    Set <String> BrandIds = new Set<String>();
    Set<String> PhoneSet = new Set<String>();

    SObject[] sobjectsList = new List<SObject>();


    Id emailContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    Id smsContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SMSMobile').getRecordTypeId();
    Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    List <Contact> brandEmailContacts = new List<Contact>();
    List <Contact> brandPhoneContacts = new List<Contact>();
    Map <String,Map<String,Map<String,List<Contact>>>> BrandToEmailtoFirstNameContactMap = new Map <String,Map<String,Map<String,List<Contact>>>>();
    Map <String,Map<String,Map<String,List<Contact>>>> BrandToPhonetoFirstNameContactMap = new Map <String,Map<String,Map<String,List<Contact>>>>();
    public Map <OlgaStagingTable__c, Contact> OSTtoNewContactMap = new Map<OlgaStagingTable__c, Contact>();


    List <Account> tobeUpdatedAccounts = new List <Account>();
    List <Contact> tobeUpdatedContacts = new List <Contact>();
    Boolean isSandbox = [select isSandbox from Organization limit 1].isSandbox;


    for(OlgaStagingTable__c OST : Trigger.new)
    {   System.debug('**** OST: '+ OST);
        if (OST.email__c!=null) {
            if (isSandbox) OST.email__c = OST.email__c.replace('@','=')+'@example.com';
            EmailSet.add(OST.email__c);
        }
        if (OST.BrandId__c!=null) BrandIds.add(OST.BrandId__c);
        if (OST.Phone__c!=null) PhoneSet.add(OST.Phone__c);
        if (OST.Other_phone__c!=null) PhoneSet.add(OST.Other_phone__c);

    }
    System.debug('**** PhoneSet: '+ PhoneSet);


    if (!BrandIds.isEmpty() && !EmailSet.isEmpty()){
        brandEmailContacts = [SELECT Id, FirstName, MiddleName, LastName,
                Brand_Id__c,  Email, Phone, MobilePhone, OtherPhone, AccountId, //Fraud__c
                ZdTnCUserId__c,ZdPVHUserId__c, External_Id__c, Customer_Id__c,
                PVHCreatedDate__c, PVHLastModifiedDate__c, ZdOtherAddress__c,  ZdMatchType__c
        FROM Contact
        WHERE (RecordTypeId = :emailContactRecordTypeId or RecordTypeId = :smsContactRecordTypeId)
        and Brand_Id__c IN :BrandIds and Email IN :EmailSet

        order by Brand_Id__c, Email, FirstName];

    }


    if (!BrandIds.isEmpty() && !PhoneSet.isEmpty()){
        brandPhoneContacts = [SELECT Id, FirstName, MiddleName, LastName,
                Brand_Id__c,  Email, Phone, MobilePhone, OtherPhone, AccountId, // Fraud__c
                ZdTnCUserId__c,ZdPVHUserId__c, External_Id__c, Customer_Id__c,
                PVHCreatedDate__c, PVHLastModifiedDate__c, ZdOtherAddress__c, ZdMatchType__c
        FROM Contact
        WHERE (RecordTypeId = :emailContactRecordTypeId or RecordTypeId = :smsContactRecordTypeId)
        and Brand_Id__c IN :BrandIds
        and (Phone in :PhoneSet or MobilePhone in :PhoneSet or OtherPhone in :PhoneSet)

        order by Brand_Id__c, Phone, MobilePhone, OtherPhone, FirstName];

    }
    System.debug('*** brandPhoneContacts: ' + brandPhoneContacts);

    Map<String, Id> emailToAccountIdMap = new Map<String,Id>();
    Map<String, Id> PhoneToAccountIdMap = new Map<String,Id>();
    Map<String, Id> MobilePhoneToAccountIdMap = new Map<String,Id>();
    Map<String, Id> OtherPhoneToAccountIdMap = new Map<String,Id>();

    List <Contact> EmailContacts = new List<Contact>();
    List <Contact> PhoneContacts = new List<Contact>();
    if (!EmailSet.isEmpty()){

        EmailContacts = [SELECT  Id, Email, AccountId
        FROM Contact
        WHERE (RecordTypeId = :emailContactRecordTypeId or RecordTypeId = :smsContactRecordTypeId)
        and Email IN :EmailSet
        order by  Email];

    }
    if (!EmailContacts.isEmpty()) {
        for (Contact Con : EmailContacts) {
            emailToAccountIdMap.put(Con.Email, Con.AccountId);
        }
    }
    if (!PhoneSet.isEmpty()){

        PhoneContacts = [SELECT  Id,  Phone, MobilePhone, OtherPhone, AccountId
        FROM Contact
        WHERE (RecordTypeId = :emailContactRecordTypeId or RecordTypeId = :smsContactRecordTypeId)
        and (Phone in :PhoneSet or MobilePhone in :PhoneSet or OtherPhone in :PhoneSet)
        order by  Phone, MobilePhone, OtherPhone];

    }
    if (!PhoneContacts.isEmpty()) {
        for (Contact Con : PhoneContacts) {

            if (Con.Phone!=null) PhoneToAccountIdMap.put(Con.Phone, Con.AccountId);
            if (Con.MobilePhone!=null) MobilePhoneToAccountIdMap.put(Con.MobilePhone, Con.AccountId);
            if (Con.OtherPhone!=null) OtherPhoneToAccountIdMap.put(Con.OtherPhone, Con.AccountId);
        }
    }
    if (!brandEmailContacts.isEmpty()) {
        for (Contact beCon : brandEmailContacts){
            Map <String,Map<String, List<Contact>>> emailToFirstNameToContactMap = new Map<String,Map<String,List<Contact>>>();
            Map <String, List<Contact>> FirstNameToContactListMap = new Map<String, List<Contact>>();
            List <Contact> contactList = new List<Contact>();


            if (BrandToEmailtoFirstNameContactMap.containsKey(beCon.Brand_Id__c)) {
                emailToFirstNameToContactMap = BrandToEmailtoFirstNameContactMap.get(beCon.Brand_Id__c);
                if (emailToFirstNameToContactMap!=null && emailToFirstNameToContactMap.containsKey(beCon.Email)) {
                    FirstNameToContactListMap = emailToFirstNameToContactMap.get(beCon.Email);
                    if (FirstNameToContactListMap!=null && FirstNameToContactListMap.containsKey(beCon.FirstName)) {
                        FirstNameToContactListMap.get(beCon.FirstName).add(beCon); //another firstname
                    } else {  //first with firstname
                        contactList.add(beCon);
                        FirstNameToContactListMap.put(beCon.FirstName,contactList);
                    }

                } else  { //first with email
                    contactList.add(beCon);
                    FirstNameToContactListMap.put(beCon.FirstName,contactList);
                    emailToFirstNameToContactMap.put(beCon.Email,FirstNameToContactListMap);
                }
            } else  {  // first with  brand id
                contactList.add(beCon);
                FirstNameToContactListMap.put(beCon.FirstName,contactList);
                emailToFirstNameToContactMap.put(beCon.Email,FirstNameToContactListMap);
                BrandToEmailtoFirstNameContactMap.put(beCon.Brand_Id__c, emailToFirstNameToContactMap);
            }


        }
    }

    if (!brandPhoneContacts.isEmpty()) {
        for (Contact beCon : brandPhoneContacts){
            System.debug('**** beCon: '+beCon);
            Map <String,Map<String, List<Contact>>> phoneToFirstNameToContactMap = new Map<String,Map<String,List<Contact>>>();
            Map <String, List<Contact>> FirstNameToContactListMap = new Map<String, List<Contact>>();
            List <Contact> contactList = new List<Contact>();
            String thisPhone;
            if (beCon.Phone!=null) thisPhone = beCon.Phone;
            else if (beCon.MobilePhone!=null) thisPhone = beCon.MobilePhone;
            else if (beCon.OtherPhone!=null) thisPhone = beCon.OtherPhone;
            System.debug('**** thisPhone: '+thisPhone);
            if (thisPhone!=null){
                if (BrandToPhonetoFirstNameContactMap.containsKey(beCon.Brand_Id__c)) {
                    phoneToFirstNameToContactMap = BrandToPhonetoFirstNameContactMap.get(beCon.Brand_Id__c);
                    if (phoneToFirstNameToContactMap!=null && phoneToFirstNameToContactMap.containsKey(thisPhone)) {
                        FirstNameToContactListMap = phoneToFirstNameToContactMap.get(thisPhone);
                        if (FirstNameToContactListMap!=null && FirstNameToContactListMap.containsKey(beCon.FirstName)) {
                            FirstNameToContactListMap.get(beCon.FirstName).add(beCon);
                        } else {
                            contactList.add(beCon);
                            FirstNameToContactListMap.put(beCon.FirstName,contactList);
                        }

                    } else  {
                        contactList.add(beCon);
                        FirstNameToContactListMap.put(beCon.FirstName,contactList);
                        phoneToFirstNameToContactMap.put(thisPhone,FirstNameToContactListMap);
                    }
                } else  {
                    contactList.add(beCon);
                    FirstNameToContactListMap.put(beCon.FirstName,contactList);
                    phoneToFirstNameToContactMap.put(thisPhone,FirstNameToContactListMap);
                    BrandToPhonetoFirstNameContactMap.put(beCon.Brand_Id__c, phoneToFirstNameToContactMap);
                }
            }

        }
    }
    System.debug('***** BrandToPhonetoFirstNameContactMap: '+ BrandToPhonetoFirstNameContactMap);

    for (OlgaStagingTable__c otable : Trigger.new){


        Contact oMatchingContact;
        Boolean createNewContact = false;
        String MatchType;
        Integer analyzeBucketNumber;

        Map <String,Map<String, List<Contact>>> oemailToFirstNameContactMap = new Map<String,Map<String,List<Contact>>>();
        Map <String,Map<String, List<Contact>>> oPhoneToFirstNameContactMap = new Map<String,Map<String,List<Contact>>>();
        Map <String, List<Contact>> oFirstNameToContactMap = new Map<String, List<Contact>>();
        List<Contact> oContactList = new List<Contact>();
        String firstName, lastName, middleName;

        if (String.isBlank(otable.Customer_Name__c)){
            //
        } else {
            String[] names = otable.Customer_Name__c.trim().split(' ');
            if (names.size()==1) {
                firstName= names[0];

            } else {
                firstName= names[0];
                lastName = names[names.size()-1];
            }
            if (names.size()>2) {
                middleName = names[1];
                Integer i = 0;
                for (String name: names){

                    if (i>1 && i<=(names.size()-2)) middleName += ' ' + name;
                    i++;
                }
                middleName = middleName.trim();
            }

        }
        System.debug('****'+ BrandToEmailtoFirstNameContactMap);
        System.debug('****'+ BrandToPhonetoFirstNameContactMap);



        if (otable.BrandId__c!=null && otable.email__c!=null) {
            oemailToFirstNameContactMap = BrandToEmailtoFirstNameContactMap.get(otable.BrandId__c);
            System.debug('****'+ otable);
            System.debug('****'+ oemailToFirstNameContactMap);

            if (oemailToFirstNameContactMap!=null && oemailToFirstNameContactMap.containsKey(otable.email__c)) {
                // match on brand+email
                oFirstNameToContactMap = oemailToFirstNameContactMap.get(otable.email__c);
                System.debug('****'+ oFirstNameToContactMap);
                if (oFirstNameToContactMap.size()==1 && oFirstNameToContactMap.values()[0].size()==1) {
                    // unique match: only one contact with same brand + email
                    System.debug('****'+ oFirstNameToContactMap.values()[0]);
                    oMatchingContact = oFirstNameToContactMap.values()[0][0];
                    MatchType = 'UniqueMatchByEmail';
                    captureUniquelyMatchedContactDetails(otable,oMatchingContact);


                }  else {
                    // multiple first names with same brand+email
                    if (oFirstNameToContactMap.containsKey(firstName)) {
                        oContactList = oFirstNameToContactMap.get(firstName);
                        if (oContactList.size()==1){
                            // unique match with brand+email+firstname
                            oMatchingContact = oContactList[0];
                            MatchType = 'UniqueMatchByEmailFirstName';
                            captureUniquelyMatchedContactDetails(otable,oMatchingContact);
                        } else {
                            // multiple matches with same brand + email + firstname, analyze bucket-2
                            analyzeBucketNumber = 2;
                            MatchType = 'MultipleMatchByEmailFirstName';
                            System.debug('***'+oContactList);
                            captureMultiMatchedContactDetails(otable, oContactList);

                            System.debug('****'+ otable.ZdMultiMatchedContactIds__c);

                        }
                    } else {
                        // no match with given brand+email+firstname, analyze bucket-1
                        analyzeBucketNumber = 1;
                        MatchType = 'NoMatchByEmailFirstName';
                    }

                }

            } else {
                // match on brand, no match on email, create new contact
                createNewContact = true;
                MatchType = 'New-NoEmailMatch';
            }

        } else if (otable.BrandId__c!=null && (otable.Phone__c!=null || otable.Other_phone__c!=null)) {
            oPhoneToFirstNameContactMap = BrandToPhonetoFirstNameContactMap.get(otable.BrandId__c);

            System.debug('****'+ oPhoneToFirstNameContactMap);

            if (oPhoneToFirstNameContactMap!=null && oPhoneToFirstNameContactMap.containsKey(otable.Phone__c)) oFirstNameToContactMap = oPhoneToFirstNameContactMap.get(otable.Phone__c);
            else if (oPhoneToFirstNameContactMap!=null && oPhoneToFirstNameContactMap.containsKey(otable.Other_phone__c)) oFirstNameToContactMap = oPhoneToFirstNameContactMap.get(otable.Other_phone__c);

            if (oPhoneToFirstNameContactMap!=null && oPhoneToFirstNameContactMap.size()>0) {
                // match on brand+phone

                System.debug('****'+ oFirstNameToContactMap);
                if (oFirstNameToContactMap.size()==1 && oFirstNameToContactMap.values()[0].size()==1) {
                    // unique match: only one contact with same brand + phone
                    System.debug('****'+ oFirstNameToContactMap.values()[0]);
                    oMatchingContact = oFirstNameToContactMap.values()[0][0];
                    MatchType = 'UniqueMatchByPhone';
                    captureUniquelyMatchedContactDetails(otable,oMatchingContact);

                }  else {
                    // multiple first names with same brand+phone
                    if (oFirstNameToContactMap.containsKey(firstName)) {
                        oContactList = oFirstNameToContactMap.get(firstName);
                        if (oContactList.size()==1){
                            // unique match with brand+phone+firstname
                            oMatchingContact = oContactList[0];
                            MatchType = 'UniqueMatchByPhoneFirstName';
                            captureUniquelyMatchedContactDetails(otable,oMatchingContact);
                        } else {
                            // multiple matches with same brand + phone + firstname, analyze bucket-2
                            analyzeBucketNumber = 2;
                            MatchType = 'MultipleMatchByPhoneFirstName';
                            System.debug('***'+oContactList);
                            captureMultiMatchedContactDetails(otable, oContactList);
                            System.debug('****'+ otable.ZdMultiMatchedContactIds__c);

                        }
                    } else {
                        // no match with given brand+email+firstname, analyze bucket-1
                        analyzeBucketNumber = 1;
                        MatchType = 'NoMatchByPhoneFirstName';
                    }

                }

            } else {
                // match on brand, no match on phone, create new contact
                createNewContact = true;
                MatchType = 'New-NoPhoneMatch';
            }

        } else {
            // no email or no phone in source, create new contact

            if (otable.BrandId__c!=null) {
                createNewContact = true;
                MatchType = 'New-noEmailorPhoneInSource';
            }


        }

        otable.ZdMatchType__c = MatchType;
        if (oMatchingContact!=null)  updateContact(otable, oMatchingContact, MatchType, tobeUpdatedContacts, tobeUpdatedAccounts);
        else if (createNewContact)  createContact(otable,MatchType,  newContactList, newAccountList, firstName, middleName, lastName, emailToAccountIdMap, phoneToAccountIdMap);




    }

    if (newContactList.size()>0) {
        sobjectsList.addAll(newAccountList);
        sobjectsList.addAll(newContactList);

        System.debug('***'+newAccountList);
        System.debug('***'+newContactList);


        Database.SaveResult[] srResults = Database.insert(sobjectsList, false);

        for (Database.SaveResult sr : srResults) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('*** srSuccess ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('sr error: ' + err.getFields());
                }
            }
        }
        for (OlgaStagingTable__c ost: OSTtoNewContactMap.keySet()){
            Contact newCon = OSTtoNewContactMap.get(ost);
            System.debug(newCon);

            if (newCon.Id!=null) ost.Contact__c = newCon.id;
        }


    }


    if (tobeUpdatedContacts.size()>0) update tobeUpdatedContacts;
    if (tobeUpdatedAccounts.size()>0) update tobeUpdatedAccounts;


    public static void captureMultiMatchedContactDetails(OlgaStagingTable__c otable, List<Contact> oContactList){
        Integer i = 1;
        String ExId, CustId;
        for (Contact c : oContactList) {
            ExId = 'None';
            CustId = 'None';
            if (c.External_Id__c!=null) ExId = c.External_Id__c;
            if (c.Customer_Id__c!=null) CustId = c.Customer_Id__c;
            if (i==1) otable.MultiMatchedContactsData__c = c.id +','+ExId+','+CustId;
            else otable.MultiMatchedContactsData__c += ';'+ c.id +','+ ExId+','+CustId;
            i++;
        }

    }

    public static void captureUniquelyMatchedContactDetails(OlgaStagingTable__c otable, Contact oMatchingContact){
        String ExId = 'None';
        String CustId = 'None';
        if (oMatchingContact.External_Id__c!=null) ExId = oMatchingContact.External_Id__c;
        if (oMatchingContact.Customer_Id__c!=null) CustId = oMatchingContact.Customer_Id__c;
        otable.ZdUniqueMatchedContactId__c = oMatchingContact.id +','+ExId+','+CustId;


    }


    public static void updateContact(OlgaStagingTable__c otable, Contact oMatchingContact, String MatchType, List<Contact> tobeUpdatedContacts, List<Account> tobeUpdatedAccounts){




        if (oMatchingContact.ZdMatchType__c==null) {

            oMatchingContact.ZdUniqueMatch__c = true;
            oMatchingContact.ZdMatchType__c = MatchType;
            if (otable.ZdPVHUserId__c != null) oMatchingContact.ZdPVHUserId__c = otable.ZdPVHUserId__c;
            if (otable.ZdTnCUserId__c != null) oMatchingContact.ZdTnCUserId__c = otable.ZdTnCUserId__c;
            if (otable.Phone__c != null && oMatchingContact.Phone == null) oMatchingContact.Phone = otable.Phone__c;
            if (otable.Other_phone__c != null && oMatchingContact.OtherPhone == null) oMatchingContact.OtherPhone = otable.Other_phone__c;
            oMatchingContact.PVHCreatedDate__c = otable.created_at__c;
            oMatchingContact.PVHLastModifiedDate__c = otable.updated_at__c;
            //uncomment below line once Fraud__c checkbox is introduced on Contact
    //      if ((oMatchingContact.id != null) && (otable.possible_fraud__c != null) && (otable.possible_fraud__c) && !(oMatchingContact.Fraud__c)) oMatchingContact.Fraud__c = true;


            if (otable.alternate_address__c != null && oMatchingContact.ZdOtherAddress__c == null) oMatchingContact.ZdOtherAddress__c = otable.alternate_address__c;
            tobeUpdatedContacts.add(oMatchingContact);
        }

    } // end updateContact()




    public static void createContact(OlgaStagingTable__c otable, String MatchType, List<Contact> newContactList, List<Account> newAccountList, String firstName, String middleName, String lastName, Map<String, Id> emailToAccountIdMap, Map<String, Id> phoneToAccountIdMap) {


        String randomNumber;

        Id accId;
        if (otable.email__c!=null) {  //take parent account from the sibling email contact
            if (emailToAccountIdMap.containsKey(otable.email__c)) accId = emailToAccountIdMap.get(otable.email__c);

        } else if (otable.Phone__c!=null || otable.Other_phone__c!=null) { // from sibling phone contact

            if (otable.Phone__c!=null && PhoneToAccountIdMap.containsKey(otable.Phone__c)){
                accId = PhoneToAccountIdMap.get(otable.Phone__c);
            } else if (otable.Phone__c!=null && MobilePhoneToAccountIdMap.containsKey(otable.Phone__c)){
                accId = MobilePhoneToAccountIdMap.get(otable.Phone__c);
            } else if (otable.Phone__c!=null && OtherPhoneToAccountIdMap.containsKey(otable.Phone__c)){
                accId = OtherPhoneToAccountIdMap.get(otable.Phone__c);
            } else if (otable.Other_phone__c!=null && PhoneToAccountIdMap.containsKey(otable.Other_phone__c)){
                accId = PhoneToAccountIdMap.get(otable.Other_phone__c);
            } else if (otable.Other_phone__c!=null && MobilePhoneToAccountIdMap.containsKey(otable.Other_phone__c)){
                accId = MobilePhoneToAccountIdMap.get(otable.Other_phone__c);
            } else if (otable.Other_phone__c!=null && OtherPhoneToAccountIdMap.containsKey(otable.Other_phone__c)){
                accId = OtherPhoneToAccountIdMap.get(otable.Other_phone__c);
            }

        }

        if (accId==null){  //no sibling contact exists with same email/phone, so create new parent account

            randomNumber  = System.now().getTime().format() + String.ValueOf(Integer.valueOf(math.rint(math.random()*1000000)));
            Account acc = new Account();
            acc.Name = firstName + ' ' + lastName;

            acc.RecordTypeId = customerAccountRecordTypeId;
            acc.ZdProfExtId__c = randomNumber;
            newAccountList.add(acc);

        }

        Contact con = new Contact();
        con.RecordTypeId = emailContactRecordTypeId;
        con.Status__c = 'ACTIVE';
        con.ZdMatchType__c = MatchType;


        if (firstName==null) firstName = 'Unknown';
        if (lastName==null) lastName = 'Unknown';

        con.FirstName = firstName;
        con.LastName = lastName;
        if (middleName!=null) con.MiddleName = middleName;
        
        con.Brand_Id__c= otable.BrandId__c;
     //   if (otable.BrandId__c == '11') con.Do_Not_Sync_with_SFMC__c  = true;
        con.Do_Not_Sync_with_SFMC__c  = true;
        if (otable.email__c!=null)  con.Email=otable.email__c;
        if (otable.Phone__c!=null) con.Phone = otable.Phone__c;
        if (otable.Other_phone__c!=null) con.OtherPhone = otable.Other_phone__c;

        con.Source_System__c = otable.Source_System__c;

        con.CreatedByMethod__c = 'Data Migration';
        if (otable.created_at__c!=null) {
            con.PVHCreatedDate__c = otable.created_at__c;
            con.CreatedDate = otable.created_at__c;
        }
        if (otable.updated_at__c!=null) {
            con.PVHLastModifiedDate__c = otable.updated_at__c;
            con.LastModifiedDate = otable.updated_at__c;
            con.ZdLastModifiedDate__c = otable.updated_at__c;
        }
        //uncomment below line once Fraud__c checkbox is introduced on Contact
    //    if (otable.possible_fraud__c!=null && otable.possible_fraud__c) con.Fraud__c = otable.possible_fraud__c;
        if (otable.alternate_address__c!=null) con.ZdOtherAddress__c = otable.alternate_address__c;


        if (otable.ZdPVHUserId__c!=null) {
            con.ZdPVHUserId__c = otable.ZdPVHUserId__c;
        }
        if (otable.ZdTnCUserId__c!=null) {
            con.ZdTnCUserId__c = otable.ZdTnCUserId__c;

        }




        if (accId!=null) con.AccountId = accId;
        else {
            Account accRef = new Account(ZdProfExtId__c = randomNumber);
            con.Account = accRef;
        }

        newContactList.add(con);

        OSTtoNewContactMap.put(otable, con);

    } // end createContact()



}