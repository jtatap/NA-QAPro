/*Json Request
{"brandId":"2","firstName":"Christina","lastName":"Doe","emailAddress":"Christina@pvh.com","emailOptIn":"true","SourceSystem":"SFCC","WelcomeSource":"01"}  
https://instance.salesforce.com/services/apexrest/SFCCSubscription/MarketingOptIn
* Jira# 
*/

//Brand specific CK
@RestResource(urlMapping='/Subscriptions/EmailMarketingOptIn')
global class Subscriptions_EmailMarketingOptIn {
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId(); 
    static Map<String,String> mapSubbrandParentbrand = new Map<String,String>();
    global class SFCCRequest{
        public String brandId;
        public String firstName; 
        public String lastName;
        public String emailAddress;
        public String requestType;//requestType
        public String SourceSystem;
        public String EmailOrgSource;//EmailOrgSource
        //public String MarketingSource;
        public String region;//required
        public String market;//required
        public String country;//required
        // public String requestType;//required
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
        Contact contact = new Contact();
        List<Contact> contacts = new List<Contact>();        
        String FileName = 'SFCCSubscription';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        SFCCRequest sfccReq = (SFCCRequest)json.deserialize(requestData, SFCCRequest.class);
        SFCCResponse sfccResponse = new SFCCResponse();  
        System.debug('### sfccReq:'+sfccReq);
        List<string> lstEmailOrgSource=new List<string>{'WE_OVERLAY','WE_CHECKOUT','WE_FOOTER','WE_MYACCOUNT'};
        if( String.isBlank(sfccReq.EmailOrgSource) || String.isEmpty(sfccReq.EmailOrgSource) || String.isBlank(sfccReq.EmailOrgSource) || !lstEmailOrgSource.contains(sfccReq.EmailOrgSource)){
            res.statusCode = 400;
            sfccResponse.code = 'INVALID_QUERY';
            sfccResponse.message = 'Request rejected. Unsupported value "head-n-tail" was passed for parameter'+sfccReq.EmailOrgSource;
            return sfccResponse;
        }
        // Brand id or email not present in request, return error message
        if(String.isEmpty(sfccReq.brandId) || String.isEmpty(sfccReq.emailAddress) || String.isBlank(sfccReq.brandId) ||  String.isBlank(sfccReq.emailAddress)  ||  String.isBlank(sfccReq.region)  ||  String.isBlank(sfccReq.country) ||  String.isBlank(sfccReq.market)) {
            res.statusCode = 400;
            sfccResponse.code = 'INVALID_QUERY';
            sfccResponse.message = 'Missing required parameters:  BrandId or email or Region or Market or Country';
            System.debug('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
            return sfccResponse;            
        } else { //Brand id and email present in request           
            //Check for existing contact
            contacts = searchContacts(sfccReq.brandId,sfccReq.emailAddress,emailRecordTypeId);
            System.debug('### contacts' + contacts);
            if(contacts != NULL && contacts.size()>0) {
                contact = contacts[0];
            }
            if(contacts.size()<1){
                
                newBrandContacts.add(createContact(sfccReq));
                
            } else { 
                //Contact Record found
                // add to profileUpdateContacts
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
                ContactUtility.createErrorLogRecords(srList,newBrandContacts[0].Latest_Source__c,FileName);
                for(Contact con : newBrandContacts){
                    if(con.id!=null) allContactList.add(con);
                }
            }
            for(Contact con: allContactList){
                allContactID.add(con.Id);
                signUpActivityList.add(SignUpActivity.signupActivity(con.Id, con.Latest_Source__c, con.Brand_Id__c));
            }
        }
        if(allContactList.size()>0){
            upsert allContactList;
        }
        res.statusCode = 200;        
        sfccResponse = returnResponse(existingCont, allContactID, sfccReq.brandId, oldContacts);
        System.debug('***sfccResponse: ' + sfccResponse);  //do not comment out this statement
        return sfccResponse;
    }    
    //Set contact email preferences
    Static void setContactEmailOptin(Contact cont,string requestType){
        if (requestType=='Subscribe'){
            if (cont.EmailOptInStatus__c == 'N' || cont.EmailOptInStatus__c == null){
            	cont.EmailOptInStatus__c = 'Y'; // true;
            	cont.EmailOptInDate__c = System.now();    
            }
            //cont.LoyaltyFlag__c=false;
            //cont.HasOptedOutOfEmail = false;
            //cont.EmailOptOutDate__c = Null;
        } else if(requestType=='UnSubscribe'){
            //cont.EmailOptInStatus__c = 'N'; //false;
            //cont.EmailOptInDate__c = Null;
            cont.HasOptedOutOfEmail = true;
            cont.EmailOptOutDate__c = System.now();
        }
    }
    Static void setEmailOrgSource(Contact cont,string reqEmailOrgSource, String country){
        System.debug('reqEmailOrgSource :'+reqEmailOrgSource);
        System.debug('country :'+country);
        if (reqEmailOrgSource=='WE_OVERLAY'){
            cont.WelcomeSource__c = '01'; // true;
        }else if(reqEmailOrgSource=='WE_CHECKOUT' && country == 'US'){
            cont.WelcomeSource__c = '04';
        }else if(reqEmailOrgSource=='WE_FOOTER'){
            cont.WelcomeSource__c = '02';
        }else if(reqEmailOrgSource=='WE_CHECKOUT' && country == 'CA'){
            cont.WelcomeSource__c = '24';
        }else if(reqEmailOrgSource=='WE_MYACCOUNT'){
            cont.WelcomeSource__c = '03';
        }
    }
    //Search Contact record
    Static List<Contact> searchContacts(String brandId, String emails,Id emailRecordTypeId){
        List<Contact> searchedContactList =  [SELECT Id, FirstName,Email,LastName, Brand_Id__c,EmailOptInStatus__c,
                                              EmailOptOutDate__c,EmailOptInDate__c, SMSOptinStatus__c, LoyaltyFlag__c,
                                              Source_System__c,WelcomeSource__c,MarketingSource__c
                                              FROM Contact 
                                              WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c =:brandId AND Email = :emails AND Bulk_Buyer__c=false order by Ecomm_Connected__c DESC, LastmodifiedDate DESC limit 1 ];
        return ((searchedContactList!=null)?searchedContactList:Null);
    }
    //Create New Contact record
    Static Contact createContact(SFCCRequest sfccReq){
        Contact con = new Contact();
        con.RecordTypeId = emailRecordTypeId;
        if(String.isNotBlank(sfccReq.sourceSystem)) {
            con.Source_System__c = sfccReq.sourceSystem;
            con.Latest_Source__c = sfccReq.sourceSystem;
        }
        con.createdByMethod__c = 'API';
        con.Status__c = 'ACTIVE'; 
        con.Brand_Id__c = sfccReq.brandId;
        if(con.Brand_Id__c == '1') con.LoyaltyFlag__c = true;
        if(String.isNotBlank(sfccReq.firstName)) con.FirstName = sfccReq.firstName;
        else if(String.isBlank(sfccReq.firstName) || String.valueOf(sfccReq.firstName) == '') con.firstName = 'Unknown';
        if(String.isNotBlank(sfccReq.lastName)){ con.LastName = sfccReq.lastName; }
        else if(String.isBlank(sfccReq.lastName) || String.valueOf(sfccReq.lastName) == '') con.LastName = 'Unknown';
        if(String.isNotBlank(sfccReq.emailAddress)) con.Email = sfccReq.emailAddress;
        //If(String.isNotBlank(sfccReq.EmailOrgSource)) con.WelcomeSource__c  = sfccReq.EmailOrgSource;
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
            setEmailOrgSource(con,sfccReq.EmailOrgSource, sfccReq.country);
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
        //If(String.isNotBlank(sfccR.EmailOrgSource)) cont.WelcomeSource__c  = sfccR.EmailOrgSource;
       // If(String.isNotBlank(sfccR.region)) cont.Region_ds__c  = sfccR.region;
        //If(String.isNotBlank(sfccR.market)) cont.Market_ds__c  = sfccR.market;
        //If(String.isNotBlank(sfccR.country)) cont.Country_ds__c  = sfccR.country;
        if(String.isNotBlank(sfccR.requestType) && sfccR.requestType == 'Subscribe'){            
            setContactEmailOptin(cont,sfccR.requestType);
        }
       
        if(String.isNotBlank(sfccR.EmailOrgSource) && (!cont.WelcomeSource__c.equals('03')) ){            
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
                    sfccRes.LoyaltyAlreadySignedUp = 'true';
                } else{
                    sfccRes.NewsLetterAlreadySignedUp = 'false';
                    sfccRes.LoyaltyAlreadySignedUp = 'false';
                }
            } else {
                sfccRes.NewsLetterAlreadySignedUp = 'false';
                sfccRes.LoyaltyAlreadySignedUp = 'false';
            }
            sfccRes.Subscriberkey = contact.Id;
            sfccRes.LoyaltyId = contact.LoyaltyId__c;               
        } 
        sfccRes.code = 'OK'; 
        sfccRes.message = 'Success'; 
        sfccRes.PreviousOptinStatus = String.valueOf(existingCont);
        return sfccRes;
    }
}