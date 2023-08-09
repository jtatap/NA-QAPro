/* Json Request
 *  {"brandId":"9","firstName":"John","lastName":"Doe","addressLine1":"123 Main Street","addressLine2":"","city":"Albany","state":"NY","zip":"14810","country":"US","emailAddress":"ajay@someEmail.com","phoneNumber":"5555555555","homePhoneNumber":"5555555555","mobilePhoneNumber":"5555555555","birthMonth":"03","birthDay":"06","birthYear":"1969","gender":"Male","location":"CO601","loyaltySignup":"true","emailOptIn":"true","smsOptIn":"true","SMSOptInFrequency":"","SourceSystem":"eComm","WelcomeSource":"1"}
 *  https://instance.salesforce.com/services/apexrest/subscriber/SignUp
 NASSC-1068,NASSC-1197,NASSC-1311
 */
@RestResource(urlMapping = '/subscriber/SignUp')
global without sharing class ECommSignUp{
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    static Map<String, String> mapSubbrandParentbrand = new Map<String, String>();
    global class EcomRequest{
        public String brandId;
        public String firstName;
        public String lastName;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String zip;
        public String country;
        public String emailAddress;
        public String phoneNumber;
        public String homePhoneNumber;
        public String mobilePhoneNumber;
        public String birthMonth;
        public String birthDay;
        public String birthYear;
        public String gender;
        public String location;
        public String loyaltySignup;
        public String emailOptIn;
        public String smsOptIn;
        public String SMSOptInFrequency;
        public String SourceSystem;
        public String WelcomeSource;
        //NASSC-1662
        public String MarketingSource;

        //Special Campagin
        public String SpecialCampaign;
        public String  LatestCampaigns;
    }

    global class ECommResponse{
        public String code;
        public String message;
        public String ContactId;
        public String LoyaltyId;
        public String ExistingCustomer;
        public String NewsLetterAlreadySignedUp;
        public String LoyaltyAlreadySignedUp;
    }

    @HttpPost
    global static ECommResponse doSignup(){

        List<Contact> profileUpdateContacts = new List<Contact>();
        Map<Id, Contact> oldContacts = new Map<Id, Contact>();
        List<Contact> newTopBrandContacts = new List<Contact>();
        List<Contact> newSubBrandContacts = new List<Contact>();
        Boolean createParent = false;
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();
        List<ID> allContactID = new List<ID>();

        List<Contact> allContactList = new List<Contact>();
        Boolean existingCont = false;

        List<Contact> searchecdParentContactList = new List<Contact>();
        List<LoyaltySettings__mdt> subBrandloyalitySetting;
        Contact contact = new Contact();
        Date reqBDate;
        List<Contact> contacts = new List<Contact>();
        String FileName = 'ECommAPI';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        EcomRequest ecomReq = (EcomRequest)json.deserialize(requestData, EcomRequest.class);
        ECommResponse ecomResponse = new ECommResponse();
        Log.push('### ecomReq:' + ecomReq);

        // Brand id or email not present in request, return error message
        if (String.isEmpty(ecomReq.brandId) || String.isEmpty(ecomReq.emailAddress) || String.isBlank(ecomReq.brandId) || String.isBlank(ecomReq.emailAddress)){
            res.statusCode = 400;
            ecomResponse.code = SYSTEM.LABEL.INVALID_QUERY;
            ecomResponse.message = SYSTEM.LABEL.Missing_required_parameters_BrandId_or_email;
            Log.push('***ecomResponse: ' + ecomResponse);  //do not comment out this statement
            return ecomResponse;
        } else{
             //Brand id and email present in request

            //populate map of subBrand,parentBrand
            List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c
                                                      from LoyaltySettings__mdt];
            for (LoyaltySettings__mdt loyalRecord : loyaltyList){
                if (loyalRecord.Parent_Brand__c != null){
                    mapSubbrandParentbrand.put(loyalRecord.BrandId__c, loyalRecord.Parent_Brand__c);
                }
            }


            If (String.isNotBlank(ecomReq.birthYear) && String.isNotBlank(ecomReq.birthMonth) && String.isNotBlank(ecomReq.birthDay) && String.valueOf(ecomReq.birthYear) != '' && String.valueOf(ecomReq.birthMonth) != '' && String.valueOf(ecomReq.birthDay) != ''){
                Log.push('inside***' + reqBDate);
                reqBDate = Date.newInstance(Integer.valueOf(ecomReq.birthYear), Integer.valueOf(ecomReq.birthMonth), Integer.valueOf(ecomReq.birthDay));
            } else{
                 //if birthDay is null set it to 01, if birthYear is null set it to 1900,if birthMonth is null set BOD to null
                if (String.valueOf(ecomReq.birthYear) == '' || String.isBlank(ecomReq.birthYear))
                    ecomReq.birthYear = '1900';
                if (String.valueOf(ecomReq.birthDay) == '' || String.isBlank(ecomReq.birthDay))
                    ecomReq.birthDay = '01';
                if (String.isBlank(ecomReq.birthMonth) || String.valueOf(ecomReq.birthMonth) == '' || Integer.valueOf(ecomReq.birthMonth) > 12){
                    Log.push('inside***' + reqBDate);
                    reqBDate = Null;
                } else{
                    Log.push('inside***' + reqBDate);
                    reqBDate = Date.newInstance(Integer.valueOf(ecomReq.birthYear), Integer.valueOf(ecomReq.birthMonth), Integer.valueOf(ecomReq.birthDay));
                }
            }

            //Check for existing contact
            contacts = searchContacts(ecomReq.brandId, ecomReq.emailAddress, emailRecordTypeId);
            Log.push('### contacts' + contacts);
            if (contacts != NULL && contacts.size() > 0){
                contact = contacts[0];
            }

            LoyaltySettings__mdt loyaltySetting;
            List<LoyaltySettings__mdt> listLoyaltySettingList = [Select Id, BrandId__c, IsLoyaltyApplicable__c, Parent_Brand__c
                                                                 from LoyaltySettings__mdt
                                                                 where BrandId__c = :ecomReq.brandId];
            if (listLoyaltySettingList.size() > 0)
                loyaltySetting = listLoyaltySettingList[0];
            if (contacts.size() < 1){
                //Contact not found
                //Is Top Level Brand
                if (loyaltySetting != null && String.isEmpty(loyaltySetting.Parent_Brand__c)){
                    newTopBrandContacts.add(createContact(ecomReq, reqBDate, loyaltySetting.Parent_Brand__c, createParent));

                    //has subbrands and email optedin
                    if (String.isNotEmpty(ecomReq.emailOptIn) && Boolean.valueOf(ecomReq.emailOptIn) == true){
                        List<LoyaltySettings__mdt> subBrandsLoyaltySetting = [Select Id, BrandId__c, IsLoyaltyApplicable__c, Parent_Brand__c
                                                                              from LoyaltySettings__mdt
                                                                              where Parent_Brand__c = :ecomReq.brandId];
                        Log.push('### subBrandsLoyaltySetting ' + subBrandsLoyaltySetting);
                        if (subBrandsLoyaltySetting.size() > 0){
                            //has subbrands
                            for (LoyaltySettings__mdt sb : subBrandsLoyaltySetting){
                                newSubBrandContacts.add(createContact(ecomReq, reqBDate, sb.BrandId__c, createParent));
                            }
                             //Log.push('### newSubBrandContacts' +newSubBrandContacts);
                        }
                    }
                } else if (loyaltySetting != null && String.isNotEmpty(loyaltySetting.Parent_Brand__c)){
                    //Not Top Level Brand
                    //Does Parent Brand Contacts exists in DB
                    searchecdParentContactList = searchContacts(loyaltySetting.Parent_Brand__c, ecomReq.emailAddress, emailRecordTypeId);
                    Log.push('### searchecdParentContactList :' + searchecdParentContactList);
                    if (searchecdParentContactList.size() < 1){
                        //Contact does not exist for Parent Brand(with Loyalty Flag = N and Email Status = N)
                        createParent = true;
                        Contact parentCon = createContact(ecomReq, reqBDate, loyaltySetting.Parent_Brand__c, createParent);
                        Log.push('### parentCon:' + parentCon);
                        // add to newTopBrandContacts
                        newTopBrandContacts.add(parentCon);

                        //setup this sub brand contact with flags from req
                        createParent = false;
                        Contact subBrandCon = createContact(ecomReq, reqBDate, ecomReq.brandId, createParent);
                        Log.push('### subBrandCon:' + subBrandCon);
                        // add to newSubBrandContacts list
                        newSubBrandContacts.add(subBrandCon);
                    } else{
                        //Parent Brand contact record exist Create Contact record for sub Brand
                        Contact subBrandCon = createContact(ecomReq, reqBDate, ecomReq.brandId, createParent);
                        Log.push('### subBrandCon:' + subBrandCon);
                        // add to newSubBrandContacts list
                        newSubBrandContacts.add(subBrandCon);
                    }
                }
            } else{
                //Contact Record found
                // add to profileUpdateContacts
                existingCont = true;
                oldContacts.put(contact.Id, contact.clone());
                profileUpdateContacts.add(updateContact(contact, ecomReq, reqBDate));
            }

            if (profileUpdateContacts.size() > 0){
                Database.SaveResult[] srList = Database.update (profileUpdateContacts, false);
                ContactUtility.createErrorLogRecords(srList, profileUpdateContacts[0].Latest_Source__c, FileName);
                for (Contact con : profileUpdateContacts){
                    if (con.id != null)
                        allContactList.add(con);
                }
            }

            if (newTopBrandContacts.size() > 0){
                Database.SaveResult[] srList = Database.insert (newTopBrandContacts, false);
                ContactUtility.createErrorLogRecords(srList, newTopBrandContacts[0].Latest_Source__c, FileName);
                for (Contact con : newTopBrandContacts){
                    if (con.id != null)
                        allContactList.add(con);
                }

            }

            if (newSubBrandContacts.size() > 0){
                Database.SaveResult[] srList = Database.insert (newSubBrandContacts, false);
                ContactUtility.createErrorLogRecords(srList, newSubBrandContacts[0].Latest_Source__c, FileName);
                for (Contact con : newSubBrandContacts){
                    if (con.id != null)
                        allContactList.add(con);
                }
            }

            for (Contact con : allContactList){
                allContactID.add(con.Id);
                signUpActivityList.add(SignUpActivity.signupActivity(con.Id, con.Latest_Source__c, con.Brand_Id__c));
            }

            /* Now, this is performed with PB+invocable apex
             *if(signUpActivityList.size()>0) SignUpActivity.logSignUpActivity(signUpActivityList);
             */
        }
        if (allContactList.size() > 0){
            upsert allContactList;
        }

        res.statusCode = 200;
        ecomResponse = returnResponse(existingCont, allContactID, ecomReq.brandId, oldContacts);
        Log.push('***ecomResponse: ' + ecomResponse);  //do not comment out this statement
        Logger.logDebug();
        return ecomResponse;
    }

    //Set contact email preferences
    Static void setContactEmailOptin(Contact cont, Boolean emailOptInFlag){
        if (emailOptInFlag){
            cont.EmailOptInStatus__c = SYSTEM.LABEL.Y; // true;
            cont.EmailOptInDate__c = System.now();
            cont.HasOptedOutOfEmail = false;
            //cont.EmailOptOutDate__c = Null;
        } else{
            cont.EmailOptInStatus__c = SYSTEM.LABEL.N; //false;
            //cont.EmailOptInDate__c = Null;
            cont.HasOptedOutOfEmail = true;
            cont.EmailOptOutDate__c = System.now();
        }
    }

    //Search Contact record
    Static List<Contact> searchContacts(String brandId, String emails, Id emailRecordTypeId){

        Log.push('### Contact search Brand Id:' + brandId);
        Log.push('### Contact search emails: ' + emails);
        Log.push('### Contact search emailRecordTypeId: ' + emailRecordTypeId);
        List<Contact> searchedContactList =  [SELECT Id, FirstName, LastName, Brand_Id__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                              Phone, MobilePhone, MailingCountry, Email, HomePhone, Birthdate, HomeStore__c, AccountId,  
                                              LoyaltyID__c, Latest_Source__c, EmailOptInStatus__c,EmailOptOutDate__c,EmailOptInDate__c, SMSOptinStatus__c, LoyaltyFlag__c, ReportsToId, Source_System__c,
                                              WelcomeSource__c,StoreOfCapture__c,Latest_Campaigns__c,MarketingSource__c,Do_Not_Sync_with_SFMC__c
                                              FROM Contact 
                                              WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c =:brandId AND Email = :emails];
        

        Logger.logDebug();
        return ((searchedContactList != null) ? searchedContactList : Null);
    }

    //Create New Contact record
    Static Contact createContact(EcomRequest ecomReq, Date reqBDate, String parentBrandId, Boolean createParent){
        Log.push('ecomReq****' + ecomReq);
        Log.push('ecomReq.emailOptIn****' + ecomReq.emailOptIn);
        Contact con = new Contact();

        con.RecordTypeId = emailRecordTypeId;
        con.Birthdate = reqBDate;
        Log.push('Birthdate***' + con.Birthdate);
        if (String.isNotBlank(ecomReq.sourceSystem)){
            con.Source_System__c = ecomReq.sourceSystem;
            con.Latest_Source__c = ecomReq.sourceSystem;
        }
        con.createdByMethod__c = SYSTEM.LABEL.API;
        con.Status__c = SYSTEM.LABEL.Active;

        if (String.isNotEmpty(parentBrandId)){
            con.Brand_Id__c = parentBrandId;
        } else
            con.Brand_Id__c = ecomReq.brandId;
        String searchBrand = ecomReq.brandId;
        //if records brand is child, assigning brandId with its parent
        if (mapSubbrandParentbrand.containsKey(ecomReq.brandId)){
            searchBrand = mapSubbrandParentbrand.get(ecomReq.brandId);
        }
        Log.push('***createContact - searchBrand = ' + searchBrand);
        if (String.isNotBlank(ecomReq.firstName))
            con.FirstName = ecomReq.firstName;
        else if (String.isBlank(ecomReq.firstName) || String.valueOf(ecomReq.firstName) == '')
            con.firstName = SYSTEM.LABEL.Unknown;
        if (String.isNotBlank(ecomReq.lastName)){
            con.LastName = ecomReq.lastName;
        } else if (String.isBlank(ecomReq.lastName) || String.valueOf(ecomReq.lastName) == '')
            con.LastName = SYSTEM.LABEL.Unknown;
        if (String.isNotBlank(ecomReq.addressLine1))
            con.MailingStreet = ecomReq.addressLine1;
        if (String.isNotBlank(ecomReq.addressLine2))
            con.MailingStreet += ' /\n/\r' + ecomReq.addressLine2;
        if (String.isNotBlank(ecomReq.city))
            con.MailingCity = ecomReq.city;
        if (String.isNotBlank(ecomReq.state))
            con.MailingState = ecomReq.state;
        if (String.isNotBlank(ecomReq.zip))
            con.MailingPostalCode = ecomReq.zip;
        if (String.isNotBlank(ecomReq.country))
            con.MailingCountry = ecomReq.country;
        if (String.isNotBlank(ecomReq.emailAddress))
            con.Email = ecomReq.emailAddress;
        if (String.isNotBlank(ecomReq.phoneNumber))
            con.Phone = ecomReq.phoneNumber;
        if (String.isNotBlank(ecomReq.homePhoneNumber))
            con.HomePhone = ecomReq.homePhoneNumber;
        if (String.isNotBlank(ecomReq.MobilePhoneNumber))
            con.MobilePhone = ecomReq.MobilePhoneNumber;
        if (String.isNotBlank(ecomReq.location))
            con.HomeStore__c = ecomReq.location;
        if (String.isNotBlank(ecomReq.location))
            con.StoreOfCapture__c = ecomReq.location;
        if (String.isNotBlank(ecomReq.WelcomeSource))
            con.WelcomeSource__c = ecomReq.WelcomeSource;
        //NASSC-3317
        If (String.isNotBlank(ecomReq.emailAddress) && (ecomReq.emailAddress.CONTAINS('@bh.extracttarget.com')) && con.Do_Not_Sync_with_SFMC__c == False){
            Log.push('ecomReq.emailAddress**' + ecomReq.emailAddress);

            con.Do_Not_Sync_with_SFMC__c = True;
        }

        //NASSC-3327
      if(String.isNotBlank(ecomReq.SpecialCampaign) && Boolean.valueOf(ecomReq.SpecialCampaign) == true){
        if  (con.Latest_Campaigns__c == null ){
              con.Latest_Campaigns__c=ecomReq.LatestCampaigns;
         }
         else{
             //con.Latest_Campaigns__c=ecomReq.LatestCampaigns+'\n'+con.Latest_Campaigns__c;
             List<String> lstCampaigns = con.Latest_Campaigns__c.split('\n');
             if(lstCampaigns.size()>3){
                 lstCampaigns.remove(lstCampaigns.size()-1);
                String str = String.join( lstCampaigns, '\n' );  
                 con.Latest_Campaigns__c=ecomReq.LatestCampaigns+'\n'+str;
             }
         }
       
     }

        //Start: NASSC-1662, 1663
        con.EventDate__c = System.now();
        if (String.isNotBlank(ecomReq.MarketingSource)){
            con.MarketingSource__c = ecomReq.MarketingSource;
            List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c = :searchBrand AND SourceSystem__c = :ecomReq.SourceSystem AND WelcomeSource__c = 'any' AND MarketingSource__c = 'any'];

            Log.push('***createContact - listDataSource = ' + listDataSource);
            if (listDataSource.size() > 0){
                con.EmailOrigSource__c = listDataSource[0].DataSource__c;
                con.Source__c = listDataSource[0].DataSource__c;
            }
        }


        if (String.isBlank(ecomReq.MarketingSource)){
            List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c = :searchBrand AND SourceSystem__c = :ecomReq.SourceSystem AND WelcomeSource__c = :ecomReq.WelcomeSource];

            if (listDataSource.size() > 0){
                con.EmailOrigSource__c = listDataSource[0].DataSource__c;
                con.Source__c = listDataSource[0].DataSource__c;
            }
        }
        //End: NASSC-1662, 1663
        Log.push('ecomReq.emailOptIn****' + ecomReq.emailOptIn);
        //NASSC-2076
        if (String.isNotBlank(ecomReq.emailOptIn) && Boolean.valueOf(ecomReq.emailOptIn) == true){
            Log.push('ecomReq.emailOptIn****' + ecomReq.emailOptIn);
            con.EmailOptInStatus__c = ecomReq.emailOptIn;
            if (String.isNotBlank(con.EmailOptInStatus__c)){
                con.EmailOptInDate__c = system.now();
                con.EmailOptOutDate__c = Null;
                con.HasOptedOutOfEmail = false;
            }
        }
        if (String.isNotBlank(ecomReq.emailOptIn) && Boolean.valueOf(ecomReq.emailOptIn) == false){
            Log.push('ecomReq.emailOptIn****' + ecomReq.emailOptIn);
            con.EmailOptInStatus__c = ecomReq.emailOptIn;
            if (String.isNotBlank(con.EmailOptInStatus__c)){
                con.EmailOptInDate__c = Null;
                con.EmailOptOutDate__c = system.now();
                con.HasOptedOutOfEmail = true;
            }
        }

        if (String.isNotBlank(ecomReq.emailOptIn) && Boolean.valueOf(ecomReq.emailOptIn) == true){
            setContactEmailOptin(con, (createParent ? false : true));
        }
        if (String.isNotBlank(ecomReq.emailOptIn) && Boolean.valueOf(ecomReq.emailOptIn) == false){
            setContactEmailOptin(con, (createParent ? false : false));
        }
        Log.push('******createParent = ' + createParent);

        /*Previous Code - Commented
         if(String.isNotBlank(ecomReq.loyaltySignup)) {
         if (Boolean.valueOf(ecomReq.loyaltySignup) == true) con.LoyaltyFlag__c = (createParent ? false : true);
         if (con.LoyaltyFlag__c) con.Loyalty_Optin_Date__c = System.now();
         }
         */
        //modified: NASSC-1656 NACDT-3457
        if (String.isNotBlank(ecomReq.loyaltySignup)){
            if (Boolean.valueOf(ecomReq.loyaltySignup) == true)
                con.LoyaltyFlag__c = true;
            if (con.LoyaltyFlag__c)
                con.Loyalty_Optin_Date__c = System.now();
        }
        Logger.logDebug();
        return con;
    }

    //Update existing Contact details
    Static Contact updateContact(Contact cont, EcomRequest ecomR, Date reqBDate){
        String addressLine;
        cont.Status__c = SYSTEM.LABEL.Active;
        //Start: NASSC:1663
        String searchBrand = ecomR.brandId;
        //if records brand is child, assigning brandId with its parent
        if (mapSubbrandParentbrand.containsKey(ecomR.brandId)){
            searchBrand = mapSubbrandParentbrand.get(ecomR.brandId);

        }
        //End: NASSC-1663
        Log.push('***updateContact - searchBrand = ' + searchBrand);
        If (String.isNotBlank(ecomR.firstName) && (!ecomR.firstName.equals(cont.FirstName)))
            cont.FirstName = ecomR.firstName;
        If (String.isNotBlank(ecomR.lastName) && (!ecomR.lastName.equals(cont.LastName)))
            cont.LastName = ecomR.lastName;
        if (String.isNotBlank(ecomR.addressLine1))
            addressLine = ecomR.addressLine1;
        if (String.isNotBlank(ecomR.addressLine2))
            addressLine += ' \r\n' + ecomR.addressLine2;
        If (String.isNotBlank(addressLine) && (addressLine != cont.MailingStreet))
            cont.MailingStreet = addressLine;
        If (String.isNotBlank(ecomR.city) && (!ecomR.city.equals(cont.MailingCity)))
            cont.MailingCity = ecomR.city;
        If (String.isNotBlank(ecomR.state) && (!ecomR.state.equals(cont.MailingState)))
            cont.MailingState = ecomR.state;
        If (String.isNotBlank(ecomR.zip) && (!ecomR.zip.equals(cont.MailingPostalCode)))
            cont.MailingPostalCode = ecomR.zip;
        If (String.isNotBlank(ecomR.country) && (!ecomR.country.equals(cont.MailingCountry)))
            cont.MailingCountry = ecomR.country;
        If (String.isNotBlank(ecomR.emailAddress) && (!ecomR.emailAddress.equals(cont.Email)))
            cont.Email = ecomR.emailAddress;
        If (String.isNotBlank(ecomR.phoneNumber) && (!ecomR.phoneNumber.equals(cont.Phone)))
            cont.Phone = ecomR.PhoneNumber;
        If (String.isNotBlank(ecomR.homePhoneNumber) && (!ecomR.homePhoneNumber.equals(cont.HomePhone)))
            cont.HomePhone = ecomR.homePhoneNumber;
        If (String.isNotBlank(ecomR.mobilePhoneNumber) && (!ecomR.mobilePhoneNumber.equals(cont.MobilePhone)))
            cont.MobilePhone = ecomR.mobilePhoneNumber;
        If (String.isNotBlank(ecomR.sourceSystem))
            cont.Latest_Source__c = ecomR.sourceSystem;
        If (String.isNotBlank(ecomR.location) && (!ecomR.location.equals(cont.HomeStore__c)))
            cont.HomeStore__c = ecomR.location;
        If (String.isNotBlank(ecomR.location) && (!ecomR.location.equals(cont.StoreOfCapture__c)))
            cont.StoreOfCapture__c = ecomR.location;
        If (String.isNotBlank(ecomR.WelcomeSource) && (!ecomR.WelcomeSource.equals(cont.WelcomeSource__c)))
            cont.WelcomeSource__c = ecomR.WelcomeSource;
        //NASSC-3317
        If (String.isNotBlank(ecomR.emailAddress) && (ecomR.emailAddress.CONTAINS('@bh.extracttarget.com')) && cont.Do_Not_Sync_with_SFMC__c == False){
            Log.push('ecomR.emailAddress**' + ecomR.emailAddress);
            cont.Do_Not_Sync_with_SFMC__c = True;
        }

        //Start: NASSC-1663
        cont.EventDate__c = System.now();
        If (String.isNotBlank(ecomR.MarketingSource)){
            cont.MarketingSource__c = ecomR.MarketingSource;
            List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c = :searchBrand AND SourceSystem__c = :ecomR.SourceSystem AND WelcomeSource__c = 'any' AND MarketingSource__c = 'any'];
            Log.push('***updateContact:MarketingSource ISNOTBLANK - listDataSource = ' + listDataSource);
            if (listDataSource.size() > 0){
                cont.Source__c = listDataSource[0].DataSource__c;
            }

        }
        If (String.isBlank(ecomR.MarketingSource)){
            cont.MarketingSource__c = null;
            List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c = :searchBrand AND SourceSystem__c = :ecomR.SourceSystem AND WelcomeSource__c = :ecomR.WelcomeSource];

            Log.push('***updateContact:MarketingSource ISBLANK - listDataSource = ' + listDataSource);
            if (listDataSource.size() > 0){
                cont.Source__c = listDataSource[0].DataSource__c;
            }

        }
        //End: NASSC-1663
        // NASSC-3327
        if(String.isNotBlank(ecomR.SpecialCampaign) && Boolean.valueOf(ecomR.SpecialCampaign) == true){
            if  (cont.Latest_Campaigns__c == null ){
                  cont.Latest_Campaigns__c=ecomR.LatestCampaigns;
             }
             else{
                // cont.Latest_Campaigns__c=ecomR.LatestCampaigns+'\n'+cont.Latest_Campaigns__c;
                 List<String> lstCampaigns = cont.Latest_Campaigns__c.split('\n');
                 if(lstCampaigns.size()>3){
                     lstCampaigns.remove(lstCampaigns.size()-1);
                    String str = String.join( lstCampaigns, '\n' );  
                     cont.Latest_Campaigns__c=ecomR.LatestCampaigns+'\n'+str;
                 }
             }
           
         }
        //Check for DOB in Request value and Contact value, if they differ update the Contact DOB,
        //else check if Contact DOB is Blank update the DOB from Request value
        If (String.isNotBlank(String.valueOf(reqBDate)) && String.isNotBlank(String.valueOf(cont.Birthdate)) && (!reqBDate.isSameDay(cont.Birthdate))){
            cont.Birthdate = reqBDate;
        } else If (String.isNotBlank(String.valueOf(reqBDate)) && String.isBlank(String.valueOf(cont.Birthdate))){
            cont.Birthdate = reqBDate;
        } /*else If(reqBDate == NULL){
            cont.Birthdate = NULL;
        } */

        /*  //If Request param 'EmailOptIn' is "true" and Contact.EmailOptinStatus__c is false:
         if(String.isNotBlank(ecomR.emailOptIn) && Boolean.valueOf(ecomR.emailOptIn) == true && cont.EmailOptInStatus__c != SYSTEM.LABEL.Y){
         setContactEmailOptin(cont,true);
         } else if(String.isNotBlank(ecomR.emailOptIn) && Boolean.valueOf(ecomR.EmailOptIn) == false && cont.EmailOptInStatus__c != SYSTEM.LABEL.N) {
         // If Request param 'EmailOptIn' is "false" and Contact.EmailOptinStatus__c is true:
         setContactEmailOptin(cont,false);
         }   */
        Log.push('ecomR.emailOptIn****' + ecomR.emailOptIn);
        // NASSC-2076
        if (String.isNotBlank(ecomR.emailOptIn) && Boolean.valueOf(ecomR.emailOptIn) == true){
            Log.push('ecomR.emailOptIn****' + ecomR.emailOptIn);
            if (String.isBlank(cont.EmailOptInStatus__c)){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.Y;
                cont.EmailOptInDate__c = system.now();
                cont.HasOptedOutOfEmail = false;
            } else if (cont.EmailOptInStatus__c == SYSTEM.LABEL.Y && cont.EmailOptInDate__c != Null){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.Y;
                cont.EmailOptInDate__c = system.now();
                cont.HasOptedOutOfEmail = false;
            } else if (cont.EmailOptInStatus__c == SYSTEM.LABEL.N && cont.EmailOptOutDate__c != Null){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.Y;
                cont.EmailOptInDate__c = system.now();
                cont.HasOptedOutOfEmail = false;
            }
        } else if (String.isNotBlank(ecomR.emailOptIn) && Boolean.valueOf(ecomR.emailOptIn) == false){
            if (String.isBlank(cont.EmailOptInStatus__c)){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.N;
                cont.EmailOptOutDate__c = system.now();
                cont.HasOptedOutOfEmail = true;
            } else if (cont.EmailOptInStatus__c == SYSTEM.LABEL.N && cont.EmailOptOutDate__c != Null){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.N;
                cont.EmailOptOutDate__c = system.now();
                cont.HasOptedOutOfEmail = true;
            } else if (cont.EmailOptInStatus__c == SYSTEM.LABEL.Y && cont.EmailOptInDate__c != Null){
                cont.EmailOptInStatus__c = SYSTEM.LABEL.N;
                cont.EmailOptOutDate__c = system.now();
                cont.HasOptedOutOfEmail = true;
            }
        }

        if (String.isNotBlank(ecomR.loyaltySignup)){
            if (Boolean.valueOf(ecomR.loyaltySignup) == true && cont.LoyaltyFlag__c == false){
                cont.LoyaltyFlag__c = true;
                cont.Loyalty_Optin_Date__c = System.now();
            } else if (Boolean.valueOf(ecomR.loyaltySignup) == false && cont.LoyaltyFlag__c == true)
                cont.LoyaltyFlag__c = false;
        }
        Log.push('cont***' + cont);
        Logger.logDebug();
        return cont;
    }

    Static ECommResponse returnResponse(Boolean existingCont, List<Id> allContactID, String brandId, Map<Id, Contact> oldContacts){
        Contact contact;
        ECommResponse ecomRes = new ECommResponse();

        Log.push('***allContactID = ' + allContactID);
        Log.push('***Brand_Id__c = ' + brandId);
        if (allContactID != null && allContactID.size() > 0){
            contact = [SELECT Id, LoyaltyId__c, EmailOptInStatus__c, LoyaltyFlag__c
                       FROM Contact
                       WHERE Id IN:allContactID AND Brand_Id__c = :brandId];

            if (existingCont){
                if (oldContacts.containsKey(contact.Id) && oldContacts.get(contact.Id).EmailOptInStatus__c == SYSTEM.LABEL.Y){
                    ecomRes.NewsLetterAlreadySignedUp = system.label.true;
                } else{
                    //removed check for N for NASSC-1197
                    ecomRes.NewsLetterAlreadySignedUp = system.label.false;
                }
            } else{
                ecomRes.NewsLetterAlreadySignedUp = system.label.false;
            }

            if (existingCont){
                if (oldContacts.containsKey(contact.Id) && oldContacts.get(contact.Id).LoyaltyFlag__c){
                    ecomRes.LoyaltyAlreadySignedUp = system.label.true;
                } else if (oldContacts.containsKey(contact.Id) && !oldContacts.get(contact.Id).LoyaltyFlag__c){
                    ecomRes.LoyaltyAlreadySignedUp = system.label.false;
                }
            } else{
                ecomRes.LoyaltyAlreadySignedUp = system.label.false;
            }

            ecomRes.ContactId = contact.Id;
            ecomRes.LoyaltyId = contact.LoyaltyId__c;
        }

        ecomRes.code = SYSTEM.LABEL.OK;
        ecomRes.ExistingCustomer = String.valueOf(existingCont);
        Logger.logDebug();
        return ecomRes;
    }

}