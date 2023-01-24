/*
 * JSON Request:
 * { "brandId": "1", "firstName": "John","lastName": "Doe","addressLine1": "123 Main Street","addressLine2": "","city": "Albany","state": "NY","zip": "14810","country": "US",
   "phonenumber":"9876567893",emailAddress": "John.Doe@someEmail.com","birthDate": "","gender": "Male","location": "TH601","loyaltySignup": "true", "emailOptIn": "true","sourceSystem": "POS"}
 * https://instance.salesforce.com/services/apexrest/posSubscriber/SignUp
 * NGCSI-184
 * Created Date :10/06/2020
 * Created By   :PVH
 * Modified By Kumar Sarathy/Salesforce : Added code to select Contact records only if Primary__c = true - currently this change has been removed from search query
 * 
 */

@RestResource(urlMapping='/posSubscriber/SignUp')
global without sharing class POSsignup {
    
       static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
       static Map<String,String> subbrandParentbrandMap = new Map<String,String>(); 
       public static Map<String,StoreMaster__c> storeMasterMap = new Map<String,StoreMaster__c>();  
    
   global class posRequest{
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
        public String loyaltyId;
        public String phonenumber;
        public String birthDate;
        public String gender;
        public String isemployee;
        public String emailOptIn;
        public String location;
        public String loyaltySignup;
        public String sourceSystem;
    }
    
    global class posResponse{
        public String code;
        public String message;
        public datetime CreatedDate;
        //public datetime lastmodifiedDate;
        public String ExistingCustomer;
        public String ContactId;
        public String LoyaltyId;
      }
    
    @HttpPost
    global static posResponse doSignup(){
        
       
        List<Contact> profileUpdateContacts = new List<Contact>();
         Map<Id, Contact> oldContacts = new Map<Id, Contact>();
        List<Contact> topBrandNewContacts = new List<Contact>();
        List<Contact> subBrandNewContacts = new List<Contact>();
        Boolean createParent = false;
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();
        List<ID> contactID = new List<ID>();
       
        List<Contact> allContactList = new List<Contact>();
        Boolean existingCont = false;
        List<Contact> toUpdateContactList = new List<Contact>();
        
        List<Contact> searchecdParentContactList = new List<Contact>();
        List<LoyaltySettings__mdt> brandloyalitySetting;
        Contact contact = new Contact();
        Date reqBDate;        
        List<Contact> contacts = new List<Contact>();        
        String FileName = 'POSAPI';
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        posRequest posReq = (posRequest)json.deserialize(requestData, posRequest.class);
        posResponse posResp = new posResponse(); 
       
         // Brand id or email or Lastname not present in request, return error message
         if((String.isEmpty(posReq.brandId) || String.isEmpty(posReq.emailAddress) || String.isEmpty(posReq.lastName) ||
          String.isBlank(posReq.brandId) ||  String.isBlank(posReq.emailAddress) || String.isBlank(posReq.lastName))
        //if((String.isEmpty(posReq.brandId)  || String.isEmpty(posReq.lastName) ||
           //String.isBlank(posReq.brandId)  || String.isBlank(posReq.lastName))
          ){
            res.statusCode = 400;
            posResp.code = 'INVALID_QUERY';
            posResp.message = 'Missing required parameters: BrandId or email or lastName';
            System.debug('***posResp: ' + posResp);  //do not comment out this statement
            return posResp;
        }else { //Brand id and email present in request            
            
            //populate map of subBrand,parentBrand            
            List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c from LoyaltySettings__mdt];
            for(LoyaltySettings__mdt loyalRecord : loyaltyList){
                if(loyalRecord.Parent_Brand__c != null){
                    subbrandParentbrandMap.put(loyalRecord.BrandId__c,loyalRecord.Parent_Brand__c);
                }
       }
                
        //Check for existing contact
         contacts = searchContacts(posReq.brandId,posReq.emailAddress,emailRecordTypeId);
            System.debug('contacts***' + contacts);
            //MGDCTH-578 - START
            if(contacts != NULL && contacts.size()>0) {
                for(Contact con : contacts){
                    if(con.Ecomm_Connected__c == true){
                 toUpdateContactList.add(con);
                    }
                 }
            if(toUpdateContactList.size()<1) {
                toUpdateContactList.add(contacts[0]);
            }
            }
            //MGDCTH-578 - END
        LoyaltySettings__mdt loyaltySetting;
        List<LoyaltySettings__mdt> loyaltySettingList = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where BrandId__c = :posReq.brandId ];
            if(loyaltySettingList.size()>0) loyaltySetting = loyaltySettingList[0];
            
       if(toUpdateContactList.size()<1){
           system.debug('** New not a@a.com Record');
              //Is Top Level Brand
           if(loyaltySetting != null && String.isEmpty(loyaltySetting.Parent_Brand__c)){
                    topBrandNewContacts.add(createContact(posReq,loyaltySetting.Parent_Brand__c, createParent));
                    
                    //Has subbrands and email optedin
                    if(String.isNotEmpty(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == true){
                        List<LoyaltySettings__mdt> subBrandsLoyaltySetting = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where Parent_Brand__c  = :posReq.brandId ];
                        system.debug('subBrandsLoyaltySetting**** '+ subBrandsLoyaltySetting);
                        if(subBrandsLoyaltySetting.size()>0){
                            //Has subbrands
                            for(LoyaltySettings__mdt sb: subBrandsLoyaltySetting){                                
                                subBrandNewContacts.add(createContact(posReq,sb.BrandId__c, createParent));
                            } 
                        }
                    }
                   //Not Top Level Brand
                }else if(loyaltySetting != null && String.isNotEmpty(loyaltySetting.Parent_Brand__c)) {
                    //Does Parent Brand Contacts exists in DB
                    searchecdParentContactList = searchContacts(loyaltySetting.Parent_Brand__c,posReq.emailAddress,emailRecordTypeId);
                    System.debug('searchecdParentContactList**** :'+searchecdParentContactList);
                    if(searchecdParentContactList.size()<1){
                        //Contact does not exist for Parent Brand(with Loyalty Flag = N and Email Status = N)
                        createParent = true;
                        Contact parentCon = createContact(posReq,loyaltySetting.Parent_Brand__c, createParent);
                        System.debug('parentCon:***'+parentCon);
                        // add to topBrandNewContacts
                        topBrandNewContacts.add(parentCon);
                        //setup this sub brand contact with flags from req
                        createParent = false;
                        Contact subBrandCon = createContact(posReq,posReq.brandId, createParent);
                        System.debug('subBrandCon:***'+subBrandCon);
                        // add to subBrandNewContacts list
                        subBrandNewContacts.add(subBrandCon);                        
                    } else {
                        //Parent Brand contact record exist Create Contact record for sub Brand
                        Contact subBrandCon = createContact(posReq,posReq.brandId, createParent);
                        System.debug('subBrandCon:***'+subBrandCon);
                        // add to subBrandNewContacts list
                        subBrandNewContacts.add(subBrandCon);
                    } 
                }         
                    
       }else{
            //Contact Record found 
           system.debug('posReq.loyaltyId**** '+ posReq.loyaltyId);
               system.debug('posReq.emailAddress**** '+ posReq.emailAddress);
           if(posReq.emailAddress =='a@a.com' && posReq.loyaltyId==''){
                system.debug('** New a@a.com Record');
               if(loyaltySetting != null && String.isEmpty(loyaltySetting.Parent_Brand__c)){
                    topBrandNewContacts.add(createContact(posReq,loyaltySetting.Parent_Brand__c, createParent));
                    
                    //Has subbrands and email optedin
                    if(String.isNotEmpty(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == true){
                        List<LoyaltySettings__mdt> subBrandsLoyaltySetting = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where Parent_Brand__c  = :posReq.brandId ];
                        system.debug('subBrandsLoyaltySetting**** '+ subBrandsLoyaltySetting);
                        if(subBrandsLoyaltySetting.size()>0){
                            //Has subbrands
                            for(LoyaltySettings__mdt sb: subBrandsLoyaltySetting){                                
                                subBrandNewContacts.add(createContact(posReq,sb.BrandId__c, createParent));
                            } 
                        }
                    }
                   //Not Top Level Brand
                }else if(loyaltySetting != null && String.isNotEmpty(loyaltySetting.Parent_Brand__c)) {
                    //Does Parent Brand Contacts exists in DB
                    searchecdParentContactList = searchContacts(loyaltySetting.Parent_Brand__c,posReq.emailAddress,emailRecordTypeId);
                    System.debug('searchecdParentContactList**** :'+searchecdParentContactList);
                    if(searchecdParentContactList.size()<1){
                        //Contact does not exist for Parent Brand(with Loyalty Flag = N and Email Status = N)
                        createParent = true;
                        Contact parentCon = createContact(posReq,loyaltySetting.Parent_Brand__c, createParent);
                        System.debug('parentCon:***'+parentCon);
                        // add to topBrandNewContacts
                        topBrandNewContacts.add(parentCon);
                        //setup this sub brand contact with flags from req
                        createParent = false;
                        Contact subBrandCon = createContact(posReq,posReq.brandId, createParent);
                        System.debug('subBrandCon:***'+subBrandCon);
                        // add to subBrandNewContacts list
                        subBrandNewContacts.add(subBrandCon);                        
                    } else {
                        //Parent Brand contact record exist Create Contact record for sub Brand
                        Contact subBrandCon = createContact(posReq,posReq.brandId, createParent);
                        System.debug('subBrandCon:***'+subBrandCon);
                        // add to subBrandNewContacts list
                        subBrandNewContacts.add(subBrandCon);
                    } 
                } 
                
            }
       for(integer i=0; i<toUpdateContactList.size(); i++){
        if(posReq.emailAddress =='a@a.com' && posReq.loyaltyId!='' && toUpdateContactList[i].LoyaltyID__c==posReq.loyaltyId){
            existingCont = true;
            oldContacts.put(toUpdateContactList[i].Id, toUpdateContactList[i].clone());
                profileUpdateContacts.add(updateContact(toUpdateContactList[i],posReq));
        }
         if(posReq.emailAddress !='a@a.com'){
             existingCont = true;
                oldContacts.put(toUpdateContactList[i].Id, toUpdateContactList[i].clone());
                profileUpdateContacts.add(updateContact(toUpdateContactList[i],posReq));
              
                    }
                }
       } 
           if(profileUpdateContacts.size()>0) {
                Database.SaveResult[] srList = Database.update(profileUpdateContacts, false);
                ContactUtility.createErrorLogRecords(srList,profileUpdateContacts[0].Latest_Source__c,FileName);
                for(Contact con : profileUpdateContacts){
                    if(con.id!=null) allContactList.add(con);
                }
            }
            
            if(topBrandNewContacts.size()>0){
                Database.SaveResult[] srList = Database.insert(topBrandNewContacts, false);
                ContactUtility.createErrorLogRecords(srList,topBrandNewContacts[0].Latest_Source__c,FileName);
                for(Contact con : topBrandNewContacts){
                    if(con.id!=null) allContactList.add(con);
                }
                
            }
             if(subBrandNewContacts.size()>0){
				Database.SaveResult[] srList = Database.insert(subBrandNewContacts, false);
                ContactUtility.createErrorLogRecords(srList,subBrandNewContacts[0].Latest_Source__c,FileName);
                for(Contact con : subBrandNewContacts){
                    if(con.id!=null) allContactList.add(con);
                }
            } 
            
            
            for(Contact con: allContactList){
                contactID.add(con.Id);
                signUpActivityList.add(SignUpActivity.signupActivity(con.Id, con.Latest_Source__c, con.Brand_Id__c));
            }
            
            
        }
        
        res.statusCode = 200;
        posResp = returnResponse(existingCont ,contactID, posReq.brandId,oldContacts);
        System.debug('***posResp: ' + posResp); 
        return posResp;
            
        
    }
     //Set contact email preferences
    Static void setContactEmailOptin(Contact cont,Boolean emailOptInFlag){
        if (emailOptInFlag){
            cont.EmailOptInStatus__c = 'Y'; // true;
            cont.EmailOptInDate__c = System.now();
            cont.HasOptedOutOfEmail = false;
            //cont.EmailOptOutDate__c = Null;
        } else {
            cont.EmailOptInStatus__c = 'N'; //false;
            //cont.EmailOptInDate__c = Null;
            cont.HasOptedOutOfEmail = true;
            cont.EmailOptOutDate__c = System.now();
        }
    }
    
     //Search Contact record
    Static List<Contact> searchContacts(String brandId, String emails,Id emailRecordTypeId){
        
        System.debug('Contact search Brand Id****'+brandId);
        System.debug('Contact search emails**** '+emails);
        System.debug('Contact search emailRecordTypeId**** '+emailRecordTypeId);
        //List<AggregateResult> dupcontact= [Select count(LoyaltyID__c), Email from contact group by Email having count(LoyaltyID__c ) > 1];
       // system.debug('dupcontact**'+dupcontact);
        
                
        List<Contact> searchedContactList =  [SELECT Id, FirstName, LastName, Brand_Id__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                              Phone, MobilePhone, MailingCountry, Email, HomePhone, Birthdate, HomeStore__c, AccountId,  
                                              LoyaltyID__c, Latest_Source__c, EmailOptInStatus__c,isEmployee__c,EmailOptOutDate__c,EmailOptInDate__c, SMSOptinStatus__c, LoyaltyFlag__c, ReportsToId, Source_System__c,
                                              WelcomeSource__c,StoreOfCapture__c,MarketingSource__c,CreatedDate,CountryOfCapture__c,SignupStore__c,Ecomm_Connected__c
                                              FROM Contact 
                                              WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c =:brandId AND Email = :emails order by LastModifiedDate desc];
        
        return ((searchedContactList!=null)?searchedContactList:Null);
    }
    

    //Create New Contact record
    Static Contact createContact(posRequest posReq,String parentBrandId,Boolean createParent){
       Contact con = new Contact();

        con.RecordTypeId = emailRecordTypeId;
        con.createdByMethod__c = 'POS API';
        con.Status__c = 'ACTIVE';  
        
        if(String.isNotEmpty(parentBrandId)){
            con.Brand_Id__c = parentBrandId;
        } else con.Brand_Id__c = posReq.brandId;
        
        String searchBrand = posReq.brandId;
        //if records brand is child, assigning brandId with its parent
        if(subbrandParentbrandMap.containsKey(posReq.brandId)){
            searchBrand = subbrandParentbrandMap.get(posReq.brandId);            
        }
       
        System.debug('***createContact - searchBrand = '+searchBrand);
        
        if(String.isNotBlank(posReq.firstName)) con.FirstName = posReq.firstName;
        else if(String.isBlank(posReq.firstName) || String.valueOf(posReq.firstName) == '') con.firstName = 'UNKNOWN';
        if(String.isNotBlank(posReq.lastName)){ con.LastName = posReq.lastName; }
        if(String.isNotBlank(posReq.addressLine1)) con.MailingStreet = posReq.addressLine1;
       // if(String.isNotBlank(posReq.addressLine2)) con.MailingStreet += ' /\n/\r' + posReq.addressLine2;
        if(String.isNotBlank(posReq.addressLine2)) con.MailingStreet += ' ' + posReq.addressLine2;
        if(String.isNotBlank(posReq.city)) con.MailingCity = posReq.city;
        if(String.isNotBlank(posReq.state)) con.MailingState = posReq.state;
        if(String.isNotBlank(posReq.zip)) con.MailingPostalCode = posReq.zip;
        if(String.isNotBlank(posReq.country)) con.MailingCountry = posReq.country;
       // if(String.isNotBlank(posReq.country)) con.CountryOfCapture__c = posReq.country;
        if(String.isNotBlank(posReq.emailAddress)) con.Email = posReq.emailAddress;
        if(String.isNotBlank(posReq.phonenumber)) con.Phone = posReq.phonenumber;
        //if(String.isNotBlank(posReq.location)) con.HomeStore__c = posReq.location;
        if(String.isNotBlank(posReq.location)) con.StoreOfCapture__c = posReq.location;
        if(String.isNotBlank(posReq.location)) con.SignupStore__c = posReq.location;
        if(String.isNotBlank(posReq.BirthDate) && (Con.Birthdate != UtilityClass.strYYYMMDDtoDate(posReq.BirthDate))) Con.Birthdate = UtilityClass.strYYYMMDDtoDate(posReq.BirthDate);
        if(String.isNotBlank(posReq.gender)) con.SelfClaimedGender__c = posReq.gender;
        if(String.isNotBlank(posReq.sourceSystem)) {
            con.Source_System__c = posReq.sourceSystem;
            con.Latest_Source__c = posReq.sourceSystem;
        }
       if(String.isNotBlank(posReq.isemployee) && Boolean.valueOf(posReq.isemployee) == true)
           con.isEmployee__c = true;
       else if(String.isNotBlank(posReq.isemployee) && Boolean.valueOf(posReq.isemployee) == false)
           con.isEmployee__c = false;
        
        
        Set<String> locationSet = new Set<String>();
         if(String.isNotBlank(posReq.location) && posReq.brandId=='1'){
         locationSet.add(posReq.location);
           List<StoreMaster__c> storeList=[SELECT Brand__c,ChainId__c,Chain_Name__c,Country__c,IsDeleted,
                                          LastReferencedDate,LastViewedDate,Name,OwnerId,Status__c,StoreNumber__c,StoreUniqueId__c FROM StoreMaster__c
                                          where StoreUniqueId__c In :locationSet AND Brand__c='1'];
         if(storeList.size()>0){     
           for(StoreMaster__c s : storeList) {
                 storeMasterMap.put(s.StoreUniqueId__c, s);
            } 
         }
            system.debug('storeMasterMap***'+storeMasterMap.values()); 
             if (storeMasterMap.size() > 0) { 
                    
                            if (storeMasterMap.get(posReq.location).Country__c != null) con.CountryOfCapture__c = storeMasterMap.get(posReq.location).Country__c;
                        }
          }
        
        
        if(String.isNotBlank(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == true){ 
            system.debug('posReq.emailOptIn****'+posReq.emailOptIn); 
            con.EmailOptInStatus__c='Y';
            if(String.isNotBlank(con.EmailOptInStatus__c)){
                con.EmailOptInDate__c=system.now();
                con.EmailOptOutDate__c=Null;
                con.HasOptedOutOfEmail=false;
            }
       }
        if(String.isNotBlank(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == false ){ 
             system.debug('posReq.emailOptIn****'+posReq.emailOptIn); 
            con.EmailOptInStatus__c='N';
            if(String.isNotBlank(con.EmailOptInStatus__c)){
                con.EmailOptInDate__c=Null;
                con.EmailOptOutDate__c=system.now();
                con.HasOptedOutOfEmail=true;
            }
       } 
        
      if(String.isNotBlank(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == true){            
            setContactEmailOptin(con,(createParent ? false : true));
        }
        if(String.isNotBlank(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == false){            
            setContactEmailOptin(con,(createParent ? false : false));
        }
        System.debug('******createParent = '+createParent);
        
        
        //Loyalty Signup 
        if(String.isNotBlank(posReq.loyaltySignup)) {
            if (Boolean.valueOf(posReq.loyaltySignup) == true) con.LoyaltyFlag__c = true;
            if (con.LoyaltyFlag__c) con.Loyalty_Optin_Date__c = System.now();
        }
        return con;
    }
    
    
     //Update existing Contact details
    Static Contact updateContact(Contact cont,posRequest posReq){
        String addressLine;
        cont.Status__c = 'ACTIVE';
        cont.Primary__c = true;
        
        String searchBrand = posReq.brandId;
        //if records brand is child, assigning brandId with its parent
        if(subbrandParentbrandMap.containsKey(posReq.brandId)){
            searchBrand = subbrandParentbrandMap.get(posReq.brandId);
            
        }
      
        System.debug('***updateContact - searchBrand = '+searchBrand);
        If(String.isNotBlank(posReq.firstName) && (!posReq.firstName.equals(cont.FirstName))) cont.FirstName = posReq.firstName;
        If(String.isNotBlank(posReq.lastName) && (!posReq.lastName.equals(cont.LastName))) cont.LastName = posReq.lastName;
        if(String.isNotBlank(posReq.addressLine1)) addressLine = posReq.addressLine1;
        if(String.isNotBlank(posReq.addressLine2)) addressLine += ' \r\n' + posReq.addressLine2;
        If(String.isNotBlank(addressLine) && (addressLine!=cont.MailingStreet)) cont.MailingStreet = addressLine ;
        If(String.isNotBlank(posReq.city) && (!posReq.city.equals(cont.MailingCity))) cont.MailingCity = posReq.city;
        If(String.isNotBlank(posReq.state) && (!posReq.state.equals(cont.MailingState))) cont.MailingState = posReq.state;
        If(String.isNotBlank(posReq.zip) && (!posReq.zip.equals(cont.MailingPostalCode))) cont.MailingPostalCode = posReq.zip;
        If(String.isNotBlank(posReq.country) && (!posReq.country.equals(cont.MailingCountry))) cont.MailingCountry = posReq.country;
       // if(String.isNotBlank(posReq.country) && (!posReq.country.equals(cont.CountryOfCapture__c))) cont.CountryOfCapture__c = posReq.country;
        //If(String.isNotBlank(posReq.emailAddress) && (!posReq.emailAddress.equals(cont.Email))) cont.Email = posReq.emailAddress;
        If(String.isNotBlank(posReq.phoneNumber) && (!posReq.phoneNumber.equals(cont.Phone))) cont.Phone = posReq.PhoneNumber;
        If(String.isNotBlank(posReq.sourceSystem)) cont.Latest_Source__c  = posReq.sourceSystem;
        if(String.isNotBlank(posReq.BirthDate) && (cont.Birthdate != UtilityClass.strYYYMMDDtoDate(posReq.BirthDate))) cont.Birthdate = UtilityClass.strYYYMMDDtoDate(posReq.BirthDate);
       // If(String.isNotBlank(posReq.location) && (!posReq.location.equals(cont.HomeStore__c))) cont.HomeStore__c = posReq.location;
       If(String.isNotBlank(posReq.location) && (!posReq.location.equals(cont.StoreOfCapture__c))) cont.StoreOfCapture__c = posReq.location;
        
        If(String.isNotBlank(posReq.location) && (String.isBlank(cont.SignupStore__c))){
            cont.SignupStore__c = posReq.location;
        }
       
        if(String.isNotBlank(posReq.isemployee) && Boolean.valueOf(posReq.isemployee) == true && (!posReq.isEmployee.equals(cont.isEmployee__c)))
           cont.isEmployee__c = true;
        else if(String.isNotBlank(posReq.isemployee) && Boolean.valueOf(posReq.isemployee) == false && (!posReq.isEmployee.equals(cont.isEmployee__c)))
           cont.isEmployee__c = false;
        
        Set<String> locationSet = new Set<String>();
         if(String.isNotBlank(posReq.location) && posReq.brandId=='1' && posReq.location==cont.StoreOfCapture__c){
         locationSet.add(posReq.location);
           List<StoreMaster__c> storeList=[SELECT Brand__c,ChainId__c,Chain_Name__c,Country__c,IsDeleted,
                                          LastReferencedDate,LastViewedDate,Name,OwnerId,Status__c,StoreNumber__c,StoreUniqueId__c FROM StoreMaster__c
                                          where StoreUniqueId__c In :locationSet AND Brand__c='1'];
             if(storeList.size()>0){ 
           for(StoreMaster__c s : storeList) {
                 storeMasterMap.put(s.StoreUniqueId__c, s);
            } 
             }
            system.debug('storeMasterMap***'+storeMasterMap.values()); 
             if (storeMasterMap.size() > 0) { 
                    
                            if (storeMasterMap.get(posReq.location).Country__c != null) cont.CountryOfCapture__c = storeMasterMap.get(posReq.location).Country__c;
                        }
          }
        
        
        
       if(String.isNotBlank(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == true){ 
              system.debug('posReq.emailOptIn****'+posReq.emailOptIn);
              if(cont.EmailOptInStatus__c=='Y'){
                 cont.EmailOptInStatus__c='Y';
                // cont.EmailOptInDate__c=system.now();
                 cont.HasOptedOutOfEmail=false;
              }
             else if(cont.EmailOptInStatus__c=='N' || cont.EmailOptInStatus__c==NUll){
                 cont.EmailOptInStatus__c='Y';
                 cont.EmailOptInDate__c=system.now();
                 cont.HasOptedOutOfEmail=false;
             }
         }
         else if(String.isNotBlank(posReq.emailOptIn) && Boolean.valueOf(posReq.emailOptIn) == false){  
              if(cont.EmailOptInStatus__c=='N'){
                 cont.EmailOptInStatus__c='N';
                 cont.EmailOptOutDate__c=system.now();
                 cont.HasOptedOutOfEmail=true;
              }
             else if(cont.EmailOptInStatus__c=='Y'  || cont.EmailOptInStatus__c==NUll){
                 cont.EmailOptInStatus__c='N';
                 cont.EmailOptOutDate__c=system.now();
                 cont.HasOptedOutOfEmail=true;
             }
         }
       
        if(String.isNotBlank(posReq.loyaltySignup)){
            if (Boolean.valueOf(posReq.loyaltySignup) == true && cont.LoyaltyFlag__c == false){ 
				cont.LoyaltyFlag__c = true;
				cont.Loyalty_Optin_Date__c = System.now();
			}
            else if (Boolean.valueOf(posReq.loyaltySignup) == false && cont.LoyaltyFlag__c == true) cont.LoyaltyFlag__c = false;
        }
        return cont;
    }
    
    
    
    
  Static posResponse returnResponse(Boolean existingCont,List<Id> contactID, String brandId,Map<Id, Contact> oldContacts){
       List<Contact> contact=new  List<Contact>();        
        posResponse posRes = new posResponse();
        
        //System.debug('***contactID = '+ContactID);
        //System.debug('***Brand_Id__c = '+brandId);
        if(contactID != null && contactID.size()>0){
            contact = [SELECT Id, LoyaltyId__c,EmailOptInStatus__c,LoyaltyFlag__c,CreatedDate,LastmodifiedDate  FROM Contact WHERE Id IN :contactID AND Brand_Id__c = :brandId];
            
            if(existingCont) 
                if(contact.size()>1){
                     posRes.ContactId = Null;
                     posRes.LoyaltyId = contact[0].LoyaltyId__c; 
                    //NASSC-3326
                     //posRes.CreatedDate = contact[0].LastmodifiedDate;
                }else {
                   posRes.ContactId = contact[0].Id;
                   posRes.LoyaltyId = contact[0].LoyaltyId__c; 
                  //NASSC-3326
                   //posRes.CreatedDate = contact[0].LastmodifiedDate; 
                } else {
                   posRes.ContactId = contact[0].Id;
                   posRes.LoyaltyId = contact[0].LoyaltyId__c; 
                   posRes.CreatedDate = contact[0].CreatedDate;
               }   
                    
                       
        }        
        posRes.code = 'OK'; 
        posRes.message = 'Success'; 
        posRes.ExistingCustomer = String.valueOf(existingCont);        
        
        return posRes;
    
}
    
}