/*
 * Json Request
{
"brandId" : "1", "emailAddress" : "thpgguest1209@yopmail.com", "SMSNumber" : "4561234522", "Subscriberkey" : "", "SMSOptinStatus" : "P", "Locale" : "en_us"
 }  

End point url
https://pvhservicecloud--qapro.sandbox.my.salesforce.com/services/apexrest/subscriptions/customeroptin


 */


//Brand specific TH

@RestResource(urlMapping='/subscriptions/customeroptin')
global class CustomerSMSOptinServices {
	static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    static String reqSMSNumberWithPrefix;    
    @HttpPost
    global static SFCCResponse doOptin(){
        Contact foundContact = new Contact();//SMS
        Contact foundSMSContact = new Contact();//SMS
        Contact brandAndEmailContact = new Contact();//SMS
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        SFCCRequest sfccReq = (SFCCRequest)json.deserialize(requestData, SFCCRequest.class);
        SFCCResponse sfccResponse = new SFCCResponse();
        Log.push('### sfccReq:'+sfccReq);
        System.debug('### sfccReq:'+sfccReq);
        reqSMSNumberWithPrefix=SYSTEM.LABEL.X1 + sfccReq.SMSNumber;
            //if(!String.isBlank(sfccReq.SMSNumber)){
                //Scenario -1: When Subscriber Key is blank, below logic will be executed. 
                if(String.isBlank(sfccReq.Subscriberkey)){
                    
                    res.StatusCode = 200;
                    sfccResponse.Code = 'MISSING_PARAMETERS';
                    sfccResponse.Message = 'Missing: ContactId';
                    sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                    sfccResponse.PreviousSMSOptinStatus='P'; 
                    sfccResponse.ExistingCustomer='No';
                   // return sfccResponse;
                }
                else{
                    foundContact = searchContact(sfccReq.Subscriberkey);//Subscriberkey=ContactID
                    foundSMSContact = searchSMSContact(reqSMSNumberWithPrefix);
                    system.debug('foundContact***'+foundContact);
                    system.debug('foundSMSContact***'+foundSMSContact);
                    
                    if(foundContact != null){
                        brandAndEmailContact =  SFMCUtility.searchEmailBrandContact(foundContact.Brand_Id__c,sfccReq.emailAddress);
                    }
                    //Scenario -2: When Contact is not found with Subscriber Key, below logic will be executed. 
                    if(foundContact == null){
                        
                        System.debug('***Error: Contact Not Found');
                        res.StatusCode = 200;
                        sfccResponse.Code = 'CONTACT_NOT_FOUND';
                        sfccResponse.Message = 'No matching contact found';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.PreviousSMSOptinStatus='P';
                       // return sfccResponse;
                    }
                    /*
                    //Scenario -3: When Contact is found with other contact Email address, below logic will be executed. 
                    else if(brandAndEmailContact != null && (foundContact.Email != sfccReq.emailAddress) && (foundContact.Id != brandAndEmailContact.Id)){
                        
                        res.statusCode = 200;
                        sfccResponse.code = 'CONTACT_EXISTS';
                        sfccResponse.message = 'Supplied Email address used by another contact';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.ExistingCustomer='Yes';
                        return sfccResponse;
                    }
					*/
					else if(foundSMSContact != null && (foundSMSContact.Id != sfccReq.Subscriberkey) && (foundSMSContact.SMSNumber__c == reqSMSNumberWithPrefix) && 
                            (foundSMSContact.SMSOptinStatus__c =='Y') && (foundSMSContact.Email != sfccReq.emailAddress)){
                         System.debug('This debug is at seq 01' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                         res.StatusCode = 200;
                        sfccResponse.Code = 'SMS_NUMBER_IN_USE';
                        sfccResponse.Message = 'SMS Number used by another contact';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.ExistingCustomer='Yes';
                       // return sfccResponse;
                         
                    }
                    /*Scenario -4: When Contact is found with another contact SMS number, below logic will be executed. 
                   // else if(foundSMSContact != null && ((foundContact.Id != foundSMSContact.Id) || (foundSMSContact.Id != sfccReq.Subscriberkey))){
                   else if(foundSMSContact != null && (foundContact.Id != foundSMSContact.Id) && (foundSMSContact.SMSNumber__c == reqSMSNumberWithPrefix)){
                      System.debug('This debug is at seq 02' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                        res.StatusCode = 200;
                        sfccResponse.Code = 'SMS_NUMBER_IN_USE';
                        sfccResponse.Message = 'SMS Number used by another contact';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.ExistingCustomer='Yes';
                        //return sfccResponse;
                        
                    }*/
                    //Scenario -5: When no other contact found with SMS number, below logic will be executed and SMS will get updated. 
                   else if((foundSMSContact == null && sfccReq.SMSOptinStatus != 'N' ) || (foundSMSContact != null && foundContact.Id == foundSMSContact.Id && sfccReq.SMSOptinStatus == 'P' && sfccReq.Subscriberkey == foundSMSContact.Id) ){
                   // else if(foundSMSContact != null && foundContact.Id == foundSMSContact.Id && sfccReq.SMSOptinStatus == 'P' && foundSMSContact.Id == sfccReq.Subscriberkey){ 
                   System.debug('This debug is at seq 03' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                       Contact updatedCon = updateContactOne(foundContact,sfccReq);
                        Savepoint sp;
                        try {
                            sp = Database.setSavepoint();
                            update updatedCon;
                            System.debug('***Contact Record Updated');  
                            res.StatusCode = 200;
                            sfccResponse.Code = 'Ok';
                            sfccResponse.Message = 'SUCCESS';
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            sfccResponse.PreviousSMSOptinStatus='P';
                        }
                        catch (Exception e) {
                            
                            System.debug('An exception occurred while updating Contact' + e.getMessage());
                            res.StatusCode = 500;
                            sfccResponse.Code = 'OTHER_ERROR';
                            sfccResponse.Message = e.getMessage();
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            Database.RollBack(sp);
                            
                        }
                        
                        
                        //return sfccResponse;
                        
                    }
                    
                    //Scenario -6: When SMS number is blank in the request, below logic will be executed. 
                    else if(foundContact != null && sfccReq.SMSNumber == null){
                        System.debug('This debug is at seq 04' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                        System.debug(foundContact);
                            res.StatusCode = 200;
                            sfccResponse.Code = 'MISSING_SMS';
                            sfccResponse.Message = 'SMS Number missing in the request';
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        	sfccResponse.ExistingCustomer='Yes';
                           // return sfccResponse;
                        
                        
                      //  sfccResponse.contactId = updatedConWithOutSMS.Id;
                        
                    }
                    //Scenario -7: When Optin field is N in the request , Below Optout logic will get executed.
                    else if (foundSMSContact !=NULL && foundSMSContact.Id == sfccReq.Subscriberkey && sfccReq.SMSOptinStatus == 'N' ){
						System.debug('This debug is at seq 05' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                        String PreviousOptinStatus = foundSMSContact.SMSOptinStatus__c;
                        Contact updatedCon = updateContactOne(foundContact,sfccReq);
                        Savepoint sp;
                        try {
                            sp = Database.setSavepoint();
                            update updatedCon;
                            System.debug('***Contact Record Updated');  
                            res.StatusCode = 200;
                            sfccResponse.Code = 'Ok';
                            sfccResponse.Message = 'SUCCESS';
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            sfccResponse.PreviousSMSOptinStatus = PreviousOptinStatus;
                        }
                        catch (Exception e) {
                            System.debug('An exception occurred while updating Contact' + e.getMessage());
                            res.StatusCode = 500;
                            sfccResponse.Code = 'OTHER_ERROR';
                            sfccResponse.Message = e.getMessage();
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            Database.RollBack(sp);
                            
                        }
                        
                        
                        //return sfccResponse;
                        
                    }
                        //Scenario -8: When Optin field is Y in the request , Below Optin logic will get executed.
                    else if (foundSMSContact !=NULL && foundSMSContact.Id == sfccReq.Subscriberkey && sfccReq.SMSOptinStatus == 'Y' ){
						System.debug('This debug is at seq 06' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                        String PreviousOptinStatus = foundSMSContact.SMSOptinStatus__c;
                        Contact updatedCon = updateContactOne(foundContact,sfccReq);
                        Savepoint sp;
                        try {
                            sp = Database.setSavepoint();
                            update updatedCon;
                            System.debug('***Contact Record Updated');  
                            res.StatusCode = 200;
                            sfccResponse.Code = 'Ok';
                            sfccResponse.Message = 'SUCCESS';
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            sfccResponse.PreviousSMSOptinStatus = PreviousOptinStatus;
                        }
                        catch (Exception e) {
                            System.debug('An exception occurred while updating Contact' + e.getMessage());
                            res.StatusCode = 500;
                            sfccResponse.Code = 'OTHER_ERROR';
                            sfccResponse.Message = e.getMessage();
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            Database.RollBack(sp);
                            
                        } 
                        
                        return sfccResponse;
                        
                    }
                    else {
                        System.debug('This debug is at seq 07' + foundContact + '*****' + foundSMSContact + '********' + sfccReq);
                        System.debug(foundContact);
                        Contact updatedCon = updateContactOne(foundContact,sfccReq);
                        System.debug(updatedCon);
                        Savepoint sp;
                        try {
                            sp = Database.setSavepoint();
                            update updatedCon;
                            System.debug('***Contact Record Updated');  
                        }
                        catch (Exception e) {
                            System.debug('An exception occurred while updating Contact' + e.getMessage());
                            res.StatusCode = 500;
                            sfccResponse.Code = 'OTHER_ERROR';
                            sfccResponse.Message = e.getMessage();
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                            sfccResponse.ExistingCustomer='Yes';
                            Database.RollBack(sp);
                            return sfccResponse;
                        }
                        
                        res.StatusCode = 200;
                        sfccResponse.Code = 'Ok';
                      //  sfccResponse.contactId = updatedCon.Id;
                        sfccResponse.Message='Success';
                        
                    }
                     
                }
            //}  
        
        return sfccResponse;
    } 
    /*****************/
    public static Contact searchContact(Id contactId){
        List<Contact> conList = [SELECT Id,FirstName,LastName,MailingStreet,MailingCity,MailingState,Brand_Id__c,Email,
                                 MailingCountry, MailingPostalCode, BirthDate, Phone, SMSNumber__c,SMSOptinStatus__c, SMSOptInDate__c,
                                 PrefCenterInterests__c, HomeStore__c,isEmployee__c,AccountId,SMSLocale__c,CountryOfCapture__c,SelfClaimedGender__c,
                                 Latest_Source__c,Source_System__c  
                                 FROM Contact WHERE Id =: contactId];
        if(!conList.isEmpty()){
            Logger.logDebug();
            return conList[0];
        }else{
            return null;
        }
        
        
    }
    
    public static Contact searchSMSContact(String inputSMSNumber){
        List<Contact> conList = [SELECT Id,FirstName,Email,LastName,MailingStreet,MailingCity,MailingState,
                                 MailingCountry, MailingPostalCode, BirthDate, Phone, SMSNumber__c,SMSOptinStatus__c, SMSOptInDate__c,
                                 PrefCenterInterests__c, HomeStore__c,isEmployee__c,SMSLocale__c,CountryOfCapture__c,SelfClaimedGender__c,
                                 Latest_Source__c,Source_System__c 
                                 FROM Contact 
                                 WHERE SMSNumber__c != null AND SMSNumber__c =: inputSMSNumber];
        
        if(!conList.isEmpty()){
            Logger.logDebug();
            return conList[0];
        }else{
            return null;
        }
        
    }
    
    public static Contact updateContactOne(Contact con, SFCCRequest pcReq){
         Log.push('***inside updateContact');
        System.debug('***inside updateContact');
        LoyaltySettings__mdt lsm = [Select preferenceCenterKeyword__c,BrandId__c from LoyaltySettings__mdt where BrandId__c=: con.Brand_Id__c];
        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, WelcomeSource__c, DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c = : con.Brand_Id__c AND SourceSystem__c ='eComm'];

            if (listDataSource.size() > 0){
                con.Source__c = listDataSource[0].DataSource__c;
            }
       
        if(String.isNotBlank(pcReq.emailAddress) && (con.Email != pcReq.emailAddress)) con.Email = pcReq.emailAddress;
        
        //Start: Setting SMS Related Fields
        if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus == 'P' && String.isBlank(con.SMSNumber__c)){
            //brand new sms optin
            Log.push('***First Time Optin');
            con.SMSNumber__c = SYSTEM.LABEL.X1 + pcReq.SMSNumber;
            con.SMSOptinStatus__c = 'P';
            con.Latest_Source__c = SYSTEM.LABEL.eCommLatestSource;
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
            con.IseCommSMS__c=True;
            //con.SMSOptInDate__c = System.now();
        }
        else if((pcReq.SMSOptinStatus == 'N') && (con.SMSOptinStatus__c == null || con.SMSOptinStatus__c == 'Y' || con.SMSOptinStatus__c == 'P')){
            // sms optout
            Log.push('***Optout');
            con.SMSOptinStatus__c = 'N';
            con.SMSOptOutDate__c = System.now();
            con.Latest_Source__c = SYSTEM.LABEL.eCommLatestSource;
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
            con.IseCommSMS__c=True;
            con.SMS_Unsubscribe_Reason__c='eComm Opt-out';
        }
        else if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus == 'P' && String.isNotBlank(con.SMSNumber__c) && con.SMSNumber__c == reqSMSNumberWithPrefix){
           //sms reoptin with same number
            Log.push('***Re-Optin with same number');
            con.Latest_Source__c = SYSTEM.LABEL.eCommLatestSource;
            con.SMSOptinStatus__c = 'P';
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
            con.IseCommSMS__c=True;
            //con.SMSOptInDate__c = System.now();
        }
        else if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus == 'P' && String.isNotBlank(con.SMSNumber__c) && con.SMSNumber__c != reqSMSNumberWithPrefix){
            //sms optin with a different number
            Log.push('***Re-Optin with different number');
            con.Latest_Source__c = SYSTEM.LABEL.eCommLatestSource;
            con.SMSNumber__c = SYSTEM.LABEL.X1 + pcReq.SMSNumber;
            con.SMSOptinStatus__c = 'P';
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
            con.IseCommSMS__c=True;
            //con.SMSOptInDate__c = System.now();
        }
        //End: Setting SMS Related Field
        
       /* if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus !='N'){
            System.debug('***First Time Optin');
            con.SMSNumber__c = pcReq.SMSNumber;
            con.SMSOptinStatus__c = 'P';
            con.SMSOptInDate__c = System.now();
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
        }
        if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus == 'N'){
            con.SMSOptinStatus__c = 'N';
            con.SMSOptOutDate__c = System.now();
            con.SMS_Unsubscribe_Reason__c='eComm Opted out';
            con.SMSOptOutDate__c = System.now();
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
        }*/
        
        //End: Setting SMS Related Field        
        if(String.isNotBlank(pcReq.Locale) && (con.SMSLocale__c != pcReq.Locale)) con.SMSLocale__c = pcReq.Locale;
        if(String.isBlank(con.CountryOfCapture__c) && String.isNotBlank(pcReq.Locale)){
            if(pcReq.Locale.length() == 5) con.CountryOfCapture__c = pcReq.Locale.right(2).toUpperCase();
        }
        System.debug(con);
        Logger.logDebug();
        return con;
    }
    
    /******************/
    global class SFCCRequest{
        public String brandId;
        public String emailAddress;
        public String Subscriberkey;
        public String SMSNumber;
        public String SMSOptinStatus;
        public String Locale;
    }
    global class SFCCResponse{
        public String Code;
        public String Message;
        public String Subscriberkey;
        public String PreviousSMSOptinStatus;
        public String ExistingCustomer;
    }
}