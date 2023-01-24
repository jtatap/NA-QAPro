/* * 
*  Json Request
*  {"Count":"2","Subscribers":[{"BrandId":"2","SubscriberKey":"","FirstName":"John",LastName":"Doe","Street":"123 Main Street","City":"Albany","State":"NY","ZIP":"14810","Country":"US","Email":"test@pvh.com","PrimaryPhone":"5555555555","HomeStore":"CO601","StoreOfCapture":"CO601","SourceSystem":"CP","LoyaltyId":"",},{"BrandId":"2",...}]}
* 
*  https://instance.salesforce.com/services/apexrest/A1subscribers/Update
* */

 @RestResource(urlmapping='/A1subscribers/Update')
global without sharing class A1CustomerProfileUpdate {
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId(); 
    static Map<Id,Contact> accIdsToContact = new Map<Id,Contact>();
    
    global class SubRequest {
        public String Count;
        public List<Subscriber> Subscribers;
        public String FileName;
    }    
    global class Subscriber {
        public String BrandId;
        public String SubscriberKey;  
        public String FirstName;
        public String LastName;
        public String Street;
        public String City;
        public String State;
        public String Zip;
        public String Country;
        public String Email;
        public String PrimaryPhone;  
        public String HomeStore;
        public String StoreOfCapture;
        public String SourceSystem;
        public String LoyaltyId;
      }
    
    global class SubResponse{
        public String Code;
        public String Count;
        public List<Subscribers> Subscribers;
        public String Message;
    }
    
    global class Subscribers{
        public String ContactId;
     }
   @HttpPost 
    global static SubResponse doUpdate(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String requestData = req.requestBody.toString();
        
        List<Contact> newBrandContacts = new List<Contact>();
        LoyaltySettings__mdt loyaltySetting;
        
        Set <Id> SubsriberKeys = new Set<Id>();
        Set <String> BrandIds = new Set<String>(); 
        Set <String> EmailAddresses = new Set<String>();
        Map <Id,Contact> existingSubkeyContactMap;
        List <Contact> brandEmailContacts = new List<Contact>();        
        Map <String,Map<String,Contact>> BrandToEmailContactMap = new Map <String,Map<String,Contact>>();        
        SubResponse errorResponse = new SubResponse();
        Boolean isError = false;
        Boolean createNew = false;
        List <Contact> profileUpdateContacts = new List <Contact>();
        List <Contact> newContacts = new List<Contact>();
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();
        
        
       SubRequest subReqReceived = (SubRequest)JSON.deserialize(requestData,SubRequest.class);
       System.debug('***subReqReceived = '+subReqReceived);
       SubRequest subReq = removeDuplicate(subReqReceived);
       system.debug('subReq**'+subReq);
        
       if (subReq.Subscribers.size()==0) isError = true; 
       String FileName =    subReq.FileName;
        
       for (Subscriber sub : subReq.Subscribers) {
            
            if (String.isEmpty(sub.BrandId) || String.isEmpty(sub.Email)) {
                isError = true;
                break;
            }
            if (String.isNotEmpty(sub.SubscriberKey)) SubsriberKeys.add(Id.valueOf(sub.SubscriberKey));
            else {
                if (String.isNotEmpty(sub.BrandId)) BrandIds.add(sub.BrandId);
                if (String.isNotEmpty(sub.Email)) EmailAddresses.add(sub.Email);
            } 
        } 
        
        if (isError) {
            res.statusCode = 400;
            errorResponse.code = 'INVALID_QUERY';
            errorResponse.Message = 'Missing required parameters:  BrandId or email';
            return errorResponse;
        }   
        
        if (!SubsriberKeys.isEmpty()) {
            existingSubkeyContactMap = 
            new Map<Id,Contact>([SELECT Id, FirstName, MiddleName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, Company_Code__c,
                                 Brand_Id__c, MailingCountry,Latest_Source__c, Email, Phone, HomePhone, MobilePhone, Birthdate,  HomeStore__c, LoyaltyID__c, External_Id__c, Customer_Id__c,
                                 StoreOfCapture__c, Source_System__c, LoyaltyFlag__c, EmailOptInDate__c, EmailOptInStatus__c, Loyalty_Optin_Date__c, PVHCreatedDate__c, PrefCenterInterests__c,Source__c, SelfClaimedGender__c,AccountId
                                 FROM Contact
                                 WHERE Id IN :SubsriberKeys]);
        }
         if (!BrandIds.isEmpty() || !EmailAddresses.isEmpty()){
            brandEmailContacts = [SELECT Id, FirstName, MiddleName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, Company_Code__c,
                                  Brand_Id__c, MailingCountry,Latest_Source__c, Email, Phone, HomePhone, MobilePhone, Birthdate,  HomeStore__c, LoyaltyID__c, External_Id__c, Customer_Id__c,
                                  StoreOfCapture__c, Source_System__c, LoyaltyFlag__c, EmailOptInDate__c, AccountId, EmailOptInStatus__c, Loyalty_Optin_Date__c, PVHCreatedDate__c, PrefCenterInterests__c, Source__c,SelfClaimedGender__c
                                  FROM Contact
                                  WHERE RecordTypeId = :emailRecordTypeId and Brand_Id__c IN :BrandIds and Email IN :EmailAddresses order by Brand_Id__c, Email];
        }
        if(!brandEmailContacts.isEmpty()) {            
            for (Contact beCon : brandEmailContacts){
                Map <String,Contact> emailToContactMap = new Map<String,Contact>();
                if (BrandToEmailContactMap.containsKey(beCon.Brand_Id__c)) BrandToEmailContactMap.get(beCon.Brand_Id__c).put(beCon.Email,beCon);
                else {
                    emailToContactMap.put(beCon.Email,beCon);
                    BrandToEmailContactMap.put(beCon.Brand_Id__c, emailToContactMap);
                } 
            }
        }
        
        for (Subscriber sub : subReq.Subscribers) {
            Contact thisContact;
            if (String.isNotEmpty(sub.SubscriberKey)){ 
                thisContact =  existingSubkeyContactMap.get(sub.SubscriberKey); 
                if(thisContact != Null) profileUpdateContacts.add(updateContact(thisContact, sub));                
            }else { 
                if (BrandToEmailContactMap.containsKey(sub.BrandId) && BrandToEmailContactMap.get(sub.BrandId).containsKey(sub.Email.toLowerCase())) {
                    thisContact = BrandToEmailContactMap.get(sub.BrandId).get(sub.Email.toLowerCase());
                    if(thisContact != Null) profileUpdateContacts.add(updateContact(thisContact, sub));
                } else {                     
                    //Contact not found
                    List<LoyaltySettings__mdt> listLoyaltySettingList = [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c from LoyaltySettings__mdt where BrandId__c = :sub.BrandId ];
                    if(listLoyaltySettingList.size()>0) loyaltySetting = listLoyaltySettingList[0];
                    if(loyaltySetting != null && String.isEmpty(loyaltySetting.Parent_Brand__c)){
                        Contact newContact = new Contact(); 
                        createNew = false;
                        newBrandContacts.add(createContact(newContact,sub,sub.BrandId, createNew));
                    }
    }
            }
        }
        
         List <contact> allContacts = new List<contact>(); 
        if (!profileUpdateContacts.isEmpty()) {
            Database.SaveResult[] srList = Database.update(profileUpdateContacts, false);
            for(Contact c : profileUpdateContacts){
                if(c.id != null ) {
                    allContacts.add(c);
                    if(String.isNotBlank(c.AccountId))  accIdsToContact.put(c.AccountId, c);
                }
            }
           ContactUtility.createErrorLogRecords(srList,profileUpdateContacts[0].Latest_Source__c,FileName);
            
            //updating Accounts for corresponding contacts
            List<Account> listAccountsToUpdate = getAccountsToUpdate();
            if(!listAccountsToUpdate.isEmpty()){
                 Database.SaveResult[] srListAcc = Database.update(listAccountsToUpdate, false);
                ContactUtility.createErrorLogRecords(srListAcc,profileUpdateContacts[0].Latest_Source__c,FileName);
            }
        }
        
        if (!newBrandContacts.isEmpty()) {
             List<Database.SaveResult> srList = Database.insert(newBrandContacts, false);
            integer newBrandContactsSize = newBrandContacts.size();
            for(integer i=0; i<newBrandContactsSize; i++){
             if(newBrandContacts[i].LastName!=null){
                allContacts.add(newBrandContacts[i]); 
              }
            }
                      
            ContactUtility.createErrorLogRecords(srList,newBrandContacts[0].Latest_Source__c,FileName);
        }
       
       SubResponse SuccessResponse = new SubResponse(); 
       List<Subscribers> subsList = new List<Subscribers>();
        
      for(Contact con : allContacts){
            Subscribers sub = new Subscribers();
            sub.ContactId = con.Id;
            subsList.add(sub);
            signUpActivityList.add(SignUpActivity.signupActivity(con.Id, con.Latest_Source__c,con.Brand_Id__c));
        }        
        
        
       SuccessResponse.Code = 'OK';
       SuccessResponse.Count = String.valueOf(subsList.size());
        SuccessResponse.Message ='Success';
       SuccessResponse.subscribers = subsList;
       res.statusCode = 200;
       return SuccessResponse; 
    }
   
    
    Static List<Contact> searchContacts(String brandId,String SubscriberKey,String emails,Id emailRecordTypeId){
      
        if(SubscriberKey!=Null){
          List<Contact> searchedContactList =  [SELECT Id, FirstName, LastName, Brand_Id__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                              Phone, MobilePhone, MailingCountry, Email, HomePhone, Birthdate, HomeStore__c, AccountId,  
                                              LoyaltyID__c, Latest_Source__c, EmailOptInStatus__c, SMSOptinStatus__c, LoyaltyFlag__c, ReportsToId, Source__c,SelfClaimedGender__c
                                              FROM Contact 
                                              WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c =:brandId AND Email = :emails AND Id=:SubscriberKey];  
            return ((searchedContactList!=null)?searchedContactList:Null);
        }
        else{
             List<Contact> searchedContactList =  [SELECT Id, FirstName, LastName, Brand_Id__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                              Phone, MobilePhone, MailingCountry, Email, HomePhone, Birthdate, HomeStore__c, AccountId,  
                                              LoyaltyID__c, Latest_Source__c, EmailOptInStatus__c, SMSOptinStatus__c, LoyaltyFlag__c, ReportsToId, Source__c,SelfClaimedGender__c
                                              FROM Contact 
                                              WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c =:brandId AND Email = :emails];
            return ((searchedContactList!=null)?searchedContactList:Null);
        }
    
       
        
        
    }
    
    private static Contact updateContact(Contact Con, Subscriber sub){
        Con.Status__c = 'ACTIVE';
        
        if(String.isNotBlank(sub.FirstName) && (Con.FirstName != sub.FirstName)) Con.FirstName = sub.FirstName;
        if(String.isNotBlank(sub.LastName) && (Con.LastName != sub.LastName)) Con.LastName = sub.LastName;
        if(String.isNotBlank(sub.Street) && (Con.MailingStreet != sub.Street)) Con.MailingStreet = sub.Street;
        if(String.isNotBlank(sub.City) && (Con.MailingCity != sub.City)) Con.MailingCity = sub.City;
        if(String.isNotBlank(sub.State) && (Con.MailingState != sub.State)) Con.MailingState = sub.State;
        if(String.isNotBlank(sub.ZIP) && (Con.MailingPostalCode != sub.ZIP)) Con.MailingPostalCode = sub.ZIP;
        if(String.isNotBlank(sub.Country) && (Con.MailingCountry != sub.Country)) Con.MailingCountry = sub.Country;
        if(String.isNotBlank(sub.PrimaryPhone) && (Con.Phone != sub.PrimaryPhone)) Con.Phone = sub.PrimaryPhone;
        if(String.isNotBlank(sub.HomeStore) && (Con.HomeStore__c != sub.HomeStore)) Con.HomeStore__c = sub.HomeStore;
        if(String.isNotBlank(sub.StoreOfCapture) && (Con.StoreOfCapture__c != sub.StoreOfCapture)) Con.StoreOfCapture__c = sub.StoreOfCapture;
        if(String.isNotBlank(sub.SourceSystem)) con.Latest_Source__c = sub.SourceSystem;
        if(String.isNotBlank(sub.LoyaltyId) && (Con.LoyaltyId__c != sub.LoyaltyId)) Con.LoyaltyId__c = sub.LoyaltyId;
        
        return Con;
    }
                                             
      private static Contact createContact(Contact newCon, Subscriber sub, String brandId, Boolean createNew) {
        newCon.createdByMethod__c = 'API';
        newCon.RecordTypeId = emailRecordTypeId;
        newCon.Status__c = 'ACTIVE';
        if (String.isNotBlank(sub.LoyaltyId)) newCon.LoyaltyId__c = sub.LoyaltyId;
        if (String.isNotBlank(brandId)) newCon.Brand_Id__c = brandId;
        if (String.isNotBlank(sub.FirstName)) newCon.FirstName = sub.FirstName; else newCon.FirstName = 'Unknown';
        if (String.isNotBlank(sub.LastName)) newCon.LastName = sub.LastName; else newCon.LastName = 'Unknown';
        if (String.isNotBlank(sub.Street)) newCon.MailingStreet = sub.Street;
        if (String.isNotBlank(sub.City)) newCon.MailingCity = sub.City;
        if (String.isNotBlank(sub.State)) newCon.MailingState = sub.State;
        if (String.isNotBlank(sub.ZIP)) newCon.MailingPostalCode = sub.ZIP;
        if (String.isNotBlank(sub.Country)) newCon.MailingCountry = sub.Country;
        if (String.isNotBlank(sub.Email)) newCon.Email = sub.Email;
        if (String.isNotBlank(sub.PrimaryPhone)) newCon.Phone = sub.PrimaryPhone;
        if (String.isNotBlank(sub.HomeStore)) newCon.HomeStore__c = sub.HomeStore;
        if (String.isNotBlank(sub.StoreOfCapture)) newCon.StoreOfCapture__c = sub.StoreOfCapture;
        if (String.isNotBlank(sub.SourceSystem)) {
            newCon.Source_System__c = sub.SourceSystem;
            newCon.Latest_Source__c = sub.SourceSystem;  
        } 
           return newCon;
      }
    
    //method: remove duplicate rows from Request for same brand & email 
    public static SubRequest removeDuplicate(SubRequest inputRequest){
        Map<String,Subscriber> mapSubscriber = new Map<String,Subscriber>();
        List<Subscriber> listSubscriber = new List<Subscriber>();
        SubRequest subObject = new SubRequest();
        if(inputRequest.Subscribers!=null)
        {
        for(Subscriber inputSub : inputRequest.Subscribers){
            if(String.isNotBlank(inputSub.BrandId) && String.isNotBlank(inputSub.Email)){
                //put in map: converting request email to lowercase
                mapSubscriber.put(inputSub.BrandId+(inputSub.Email).toLowercase(),inputSub);
            }
        }
        }
       // System.debug('***mapSubscriber = '+mapSubscriber);
        for(Subscriber subInput : mapSubscriber.values()){
            listSubscriber.add(subInput);
        }
        subObject.Count = String.valueOf(mapSubscriber.size());
        subObject.Subscribers = new List<Subscriber>();
        subObject.Subscribers.addAll(listSubscriber);
        subObject.FileName = inputRequest.FileName;
        return subObject;
    }
    public static List<Account> getAccountsToUpdate(){
       // System.debug('***inside updateAccount');
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
    
    
}