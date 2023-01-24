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
        System.debug('### sfccReq:'+sfccReq);
            if(!String.isBlank(sfccReq.SMSNumber)){
                //Scenario -1: When Subscriber Key is blank, below logic will be executed. 
                if(String.isBlank(sfccReq.Subscriberkey)){
                    
                    res.StatusCode = 200;
                    sfccResponse.Code = 'MISSING_PARAMETERS';
                    sfccResponse.Message = 'Missing: ContactId';
                    sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                    sfccResponse.PreviousSMSOptinStatus='P'; 
                    sfccResponse.ExistingCustomer='No';
                    return sfccResponse;
                }
                else{
                    foundContact = searchContact(sfccReq.Subscriberkey);//Subscriberkey=ContactID
                    foundSMSContact = searchSMSContact(sfccReq.SMSNumber);
                    
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
                        return sfccResponse;
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
                    //Scenario -4: When Contact is found with another contact SMS number, below logic will be executed. 
                    else if(foundSMSContact != null && (foundContact.Id != foundSMSContact.Id)){
                        res.StatusCode = 200;
                        sfccResponse.Code = 'SMS_NUMBER_IN_USE';
                        sfccResponse.Message = 'SMS Number used by another contact';
                        sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        sfccResponse.ExistingCustomer='Yes';
                        return sfccResponse;
                        
                    }
                    //Scenario -5: When no other contact found with SMS number, below logic will be executed and SMS will get updated. 
                    else if((foundSMSContact == null && sfccReq.SMSOptinStatus != 'N') || (foundSMSContact != null && foundContact.Id == foundSMSContact.Id && sfccReq.SMSOptinStatus == 'P') ){
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
                        
                        
                        return sfccResponse;
                        
                    }
                    //Scenario -6: When SMS number is blank in the request, below logic will be executed. 
                    else if(foundContact != null && sfccReq.SMSNumber == null){
                        System.debug(foundContact);
                            res.StatusCode = 200;
                            sfccResponse.Code = 'MISSING_SMS';
                            sfccResponse.Message = 'SMS Number missing in the request';
                            sfccResponse.Subscriberkey=sfccReq.Subscriberkey;
                        	sfccResponse.ExistingCustomer='Yes';
                            return sfccResponse;
                        
                        
                      //  sfccResponse.contactId = updatedConWithOutSMS.Id;
                        
                    }
                    //Scenario -7: When Optin field is N in the request , Below Optout logic will get executed.
                    else if (foundSMSContact !=NULL && foundSMSContact.Id == sfccReq.Subscriberkey && sfccReq.SMSOptinStatus == 'N' ){

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
            }  
        
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
        LoyaltySettings__mdt lsm = [Select preferenceCenterKeyword__c,BrandId__c from LoyaltySettings__mdt where BrandId__c=: con.Brand_Id__c];
        if(String.isNotBlank(pcReq.emailAddress) && (con.Email != pcReq.emailAddress)) con.Email = pcReq.emailAddress;
        if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus !='N'){
            System.debug('***First Time Optin');
            con.SMSNumber__c = pcReq.SMSNumber;
            con.SMSOptinStatus__c = 'P';
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
        }
        if(String.isNotBlank(pcReq.SMSNumber) && pcReq.SMSOptinStatus == 'N'){
            con.SMSOptinStatus__c = 'N';
            con.SMSOptOutDate__c = System.now();
            con.SMS_Unsubscribe_Reason__c='eComm Opted out';
            con.Keyword__c = lsm.preferenceCenterKeyword__c;
        }
        
        //End: Setting SMS Related Field        
        if(String.isNotBlank(pcReq.Locale) && (con.SMSLocale__c != pcReq.Locale)) con.SMSLocale__c = pcReq.Locale;
        System.debug(con);
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