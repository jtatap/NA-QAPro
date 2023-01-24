/******************************************************************************
* @Description: custom REST API to consume the preference center updates from eComm.
* @Date       : April 15, 2020
* @JIRA       : NASSC-1671
*
******************************************************************************/

@RestResource(urlMapping='/subscriber/profile')
global without sharing class SubscriberProfileUpdates {
    
    global class PCUpdateRequest{
        public String ContactId;
        public String isEmployee;
        public Name Name;
        public String Email;
        public MailingAddress MailingAddress;
        public String BirthDate;
        public String Phone;
        public SMS SMS;
        public String PrefCenterInterests;
        public String HomeStore;
        public String Gender;
        public String SourceSystem;
        
    }
    
    global class Name {
        public String FirstName;
        public String LastName;
    }
    
    global class MailingAddress {
        public String Street;
        public String City;
        public String State;
        public String Country;
        public String PostalCode;
    }
    
    global class SMS {
        public String SMSNumber ;
        public String SMSOptinStatus;
        //public String SMSOptinDate;
        public String Locale; 
    }
    
    global class PCUpdateResponse{
        public String code;
        public String message;
        public String contactId;
    }
    
    
    @HttpPost
    global static PCUpdateResponse doSignUp(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PCUpdateResponse pcResponse = new PCUpdateResponse();
        Contact foundContact = new Contact();
        Contact foundSMSContact = new Contact();
        Contact brandAndEmailContact = new Contact();
        String requestData = req.requestBody.toString();
        PCUpdateRequest pcRequest = (PCUpdateRequest)json.deserialize(requestData, PCUpdateRequest.class);
        System.debug('** req: '+ pcRequest);
        
        //scenario: if ContactId missing in request parameter
        if(String.isBlank(pcRequest.ContactId)){
            res.statusCode = 400;
            pcResponse.code = 'MISSING_PARAMETERS';
            pcResponse.message = 'Missing: ContactId';
            return pcResponse;
        }
        
        else{
            System.debug('** '+ pcRequest.ContactId);
           // System.debug('** '+ pcRequest.SMS.SMSNumber);
            //System.debug('** '+ pcRequest.Name.FirstName);
            System.debug('** '+ pcRequest.MailingAddress.City);
            foundContact = searchContact(pcRequest.ContactId);
            foundSMSContact = searchSMSContact(pcRequest.SMS.SMSNumber);
          
            
            if(foundContact != null){
                brandAndEmailContact =  SFMCUtility.searchEmailBrandContact(foundContact.Brand_Id__c,pcRequest.Email);
            }
            
            
           
            if(foundContact == null){
                System.debug('***Error: Contact Not Found');
                res.statusCode = 400;
                pcResponse.code = 'INVALID_CONTACTID';
                pcResponse.message = 'No matching contact found';
                return pcResponse;
                
            }
            
            else if(brandAndEmailContact != null && (foundContact.Email != pcRequest.Email) && (foundContact.Id != brandAndEmailContact.Id)){
                System.debug('***Error: Another Contact Exists with Email');            
                res.statusCode = 400;
                pcResponse.code = 'INVALID_EMAIL';
                pcResponse.message = 'Supplied Email address used by another contact';
                return pcResponse;
            }
            
            else if(foundSMSContact != null && (foundContact.Id != foundSMSContact.Id)){
                System.debug('***Error: Another Contact Exists with SMSNumber');            
                res.statusCode = 400;
                pcResponse.code = 'INVALID_SMSNUMBER';
                pcResponse.message = 'SMS Number used by another contact';
                return pcResponse;
                
            }
           
            else if(foundContact != null && pcRequest.SMS.SMSNumber == null){
                
                System.debug(foundContact);
                Contact updatedConWithOutSMS= updateContacWithOutSMSNumber(foundContact,pcRequest);
                System.debug(updatedConWithOutSMS);
                Account updatedAcc = updateAccount(foundContact,pcRequest);
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
                    res.statusCode = 400;
                    pcResponse.code = 'OTHER_ERROR';
                    pcResponse.message = e.getMessage();
                    Database.RollBack(sp);
                    return pcResponse;
                }
                
                res.statusCode = 200;
                pcResponse.code = 'OK';
                pcResponse.contactId = updatedConWithOutSMS.Id;
                
            }            
            else {
                System.debug(foundContact);
                Contact updatedCon = updateContact(foundContact,pcRequest);
                System.debug(updatedCon);
                Account updatedAcc = updateAccount(foundContact,pcRequest);
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
                    res.statusCode = 400;
                    pcResponse.code = 'OTHER_ERROR';
                    pcResponse.message = e.getMessage();
                    Database.RollBack(sp);
                    return pcResponse;
                }
                
                res.statusCode = 200;
                pcResponse.code = 'OK';
                pcResponse.contactId = updatedCon.Id;
                pcResponse.message='Success';
                
            } 
            
        }
        return pcResponse;        
    }
    
    public static Contact searchContact(Id contactId){
        List<Contact> conList = [SELECT Id,FirstName,LastName,MailingStreet,MailingCity,MailingState,Brand_Id__c,Email,
                                 MailingCountry, MailingPostalCode, BirthDate, Phone, SMSNumber__c,SMSOptinStatus__c, SMSOptInDate__c,
                                 PrefCenterInterests__c, HomeStore__c,isEmployee__c,AccountId,SMSLocale__c,CountryOfCapture__c,SelfClaimedGender__c,
                                 Latest_Source__c,Source_System__c,Keyword__c 
                                 FROM Contact WHERE Id =: contactId];
        if (conList.size()>0) return conList[0];
        else return null;
        
    }
    
    public static Contact searchSMSContact(String inputSMSNumber){
        List<Contact> conList = [SELECT Id,FirstName,LastName,MailingStreet,MailingCity,MailingState,
                                 MailingCountry, MailingPostalCode, BirthDate, Phone, SMSNumber__c,SMSOptinStatus__c, SMSOptInDate__c,
                                 PrefCenterInterests__c, HomeStore__c,isEmployee__c,SMSLocale__c,CountryOfCapture__c,SelfClaimedGender__c,
                                 Latest_Source__c,Source_System__c,Keyword__c 
                                 FROM Contact 
                                 WHERE SMSNumber__c != null AND SMSNumber__c =: inputSMSNumber];
        
        if (conList.size()>0) return conList[0];
        else return null;
        
    }
    
    public static Contact updateContact(Contact con, PCUpdateRequest pcReq){
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
        if(String.isNotBlank(pcReq.SourceSystem) && (con.Latest_Source__c != pcReq.SourceSystem))
        {
            con.Latest_Source__c = pcReq.SourceSystem;
        }
        
        
       /*if(String.isBlank(pcReq.SourceSystem)){
             con.Latest_Source__c='eComm';
        }*/
       if(String.isNotBlank(pcReq.isEmployee) && Boolean.valueOf(pcReq.isEmployee) == true && (!pcReq.isEmployee.equals(con.isEmployee__c)))
           con.isEmployee__c = true;
       else if(String.isNotBlank(pcReq.isEmployee) && Boolean.valueOf(pcReq.isEmployee) == false && (!pcReq.isEmployee.equals(con.isEmployee__c)))
           con.isEmployee__c = false;
        //if(String.isNotBlank(pcReq.SourceSystem) && (con.Source_System__c != pcReq.SourceSystem)) con.Source_System__c = pcReq.SourceSystem;
        
     
        
       //Start: Setting SMS Related Fields
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
        if(string.isNotBlank(pcReq.PrefCenterInterests) && (con.PrefCenterInterests__c != pcReq.PrefCenterInterests)) con.PrefCenterInterests__c = pcReq.PrefCenterInterests;
        if(String.isNotBlank(pcReq.HomeStore) && (con.HomeStore__c != pcReq.HomeStore)) con.HomeStore__c = pcReq.HomeStore;
        if(String.isNotBlank(pcReq.Gender) && (con.SelfClaimedGender__c != pcReq.Gender)) con.SelfClaimedGender__c = pcReq.Gender;
        
        //GCT-1571 TH - SMS Source to Match keyword opt in
           LoyaltySettings__mdt prefernceKey =[select BrandId__c,preferenceCenterKeyword__c from LoyaltySettings__mdt where BrandId__c='1' limit 1];
            if(prefernceKey!=Null){
                con.Keyword__c=prefernceKey.preferenceCenterKeyword__c;
            }
        
        if(String.isBlank(con.CountryOfCapture__c) && String.isNotBlank(pcReq.SMS.Locale)){
            if(pcReq.SMS.Locale.length() == 5) con.CountryOfCapture__c = pcReq.SMS.Locale.right(2).toUpperCase();
        }
        System.debug(con);
        return con;
    }
    /* NACDT-3788 AND BELT-1614 */
    public static Contact updateContacWithOutSMSNumber(Contact con, PCUpdateRequest pcReq){
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
       
        if(String.isNotBlank(pcReq.SourceSystem) && (con.Latest_Source__c != pcReq.SourceSystem)) con.Latest_Source__c = pcReq.SourceSystem;
       /*  if(String.isNotBlank(pcReq.SourceSystem) && (con.Latest_Source__c != pcReq.SourceSystem))
        {
            con.Latest_Source__c = pcReq.SourceSystem;
        }
       if(String.isBlank(pcReq.SourceSystem)){
             con.Latest_Source__c='eComm';
        }*/
       
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
        
        //GCT-1571 TH - SMS Source to Match keyword opt in
        LoyaltySettings__mdt prefernceKey =[select BrandId__c,preferenceCenterKeyword__c from LoyaltySettings__mdt where BrandId__c='1' limit 1];
        if(prefernceKey!=Null){
           con.Keyword__c=prefernceKey.preferenceCenterKeyword__c;
          }
        
        if(String.isBlank(con.CountryOfCapture__c) && String.isNotBlank(pcReq.SMS.Locale)){
            if(pcReq.SMS.Locale.length() == 5) con.CountryOfCapture__c = pcReq.SMS.Locale.right(2).toUpperCase();
        }
        System.debug(con);
        return con;
     }
    
    public static Account updateAccount(Contact con, PCUpdateRequest pcReq){
        System.debug('***inside updateAccount');
        List<Account> listAccount = [Select Id,Gender__c,Name from Account where Id=: con.AccountId];
        if (listAccount.size() > 0){
            if(String.isNotBlank(pcReq.Gender) && (listAccount[0].Gender__c != pcReq.Gender)) listAccount[0].Gender__c = pcReq.Gender;
            if((String.isNotBlank(pcReq.Name.FirstName) && pcReq.Name.FirstName!='Unknown') && (String.isNotBlank(pcReq.Name.LastName) && pcReq.Name.LastName!='Unknown' )){
                listAccount[0].Name=pcReq.Name.FirstName+pcReq.Name.LastName;
            }
        }
        
        return listAccount[0];
    }
    
}