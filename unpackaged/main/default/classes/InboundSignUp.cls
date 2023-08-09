/**
*Json Request
* Inbound API:{"Count":"1","Subscribes":[{"BrandId":"2","SourceSystem":"wifi", "WelcomeSource":"02","Email":"onbou1@yopmail.com","EmailOptinFlag":"true","LoyaltyOptinFlag":"true","SMSOptIn":"false","FirstName":"Inboundwifi","LastName":"testCKUpdatedAgainAgain","address1":"123 Main Street","address2":"","City":"Albany","State":"NY","ZIP":"14810","MailingCountry":"US","Phonenumber":"5555555555","HomePhone":"2222222222","MobilePhone":"5083330304","BirthMonth":"9","BirthDay":"22","Birthyear":"2000","Gender":"M","Region":"US","Country":"US","Market":"New York","preferredLanguage":"English"}]}}
* RAF Payload:{"Count":"1","Subscribes":[{"BrandId":"1","SourceSystem":"Extole","WelcomeSource":"06","Email":"a1@yopmail.com","EmailOptinFlag":"true","LoyaltyOptinFlag":"true","SMSOptIn":"false","FirstName":"Extole1234", "LastName":"testth","address1":"123 Main Street","address2":"Costco","City":"Albany","State":"NY","ZIP":"14810","MailingCountry":"US","Phonenumber":"5555555555","HomePhone":"2222222222","MobilePhone":"5083330304","BirthMonth":"9","BirthDay":"22","Birthyear":"2000","Gender":"M","Region":"US","Country":"US","Market":"New York","preferredLanguage":"E"}]}
*  https://instance.salesforce.com/services/apexrest/subscribers/SignUps
*  POD1-79,POD1-14
**/

