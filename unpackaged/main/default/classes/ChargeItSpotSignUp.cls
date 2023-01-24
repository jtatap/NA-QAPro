/*
*  {"context":{"locale":"en_US","timezone":"PST8PDT","library":{"name":"analytics-java","version":"analytics/2.0.0-RC3"}},"integrations":{},"messageId":"52b3947f-23bc-4454-96e6-f33bcbf920ae","timestamp":"2018-08-08T14:29:33.795Z","traits":{"brand":"TH Store number 083","email":"YYZ@GMAIL.COM","emailExplicitOptinRequired":"false","emailOptin":"false","location":"TestLocation","serialNumber":"12345","site":"SiteName","smsExplicitOptinRequired":"false","smsOptin":"true","source":"ChargeItSpot","storeNumber":"1234"},"type":"identify","userId":"7785551212","writeKey":"somewritekey","receivedAt":"2018-08-08T14:29:37.795Z","sentAt":"2018-08-08T14:29:37.000Z","originalTimestamp":"2018-08-08T14:29:33+0000"}
* 
* Json request body sample from Segment.io
* {"messageId":"test-message-mkn7f6","timestamp":"2019-07-11T13:26:57.397Z","type":"identify","email":"test@example.org","projectId":"PWJdr2j1VW","traits":{"trait1":1,"trait2":"test","trait3":true},"userId":"test-user-wtg88h"}
* Note: For HMAC authentication json format changes the digest
* 
* Header
* X-Signature: 61438bde8f48b89b310aa972fd92d7831d2d70c7
* 
* https://instance.salesforce.com/services/apexrest/ChargeItSpot/SignUp

ChageItSpot request comes only for brand 1 (Tommy (TH))
*   NASSC-1087
    NASSC-1138: Update ChageItSpot for brand parameter changes
    NASSC-1311 
*/

