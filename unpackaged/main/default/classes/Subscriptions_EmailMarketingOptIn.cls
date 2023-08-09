/*Json Request
 {"brandId":"2","firstName":"Christina","lastName":"Doe","emailAddress":"Christina@pvh.com","emailOptIn":"true","SourceSystem":"SFCC","WelcomeSource":"01"}
 https://instance.salesforce.com/services/apexrest/SFCCSubscription/MarketingOptIn
 * Jira#
 */
//Brand specific CK
@RestResource(urlMapping = '/Subscriptions/EmailMarketingOptIn')
global class Subscriptions_EmailMarketingOptIn{
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    static Map<String, String> mapSubbrandParentbrand = new Map<String, String>();
    static boolean isTealiumApi = false; 
    global class SFCCRequest{
        public String brandId;
        public String firstName;
        public String lastName;
        public String emailAddress;
        public String requestType;//requestType
        public String SourceSystem;
        public String EmailOrgSource;//EmailOrgSource
        public String gender;
        public String DOB;
        //public String MarketingSource;
        public String region;//required
        public String market;//required
        public String country;//required
        // public String requestType;//required
        public String loyaltyflag;
        public String campaignName;
        public String apiCallType;
       
       
        
    }

    global class SFCCResponse{
        public String code;
        public String message;
        public String Subscriberkey;//Subscriberkey
        public String LoyaltyId;
        public String PreviousOptinStatus;//PreviousOptinStatus --Yes/No
        public String NewsLetterAlreadySignedUp;
        public String LoyaltyAlreadySignedUp;
    }

    @HttpPost
    global static SFCCResponse doSignup(){
        List<Contact> profileUpdateContacts = new List<Contact>();
        Map<Id, Contact> oldContacts = new Map<Id, Contact>();
        List<Contact> newBrandContacts = new List<Contact>();
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();
        List<ID> allContactID = new List<ID>();
        List<Contact> allContactList = new List<Contact>();
        Boolean existingCont = false;
        string DOB;
        Contact contact = new Contact();
        List<Contact> contacts = new List<Contact>();
        String FileName = SYSTEM.LABEL.SFCCSubscription;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        SFCCRequest sfccReq = (SFCCRequest)json.deserialize(requestData, SFCCRequest.class);
        SFCCResponse sfccResponse = new SFCCResponse();
        
        Log.push('### sfccReq:' + sfccReq);
        System.debug('### sfccReq:' + sfccReq);
        List<string> lstEmailOrgSource = new List<string>{ 'WE_OVERLAY', SYSTEM.LABEL.WE_CHECKOUT, 'WE_FOOTER', 'WE_MYACCOUNT' ,'WE_CAMPAIGN' };
        	
        if(sfccReq.apiCallType == 'Tealium')
        {
            isTealiumApi = true;
        }
            if ((String.isBlank(sfccReq.EmailOrgSource) || String.isEmpty(sfccReq.EmailOrgSource) || String.isBlank(sfccReq.EmailOrgSource) || !lstEmailOrgSource.contains(sfccReq.EmailOrgSource)) && !isTealiumApi){
            res.statusCode = 400;
            sfccResponse.code = SYSTEM.LABEL.INVALID_QUERY;
            sfccResponse.message = SYSTEM.LABEL.Request_rejected_Unsupported_value_head_n_tail_was_passed_for_parameter + sfccReq.EmailOrgSource;
            return sfccResponse;
        }
        // Brand id or email not present in request, return error message
        if ((String.isEmpty(sfccReq.brandId) || String.isEmpty(sfccReq.emailAddress) || String.isBlank(sfccReq.brandId) || String.isBlank(sfccReq.emailAddress) || String.isBlank(sfccReq.region) || String.isBlank(sfccReq.country) || String.isBlank(sfccReq.market)) && !isTealiumApi){
            res.statusCode = 400;
            sfccResponse.code = SYSTEM.LABEL.INVALID_QUERY;
            sfccResponse.message = SYSTEM.LABEL.Missing_required_parameters_BrandId_or_email_or_Region_or_Market_or_Country;
            Log.push('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
            return sfccResponse;
        } 
            
		if ((String.isEmpty(sfccReq.brandId) || String.isEmpty(sfccReq.emailAddress) || String.isBlank(sfccReq.brandId) || String.isBlank(sfccReq.emailAddress) || String.isEmpty(sfccReq.requestType) || String.isBlank(sfccReq.requestType) ) && isTealiumApi){
            res.statusCode = 400;
            sfccResponse.code = SYSTEM.LABEL.INVALID_QUERY;
            sfccResponse.message = SYSTEM.LABEL.Missing_required_parameters_BrandId_or_email_or_requestType;
            Log.push('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
            return sfccResponse;            
        }
        
        else{
             //Brand id and email present in request
            //Check for existing contact
            contacts = searchContacts(sfccReq.brandId, sfccReq.emailAddress, emailRecordTypeId);
            Log.push('### contacts' + contacts);
            
            if (contacts != NULL && contacts.size() > 0){
                contact = contacts[0];
            }
            if (contacts.size() < 1){

                newBrandContacts.add(createContact(sfccReq));

            } else{
                //Contact Record found
                // add to profileUpdateContacts
                existingCont = true;
                oldContacts.put(contact.Id, contact.clone());
                profileUpdateContacts.add(updateContact(contact, sfccReq));
            }
            if (profileUpdateContacts.size() > 0){
                Database.SaveResult[] srList = Database.update (profileUpdateContacts, false);
                ContactUtility.createErrorLogRecords(srList, profileUpdateContacts[0].Latest_Source__c, FileName);
                for (Contact con : profileUpdateContacts){
                    if (con.id != null)
                        allContactList.add(con);
                }
            }
            if (newBrandContacts.size() > 0){
                Database.SaveResult[] srList = Database.insert (newBrandContacts, false);
                ContactUtility.createErrorLogRecords(srList, newBrandContacts[0].Latest_Source__c, FileName);
                for (Contact con : newBrandContacts){
                    if (con.id != null)
                        allContactList.add(con);
                }
            }
            for (Contact con : allContactList){
                allContactID.add(con.Id);
                signUpActivityList.add(SignUpActivity.signupActivity(con.Id, con.Latest_Source__c, con.Brand_Id__c));
            }
        }
        if (allContactList.size() > 0){
            upsert allContactList;
        }
        res.statusCode = 200;
        sfccResponse = returnResponse(existingCont, allContactID, sfccReq.brandId, oldContacts);
        Log.push('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
        Logger.logDebug();
        return sfccResponse;
    }

    //Set contact email preferences
    Static void setContactEmailOptin(Contact cont, string requestType){
        if (requestType == SYSTEM.LABEL.Subscribe){
            if (cont.EmailOptInStatus__c == 'N' || cont.EmailOptInStatus__c == null){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.Y; // true;
                cont.EmailOptInDate__c = System.now();
            }
            
            //cont.LoyaltyFlag__c = false;
            //cont.HasOptedOutOfEmail = false;
            //cont.EmailOptOutDate__c = Null;
        } else if (requestType == SYSTEM.LABEL.UnSubscribe){
            //cont.EmailOptInStatus__c = 'N'; //false;
            //cont.EmailOptInDate__c = Null;
            cont.HasOptedOutOfEmail = true;
            cont.EmailOptOutDate__c = System.now();
        }
    }

    Static void setEmailOrgSource(Contact cont, string reqEmailOrgSource, String country){
        Log.push('reqEmailOrgSource :' + reqEmailOrgSource);
       System.debug('reqEmailOrgSource***:' + reqEmailOrgSource);
        Log.push('country :' + country);
        if (reqEmailOrgSource == SYSTEM.LABEL.WE_OVERLAY){
            cont.WelcomeSource__c = SYSTEM.LABEL.X01; // true;
        } else if (reqEmailOrgSource == SYSTEM.LABEL.WE_CHECKOUT && country == SYSTEM.LABEL.US){
            cont.WelcomeSource__c = SYSTEM.LABEL.X04;
        } else if (reqEmailOrgSource == SYSTEM.LABEL.WE_FOOTER){
            cont.WelcomeSource__c = SYSTEM.LABEL.X02;
        } else if (reqEmailOrgSource == SYSTEM.LABEL.WE_CHECKOUT && country == SYSTEM.LABEL.CA){
            cont.WelcomeSource__c = SYSTEM.LABEL.X24;
        } else if (reqEmailOrgSource == SYSTEM.LABEL.WE_MYACCOUNT){
            cont.WelcomeSource__c = SYSTEM.LABEL.X03;
        }else if (reqEmailOrgSource == SYSTEM.LABEL.WE_CAMPAIGN){
            cont.WelcomeSource__c = SYSTEM.LABEL.X07;
        }
        Logger.logDebug();
    }

    //Search Contact record
    Static List<Contact> searchContacts(String brandId, String emails, Id emailRecordTypeId){
        List<Contact> searchedContactList = [SELECT Id, FirstName,Birthdate,Latest_Source__c,SelfClaimedGender__c, Email,Region_ds__c,Market_ds__c,Country_ds__c,LastName,Latest_Campaigns__c,Campaign_Signup_Date__c, Brand_Id__c, EmailOptInStatus__c, EmailOptOutDate__c, EmailOptInDate__c, SMSOptinStatus__c, LoyaltyFlag__c, Source_System__c, WelcomeSource__c, MarketingSource__c,OptOutShare__c
                                             FROM Contact
                                             WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c = :brandId AND Email = :emails AND Bulk_Buyer__c = false
                                             order by Ecomm_Connected__c DESC, LastmodifiedDate DESC
                                             limit 1];
        return ((searchedContactList != null) ? searchedContactList : Null);
    }

    //Create New Contact record
    Static Contact createContact(SFCCRequest sfccReq){
        Contact con = new Contact();
        con.RecordTypeId = emailRecordTypeId;
        if (String.isNotBlank(sfccReq.sourceSystem)){
            con.Source_System__c = sfccReq.sourceSystem;
            con.Latest_Source__c = sfccReq.sourceSystem;
        }
        con.createdByMethod__c = SYSTEM.LABEL.API;
        con.Status__c = SYSTEM.LABEL.Active;
        con.Brand_Id__c = sfccReq.brandId;
        if(con.Brand_Id__c == '1') con.LoyaltyFlag__c = true;
        if (String.isNotBlank(sfccReq.firstName))
            con.FirstName = sfccReq.firstName;
        else if (String.isBlank(sfccReq.firstName) || String.valueOf(sfccReq.firstName) == '')
            con.firstName = SYSTEM.LABEL.Unknown;
        if (String.isNotBlank(sfccReq.lastName)){
            con.LastName = sfccReq.lastName;
        } else if (String.isBlank(sfccReq.lastName) || String.valueOf(sfccReq.lastName) == '')
            con.LastName = SYSTEM.LABEL.Unknown;
        if (String.isNotBlank(sfccReq.emailAddress))
            con.Email = sfccReq.emailAddress;
        //If(String.isNotBlank(sfccReq.EmailOrgSource)) con.WelcomeSource__c  = sfccReq.EmailOrgSource;
        If (String.isNotBlank(sfccReq.region))
            con.Region_ds__c = sfccReq.region;
        If (String.isNotBlank(sfccReq.market))
            con.Market_ds__c = sfccReq.market;
        If (String.isNotBlank(sfccReq.country))
            con.Country_ds__c = sfccReq.country;
        if (String.isNotBlank(sfccReq.requestType) && sfccReq.requestType == SYSTEM.LABEL.Subscribe){
            setContactEmailOptin(con, sfccReq.requestType);
        }
        if (String.isNotBlank(sfccReq.requestType) && sfccReq.requestType == SYSTEM.LABEL.UnSubscribe){
            setContactEmailOptin(con, sfccReq.requestType);
        }

        if (String.isNotBlank(sfccReq.EmailOrgSource)){
            setEmailOrgSource(con, sfccReq.EmailOrgSource, sfccReq.country);
        }
        
        //GCT-4552 - Ad Opt Out flag
       // if (String.isNotBlank(sfccReq.requestType) && sfccReq.requestType == SYSTEM.LABEL.Advertise_Out){
        //    con.OptOutShare__c = true;
       // }
        /** Project Blue GCT-4218**/
        if(sfccReq.EmailOrgSource==SYSTEM.LABEL.WE_CAMPAIGN && sfccReq.brandId=='2'){
             Date reqBDate;
             string Dt=sfccReq.DOB;
             String[] str = dt.split(' ');
             String[] dts = str[0].split('/');
              
            System.debug('sfccReq.DOB***'+sfccReq.DOB);
             if(String.isNotBlank(sfccReq.DOB) && sfccReq.DOB!='/1904' && Integer.valueOf(dts[0])!=Null && Integer.valueOf(dts[1])!=Null) {
                    reqBDate = Date.newInstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
              }
            
        if (String.isNotBlank(sfccReq.campaignName)){
            con.Latest_Campaigns__c = sfccReq.campaignName;
            con.Campaign_Signup_Date__c=System.Today();
            con.EmailOrigSource__c=SYSTEM.LABEL.WE_CAMPAIGN;
            con.WelcomeSource__c = SYSTEM.LABEL.X07;
            if(String.isNotBlank(sfccReq.Gender) && (con.SelfClaimedGender__c != sfccReq.Gender)) con.SelfClaimedGender__c = sfccReq.Gender;
            If(reqBDate!=Null && con.Birthdate!=reqBDate)con.Birthdate = reqBDate;
            
           
        }
        if (String.isNotBlank(sfccReq.loyaltyflag) && con.LoyaltyFlag__c!=true){
            con.LoyaltyFlag__c = true;
            con.Loyalty_Optin_Date__c=System.now();
        }
            
        
    }
        return con;
    }

    //Update existing Contact details
    Static Contact updateContact(Contact cont, SFCCRequest sfccR){
         string Dt=sfccR.DOB;
        cont.Status__c = SYSTEM.LABEL.Active;
        
        
        If (String.isNotBlank(sfccR.firstName) && (!sfccR.firstName.equals(cont.FirstName)) && sfccR.firstName!='Unknown'){
            cont.FirstName = sfccR.firstName;
        }
            
        If (String.isNotBlank(sfccR.lastName) && (!sfccR.lastName.equals(cont.LastName)) && sfccR.lastName!='Unknown' ){
            cont.LastName = sfccR.lastName;
        }
        If (String.isNotBlank(sfccR.emailAddress) && (!sfccR.emailAddress.equals(cont.Email)))
            cont.Email = sfccR.emailAddress;
        If (String.isNotBlank(sfccR.sourceSystem))
            cont.Latest_Source__c = sfccR.sourceSystem;
        //If(String.isNotBlank(sfccR.EmailOrgSource)) cont.WelcomeSource__c  = sfccR.EmailOrgSource;
        // If(String.isNotBlank(sfccR.region)) cont.Region_ds__c  = sfccR.region;
        //If(String.isNotBlank(sfccR.market)) cont.Market_ds__c  = sfccR.market;
        //If(String.isNotBlank(sfccR.country)) cont.Country_ds__c  = sfccR.country;
        if (String.isNotBlank(sfccR.requestType) && sfccR.requestType == SYSTEM.LABEL.Subscribe){
            setContactEmailOptin(cont, sfccR.requestType);
        }

        if (String.isNotBlank(sfccR.EmailOrgSource) && (sfccR.EmailOrgSource!=SYSTEM.LABEL.WE_CAMPAIGN) && cont.WelcomeSource__c!=Null && (!cont.WelcomeSource__c.equals('03'))){
            system.debug('sfccR.EmailOrgSource****'+sfccR.EmailOrgSource);
            setEmailOrgSource(cont, sfccR.EmailOrgSource, sfccR.country);
        }
        //GCT-4552 - Ad Opt Out flag
        if(isTealiumApi)
        {
         if (String.isNotBlank(sfccR.requestType) && sfccR.requestType == SYSTEM.LABEL.Advertise_Out){
             if(!cont.OptOutShare__c) {
             cont.OptOutShare__c = true;
            cont.Advertising_Opt_out__c = 'Y';
            cont.Advertising_Opt_out_Date__c = System.now();
            cont.Email_Address_Reason_Code__c = 'Tealium Request: Advertise OptOut';
            update cont;
            //cont.AdvertiseOptinDate__c = null;
          	PersonalDataFormApexController.CaseWrapper caseWrapper=     PersonalDataFormApexController.createCaseForDonotSellShare(cont.Brand_Id__c, cont.Email,isTealiumApi);
      		System.debug('Case number generated for tealium ' + caseWrapper.caseNumber);
        	
            callR2RProcessService(caseWrapper.caseNumber,caseWrapper.caseId,caseWrapper.verificationCode);
                

             }
        } 
        if (String.isNotBlank(sfccR.requestType) && sfccR.requestType == SYSTEM.LABEL.Advertise_In){
            cont.OptOutShare__c = false;
            cont.Advertising_Opt_out__c = 'N';
            cont.AdvertiseOptinDate__c = System.now();
            cont.Email_Address_Reason_Code__c = 'Tealium Request: Advertise OptIn';
            //cont.Advertising_Opt_out_Date__c = null;
        }
            
        }
       
        
         /** Project Blue **/
        if(sfccR.EmailOrgSource==SYSTEM.LABEL.WE_CAMPAIGN && sfccR.brandId=='2'){
            Date reqBDate;
            String[] str = dt.split(' ');
            String[] dts = str[0].split('/');
            
            if(String.isNotBlank(sfccR.DOB) && sfccR.DOB!='/1904' && Integer.valueOf(dts[0])!=Null && Integer.valueOf(dts[1])!=Null) {
                    reqBDate = Date.newInstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
              }
            
            
          If (String.isNotBlank(sfccR.region) &&  cont.Region_ds__c !='Americas')
            cont.Region_ds__c = sfccR.region;
            
          If (String.isNotBlank(sfccR.market) &&  cont.Market_ds__c !='NA')
            cont.Market_ds__c = sfccR.market;
            
          If (String.isNotBlank(sfccR.country) && cont.Country_ds__c !='US')
            cont.Country_ds__c = sfccR.country;
            
          if (String.isNotBlank(sfccR.campaignName)){
                cont.Latest_Campaigns__c = sfccR.campaignName;
                cont.Campaign_Signup_Date__c=System.Today();
                cont.WelcomeSource__c = SYSTEM.LABEL.X07;
                cont.EmailOrigSource__c=SYSTEM.LABEL.WE_CAMPAIGN;
                system.debug('cont.WelcomeSource__c***'+cont.WelcomeSource__c);
                system.debug(' cont.EmailOrigSource__c***'+ cont.EmailOrigSource__c);
                if(String.isNotBlank(sfccR.Gender) && (cont.SelfClaimedGender__c != sfccR.Gender)) cont.SelfClaimedGender__c = sfccR.Gender;
                If(reqBDate!=Null && cont.Birthdate!=reqBDate)cont.Birthdate = reqBDate;
              }
            if (String.isNotBlank(sfccR.loyaltyflag) && cont.LoyaltyFlag__c!=true){
                cont.LoyaltyFlag__c = true;
                cont.Loyalty_Optin_Date__c=System.now();
            }
        }

        return cont;
    }

    Static SFCCResponse returnResponse(Boolean existingCont, List<Id> allContactID, String brandId, Map<Id, Contact> oldContacts){
        Contact contact;
        SFCCResponse sfccRes = new SFCCResponse();
        Log.push('***allContactID = ' + allContactID);
        Log.push('***Brand_Id__c = ' + brandId);
        if (allContactID != null && allContactID.size() > 0){
            contact = [SELECT Id, LoyaltyId__c, EmailOptInStatus__c, LoyaltyFlag__c
                       FROM Contact
                       WHERE Id IN:allContactID AND Brand_Id__c = :brandId];
            if (existingCont){
                if (oldContacts.containsKey(contact.Id) && oldContacts.get(contact.Id).EmailOptInStatus__c == 'Y'){
                    sfccRes.NewsLetterAlreadySignedUp = system.label.true;
                    sfccRes.LoyaltyAlreadySignedUp = 'true';
                } else{
                    sfccRes.NewsLetterAlreadySignedUp = system.label.false;
                    sfccRes.LoyaltyAlreadySignedUp = 'false';
                }
            } else{
                sfccRes.NewsLetterAlreadySignedUp = system.label.false;
                sfccRes.LoyaltyAlreadySignedUp = 'false';
            }
            sfccRes.Subscriberkey = contact.Id;
            sfccRes.LoyaltyId = contact.LoyaltyId__c;
        }
        sfccRes.code = SYSTEM.LABEL.OK;
        sfccRes.message = SYSTEM.LABEL.Success;
        sfccRes.PreviousOptinStatus = String.valueOf(existingCont);
        Logger.logDebug();
        return sfccRes;
    }
     @Future(callout=true)
    public static void callR2RProcessService(String caseNumber, String caseId, String verificationCode){
        System.debug('+++++++++++ callR2RProcessService');
        System.debug('+++++++++++ isFirstRun ' + PrivacyCaseTriggerHandler.isFirstRun);
            String url = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/public/v1/r2rProcesss' + '?in_response=Open&' + 'in_verificationCode=' + verificationCode + '&in_caseid=' + caseId;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
}