@RestResource(urlMapping='/subscribers/SignUps')
global without sharing class InboundSignUp {
    
    private static Id contactEmailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId(); 
    private static Map<String,String> mapSubbrandParentbrand = new Map<String,String>();    
    private static Map<Id,Contact> accIdsToContact = new Map<Id,Contact>();
    
    global class signupRequest{
        public string count;
        public List<Subscriber> Subscribes;        
    }
    
    global class Subscriber{
        public string brandId;
        public string sourceSystem;
        public string welcomeSource;
        public string email;
        public string emailOptinFlag;
        public string loyaltyOptinFlag;
       // public string smsOptIn;
        public string firstName;
        public string lastName;
     /* public string address1;
        public string address2;
        public string city;
        public string state;
        public string zip;
        public string phonenumber;
        public string homePhone;
        public string mobilePhone;
        public String birthDate;
        public string birthMonth;
        public string birthDay;
        public string birthyear;
        public string gender;*/
        public string Country;
        public string region;
        public string market;
        public string preferredLanguage;
    } 
    
    
    global class signupResponse{
        public List<Subscribes> Subscribes;
        public Integer count;
    }
    
    
    global class Subscribes{
        public Integer StatusCode;
        public String Code;
        public String Message;
        public String ContactId;
        public String LoyaltyId;
        public String ExistingCustomer;
     }
    
  
    @HttpPost 
    global static signupResponse doSignUp(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String requestData = req.requestBody.toString();
        List<Contact> insertParentBrandContacts = new List<Contact>();//insert parent brand contact
        List<Contact> insertSubBrandContacts = new List<Contact>();//insert sub brand contact
        Boolean createParent = false;
        List<Contact> searchedParentContactList = new List<Contact>();
        //Converting JSON Payload into Apex class
        signupRequest signupRequestPayload = (signupRequest)JSON.deserialize(requestData,signupRequest.class);
        signupRequest subReq = removeDuplicate(signupRequestPayload);
        Set<String> BrandIds = new Set<String>(); 
        Set<String> EmailAddresses = new Set<String>();
        String sourceSystem;
        List<Contact> brandEmailContacts = new List<Contact>();  
        List<Contact> brandLoyaltyContacts = new List<Contact>();  
        Map<String,Map<String,Contact>> BrandToEmailContactMap = new Map <String,Map<String,Contact>>(); //mapping brand+email to contact
        Map<string,Contact> loyaltyToContactMap = new Map<string,Contact>();
        signupResponse errorResponse = new signupResponse();
        String errorMessage = ' ';
        Boolean existingCont = false;
        Boolean newCont = false;
        List<ID> contactID = new List<ID>();
        List<Subscribes> subsList = new List<Subscribes>();
        List<Subscribes> subsListAll = new List<Subscribes>();
        List<Contact> profileUpdateContacts = new List <Contact>();
        List<Contact> newContacts = new List<Contact>();
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>(); 
        Boolean isError = false;
        
        for(Subscriber sub : signupRequestPayload.Subscribes) {
           //validating input paramerters which are required
            if(String.isEmpty(sub.brandId) || String.isEmpty(sub.email) || String.isEmpty(sub.sourceSystem) || String.isEmpty(sub.Country)||
               String.isBlank(sub.brandId) || String.isBlank(sub.email) || String.isBlank(sub.sourceSystem) || String.isBlank(sub.Country)){
                   isError = true;
                   break;
               }
         
                if(String.isNotEmpty(sub.BrandId)) BrandIds.add(sub.BrandId);
                if(String.isNotEmpty(sub.Email)) EmailAddresses.add(sub.Email);
                if(String.isNotEmpty(sub.sourceSystem)) sourceSystem = sub.sourceSystem;
            
        }
        if (isError) {
            res.statusCode = 400;
            Subscribes sub = new Subscribes();
            sub.StatusCode = 400;
            sub.Code = 'INVALID_QUERY';
            sub.Message = 'FAILURE:Missing BrandId or EmailId or Source System or Country';
            subsList.add(sub);
            errorResponse.subscribes = subsList;
            errorResponse.count = subsList.size();
            return errorResponse;
        } 
        //populate map of subBrand,parentBrand            
        List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c from LoyaltySettings__mdt];
        for(LoyaltySettings__mdt loyalRecord : loyaltyList){
            if(loyalRecord.Parent_Brand__c != null){
                mapSubbrandParentbrand.put(loyalRecord.BrandId__c,loyalRecord.Parent_Brand__c);
            }
        }
        
        System.debug(BrandIds+''+EmailAddresses);
        if (!BrandIds.isEmpty() && !EmailAddresses.isEmpty()){
            brandEmailContacts = [SELECT Id, FirstName, MiddleName, LastName,Latest_Source__c,WelcomeSource__c,Market_ds__c,Country_ds__c,Region_ds__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, Company_Code__c,
                                  Brand_Id__c, MailingCountry, Email, Phone, HomePhone, MobilePhone, Birthdate,  HomeStore__c, LoyaltyID__c, External_Id__c, Customer_Id__c,
                                  StoreOfCapture__c, Source_System__c,Ecomm_Connected__c, LoyaltyFlag__c, EmailOptInDate__c, AccountId, EmailOptInStatus__c, Loyalty_Optin_Date__c, PVHCreatedDate__c, PrefCenterInterests__c, Source__c,SelfClaimedGender__c
                                  FROM Contact
                                  WHERE Brand_Id__c IN :BrandIds and Email IN :EmailAddresses order by Ecomm_Connected__c DESC, LastmodifiedDate DESC];
        }
        
        Log.push('loyaltyToContactMap : '+loyaltyToContactMap);
        system.debug('brandEmailContacts***'+brandEmailContacts);
        if (!brandEmailContacts.isEmpty()) {            
             for (Contact beCon : brandEmailContacts){
                Map <String,Contact> emailToContactMap = new Map<String,Contact>();
                if (BrandToEmailContactMap.containsKey(beCon.Brand_Id__c)) BrandToEmailContactMap.get(beCon.Brand_Id__c).put(beCon.Email,beCon);
                else {
                    emailToContactMap.put(beCon.Email,beCon);
                    BrandToEmailContactMap.put(beCon.Brand_Id__c, emailToContactMap);
                } 
            }
        }
        system.debug(BrandToEmailContactMap);

        
        for (Subscriber sub : subReq.Subscribes) {
            Log.push('entered into for loop');
            system.debug('entered into for loop***');
            Contact thisContact;
         if (BrandToEmailContactMap.size()>0 && BrandToEmailContactMap.containsKey(sub.BrandId) && BrandToEmailContactMap.get(sub.BrandId).containsKey(sub.Email.toLowerCase())) {
              thisContact = BrandToEmailContactMap.get(sub.BrandId).get(sub.Email.toLowerCase());
                 system.debug('thisContact***'+thisContact);
                      if(thisContact != Null){
						  existingCont = true;
						  profileUpdateContacts.add(updateContact(thisContact,sub,sub.BrandId,existingCont));
						  
					  }
            }else { 
                    system.debug('entered into for loop***');
                      Contact newParentContact = new Contact(); 
                 system.debug('newParentContact***'+newParentContact); 
                        createParent = false;
                        existingCont = false;						
                        profileUpdateContacts.add(createContact(newParentContact,Sub,sub.BrandId,existingCont));
                        system.debug('profileUpdateContacts***'+profileUpdateContacts); 
                    }         
           }
            
        
        //Log.push('***SIZE profileUpdateContacts = '+profileUpdateContacts.size());
        Log.push('***profileUpdateContacts = '+profileUpdateContacts);
        system.debug('profileUpdateContacts*****'+profileUpdateContacts);
        List <contact> allContacts = new List<contact>(); 
        if (!profileUpdateContacts.isEmpty()) {
             for(Contact c : profileUpdateContacts){
                //if(c.id != null ) {
                    allContacts.add(c);
                    if(String.isNotBlank(c.AccountId))  accIdsToContact.put(c.AccountId, c);
               // }
            }
        }
        
        system.debug('allContacts****'+allContacts);
         if (allContacts.size() > 0){
          system.debug('**Inside UpdateContact**'+allContacts);
            upsert allContacts;
        } 

            Log.push('^^^accIdsToContact = '+accIdsToContact);
            //ContactUtility.createErrorLogRecords(srList,profileUpdateContacts[0].Latest_Source__c,FileName);
            
            //updating Accounts for corresponding contacts
            List<Account> listAccountsToUpdate = getAccountsToUpdate();
            if(!listAccountsToUpdate.isEmpty()){
                //Log.push('^^^listAccountsToUpdate = '+listAccountsToUpdate);
                Database.SaveResult[] srListAcc = Database.update(listAccountsToUpdate, false);
              //  ContactUtility.createErrorLogRecords(srListAcc,profileUpdateContacts[0].Latest_Source__c,FileName);
            }
            
             
      
		
		for(contact finalRes : allContacts){
                    Subscribes sub = new Subscribes();
                    sub.StatusCode = 200;
                    sub.Code = ' OK';
                    sub.Message = 'Success';
                    sub.ContactId = finalRes.Id;
                    sub.LoyaltyId = finalRes.LoyaltyId__c;
                    sub.ExistingCustomer =String.valueOf(finalRes.IsExisting__c);
                    subsList.add(sub);
                    system.debug('subsList>>>>>>>>>>'+subsList);
                    signUpActivityList.add(SignUpActivity.signupActivity(finalRes.Id, finalRes.Latest_Source__c,finalRes.Brand_Id__c));
               
            }  
		
		
        
        
         signupResponse genRes = new signupResponse();
        
        Logger.logDebug();
        system.debug('****');
        //Response status
        genRes.subscribes = subsList;
        genRes.count=Integer.valueOf(signupRequestPayload.count);
        genRes.count = subsList.size();
        res.statusCode = 200;
        //genRes.subscribes = subsList;
        return genRes;
    }

    //Creating or updating contact details based on payload
    private static Contact createContact(Contact newCon,Subscriber sub,String brandId,boolean existingCont) {
        system.debug('**Inside NewContact**');
        newCon.createdByMethod__c = 'API';
        newCon.RecordTypeId = contactEmailRecordTypeId;
        newCon.Status__c = 'ACTIVE';
         newCon.IsExisting__c=false;
        if (String.isNotBlank(brandId)) newCon.Brand_Id__c = brandId;
        if (String.isNotBlank(sub.firstName)) newCon.FirstName = sub.firstName; else newCon.FirstName = 'Unknown';
        if(String.isNotBlank(sub.lastName)){ newCon.LastName = sub.lastName; }
        else if(String.isBlank(sub.lastName) || String.valueOf(sub.lastName) == '') newCon.LastName = 'Unknown';
      /*  if (String.isNotBlank(sub.address1) && String.isNotBlank(sub.address2)){
            newCon.MailingStreet = sub.address1 + '\n' + sub.address2;
        }else if(String.isNotBlank(sub.address1)){
            newCon.MailingStreet = sub.address1;
        }
        newCon.MailingCity = sub.City;
        newCon.MailingState = sub.State;
        newCon.MailingPostalCode = sub.ZIP;
        if (String.isNotBlank(sub.Country)) newCon.MailingCountry = sub.Country;
        newCon.Phone = sub.phonenumber;
        newCon.HomePhone = sub.HomePhone;
        newCon.MobilePhone = sub.MobilePhone;*/
         if (String.isNotBlank(sub.email)) newCon.Email = sub.email;
        newCon.WelcomeSource__c = sub.welcomeSource;
        if(sub.preferredLanguage == 'English'){
            newCon.Language__c = 'E';
        }else if(sub.preferredLanguage == 'French'){
            newCon.Language__c = 'F';  
        }else{
            newCon.Language__c =sub.preferredLanguage;
        }
        //Checking Birth Day, Month and Year from payload
      /*  if(String.isNotEmpty(sub.birthDay) && String.isNotEmpty(sub.birthMonth) && String.isNotEmpty(sub.birthYear) ){
            newCon.Birthdate = Date.newInstance(integer.valueOf(sub.birthYear),integer.valueOf(sub.birthMonth),integer.valueOf(sub.birthDay));
        } //Converting Birth Date from Payload to date format
        else if(String.isNotBlank(sub.BirthDate) && (newCon.Birthdate != UtilityClass.strYYYMMDDtoDate(sub.BirthDate))){
            newCon.Birthdate = UtilityClass.strYYYMMDDtoDate(sub.birthDate);
        }*/
        newCon.Market_ds__c = sub.market; 
        newCon.Region_ds__c = sub.region; 
        newCon.Country_ds__c = sub.Country;
        if(String.isBlank(sub.SourceSystem)) {
            newCon.Source_System__c = sub.SourceSystem;
        }
        if(String.isNotBlank(sub.SourceSystem)) {
            newCon.Latest_Source__c = sub.SourceSystem;
        }
        String subLoyaltyOptinValue='N';
        if (String.isNotBlank(sub.LoyaltyOptinFlag) && Boolean.valueOf(sub.LoyaltyOptinFlag)) {
            subLoyaltyOptinValue = 'Y';
        }
        if(subLoyaltyOptinValue=='Y') {
            newCon.LoyaltyFlag__c = Boolean.valueOf(sub.LoyaltyOptinFlag); 
            newCon.Loyalty_Optin_Date__c = system.now();
        }
       /* if (String.isNotBlank(sub.smsOptIn) && Boolean.valueOf(sub.smsOptIn)) {
            newCon.SMSOptinStatus__c = 'Y';
            newCon.SMSOptInDate__c = System.now();
            if (String.isNotBlank(sub.MobilePhone)) newCon.SMSNumber__c = sub.MobilePhone;
            if (String.isNotBlank(sub.Country)) newCon.SMSLocale__c = sub.Country;
        }*/
        String subEmailOptinValue='N';
        if(String.isNotBlank(sub.EmailOptinFlag) && Boolean.valueOf(sub.EmailOptinFlag)) {
            subEmailOptinValue= 'Y';
        }
        
        //if(String.isNotBlank(sub.SourceSystem)) 
           // subEmailOptinValue= 'Y';
        if(subEmailOptinValue=='Y') {
            newCon.EmailOptInStatus__c = subEmailOptinValue;
            newCon.EmailOptInDate__c = System.now();
            newCon.HasOptedOutOfEmail = false;            
        } else if(subEmailOptinValue=='N'){
            newCon.EmailOptInStatus__c = 'N';
            newCon.EmailOptOutDate__c=system.now();
            newCon.HasOptedOutOfEmail=true;
        }
        /*if(string.isEmpty(newCon.Id)){
            /if(createParent){
                newCon.EmailOptInStatus__c = 'N';
                newCon.EmailOptOutDate__c=system.now();
                newCon.EmailOptInDate__c=Null;
                newCon.HasOptedOutOfEmail=true;
            //}
        }*/
        if(String.isNotBlank(sub.SourceSystem)){
            String searchBrand = sub.BrandId;
            if(mapSubbrandParentbrand.containsKey(sub.BrandId)){
                searchBrand = mapSubbrandParentbrand.get(sub.BrandId);
            }
            //Matching of Brand Details against SubscriberDataSources object
            List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, 
                                                               WelcomeSource__c,DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c=:searchBrand AND
                                                               SourceSystem__c=:sub.SourceSystem];
            
            if (listDataSource.size()>0){
                newCon.EmailOrigSource__c = listDataSource[0].DataSource__c;
                newCon.Source__c = listDataSource[0].DataSource__c;
            }  
        }
        
        Logger.logDebug();
      //  if(String.isNotBlank(sub.Gender) && (newCon.SelfClaimedGender__c != sub.Gender)) newCon.SelfClaimedGender__c = sub.Gender;
        return newCon;
    }
    
     ////Existing conact Update 
     private static Contact updateContact(Contact Con,Subscriber sub,String brandId,boolean existingCont){
         system.debug('**Inside UpdateContact**');
        Con.Status__c = 'ACTIVE';
          Con.IsExisting__c=true;
        if(String.isNotBlank(sub.brandId) && (Con.Brand_ID__c != sub.brandId)) Con.Brand_ID__c = sub.brandId;
        //if(String.isNotBlank(sub.email) && (Con.Email != sub.email)) Con.Email = sub.email;
         if(String.isNotBlank(sub.firstName) && (Con.FirstName != sub.firstName)){
               Con.FirstName = sub.firstName;
         }
         
        
         if(String.isNotBlank(sub.lastName) && (Con.LastName != sub.lastName)){ 
                 Con.LastName = sub.lastName;
         }
         
        
        if(String.isNotBlank(sub.welcomeSource) && (Con.WelcomeSource__c != sub.welcomeSource)) Con.WelcomeSource__c = sub.welcomeSource;
        
        
        if(String.isNotBlank(sub.market) && (Con.Market_ds__c != sub.market))Con.Market_ds__c = sub.market; 
        if(String.isNotBlank(sub.region) && (Con.Region_ds__c != sub.region))Con.Region_ds__c = sub.region; 
        if(String.isNotBlank(sub.Country) && (Con.Country_ds__c != sub.Country))Con.Country_ds__c = sub.Country; 
        
        //Source System 
        if(String.isNotBlank(sub.SourceSystem)) {
             con.Latest_Source__c = sub.SourceSystem;
        
        }
        List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, 
                                                               WelcomeSource__c,DataSource__c
                                                               FROM SubscriberDataSources__mdt
                                                               WHERE Brand__c=:brandId AND
                                                               SourceSystem__c=:sub.SourceSystem AND WelcomeSource__c=:sub.welcomeSource];
        if (listDataSource.size()>0){
                Con.Source__c = listDataSource[0].DataSource__c;
       }  
             
       If(String.isNotBlank(sub.LoyaltyOptinFlag) && (Con.LoyaltyFlag__c != Boolean.valueOf(sub.LoyaltyOptinFlag)) && Con.LoyaltyFlag__c !=True){
                Con.LoyaltyFlag__c = Boolean.valueOf(sub.LoyaltyOptinFlag);
                Con.Loyalty_Optin_Date__c=System.Today();
            }
            
        
        if(String.isNotBlank(sub.emailOptinFlag) && Boolean.valueOf(sub.emailOptinFlag) == true && con.EmailOptInStatus__c!='Y'){ 
            con.EmailOptInStatus__c='Y';
            con.EmailOptInDate__c=system.now();
            con.HasOptedOutOfEmail=false;
            }
       
        if(String.isNotBlank(sub.emailOptinFlag) && Boolean.valueOf(sub.emailOptinFlag) == false && con.EmailOptInStatus__c!='N'){ 
             con.EmailOptInStatus__c='N';
             con.EmailOptOutDate__c=system.now();
             con.HasOptedOutOfEmail=true;
            }
      Logger.logDebug();
       return Con;
    }
    
    /*
    * Name : removeDuplicate
    * Description: removing of duplicate data from payload
    */ 
    public static signupRequest removeDuplicate(signupRequest inputRequest){
        Map<String,Subscriber> mapSubscriber = new Map<String,Subscriber>();
        List<Subscriber> listSubscriber = new List<Subscriber>();
        signupRequest subObject = new signupRequest();
        for(Subscriber inputSub : inputRequest.Subscribes){
            if(String.isNotBlank(inputSub.BrandId) && String.isNotBlank(inputSub.Email)){
                mapSubscriber.put(inputSub.BrandId+(inputSub.Email).toLowercase(),inputSub);
            }
            else if(String.isNotBlank(inputSub.BrandId) && String.isNotBlank(inputSub.email)){
                mapSubscriber.put(inputSub.BrandId+(inputSub.email).toLowercase(),inputSub);
            }
        }
        for(Subscriber subInput : mapSubscriber.values()){
            listSubscriber.add(subInput);
        }
        subObject.Count = String.valueOf(mapSubscriber.size());
        subObject.Subscribes = new List<Subscriber>();
        subObject.Subscribes.addAll(listSubscriber);
        return subObject;
    }
    
    /*
    * Name : getAccountsToUpdate
    * Description : Updating of gender on Account based on SelfClaimedGender
    */ 
    public static List<Account> getAccountsToUpdate(){
        List<Account> listUpdAccounts = new List<Account>();
        List<Account> listAccounts = [Select Id, Gender__c from Account where Id IN:accIdsToContact.keySet()];
        for(Account acc : listAccounts){
            if(accIdsToContact.containsKey(acc.Id)){
                if(acc.Gender__c != accIdsToContact.get(acc.Id).SelfClaimedGender__c){
                    acc.Gender__c = accIdsToContact.get(acc.Id).SelfClaimedGender__c;
                    listUpdAccounts.add(acc);
                }
            }
        }
        return listUpdAccounts;
    }
    
    /* Name : fetchExistingContact
    * Description : fetching contact details based on brand Id and email address
    */ 
    public static List<contact> fetchExistingContact(Set<String> brandIdSet,Set<String> emailAddressSet){
        List<Contact> existingContactList = new List<Contact>();
        existingContactList = [SELECT Id,AccountId,FirstName,MiddleName,LastName,MailingStreet,MailingCity, MailingState,MailingPostalCode,Company_Code__c,
                               Brand_Id__c,MailingCountry,Email,Phone,HomePhone,MobilePhone,Birthdate,HomeStore__c,LoyaltyID__c,External_Id__c,Customer_Id__c,
                               StoreOfCapture__c,Source_System__c,Ecomm_Connected__c,LoyaltyFlag__c,EmailOptInDate__c,EmailOptInStatus__c,Loyalty_Optin_Date__c, 
                               PVHCreatedDate__c,PrefCenterInterests__c,Source__c,SelfClaimedGender__c,Latest_Source__c
                               FROM Contact 
                               WHERE Brand_Id__c IN:brandIdSet AND Email IN:emailAddressSet
                               AND RecordTypeId=:contactEmailRecordTypeId order by Ecomm_Connected__c DESC, LastmodifiedDate DESC LIMIT 1];
       
        system.debug('existingContactList::::::::::::: '+existingContactList);
        return existingContactList;
    }
    
    /*
    * Name : getSubToParentBrandDetails
    * Description : matching sub brand to parent brand based on loyalty settings
    */ 
    
    public static Map<String,String> getSubToParentBrandDetails(){
        Map<String,String> subToParentBrandMap = new Map<String,String>();
        List<LoyaltySettings__mdt> loyaltySettingsList = [SELECT Id,BrandId__c,Parent_Brand__c FROM LoyaltySettings__mdt];
        for(LoyaltySettings__mdt loyaltySettings : loyaltySettingsList){
            if(string.isNotEmpty(loyaltySettings.Parent_Brand__c)){
                subToParentBrandMap.put(loyaltySettings.BrandId__c,loyaltySettings.Parent_Brand__c);
            }
        }
        return subToParentBrandMap;
    }
    
    /*
    * Name : brandLoyaltySettings
    * Description : matching brandId to loyalty settings
    */ 
    public static Map<String,LoyaltySettings__mdt> brandLoyaltySettings(Set<String> brandIdSet){
        Map<String,LoyaltySettings__mdt> loyaltySettingsMap = new Map<String,LoyaltySettings__mdt>();
        List<LoyaltySettings__mdt> loyaltySettingList = [SELECT Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c 
                                                         FROM LoyaltySettings__mdt 
                                                         WHERE BrandId__c IN:brandIdSet AND BrandId__c!=''];
        system.debug('loyaltySettingList:: '+loyaltySettingList);
        if(!loyaltySettingList.isEmpty()){
            for(LoyaltySettings__mdt loyaltySettings: loyaltySettingList){
                loyaltySettingsMap.put(loyaltySettings.BrandId__c,loyaltySettings);
            }
        }
        return loyaltySettingsMap;
    }
}