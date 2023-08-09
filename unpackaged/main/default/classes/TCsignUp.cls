/*
 * Created Date :10/04/2020
 * Created By   :PVH
 *
 * JSON Request :
 * {"brandId": "11","firstName": "John","lastName": "Doe","country":"US","emailAddress": "john@someEmail.com","emailOptIn": "true","SourceSystem": "TC","WelcomeSource": "01"}
 * URL: https://instance.salesforce.com/services/apexrest/tcsubscriber/SignUp
 *
 */
@RestResource(urlMapping = '/tcsubscriber/SignUp')
global without sharing class TCsignUp{
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    static Map<String, String> mapSubbrandParentbrand = new Map<String, String>();
    global class TnCoRequest{
        public String brandId;
        public String firstName;
        public String lastName;
        public String country;
        public String emailAddress;
        public String emailOptIn;
        public String SourceSystem;
        public String WelcomeSource;
    }

    global class TnCoResponse{
        public String code;
        public String message;
        public String ContactId;
        public String ExistingCustomer;
        public String NewsLetterAlreadySignedUp;
    }

    @HttpPost
    global static TnCoResponse doSignup(){

        List<Contact> profileUpdateContacts = new List<Contact>();
        Map<Id, Contact> oldContacts = new Map<Id, Contact>();
        Boolean existingCont = false;
        List<Contact> newConList = new List<Contact>();
        List<Contact> allContactList = new List<Contact>();

        List<ID> allContactID = new List<ID>();
        Contact contact = new Contact();
        Date reqBDate;

        List<Contact> contacts = new List<Contact>();
        List<Contact> updatedconList = new List<Contact>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        TnCoRequest tNcoReq = (TnCoRequest)json.deserialize(requestData, TnCoRequest.class);
        Log.push('tNcoReq***' + tNcoReq);
        TnCoResponse tnCoResponse = new TnCoResponse();

        // Brand id or email not present in request, return error message
        if (String.isEmpty(tNcoReq.brandId) || String.isEmpty(tNcoReq.emailAddress) || String.isBlank(tNcoReq.brandId) || String.isBlank(tNcoReq.emailAddress)){
            res.statusCode = 400;
            tnCoResponse.code = SYSTEM.LABEL.INVALID_QUERY;
            tnCoResponse.message = SYSTEM.LABEL.Missing_required_parameters_BrandId_or_email;
            Log.push('***tnCoResponse: ' + tnCoResponse);
            return tnCoResponse;
        } else{
            //Brand id and email present in request

            //Check for existing contact
            contacts = searchContacts(tNcoReq.brandId, tNcoReq.emailAddress, emailRecordTypeId);
            Log.push('contacts***' + contacts);
            if (contacts != NULL && contacts.size() > 0){
                contact = contacts[0];
            }
            If (tNcoReq.brandId == SYSTEM.LABEL.X11){
                //Contact not found
                if (contacts.size() < 1){
                    newConList.add(createContact(tNcoReq, tNcoReq.brandId));

                } else{
                    existingCont = true;
                    oldContacts.put(contact.Id, contact.clone());
                    profileUpdateContacts.add(updateContact(contact, tNcoReq));
                }
            }

            if (profileUpdateContacts.size() > 0){
                Database.SaveResult[] srList = Database.update (profileUpdateContacts, false);
                for (Contact con : profileUpdateContacts){
                    if (con.id != null)
                        allContactList.add(con);
                }
            }
            if (newConList.size() > 0){
                Database.SaveResult[] srList = Database.insert (newConList, false);
                for (Contact con : newConList){
                    if (con.id != null)
                        allContactList.add(con);
                }

            }


            for (Contact con : allContactList){
                allContactID.add(con.Id);
            }


        }

        res.statusCode = 200;
        tnCoResponse = returnResponse(existingCont, allContactID, tNcoReq.brandId, oldContacts);
        Log.push('***tnCoResponse: ' + tnCoResponse);
        Logger.logDebug();
        return tnCoResponse;
    }

    //Search Contact record
    Static List<Contact> searchContacts(String brandId, String emails, Id emailRecordTypeId){

        Log.push('Contact search Brand Id***' + brandId);
        Log.push('Contact search emails***' + emails);
        Log.push('Contact search emailRecordTypeId***' + emailRecordTypeId);
        List<Contact> searchedContactList = [SELECT Id, FirstName, LastName, Brand_Id__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, Phone, MobilePhone, MailingCountry, Email, HomePhone, Birthdate, HomeStore__c, AccountId, Latest_Source__c, EmailOptInStatus__c, ReportsToId, Source_System__c, Do_Not_Sync_with_SFMC__c, WelcomeSource__c, StoreOfCapture__c, createdByMethod__c
                                             FROM Contact
                                             WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c = :brandId AND Email = :emails];
        Logger.logDebug();
        return ((searchedContactList != null) ? searchedContactList : Null);
    }

    //Create New Contact record
    Static Contact createContact(TnCoRequest tNcoReq, String brandId){
        Log.push('tNcoReq.emailOptIn****' + tNcoReq.emailOptIn);
        Contact con = new Contact();
        con.RecordTypeId = emailRecordTypeId;

        if (String.isNotBlank(tNcoReq.sourceSystem)){
            con.Source_System__c = tNcoReq.sourceSystem;
            con.Latest_Source__c = tNcoReq.sourceSystem;
        } else{
            con.Source_System__c = SYSTEM.LABEL.TC;
            con.Latest_Source__c = SYSTEM.LABEL.TC;
        }
        con.createdByMethod__c = SYSTEM.LABEL.API;
        con.Status__c = SYSTEM.LABEL.Active;

        if (String.isNotEmpty(brandId)){
            con.Brand_Id__c = brandId;
        } else
            con.Brand_Id__c = tNcoReq.brandId;
        String searchBrand = tNcoReq.brandId;
        Log.push('createContact - searchBrand**** = ' + searchBrand);

        if (String.isNotBlank(tNcoReq.firstName))
            con.FirstName = tNcoReq.firstName;
        else if (String.isBlank(tNcoReq.firstName) || String.valueOf(tNcoReq.firstName) == '')
            con.firstName = SYSTEM.LABEL.UNKNOWN1;
        if (String.isNotBlank(tNcoReq.lastName)){
            con.LastName = tNcoReq.lastName;
        } else if (String.isBlank(tNcoReq.lastName) || String.valueOf(tNcoReq.lastName) == '')
            con.LastName = SYSTEM.LABEL.UNKNOWN1;
        if (String.isNotBlank(tNcoReq.country)){
            con.MailingCountry = tNcoReq.country;
        } else if (String.isBlank(tNcoReq.country) || String.valueOf(tNcoReq.country) == '')
            con.MailingCountry = 'US';
        if (String.isNotBlank(tNcoReq.emailAddress))
            con.Email = tNcoReq.emailAddress;
        Log.push('WelcomeSource**** = ' + tNcoReq.WelcomeSource);

        if (String.isNotBlank(tNcoReq.WelcomeSource))
            con.WelcomeSource__c = tNcoReq.WelcomeSource;
        If (String.isNotBlank(tNcoReq.sourceSystem)){
            con.Latest_Source__c = tNcoReq.sourceSystem;
        } else if (String.isBlank(tNcoReq.sourceSystem) || String.valueOf(tNcoReq.sourceSystem) == '')
            con.Latest_Source__c = SYSTEM.LABEL.TC;
        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                           FROM SubscriberDataSources__mdt
                                                           WHERE Brand__c = :searchBrand AND SourceSystem__c = :tNcoReq.SourceSystem AND WelcomeSource__c = :tNcoReq.WelcomeSource];

        if (listDataSource.size() > 0){
            con.EmailOrigSource__c = listDataSource[0].DataSource__c;
            con.Source__c = listDataSource[0].DataSource__c;
        }

        if (String.isNotBlank(tNcoReq.emailOptIn) && Boolean.valueOf(tNcoReq.emailOptIn) == true){
            con.EmailOptInStatus__c = SYSTEM.LABEL.Y;
            if (String.isNotBlank(con.EmailOptInStatus__c)){
                con.EmailOptInDate__c = system.now();
                con.EmailOptOutDate__c = Null;
                con.HasOptedOutOfEmail = false;
                con.Do_Not_Sync_with_SFMC__c = false;
            }
        }
        if (String.isNotBlank(tNcoReq.emailOptIn) && Boolean.valueOf(tNcoReq.emailOptIn) == false){
            con.EmailOptInStatus__c = SYSTEM.LABEL.N;
            if (String.isNotBlank(con.EmailOptInStatus__c)){
                con.EmailOptInDate__c = Null;
                con.EmailOptOutDate__c = system.now();
                con.HasOptedOutOfEmail = true;
            }
        }
        Logger.logDebug();
        return con;
    }

    //Update existing Contact details
    Static Contact updateContact(Contact cont, TnCoRequest tNcoR){

        cont.Status__c = SYSTEM.LABEL.Active;
        cont.createdByMethod__c = SYSTEM.LABEL.API;
        String searchBrand = tNcoR.brandId;
        Log.push('***updateContact - searchBrand = ' + searchBrand);

        If (String.isNotBlank(tNcoR.firstName) && (!tNcoR.firstName.equals(cont.FirstName)))
            cont.FirstName = tNcoR.firstName;
        If (String.isNotBlank(tNcoR.lastName) && (!tNcoR.lastName.equals(cont.LastName)))
            cont.LastName = tNcoR.lastName;
        If (String.isNotBlank(tNcoR.country) && (!tNcoR.country.equals(cont.MailingCountry)))
            cont.MailingCountry = tNcoR.country;
        If (String.isNotBlank(tNcoR.emailAddress) && (!tNcoR.emailAddress.equals(cont.Email)))
            cont.Email = tNcoR.emailAddress;
        If (String.isNotBlank(tNcoR.WelcomeSource) && (!tNcoR.WelcomeSource.equals(cont.WelcomeSource__c)))
            cont.WelcomeSource__c = tNcoR.WelcomeSource;
        if (String.isNotBlank(tNcoR.sourceSystem)){
            cont.Source_System__c = tNcoR.sourceSystem;
            cont.Latest_Source__c = tNcoR.sourceSystem;
        } else{
            cont.Source_System__c = SYSTEM.LABEL.TC;
            cont.Latest_Source__c = SYSTEM.LABEL.TC;
        }


        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                           FROM SubscriberDataSources__mdt
                                                           WHERE Brand__c = :searchBrand AND SourceSystem__c = :tNcoR.SourceSystem AND WelcomeSource__c = :tNcoR.WelcomeSource];

        if (listDataSource.size() > 0){
            cont.Source__c = listDataSource[0].DataSource__c;
        }

        if (String.isNotBlank(tNcoR.emailOptIn) && Boolean.valueOf(tNcoR.emailOptIn) == true){
            Log.push('*** tNcoR.emailOptIn = ' + tNcoR.emailOptIn);
            if (cont.EmailOptInStatus__c == SYSTEM.LABEL.Y){
                Log.push('*** cont.EmailOptInStatus__c = ' + cont.EmailOptInStatus__c);
                cont.EmailOptInStatus__c = SYSTEM.LABEL.Y;
                //cont.EmailOptInDate__c=system.now();
                cont.HasOptedOutOfEmail = false;
                cont.Do_Not_Sync_with_SFMC__c = false;
            } else if (cont.EmailOptInStatus__c == SYSTEM.LABEL.N || cont.EmailOptInStatus__c == NUll){
                Log.push('*** tNcoR.emailOptIn = ' + tNcoR.emailOptIn);
                cont.EmailOptInStatus__c = SYSTEM.LABEL.Y;
                cont.Do_Not_Sync_with_SFMC__c = false;
                cont.EmailOptInDate__c = system.now();
                cont.HasOptedOutOfEmail = false;

            }
        } else if (String.isNotBlank(tNcoR.emailOptIn) && Boolean.valueOf(tNcoR.emailOptIn) == false){
            if (cont.EmailOptInStatus__c == SYSTEM.LABEL.N){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.N;
                // cont.EmailOptOutDate__c=system.now();
                cont.HasOptedOutOfEmail = true;
            } else if (cont.EmailOptInStatus__c == SYSTEM.LABEL.Y || cont.EmailOptInStatus__c == NUll){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.N;
                cont.EmailOptOutDate__c = system.now();
                cont.HasOptedOutOfEmail = true;
                //cont.Do_Not_Sync_with_SFMC__c=false;
            }
        }
        Logger.logDebug();
        return cont;
    }

    Static TnCoResponse returnResponse(Boolean existingCont, List<Id> allContactID, String brandId, Map<Id, Contact> oldContacts){
        Contact contact;
        TnCoResponse tNcoRes = new TnCoResponse();

        Log.push('***allContactID = ' + allContactID);
        Log.push('***Brand_Id__c = ' + brandId);
        if (allContactID != null && allContactID.size() > 0){
            contact = [SELECT Id, LoyaltyId__c, EmailOptInStatus__c, LoyaltyFlag__c, createdByMethod__c, Do_Not_Sync_with_SFMC__c, EmailOptInDate__c
                       FROM Contact
                       WHERE Id IN:allContactID AND Brand_Id__c = :brandId];

            if (existingCont){
                if (oldContacts.containsKey(contact.Id) && oldContacts.get(contact.Id).EmailOptInStatus__c == SYSTEM.LABEL.Y){
                    tNcoRes.NewsLetterAlreadySignedUp = system.label.true;
                    oldContacts.get(contact.Id).Do_Not_Sync_with_SFMC__c = false;
                } else if (oldContacts.containsKey(contact.Id) && oldContacts.get(contact.Id).EmailOptInStatus__c == SYSTEM.LABEL.N && oldContacts.get(contact.Id).createdByMethod__c != SYSTEM.LABEL.API){
                    tNcoRes.NewsLetterAlreadySignedUp = SYSTEM.LABEL.flase;
                    oldContacts.get(contact.Id).EmailOptInStatus__c = SYSTEM.LABEL.Y;
                    oldContacts.get(contact.Id).EmailOptInDate__c = system.now();
                    oldContacts.get(contact.Id).Do_Not_Sync_with_SFMC__c = false;
                }
            } else{
                tNcoRes.NewsLetterAlreadySignedUp = system.label.false;
                if (oldContacts.containsKey(contact.Id)){
                    oldContacts.get(contact.Id).Do_Not_Sync_with_SFMC__c = false;
                }
            }

            tNcoRes.ContactId = contact.Id;

        }

        tNcoRes.code = SYSTEM.LABEL.OK;
        tNcoRes.ExistingCustomer = String.valueOf(existingCont);
        tNcoRes.message = SYSTEM.LABEL.Success;
        Logger.logDebug();
        return tNcoRes;
    }

}