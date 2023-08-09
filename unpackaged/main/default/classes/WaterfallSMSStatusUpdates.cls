/******************************************************************************
 * @Description: WaterfallSMSStatusUpdates
 * @Author     :
 * @Date       : April 17, 2020
 * @JIRA       : NASSC-1614
 *
 ******************************************************************************/
@RestResource(urlmapping = '/Subscribers/SMSOptin/Waterfall')
global without sharing class WaterfallSMSStatusUpdates{
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    global class SubRequest{
        public String Count;
        public List<Subscriber> Subscribes;
        public String FileName;
    }

    global class Subscriber{
        public String BrandId;
        public String Country;
        public String ProcessedTimeStamp;
        public String SMSNumber;
        public String ShortCode;
        public String Keyword;
        public String SMSFlag;
        public String Email;
        public String SourceSystem;
    }

    global class SubResponse{
        public String Code;
        public String Count;
        public List<Subscribes> Subscribers;
        public String Message;
    }

    global class Subscribes{
        public String ContactId;
    }

    @HttpPost
    global static SubResponse doSignUp(){
        List<Contact> allContacts = new List<Contact>();
        Contact SMSMatchedContact = new Contact();
        Contact EmailMatchedContact = new Contact();
        List<Contact> listUpdateContact = new List<Contact>();
        List<Contact> listCreateContact = new List<Contact>();
        Boolean smsAndEmailExactMatch = false;
        Boolean isRequiredParameterMissing = false;
        SubResponse errorResponse = new SubResponse();
        SubResponse successResponse = new SubResponse();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestData = req.requestBody.toString();
        Log.push('request data ' + requestData);
        SubRequest subReqReceived = (SubRequest)JSON.deserialize(requestData, SubRequest.class);
        Log.push('***subReqReceived = ' + subReqReceived);
        //called removeDuplicate method to remove duplicate rows based on same brand & email
        //SubRequest subReq = removeDuplicate(subReqReceived);
        SubRequest subReq = subReqReceived;
        Log.push('***subReq_afterDuplicateRemoved :' + subReq);
        Set<String> setBrandIds = new Set<String>();
        Set<String> setEmails = new Set<String>();
        Set<String> setSMSNumber = new Set<String>();
        Set<String> CAKeywords = new Set<String>();
        Map<String, Map<String, Contact>> BrandToEmailContactMap = new Map<String, Map<String, Contact>>();
        Map<String, Map<String, Contact>> BrandToSMSContactMap = new Map<String, Map<String, Contact>>();
        Map<String, Map<String, String>> BrandToCAKeywordToLocaleMap = new Map<String, Map<String, String>>();
        List<Contact> brandEmailContacts = new List<Contact>();
        List<Contact> brandSMSContacts = new List<Contact>();
        Boolean isError = false;
        List<CanadaSMSLocaleSettings__mdt> listCASMSLocales = new List<CanadaSMSLocaleSettings__mdt>();
        String DefaultSMSLocale = SYSTEM.LABEL.en_US;
        String SMSLocale;

        for (Subscriber sub : subReq.Subscribes){

            if (String.isNotBlank(sub.BrandId))
                setBrandIds.add(sub.BrandId);
            if (String.isNotBlank(sub.Email))
                setEmails.add(sub.Email);
            if (String.isNotBlank(sub.SMSNumber))
                setSMSNumber.add(sub.SMSNumber);
            if (String.isNotBlank(sub.Country) && (sub.Country == SYSTEM.LABEL.CA))
                CAKeywords.add(sub.Keyword);
        }
        if (!CAKeywords.isEmpty()){
            listCASMSLocales = [SELECT BrandId__c, Keyword__c, Locale__c
                                FROM CanadaSMSLocaleSettings__mdt
                                WHERE BrandId__c in:setBrandIds AND Keyword__c in:CAKeywords];
        }

        if (listCASMSLocales.size() > 0){
            for (CanadaSMSLocaleSettings__mdt CASetting : listCASMSLocales){
                Map<String, String> CAKeywordToLocaleMap = new Map<String, String>();
                if (BrandToCAKeywordToLocaleMap.containsKey(CASetting.BrandId__c))
                    BrandToCAKeywordToLocaleMap.get(CASetting.BrandId__c).put(CASetting.Keyword__c, CASetting.Locale__c);
                else{
                    CAKeywordToLocaleMap.put(CASetting.Keyword__c, CASetting.Locale__c);
                    BrandToCAKeywordToLocaleMap.put(CASetting.BrandId__c, CAKeywordToLocaleMap);
                }
            }
        }

        if (!setBrandIds.isEmpty() || !setEmails.isEmpty()){
            brandEmailContacts = [SELECT id, Brand_Id__c, Email, SMSNumber__c, AccountId, StoreOfCapture__c, CountryOfCapture__c, LoyaltyID__c, LoyaltyFlag__c, SMSOptinStatus__c, EmailOptInStatus__c, Loyalty_Optin_Date__c, SMSOptInDate__c, Source_System__c, Latest_Source__c
                                  FROM CONTACT
                                  WHERE Brand_Id__c IN:setBrandIds AND Email IN:setEmails];

        }

        if (!setBrandIds.isEmpty() || !setSMSNumber.isEmpty()){
            brandSMSContacts = [SELECT id, Brand_Id__c, Email, SMSNumber__c, AccountId, StoreOfCapture__c, CountryOfCapture__c, LoyaltyID__c, LoyaltyFlag__c, SMSOptinStatus__c, EmailOptInStatus__c, Loyalty_Optin_Date__c, SMSOptInDate__c, Source_System__c, Latest_Source__c
                                FROM CONTACT
                                WHERE Brand_Id__c IN:setBrandIds AND SMSNumber__c IN:setSMSNumber];

        }

        if (!brandEmailContacts.isEmpty()){
            for (Contact beCon : brandEmailContacts){
                Map<String, Contact> emailToContactMap = new Map<String, Contact>();
                if (BrandToEmailContactMap.containsKey(beCon.Brand_Id__c))
                    BrandToEmailContactMap.get(beCon.Brand_Id__c).put(beCon.Email, beCon);
                else{
                    emailToContactMap.put(beCon.Email, beCon);
                    BrandToEmailContactMap.put(beCon.Brand_Id__c, emailToContactMap);
                }
            }
        }

        if (!brandSMSContacts.isEmpty()){
            for (Contact bsCon : brandSMSContacts){
                Map<String, Contact> SMSToContactMap = new Map<String, Contact>();
                if (BrandToSMSContactMap.containsKey(bsCon.Brand_Id__c))
                    BrandToSMSContactMap.get(bsCon.Brand_Id__c).put(bsCon.SMSNumber__c, bsCon);
                else{
                    SMSToContactMap.put(bsCon.SMSNumber__c, bsCon);
                    BrandToSMSContactMap.put(bsCon.Brand_Id__c, SMSToContactMap);
                }
            }
        }
        Log.push('***BrandToSMSContactMap = ' + BrandToSMSContactMap);

        for (Subscriber sub : subReq.Subscribes){
            if (String.isNotBlank(sub.Country) && (sub.Country == SYSTEM.LABEL.CA) && BrandToCAKeywordToLocaleMap.containsKey(sub.BrandId) && BrandToCAKeywordToLocaleMap.get(sub.BrandId).containsKey(sub.Keyword)){
                SMSLocale = BrandToCAKeywordToLocaleMap.get(sub.BrandId).get(sub.Keyword);
            } else
                SMSLocale = DefaultSMSLocale;
            if (String.isNotBlank(sub.SMSFlag) && (Integer.valueOf(sub.SMSFlag) == 1 || Integer.valueOf(sub.SMSFlag) == 2)){
                  //opt outs
                Log.push('***SMSFlag = 1 OR 2');

                if (BrandToSMSContactMap.containsKey(sub.BrandId) && BrandToSMSContactMap.get(sub.BrandId).containsKey(sub.SMSNumber)){
                    Contact optOutContact = BrandToSMSContactMap.get(sub.BrandId).get(sub.SMSNumber);

                    Log.push('***optOutContact exists');
                    optOutContact.SMSOptinStatus__c = SYSTEM.LABEL.N;
                    if (String.isNotBlank(sub.ProcessedTimeStamp))
                        optOutContact.SMSOptOutDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
                    optOutContact.SMSLocale__c = SMSLocale;
                    optOutContact.Latest_Source__c = SYSTEM.LABEL.Waterfall;
                    listUpdateContact.add(optOutContact);
                } else{
                     //if no contact exists with matching SMS Number for optout

                    // do nothing - this may change in future.
                }
            } else if (String.isNotBlank(sub.SMSFlag) && Integer.valueOf(sub.SMSFlag) == 0){
                 //opt ins

                Log.push('***SMSFlag is 0');
                if (BrandToSMSContactMap.containsKey(sub.BrandId) && BrandToSMSContactMap.get(sub.BrandId).containsKey(sub.SMSNumber)){
                    SMSMatchedContact = BrandToSMSContactMap.get(sub.BrandId).get(sub.SMSNumber);
                } else
                    SMSMatchedContact = null;
                if (BrandToEmailContactMap.containsKey(sub.BrandId) && BrandToEmailContactMap.get(sub.BrandId).containsKey(sub.Email.toLowerCase())){
                    EmailMatchedContact = BrandToEmailContactMap.get(sub.BrandId).get(sub.Email.toLowerCase());
                } else
                    EmailMatchedContact = null;
                if (SMSMatchedContact == null){
                    if (EmailMatchedContact == null){
                        //Opt-In #1
                        Log.push('Scenario optin #1');
                        Contact newSMSAndEmailContact = createNewSMSAndEmailContact(sub);
                        newSMSAndEmailContact.SMSLocale__c = SMSLocale;
                        listCreateContact.add(newSMSAndEmailContact);
                    } else if (EmailMatchedContact != null && String.isBlank(EmailMatchedContact.SMSNumber__c)){
                        //Opt-In #2
                        Log.push('Scenario optin #2');
                        EmailMatchedContact.SMSNumber__c = sub.SMSNumber;
                        EmailMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                        if (String.isNotBlank(sub.ProcessedTimeStamp))
                            EmailMatchedContact.SMSOptInDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
                        EmailMatchedContact.Latest_Source__c = SYSTEM.LABEL.Waterfall;
                        EmailMatchedContact.SMSLocale__c = SMSLocale;
                        listUpdateContact.add(EmailMatchedContact);
                    } else if (EmailMatchedContact != null && String.isNotBlank(EmailMatchedContact.SMSNumber__c) && EmailMatchedContact.SMSNumber__c != sub.SMSNumber){
                        //Opt-In #3
                        Log.push('Scenario optin #3');
                        Contact newSMSOnlyContact = createNewSMSOnlyContact(sub);
                        newSMSOnlyContact.SMSLocale__c = SMSLocale;
                        newSMSOnlyContact.AccountId = EmailMatchedContact.AccountId;
                        listCreateContact.add(newSMSOnlyContact);

                    }
                } else{
                    //SMSMatched Contact Exists in Salesforce
                    if (SMSMatchedContact.Email == null){
                        if (EmailMatchedContact == null){
                            //Re-Opt-In #5
                            Log.push('Scenario Re-optin #5');
                            if (String.isNotBlank(sub.Email))
                                SMSMatchedContact.Email = sub.Email;
                            SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                            if (String.isNotBlank(sub.ProcessedTimeStamp))
                                SMSMatchedContact.SMSOptInDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
                            SMSMatchedContact.Latest_Source__c = SYSTEM.LABEL.Waterfall;
                            SMSMatchedContact.SMSLocale__c = SMSLocale;
                            listUpdateContact.add(SMSMatchedContact);
                        } else{
                            //Re-Opt-In #1,#2,#3,#4,#5,#6
                            Log.push('Scenario Re-optin #1,#2,#3,#4,#5,#6');
                            SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                            if (String.isNotBlank(sub.ProcessedTimeStamp))
                                SMSMatchedContact.SMSOptInDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
                            SMSMatchedContact.Latest_Source__c = SYSTEM.LABEL.Waterfall;
                            SMSMatchedContact.SMSLocale__c = SMSLocale;
                            listUpdateContact.add(SMSMatchedContact);
                        }
                    } else{
                        //Re-Opt-In #1,#2,#3,#4,#5,#6
                        Log.push('Scenario Re-optin #1,#2,#3,#4,#5,#6');
                        SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                        if (String.isNotBlank(sub.ProcessedTimeStamp))
                            SMSMatchedContact.SMSOptInDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
                        SMSMatchedContact.Latest_Source__c = SYSTEM.LABEL.Waterfall;
                        SMSMatchedContact.SMSLocale__c = SMSLocale;
                        listUpdateContact.add(SMSMatchedContact);
                    }
                }


            }


        }

        if (listCreateContact.size() > 0){
            try{
                insert listCreateContact;
                allContacts.addAll(listCreateContact);
            } catch (Exception e){
                Logger.logException(e);
            }
        }
        if (listUpdateContact.size() > 0){
            try{
                update listUpdateContact;
                allContacts.addAll(listUpdateContact);
            } catch (Exception e){
                Logger.logException(e);
            }
        }

        List<Subscribes> subsList = new List<Subscribes>();
        for (Contact cons : allContacts){

            Subscribes subObject = new Subscribes();
            res.statusCode = 200;
            successResponse.Code = SYSTEM.LABEL.OK;
            successResponse.Message = SYSTEM.LABEL.Success;

            subObject.ContactId = cons.Id;
            subsList.add(subObject);
            successResponse.Subscribers = subsList;
            successResponse.Count = String.valueOf(subsList.size());
        }
        Logger.logDebug();
        return successResponse;
    }

    public static Contact createNewSMSAndEmailContact(Subscriber sub){
        Contact newCon = createNewSMSOnlyContact(sub);
        if (String.isNotBlank(sub.Email))
            newCon.Email = sub.Email;
        newCon.EmailOptInStatus__c = SYSTEM.LABEL.N;
        return newCon;
    }

    public static Contact createNewSMSOnlyContact(Subscriber sub){
        Contact newCon = new Contact();

        newCon.createdByMethod__c = SYSTEM.LABEL.API;
        newCon.RecordTypeId = emailRecordTypeId;
        newCon.Status__c = SYSTEM.LABEL.Active;
        newCon.Source_System__c = SYSTEM.LABEL.Waterfall;
        newCon.Latest_Source__c = SYSTEM.LABEL.Waterfall;
        newCon.FirstName = SYSTEM.LABEL.Unknown;
        newCon.LastName = SYSTEM.LABEL.Unknown;

        if (String.isNotBlank(sub.BrandId))
            newCon.Brand_Id__c = sub.BrandId;
        if (String.isNotBlank(sub.SMSNumber))
            newCon.SMSNumber__c = sub.SMSNumber;
        newCon.SMSOptinStatus__c = SYSTEM.LABEL.Y;

        newCon.LoyaltyFlag__c = true;
        if (String.isNotBlank(sub.ProcessedTimeStamp)){
            newCon.Loyalty_Optin_Date__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
            newCon.SMSOptInDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
            newCon.PVHCreatedDate__c = UtilityClass.strYYYMMDDtoDateTime(sub.ProcessedTimeStamp);
        }
        return newCon;
    }

    //method: remove duplicate rows from Request for same brand & email
    public static SubRequest removeDuplicate(SubRequest inputRequest){
        Map<String, Subscriber> mapSubscriber = new Map<String, Subscriber>();
        List<Subscriber> listSubscriber = new List<Subscriber>();
        SubRequest subObject = new SubRequest();
        for (Subscriber inputSub : inputRequest.Subscribes){
            if (String.isNotBlank(inputSub.BrandId)){
                if (String.isNotBlank(inputSub.Email)){
                    //put in map: converting request email to lowercase
                    mapSubscriber.put(inputSub.BrandId + (inputSub.Email).toLowercase(), inputSub);
                } else if (String.isNotBlank(inputSub.SMSNumber)){
                    mapSubscriber.put(inputSub.BrandId + inputSub.SMSNumber, inputSub);
                }
            }
        }
        Log.push('***mapSubscriber = ' + mapSubscriber);
        for (Subscriber subInput : mapSubscriber.values()){
            listSubscriber.add(subInput);
        }
        subObject.Count = String.valueOf(mapSubscriber.size());
        subObject.Subscribes = new List<Subscriber>();
        subObject.Subscribes.addAll(listSubscriber);
        subObject.FileName = inputRequest.FileName;
        Logger.logDebug();
        return subObject;
    }

}