@RestResource(urlMapping='/ChargeItSpot/SignUp')
global without sharing class ChargeItSpotSignUp {
    static Map<String,String> mapSubbrandParentbrand = new Map<String,String>();
    
    static DateTime chargeItTimeStamp;
    static Id intOwnerId;
    static String reqSMSNumberWithPrefix;


    global class ChargItReq{
        public context context;
        public integration integrations;
        public String messageId;
        public String timestamp;
        public trait traits;
        public String type;
        public String userId;  //represents SMS Phone number
        public String writeKey;
        public String receivedAt;
        public String sentAt;
        public String originalTimestamp;        
    }
    
    global class context{
        public String locale;
        public String timezone;
        public library library;
    }
    
    global class library{
        public String name;
        public String version;
    }
    
    global class integration{}
    
    global class trait{
        public String brand;
        public String email;
        public String emailExplicitOptinRequired;
        public String emailOptin;
        public String location;
        public String serialNumber;
        public String site;
        public String smsExplicitOptinRequired;
        public String smsOptin;
        public String source;
        public String storeNumber;
    }
    
    global class ChargeItResponse{
        public String code;
        public String message;
    }
    
    global static boolean authenticateRequest(RestRequest req){
        system.debug('RestRequest****'+req);
        Boolean validRequester = false;
        
        string sharedSecret =  [SELECT Secret__c FROM SharedSecret__mdt WHERE DeveloperName = 'ChargeItSpot' LIMIT 1].Secret__c;
        system.debug('sharedSecret: ' + sharedSecret);
        
        //String xsignature = req.headers.get('X-Signature');
        
         list<string> headerKeyList=new  list<string>();
         list<string> headerValueList=new  list<string>();
        
        for(String reqKey:req.headers.keySet()){
            headerKeyList.add(reqKey);
        }
        for(string header:req.headers.values()){
            headerValueList.add(header);
        }
        
        String xsignature;
        if(headerKeyList.size()>0){
          for(integer i=0; i<headerKeyList.size();i++){
              if(headerKeyList[i]=='X-Signature'){
                  xsignature= headerValueList[i];
              }
          } 
            
        }
         system.debug('X signature ****'+ xsignature);
         
       if(xsignature != Null && String.isNotBlank(xsignature)){
            Blob digest = Crypto.generateMac('hmacSHA1', req.requestBody, Blob.valueOf(sharedSecret));  
            system.debug('digest hex: '+ EncodingUtil.convertToHex(digest));  
            if(EncodingUtil.convertToHex(digest) == xsignature) validRequester = true;
        } 
        return validRequester;    
    }    
    
    @HttpPost
    global static ChargeItResponse doSignUp(){
        Boolean authenticated = false;  
        RestRequest req = RestContext.request;
        
        system.debug('req***'+req);
        RestResponse res = RestContext.response;
        ChargeItResponse chargeItResponse = new ChargeItResponse();

        Contact SMSMatchedContact = new Contact();
        Contact emailMatchedContact = new Contact();
        Boolean smsAndEmailExactMatch = false;
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();
        String brandId;
        Contact newContact;
        List <Contact> toBeUpdatedContacts = new List<Contact>();

        
      Organization org = [Select isSandbox from Organization LIMIT 1];
        if (org.IsSandbox) authenticated = true; // no x-signature auth needed on sandboxes
        else authenticated = authenticateRequest(req); 
      // authenticated = authenticateRequest(req);
        
        if(authenticated){
            String requestData = req.requestBody.toString();
             system.debug('requestData***'+requestData);
            ChargItReq chgItReq = (ChargItReq)json.deserialize(requestData, ChargItReq.class);
              system.debug('chgItReq***'+chgItReq);
            // Brand, email or userId not present in request, return error message
            if(String.isBlank(chgItReq.traits.brand) || String.isBlank(chgItReq.traits.email) || String.isBlank(chgItReq.userId) || !SFMCUtility.validateEmail(chgItReq.traits.email))
            {
                res.statusCode = 400;
                chargeItResponse.code = 'MISSING_REQ_PARAMS';
                chargeItResponse.message = 'Missing brand/email/userId or invalid email';
                return chargeItResponse;
            }
            // if both emailOptin & smsOptin are missing, or if both are false, do nothing..
            else if ((String.isBlank(chgItReq.traits.emailOptin) && String.isBlank(chgItReq.traits.smsOptin)) && (!Boolean.valueOf(chgItReq.traits.emailOptin) && !Boolean.valueOf(chgItReq.traits.smsOptin)) )
            {
                // do nothing..

            }
            else { //all req params exist
               
                reqSMSNumberWithPrefix =  '1'+chgItReq.userId;
                //populate map of subBrand,parentBrand            
                List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c from LoyaltySettings__mdt];
                for(LoyaltySettings__mdt loyalRecord : loyaltyList){
                    if(loyalRecord.Parent_Brand__c != null){
                        mapSubbrandParentbrand.put(loyalRecord.BrandId__c,loyalRecord.Parent_Brand__c);
                    }
                }
                
                String[] reqBrandArray = chgItReq.traits.brand.split(' ');
                String reqBrand = reqBrandArray[0];
                System.debug('### reqBrand: ' + reqBrand);
                if (String.isNotBlank(chgItReq.timestamp)) chargeItTimeStamp = UtilityClass.strYYYMMDDtoDateTime(chgItReq.timestamp);

                List <User> IntegrationUsers = [SELECT Id FROM User WHERE Profile.Name='PVHIntegrationAPIUser' AND IsActive = true LIMIT 1];
                if (IntegrationUsers.size()>0) {
                    intOwnerId = IntegrationUsers[0].Id;
                }

                List<LoyaltySettings__mdt> listLoyaltySettingList = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c, DeveloperName 
                                                                     FROM LoyaltySettings__mdt 
                                                                     WHERE DeveloperName  = :reqBrand ];
                if(listLoyaltySettingList.size()>0) {
                    

                    brandId = listLoyaltySettingList[0].BrandId__c;


                    SMSMatchedContact = SFMCUtility.searchSMSBrandContact(brandId,reqSMSNumberWithPrefix);
                    emailMatchedContact = SFMCUtility.searchEmailBrandContact(brandId, chgItReq.traits.email);
                    if (SMSMatchedContact!=null && SMSMatchedContact.Email!=null && SMSMatchedContact.Email==chgItReq.traits.email) smsAndEmailExactMatch = true;

                    System.debug('SMSMatchedContact: '+SMSMatchedContact);
                    System.debug('emailMatchedContact: '+emailMatchedContact);
                    System.debug('smsAndEmailExactMatch' + smsAndEmailExactMatch);

                    if (!Boolean.valueOf(chgItReq.traits.smsOptin) && Boolean.valueOf(chgItReq.traits.emailOptin)) {

                        if (emailMatchedContact==null){
                            // create new contact with email, smsnumber, emailoptin, loyaltyopin
                            newContact = createNewSMSAndEmailContact(chgItReq, brandId);

                        } else {
                            // update contact with SMS number, emailoptin, loyalty optin
                            updateEmailContactForFlags(chgItReq, emailMatchedContact);
                            emailMatchedContact.SMSNumber__c = reqSMSNumberWithPrefix;
                            toBeUpdatedContacts.add(emailMatchedContact);


                        }


                    } else if (Boolean.valueOf(chgItReq.traits.smsOptin)) {

                        if (smsAndEmailExactMatch) {
                            // reoptin#1  - update SMSMatchedContact with smsOptin = 'P', loyalty opin - callout
                            updateSMSContactForFlags(chgItReq, SMSMatchedContact);
                            toBeUpdatedContacts.add(SMSMatchedContact);


                        } else if (SMSMatchedContact==null && emailMatchedContact==null){
                            // optin#1 - create new contact with email, smsnumber, smsOptin='P', emailoptin, loyaltyopin - callout
                            newContact = createNewSMSAndEmailContact(chgItReq, brandId);

                        } else if (SMSMatchedContact!=null && emailMatchedContact==null){
                            //only sms match found
                            if (SMSMatchedContact.Email==null){
                                // reoptin#5  - update SMSMatchedContact with Email, smsOptin = 'P', loyalty opin, emailOptin - callout
                                updateSMSContactForFlags(chgItReq, SMSMatchedContact);
                                SMSMatchedContact.Email = chgItReq.traits.email;
                                if (SMSMatchedContact.EmailOptInStatus__c != 'Y') {
                                    SMSMatchedContact.EmailOptInStatus__c = 'Y';
                                    SMSMatchedContact.EmailOptInDate__c = chargeItTimeStamp;
                                    SMSMatchedContact.EmailOptOutDate__c = null;
                                }
                                toBeUpdatedContacts.add(SMSMatchedContact);


                            } else {
                                // reoptin#4A  - update SMSMatchedContact with  smsOptin = 'P', loyalty opin - callout
                                    updateSMSContactForFlags(chgItReq, SMSMatchedContact);
                                    toBeUpdatedContacts.add(SMSMatchedContact);

                                if (Boolean.valueOf(chgItReq.traits.emailOptin)) {
                                    // reoptin#4B - create new contact with email, emailoptin, loyaltyopin; accId & loyaltyId from smsMatchedContact
                                    newContact = createNewSMSAndEmailContact(chgItReq, brandId);  //this will be an emailContact
                                    newContact.SMSNumber__c = null;
                                    newContact.SMSOptInDate__c = null;
                                    newContact.AccountId = SMSMatchedContact.AccountId;
                                    newContact.LoyaltyID__c = SMSMatchedContact.LoyaltyID__c;
                                    /*NACDT-3745*/
                                    if(newContact.SMSNumber__c == null){
                                        newContact.SMSOptinStatus__c='';
                                    }
                                }

                            }

                        } else if (SMSMatchedContact==null && emailMatchedContact!=null){
                            //only email match found
                            // optin#2,3
                            if (emailMatchedContact.SMSNumber__c==null){
                                // optin#2 - update emailMatchedContact with SMSNumber, SMSOptin = 'P', loyalty flag, email optin -- callout

                                updateEmailContactForFlags(chgItReq, emailMatchedContact);
                                emailMatchedContact.SMSNumber__c = reqSMSNumberWithPrefix;
                                emailMatchedContact.SMSOptinStatus__c = 'P';
                                emailMatchedContact.SMSOptInDate__c = chargeItTimeStamp;

                                toBeUpdatedContacts.add(emailMatchedContact);


                            } else {
                                // optin#3
                                // create new contact with smsnumber, smsOptin = Y, loyaltyopin; accId & loyalty id from emailMatchedContact
                                newContact = createNewSMSOnlyContact(chgItReq, brandId);
                                newContact.AccountId = emailMatchedContact.AccountId;
                                newContact.LoyaltyID__c = emailMatchedContact.LoyaltyID__c;

                                if (Boolean.valueOf(chgItReq.traits.emailOptin)) {
                                    //update emailMatchedContact's loyalty optin & emailoptin
                                    updateEmailContactForFlags(chgItReq, emailMatchedContact);
                                    toBeUpdatedContacts.add(emailMatchedContact);
                                }

                            }

                        } else if (SMSMatchedContact!=null && emailMatchedContact!=null && !smsAndEmailExactMatch){
                                //separate sms and email matched contacts found
                                // reoptin#2, 3, 6, 7 - updated SMSMatchedContact smsOptin = 'P', loyalty -- callout
                                updateSMSContactForFlags(chgItReq, SMSMatchedContact);
                                toBeUpdatedContacts.add(SMSMatchedContact);

                                if (Boolean.valueOf(chgItReq.traits.emailOptin)) {
                                    //update emailMatchedContact's loyalty optin & emailoptin
                                    updateEmailContactForFlags(chgItReq, emailMatchedContact);
                                    toBeUpdatedContacts.add(emailMatchedContact);

                                }

                        }

                    }

                    if (newContact!=null) {
                        insert newContact;
                        signUpActivityList.add(SignUpActivity.signupActivity(newContact.Id, newContact.Latest_Source__c,newContact.Brand_Id__c));



                    }
                    System.debug(toBeUpdatedContacts.size());
                    if (toBeUpdatedContacts.size()>0) {
                        update toBeUpdatedContacts;
                        for (Contact con: toBeUpdatedContacts){
                            signUpActivityList.add(SignUpActivity.signupActivity(con.Id, con.Latest_Source__c,con.Brand_Id__c));

                        }


                    }


                    res.statusCode = 200;
                    chargeItResponse.code = 'OK';
                    chargeItResponse.message = 'Success';

                    /* Now, this is performed with PB+invocable apex
                     *if(signUpActivityList.size()>0) SignUpActivity.logSignUpActivity(signUpActivityList); 
                     */
                }
            }            
        } else { //Invalid Shared Secret key
            res.statusCode = 400;
            chargeItResponse.code = 'AUTHENTICATION_FAILED';
            chargeItResponse.message = 'Incorrect shared secret';
        }
        return chargeItResponse;
    }
    
    

    
    
    //Create Contact
    Static Contact createNewSMSOnlyContact(ChargItReq chgItReq, String brandId){

        Contact con = new Contact();

        if(intOwnerId!=null) con.OwnerId = intOwnerId;
        //if(String.isNotBlank(chgItReq.traits.email)) con.Email = chgItReq.traits.email;
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();

        con.Source_System__c = 'ChargeItSpot'; //chgItReq.traits.source;
        con.Latest_Source__c = 'ChargeItSpot'; //chgItReq.traits.source;
        
        if(String.isNotBlank(chgItReq.context.locale)) con.SMSLocale__c = chgItReq.context.locale;
        
        con.Source__c = 'ChargeItSpot';
        con.Brand_Id__c = brandId;
        con.createdByMethod__c = 'API';
        if (chargeItTimeStamp!=null) con.PVHCreatedDate__c = chargeItTimeStamp;

        //Start: NASSC-1663
        if (chargeItTimeStamp!=null) con.EventDate__c = chargeItTimeStamp;
        String getDataSource = fetchDataSource(brandId);
        if(String.isNotBlank(getDataSource)){
                con.EmailOrigSource__c = getDataSource;
                con.Source__c = getDataSource;
        }
        //End: NASSC-1663
        
        con.Status__c = 'ACTIVE';
        con.LastName = 'Unknown';   //LastName is set to 'Unknown'
        con.FirstName = 'Unknown';   //LastName is set to 'Unknown'
        if(String.isNotBlank(chgItReq.traits.storeNumber)) con.HomeStore__c = chgItReq.traits.storeNumber;
        if(String.isNotBlank(chgItReq.traits.storeNumber)) con.StoreOfCapture__c = chgItReq.traits.storeNumber;
        
        //GCT-1571 TH - SMS Source to Match keyword opt in
            LoyaltySettings__mdt chrageItKey =[select BrandId__c,chargeItKeyword__c from LoyaltySettings__mdt where BrandId__c='1' limit 1];
            if(chrageItKey!=Null){
                con.Keyword__c=chrageItKey.chargeItKeyword__c;
            }
        
        if(String.isNotBlank(chgItReq.userId)) con.SMSNumber__c = reqSMSNumberWithPrefix;
        if(String.isNotBlank(chgItReq.traits.smsOptin) && Boolean.valueOf(chgItReq.traits.smsOptin) == true){
            con.SMSOptinStatus__c = 'P'; //true;
            con.LoyaltyFlag__c = true;
            if (chargeItTimeStamp!=null) {
                con.SMSOptInDate__c = chargeItTimeStamp;
                con.Loyalty_Optin_Date__c = chargeItTimeStamp;
            }


        }
        system.debug('con.CountryOfCapture__c****'+con.CountryOfCapture__c);
        if(String.isBlank(con.CountryOfCapture__c)){
            if(String.isNotBlank(chgItReq.context.locale) && chgItReq.context.locale.length() == 5){ 
           con.CountryOfCapture__c = chgItReq.context.locale.right(2).toUpperCase();
            system.debug('con.CountryOfCapture__c****'+con.CountryOfCapture__c); 
                                                                                                   }
        }

       return con;
       
    
    }

    public static Contact createNewSMSAndEmailContact(ChargItReq chgItReq, String brandId){
        Contact con = createNewSMSOnlyContact(chgItReq, brandId);
        con.Email = chgItReq.traits.email;
        
        //GCT-1571 TH - SMS Source to Match keyword opt in
           LoyaltySettings__mdt chrageItKey =[select BrandId__c,chargeItKeyword__c from LoyaltySettings__mdt where BrandId__c='1' limit 1];
            if(chrageItKey!=Null){
                con.Keyword__c=chrageItKey.chargeItKeyword__c;
            }

        if(String.isNotBlank(chgItReq.traits.emailOptIn) && Boolean.valueOf(chgItReq.traits.emailOptIn) == true){

            con.EmailOptInStatus__c = 'Y'; //true;
            if (!con.LoyaltyFlag__c) con.LoyaltyFlag__c = true;
            if (chargeItTimeStamp!=null) con.EmailOptInDate__c = chargeItTimeStamp;
        }
        return con;

    }

    public static void updateEmailContactForFlags(ChargItReq chgItReq, Contact emailContact){

        if(emailContact.EmailOptInStatus__c!='Y' &&
                ((String.isNotBlank(chgItReq.traits.emailOptIn) && Boolean.valueOf(chgItReq.traits.emailOptIn) == true) || (String.isNotBlank(chgItReq.traits.smsOptIn) && Boolean.valueOf(chgItReq.traits.smsOptIn) == true))
                ){
                    emailContact.EmailOptInStatus__c = 'Y';
                    emailContact.EmailOptOutDate__c = null;
                    emailContact.EmailOptInDate__c = chargeItTimeStamp;

        }
        if (!emailContact.LoyaltyFlag__c) {
            emailContact.LoyaltyFlag__c = true;
            emailContact.Loyalty_Optin_Date__c = chargeItTimeStamp;
        }
        emailContact.Latest_Source__c = 'ChargeItSpot';
        
        //GCT-1571 TH - SMS Source to Match keyword opt in
        LoyaltySettings__mdt chrageItKey =[select BrandId__c,chargeItKeyword__c from LoyaltySettings__mdt where BrandId__c='1' limit 1];
            if(chrageItKey!=Null && emailContact.Keyword__c!=chrageItKey.chargeItKeyword__c){
                emailContact.Keyword__c=chrageItKey.chargeItKeyword__c;
            }
        
        //Start: NASSC-1663
        if (chargeItTimeStamp!=null) emailContact.EventDate__c = chargeItTimeStamp;
        String getDataSource = fetchDataSource(emailContact.Brand_Id__c);
        if(String.isNotBlank(getDataSource)){
                emailContact.Source__c = getDataSource;
        }
        //End: NASSC-1663
        
        if(String.isNotBlank(chgItReq.context.locale)) emailContact.SMSLocale__c = chgItReq.context.locale;
         system.debug('emailContact.CountryOfCapture__c****'+emailContact.CountryOfCapture__c);
        if(String.isBlank(emailContact.CountryOfCapture__c)){
            if(String.isNotBlank(chgItReq.context.locale) && chgItReq.context.locale.length() == 5) {
                emailContact.CountryOfCapture__c = chgItReq.context.locale.right(2).toUpperCase();
                system.debug('emailContact.CountryOfCapture__c****'+emailContact.CountryOfCapture__c);
            }
        }
        
    }

    public static void updateSMSContactForFlags(ChargItReq chgItReq, Contact smsContact){

        if(smsContact.EmailOptInStatus__c!='Y' &&
                ((String.isNotBlank(chgItReq.traits.emailOptIn) && Boolean.valueOf(chgItReq.traits.emailOptIn) == true) || (String.isNotBlank(chgItReq.traits.smsOptIn) && Boolean.valueOf(chgItReq.traits.smsOptIn) == true))
                ){

                    if (!smsContact.LoyaltyFlag__c) {
                        smsContact.LoyaltyFlag__c = true;
                        smsContact.Loyalty_Optin_Date__c = chargeItTimeStamp;
                    }


        }
        
        //GCT-1571 TH - SMS Source to Match keyword opt in
         LoyaltySettings__mdt chrageItKey =[select BrandId__c,chargeItKeyword__c from LoyaltySettings__mdt where BrandId__c='1' limit 1];
         if(chrageItKey!=Null && smsContact.Keyword__c!=chrageItKey.chargeItKeyword__c){
             smsContact.Keyword__c=chrageItKey.chargeItKeyword__c;
            }
        
        if (smsContact.SMSOptinStatus__c!='P' && (String.isNotBlank(chgItReq.traits.smsOptIn) && Boolean.valueOf(chgItReq.traits.smsOptIn) == true)) {
            smsContact.SMSOptinStatus__c = 'P';
            smsContact.SMSOptInDate__c = chargeItTimeStamp;
            smsContact.Latest_Source__c = 'ChargeItSpot';
        }
        
        //Start: NASSC-1663
        if (chargeItTimeStamp!=null) smsContact.EventDate__c = chargeItTimeStamp;
        String getDataSource = fetchDataSource(smsContact.Brand_Id__c);
        if(String.isNotBlank(getDataSource)){
                smsContact.Source__c = getDataSource;
        }
        //End: NASSC-1663

        if(String.isNotBlank(chgItReq.context.locale)) smsContact.SMSLocale__c = chgItReq.context.locale;
        
        if(String.isBlank(smsContact.CountryOfCapture__c)){
            if(String.isNotBlank(chgItReq.context.locale) && chgItReq.context.locale.length() == 5) smsContact.CountryOfCapture__c = chgItReq.context.locale.right(2).toUpperCase();
        }
    }
    
    //Start: NASSC-1663
    public static String fetchDataSource(String searchBrand){
        
        //if records brand is child, assigning brandId with its parent
        if(mapSubbrandParentbrand.containsKey(searchBrand)){
            searchBrand = mapSubbrandParentbrand.get(searchBrand);
        }
        System.debug('***fetchDataSource: searchBrand = '+searchBrand);
        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, 
                                                              WelcomeSource__c,DataSource__c
                                                              FROM SubscriberDataSources__mdt
                                                              WHERE Brand__c=:searchBrand AND
                                                              SourceSystem__c='ChargeItSpot'];
        System.debug('***fetchDataSource: listDataSource = '+listDataSource);
        if (listDataSource.size()>0) return listDataSource[0].DataSource__c;
        else return null;
    }
    //End: NASSC-1663
}