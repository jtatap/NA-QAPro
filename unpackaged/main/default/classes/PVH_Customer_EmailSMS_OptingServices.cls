@RestResource(urlMapping='/subscriptions/customeroptinss')
global class PVH_Customer_EmailSMS_OptingServices {
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    
    @HttpPost
    global static SFCCResponse doSignup(){
        List<Contact> profileUpdateContacts = new List<Contact>();
        Map<Id, Contact> oldContacts = new Map<Id, Contact>();
        List<Contact> newBrandContacts = new List<Contact>();
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();
        List<ID> allContactID = new List<ID>();
        List<Contact> allContactList = new List<Contact>();        
        Boolean existingCont = false;
        Contact contact = new Contact();
        List<Contact> contacts = new List<Contact>();        
        String FileName = 'SFCCSubscription';
        Contact foundContact = new Contact();//SMS
        Contact foundSMSContact = new Contact();//SMS
        Contact brandAndEmailContact = new Contact();//SMS
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        SFCCRequest sfccReq = (SFCCRequest)json.deserialize(requestData, SFCCRequest.class);
        SFCCResponse sfccResponse = new SFCCResponse();  
        System.debug('### sfccReq:'+sfccReq);
        List<string> lstEmailOrgSource=new List<string>{'WE_OVERLAY','WE_CHECKOUT','WE_FOOTER'};
            if(!String.isBlank(sfccReq.SMSNumber)){
                if(String.isBlank(sfccReq.Subscriberkey)){
                    res.StatusCode = 200;
                    sfccResponse.code = 'MISSING_PARAMETERS';
                    sfccResponse.message = 'Missing: ContactId';
                    sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                    sfccResponse.PreviousOptinStatus='P'; 
                    sfccResponse.ExistingCustomer='No';
                    return sfccResponse;
                }
                else{
                    foundContact = searchContact(sfccReq.Subscriberkey);//Subscriberkey=ContactID
                    foundSMSContact = searchSMSContact(sfccReq.SMSNumber);
                    
                    if(foundContact != null){
                        brandAndEmailContact =  SFMCUtility.searchEmailBrandContact(foundContact.Brand_Id__c,sfccReq.Email);
                    }
                    if(foundContact == null){
                        System.debug('***Error: Contact Not Found');
                        res.statusCode = 200;
                        sfccResponse.code = 'INVALID_CONTACTID';
                        sfccResponse.message = 'No matching contact found';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.PreviousOptinStatus='P'; 
                        sfccResponse.ExistingCustomer='No';
                        return sfccResponse;
                        
                    }
                    else if(brandAndEmailContact != null && (foundContact.Email != sfccReq.Email) && (foundContact.Id != brandAndEmailContact.Id)){
                        System.debug('***Error: Another Contact Exists with Email');            
                        res.statusCode = 200;
                        sfccResponse.code = 'INVALID_EMAIL';
                        sfccResponse.message = 'Supplied Email address used by another contact';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.ExistingCustomer='Yes';
                        return sfccResponse;
                    }
                    else if(foundSMSContact != null && (foundContact.Id != foundSMSContact.Id)){
                        System.debug('***Error: Another Contact Exists with SMSNumber');            
                        res.statusCode = 200;
                        sfccResponse.code = 'INVALID_SMSNUMBER';
                        sfccResponse.message = 'SMS Number used by another contact';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.ExistingCustomer='Yes';
                        return sfccResponse;
                        
                    }
                    else if(foundContact != null && sfccReq.SMSNumber == null){
                        
                        System.debug(foundContact);
                        Contact updatedConWithOutSMS= updateContacWithOutSMSNumber(foundContact,sfccReq);
                        System.debug(updatedConWithOutSMS);
                        Account updatedAcc = updateAccount(foundContact,sfccReq);
                        Savepoint sp;
                        try {
                            sp = Database.setSavepoint();
                            update updatedConWithOutSMS;
                            System.debug('***Contact Record Updated without SMS Number');  
                            update updatedAcc;
                            System.debug('***Account Record Updated'); 
                        }
                        catch (Exception e) {
                            System.debug('An exception occurred while updating Contact' + e.getMessage());
                            res.statusCode = 500;
                            sfccResponse.code = 'OTHER_ERROR';
                            sfccResponse.message = e.getMessage();
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            Database.RollBack(sp);
                            return sfccResponse;
                        }
                        
                        res.statusCode = 200;
                        sfccResponse.code = 'OK';
                        sfccResponse.contactId = updatedConWithOutSMS.Id;
                        
                    }
                    else {
                        System.debug(foundContact);
                        Contact updatedCon = updateContactOne(foundContact,sfccReq);
                        System.debug(updatedCon);
                        Account updatedAcc = updateAccount(foundContact,sfccReq);
                        Savepoint sp;
                        try {
                            sp = Database.setSavepoint();
                            update updatedCon;
                            System.debug('***Contact Record Updated');  
                            update updatedAcc;
                            System.debug('***Account Record Updated'); 
                        }
                        catch (Exception e) {
                            System.debug('An exception occurred while updating Contact' + e.getMessage());
                            res.statusCode = 500;
                            sfccResponse.code = 'OTHER_ERROR';
                            sfccResponse.message = e.getMessage();
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            Database.RollBack(sp);
                            return sfccResponse;
                        }
                        
                        res.statusCode = 200;
                        sfccResponse.code = 'OK';
                        sfccResponse.contactId = updatedCon.Id;
                        sfccResponse.message='Success';
                        
                    } 
                }
            }else{
                
                if( String.isBlank(sfccReq.EmailOrgSource) || String.isEmpty(sfccReq.EmailOrgSource) || String.isBlank(sfccReq.EmailOrgSource) || !lstEmailOrgSource.contains(sfccReq.EmailOrgSource)){
                    res.statusCode = 200;
                    sfccResponse.code = 'INVALID_QUERY';
                    sfccResponse.message = 'Request rejected. Unsupported value "head-n-tail" was passed for parameter'+sfccReq.EmailOrgSource;
                    return sfccResponse;
                }
                // Brand id or email not present in request, return error message
                if(String.isEmpty(sfccReq.brandId) || String.isEmpty(sfccReq.emailAddress) || String.isBlank(sfccReq.brandId) ||  String.isBlank(sfccReq.emailAddress)  ||  String.isBlank(sfccReq.region)  ||  String.isBlank(sfccReq.country) ||  String.isBlank(sfccReq.market)) {
                    res.statusCode = 200;
                    sfccResponse.code = 'INVALID_QUERY';
                    sfccResponse.message = 'Missing required parameters:  BrandId or email or Region or Market or Country';
                    System.debug('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
                    return sfccResponse;            
                }
                else { //Brand id and email present in request           
                    //Check for existing contact
                    contacts = searchContacts(sfccReq.brandId,sfccReq.emailAddress,emailRecordTypeId);
                    System.debug('### contacts' + contacts);
                    if(contacts != NULL && contacts.size()>0) {
                        contact = contacts[0];
                    }
                    if(contacts.size()<1){
                        
                        newBrandContacts.add(createContact(sfccReq));
                        
                    }
                    else { 
                        existingCont = true;
                        oldContacts.put(contact.Id, contact.clone());
                        profileUpdateContacts.add(updateContact(contact,sfccReq));
                    }
                    if(profileUpdateContacts.size()>0) {
                        Database.SaveResult[] srList = Database.update(profileUpdateContacts, false);
                        ContactUtility.createErrorLogRecords(srList,profileUpdateContacts[0].Latest_Source__c,FileName);
                        for(Contact con : profileUpdateContacts){
                            if(con.id!=null) allContactList.add(con);
                        }
                    }
                    if(newBrandContacts.size()>0){
                        Database.SaveResult[] srList = Database.insert(newBrandContacts, false);
                        System.debug('srList '+srList);
                        ContactUtility.createErrorLogRecords(srList,newBrandContacts[0].Latest_Source__c,FileName);
                        for(Contact con : newBrandContacts){
                            if(con.id!=null) allContactList.add(con);
                        }
                    }
                    for(Contact con: allContactList){
                        allContactID.add(con.Id);
                        
                    }
                }
                if(allContactList.size()>0){
                    upsert allContactList;
                }
                
                res.statusCode = 200;        
                sfccResponse = returnResponse(existingCont, allContactID, sfccReq.brandId, oldContacts);
                System.debug('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
            }  
        
        return sfccResponse;
    } 
    global Static void setContactEmailOptin(Contact cont,string requestType){
        if (requestType=='Subscribe'){
            cont.EmailOptInStatus__c = 'Y'; // true;
            cont.EmailOptInDate__c = System.now();
            cont.LoyaltyFlag__c=false;
        } else if(requestType=='UnSubscribe'){
            cont.HasOptedOutOfEmail = true;
            cont.EmailOptOutDate__c = System.now();
        }
    }
    global Static void setEmailOrgSource(Contact cont,string reqEmailOrgSource, String country){
        if (reqEmailOrgSource=='WE_OVERLAY'){
            cont.WelcomeSource__c = '01'; // true;
        }else if(reqEmailOrgSource=='WE_CHECKOUT' && country != 'CA'){
            cont.WelcomeSource__c = '02';
        }else if(reqEmailOrgSource=='WE_FOOTER'){
            cont.WelcomeSource__c = '04';
        }else if(reqEmailOrgSource=='WE_CHECKOUT' && country == 'CA'){
            cont.WelcomeSource__c = '24';
        }
    }
    //Search Contact record
    Static List<Contact> searchContacts(String brandId, String emails,Id emailRecordTypeId){
        List<Contact> searchedContactList =  [SELECT Id, FirstName,Email,LastName, Brand_Id__c,EmailOptInStatus__c,
                                              EmailOptOutDate__c,EmailOptInDate__c, SMSOptinStatus__c, LoyaltyFlag__c,
                                              Source_System__c,WelcomeSource__c,MarketingSource__c
                                              FROM Contact 
                                              WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c =:brandId AND Email = :emails AND Bulk_Buyer__c=false LIMIT 1];// AND Primary__c = true order by Ecomm_Connected__c DESC, LastmodifiedDate DESC limit 1 ];
        return ((searchedContactList!=null)?searchedContactList:Null);
    }
    //Create New Contact record
    Static Contact createContact(SFCCRequest sfccReq){
        Contact con = new Contact();
        con.RecordTypeId = emailRecordTypeId;
        //con.Primary__c = true; // Since we are creating a new Contact record, set it as Primary.
        if(String.isNotBlank(sfccReq.sourceSystem)) {
            con.Source_System__c = sfccReq.sourceSystem;
            con.Latest_Source__c = sfccReq.sourceSystem;
        }
        con.createdByMethod__c = 'API';
        con.Status__c = 'ACTIVE'; 
        con.Brand_Id__c = sfccReq.brandId;
        if(String.isNotBlank(sfccReq.firstName)) con.FirstName = sfccReq.firstName;
        else if(String.isBlank(sfccReq.firstName) || String.valueOf(sfccReq.firstName) == '') con.firstName = 'Unknown';
        if(String.isNotBlank(sfccReq.lastName)){ con.LastName = sfccReq.lastName; }
        else if(String.isBlank(sfccReq.lastName) || String.valueOf(sfccReq.lastName) == '') con.LastName = 'Unknown';
        if(String.isNotBlank(sfccReq.emailAddress)) con.Email = sfccReq.emailAddress;
        If(String.isNotBlank(sfccReq.region)) con.Region_ds__c  = sfccReq.region;
        If(String.isNotBlank(sfccReq.market)) con.Market_ds__c  = sfccReq.market;
        If(String.isNotBlank(sfccReq.country)) con.Country_ds__c  = sfccReq.country;
        if(String.isNotBlank(sfccReq.requestType) && sfccReq.requestType == 'Subscribe'){            
            setContactEmailOptin(con,sfccReq.requestType);
        }
        if(String.isNotBlank(sfccReq.requestType) && sfccReq.requestType== 'UnSubscribe'){            
            setContactEmailOptin(con,sfccReq.requestType);
        }
        
        if(String.isNotBlank(sfccReq.EmailOrgSource) ){            
            setEmailOrgSource(con,sfccReq.EmailOrgSource,sfccReq.country );
        }
        return con;
    }    
    //Update existing Contact details
    Static Contact updateContact(Contact cont, SFCCRequest sfccR){
        cont.Status__c = 'ACTIVE';
        If(String.isNotBlank(sfccR.firstName) && (!sfccR.firstName.equals(cont.FirstName))) cont.FirstName = sfccR.firstName;
        If(String.isNotBlank(sfccR.lastName) && (!sfccR.lastName.equals(cont.LastName))) cont.LastName = sfccR.lastName;
        If(String.isNotBlank(sfccR.emailAddress) && (!sfccR.emailAddress.equals(cont.Email))) cont.Email = sfccR.emailAddress;
        If(String.isNotBlank(sfccR.sourceSystem)) cont.Latest_Source__c  = sfccR.sourceSystem;
        If(String.isNotBlank(sfccR.region)) cont.Region_ds__c  = sfccR.region;
        If(String.isNotBlank(sfccR.market)) cont.Market_ds__c  = sfccR.market;
        If(String.isNotBlank(sfccR.country)) cont.Country_ds__c  = sfccR.country;
        if(String.isNotBlank(sfccR.requestType) && sfccR.requestType == 'Subscribe'){            
            setContactEmailOptin(cont,sfccR.requestType);
        }
        
        if(String.isNotBlank(sfccR.EmailOrgSource) ){            
            setEmailOrgSource(cont,sfccR.EmailOrgSource, sfccR.country);
        }
        return cont;
    }     
    Static SFCCResponse returnResponse(Boolean existingCont, List<Id> allContactID, String brandId, Map<Id, Contact> oldContacts){
        Contact contact;        
        SFCCResponse sfccRes = new SFCCResponse();        
        System.debug('***allContactID = '+allContactID);
        System.debug('***Brand_Id__c = '+brandId);
        if(allContactID != null && allContactID.size()>0){
            contact = [SELECT Id, LoyaltyId__c,EmailOptInStatus__c,LoyaltyFlag__c FROM Contact WHERE Id IN :allContactID AND Brand_Id__c = :brandId  ];
            if(existingCont){
                if(oldContacts.containsKey(contact.Id) && oldContacts.get(contact.Id).EmailOptInStatus__c == 'Y'){
                    sfccRes.NewsLetterAlreadySignedUp = 'true';
                } else{
                    sfccRes.NewsLetterAlreadySignedUp = 'false';
                }
            } else {
                sfccRes.NewsLetterAlreadySignedUp = 'false';
            }
            sfccRes.Subscriberkey = contact.Id;
            sfccRes.LoyaltyId = contact.LoyaltyId__c;               
        } 
        sfccRes.code = 'OK'; 
        sfccRes.message = 'Success'; 
        sfccRes.PreviousOptinStatus = String.valueOf(existingCont);
        return sfccRes;
    }
    
    /*****************/
    public static Contact searchContact(Id contactId){
        List<Contact> conList = [SELECT Id,FirstName,LastName,MailingStreet,MailingCity,MailingState,Brand_Id__c,Email,
                                 MailingCountry, MailingPostalCode, BirthDate, Phone, SMSNumber__c,SMSOptinStatus__c, SMSOptInDate__c,
                                 PrefCenterInterests__c, HomeStore__c,isEmployee__c,AccountId,SMSLocale__c,CountryOfCapture__c,SelfClaimedGender__c,
                                 Latest_Source__c,Source_System__c  
                                 FROM Contact WHERE Id =: contactId];
        if(!conList.isEmpty()){
            return conList[0];
        }else{
            return null;
        }
        
        
    }
    
    public static Contact searchSMSContact(String inputSMSNumber){
        List<Contact> conList = [SELECT Id,FirstName,LastName,MailingStreet,MailingCity,MailingState,
                                 MailingCountry, MailingPostalCode, BirthDate, Phone, SMSNumber__c,SMSOptinStatus__c, SMSOptInDate__c,
                                 PrefCenterInterests__c, HomeStore__c,isEmployee__c,SMSLocale__c,CountryOfCapture__c,SelfClaimedGender__c,
                                 Latest_Source__c,Source_System__c 
                                 FROM Contact 
                                 WHERE SMSNumber__c != null AND SMSNumber__c =: inputSMSNumber];
        
        if(!conList.isEmpty()){
            return conList[0];
        }else{
            return null;
        }
        
    }
    
    public static Contact updateContactOne(Contact con, SFCCRequest pcReq){
        System.debug('***inside updateContact');
        
        if(String.isNotBlank(pcReq.Name.FirstName) && (con.FirstName != pcReq.Name.FirstName)) con.FirstName = pcReq.Name.FirstName;
        if(String.isNotBlank(pcReq.Name.LastName) && (con.LastName != pcReq.Name.LastName)) con.LastName = pcReq.Name.LastName;
        if(String.isNotBlank(pcReq.Email) && (con.Email != pcReq.Email)) con.Email = pcReq.Email;
        if(String.isNotBlank(pcReq.MailingAddress.Street) && (con.MailingStreet != pcReq.MailingAddress.Street)) con.MailingStreet = pcReq.MailingAddress.Street;
        if(String.isNotBlank(pcReq.MailingAddress.City) && (con.MailingCity != pcReq.MailingAddress.City)) con.MailingCity = pcReq.MailingAddress.City;
        if(String.isNotBlank(pcReq.MailingAddress.State) && (con.MailingState != pcReq.MailingAddress.State)) con.MailingState = pcReq.MailingAddress.State;
        if(String.isNotBlank(pcReq.MailingAddress.Country) && (con.MailingCountry != pcReq.MailingAddress.Country)) con.MailingCountry = pcReq.MailingAddress.Country;
        if(String.isNotBlank(pcReq.MailingAddress.PostalCode) && (con.MailingPostalCode != pcReq.MailingAddress.PostalCode)) con.MailingPostalCode = pcReq.MailingAddress.PostalCode;
        if(String.isNotBlank(pcReq.BirthDate) && (con.Birthdate != Date.valueOf(pcReq.BirthDate))) con.Birthdate = Date.valueOf(pcReq.BirthDate);
        if(String.isNotBlank(pcReq.Phone) && (con.Phone != pcReq.Phone)) con.Phone = pcReq.Phone;
        //if(String.isNotBlank(pcReq.PrefCenterInterests) && (con.PrefCenterInterests__c != pcReq.PrefCenterInterests)) con.PrefCenterInterests__c = pcReq.PrefCenterInterests;
        if(String.isNotBlank(pcReq.SourceSystem) && (con.Latest_Source__c != pcReq.SourceSystem))
        {
            con.Latest_Source__c = pcReq.SourceSystem;
        }
        
        if(String.isNotBlank(pcReq.isEmployee) && Boolean.valueOf(pcReq.isEmployee) == true && (!pcReq.isEmployee.equals(con.isEmployee__c)))
            con.isEmployee__c = true;
        else if(String.isNotBlank(pcReq.isEmployee) && Boolean.valueOf(pcReq.isEmployee) == false && (!pcReq.isEmployee.equals(con.isEmployee__c)))
            con.isEmployee__c = false;
        
        if(String.isNotBlank(pcReq.SMS.SMSNumber) && pcReq.SMS.SMSOptinStatus == 'P' && String.isBlank(con.SMSNumber__c)){
            //brand new sms optin
            System.debug('***First Time Optin');
            con.SMSNumber__c = pcReq.SMS.SMSNumber;
            con.SMSOptinStatus__c = 'P';
            con.SMSOptInDate__c = System.now();
        }
        else if((pcReq.SMS.SMSOptinStatus == 'N') && (con.SMSOptinStatus__c == null || con.SMSOptinStatus__c == 'Y' || con.SMSOptinStatus__c == 'P')){
            // sms optout
            System.debug('***Optout');
            con.SMSOptinStatus__c = 'N';
            con.SMSOptOutDate__c = System.now();
            con.SMS_Unsubscribe_Reason__c='eComm Opt-out';
        }
        else if(String.isNotBlank(pcReq.SMS.SMSNumber) && pcReq.SMS.SMSOptinStatus == 'P' && String.isNotBlank(con.SMSNumber__c) && con.SMSNumber__c == pcReq.SMS.SMSNumber){
            //sms reoptin with same number
            System.debug('***Re-Optin with same number');
            con.SMSOptinStatus__c = 'P';
            con.SMSOptInDate__c = System.now();
        }
        else if(String.isNotBlank(pcReq.SMS.SMSNumber) && pcReq.SMS.SMSOptinStatus == 'P' && String.isNotBlank(con.SMSNumber__c) && con.SMSNumber__c != pcReq.SMS.SMSNumber){
            //sms optin with a different number
            System.debug('***Re-Optin with different number');
            con.SMSNumber__c = pcReq.SMS.SMSNumber;
            con.SMSOptinStatus__c = 'P';
            con.SMSOptInDate__c = System.now();
        }
        //End: Setting SMS Related Field
        
        if(String.isNotBlank(pcReq.SMS.Locale) && (con.SMSLocale__c != pcReq.SMS.Locale)) con.SMSLocale__c = pcReq.SMS.Locale;
        if(String.isNotBlank(pcReq.PrefCenterInterests) && (con.PrefCenterInterests__c != pcReq.PrefCenterInterests)) con.PrefCenterInterests__c = pcReq.PrefCenterInterests;
        if(String.isNotBlank(pcReq.HomeStore) && (con.HomeStore__c != pcReq.HomeStore)) con.HomeStore__c = pcReq.HomeStore;
        if(String.isNotBlank(pcReq.Gender) && (con.SelfClaimedGender__c != pcReq.Gender)) con.SelfClaimedGender__c = pcReq.Gender;
        
        if(String.isBlank(con.CountryOfCapture__c) && String.isNotBlank(pcReq.SMS.Locale)){
            if(pcReq.SMS.Locale.length() == 5) con.CountryOfCapture__c = pcReq.SMS.Locale.right(2).toUpperCase();
        }
        System.debug(con);
        return con;
    }
    /* NACDT-3788 AND BELT-1614 */
    public static Contact updateContacWithOutSMSNumber(Contact con, SFCCRequest pcReq){
        system.debug('***inside updateContactWithOutSMSNumber');
        if(String.isNotBlank(pcReq.Name.FirstName) && (con.FirstName != pcReq.Name.FirstName)) con.FirstName = pcReq.Name.FirstName;
        if(String.isNotBlank(pcReq.Name.LastName) && (con.LastName != pcReq.Name.LastName)) con.LastName = pcReq.Name.LastName;
        if(String.isNotBlank(pcReq.Email) && (con.Email != pcReq.Email)) con.Email = pcReq.Email;
        if(String.isNotBlank(pcReq.MailingAddress.Street) && (con.MailingStreet != pcReq.MailingAddress.Street)) con.MailingStreet = pcReq.MailingAddress.Street;
        if(String.isNotBlank(pcReq.MailingAddress.City) && (con.MailingCity != pcReq.MailingAddress.City)) con.MailingCity = pcReq.MailingAddress.City;
        if(String.isNotBlank(pcReq.MailingAddress.State) && (con.MailingState != pcReq.MailingAddress.State)) con.MailingState = pcReq.MailingAddress.State;
        if(String.isNotBlank(pcReq.MailingAddress.Country) && (con.MailingCountry != pcReq.MailingAddress.Country)) con.MailingCountry = pcReq.MailingAddress.Country;
        if(String.isNotBlank(pcReq.MailingAddress.PostalCode) && (con.MailingPostalCode != pcReq.MailingAddress.PostalCode)) con.MailingPostalCode = pcReq.MailingAddress.PostalCode;
        if(String.isNotBlank(pcReq.BirthDate) && (con.Birthdate != Date.valueOf(pcReq.BirthDate))) con.Birthdate = Date.valueOf(pcReq.BirthDate);
        if(String.isNotBlank(pcReq.Phone) && (con.Phone != pcReq.Phone)) con.Phone = pcReq.Phone; 
        //if(String.isNotBlank(pcReq.PrefCenterInterests) && (con.PrefCenterInterests__c != pcReq.PrefCenterInterests)) con.PrefCenterInterests__c = pcReq.PrefCenterInterests;
        if(String.isNotBlank(pcReq.SourceSystem) && (con.Latest_Source__c != pcReq.SourceSystem)) con.Latest_Source__c = pcReq.SourceSystem;
        
        
        if(String.isNotBlank(pcReq.isEmployee) && Boolean.valueOf(pcReq.isEmployee) == true)
            con.isEmployee__c = true;
        else if(String.isNotBlank(pcReq.isEmployee) && Boolean.valueOf(pcReq.isEmployee) == false)
            con.isEmployee__c = false;
        
        if((pcReq.SMS.SMSOptinStatus == 'N') && (con.SMSOptinStatus__c == null || con.SMSOptinStatus__c == 'Y' || con.SMSOptinStatus__c == 'P')){
            // sms optout
            System.debug('***Optout');
            con.SMSOptinStatus__c = 'N';
            con.SMSOptOutDate__c = System.now();
            con.SMS_Unsubscribe_Reason__c='eComm Opt-out';
        }
        /* NACDT-3828 */
        //End: Setting SMS Related Field
        if(String.isNotBlank(pcReq.SMS.Locale) && (con.SMSLocale__c != pcReq.SMS.Locale)) con.SMSLocale__c = pcReq.SMS.Locale;
        if(String.isNotBlank(pcReq.PrefCenterInterests) && (con.PrefCenterInterests__c != pcReq.PrefCenterInterests)) con.PrefCenterInterests__c = pcReq.PrefCenterInterests;
        if(String.isNotBlank(pcReq.HomeStore) && (con.HomeStore__c != pcReq.HomeStore)) con.HomeStore__c = pcReq.HomeStore;
        if(String.isNotBlank(pcReq.Gender) && (con.SelfClaimedGender__c != pcReq.Gender)) con.SelfClaimedGender__c = pcReq.Gender;
        
        if(String.isBlank(con.CountryOfCapture__c) && String.isNotBlank(pcReq.SMS.Locale)){
            if(pcReq.SMS.Locale.length() == 5) con.CountryOfCapture__c = pcReq.SMS.Locale.right(2).toUpperCase();
        }
        System.debug(con);
        return con;
    }
    
    public static Account updateAccount(Contact con, SFCCRequest pcReq){
        System.debug('***inside updateAccount');
        List<Account> listAccount = [Select Id,Gender__c,Name from Account where Id=: con.AccountId];
        if (!listAccount.isEmpty()){
            if(String.isNotBlank(pcReq.Gender) && (listAccount[0].Gender__c != pcReq.Gender)) listAccount[0].Gender__c = pcReq.Gender;
            if((String.isNotBlank(pcReq.Name.FirstName) && pcReq.Name.FirstName!='Unknown') && (String.isNotBlank(pcReq.Name.LastName) && pcReq.Name.LastName!='Unknown' )){
                listAccount[0].Name=pcReq.Name.FirstName+pcReq.Name.LastName;
            }
        }
        
        return listAccount[0];
    }
    /******************/
    global class SFCCRequest{
        public String brandId;
        public String firstName; 
        public String lastName;
        public String emailAddress;
        public String requestType;
        public String SourceSystem;
        public String Subscriberkey;
        public String EmailOrgSource;
        public String region;
        public String market;
        public String country;
        public String SMSNumber;
        public String SMSOptinStatus;
        public ID ContactId;
        public String Locale;
        public Name Name;
        public String Email;
        public MailingAddress MailingAddress;
        public String BirthDate;
        public String Phone;
        public SMS SMS;
        public String PrefCenterInterests;
        public String HomeStore;
        public String Gender;
        public String isEmployee;
    }
    global class SFCCResponse{
        public String code;
        public String message;
        public String Subscriberkey;
        public String LoyaltyId;
        public String PreviousOptinStatus;
        public String NewsLetterAlreadySignedUp;
        public String LoyaltyAlreadySignedUp;
        public String ExistingCustomer;
        public ID contactId;
    }
    global class Name {
        public String FirstName;
        public String LastName;
    }
    global class SMS {
        public String SMSNumber ;
        public String SMSOptinStatus;
        
        public String Locale; 
    }
    global class MailingAddress {
        public String Street;
        public String City;
        public String State;
        public String Country;
        public String PostalCode;
    }
    
    
    
}