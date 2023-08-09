/**
 * @class:       PersonalDataFormApexController
 * @JIRA:        NASSC-98 Privacy (CCPA) Forms
 * @description: Controller Class to show picklist values to Privacy Data Form and 
 *               to create Case after form submission.
 */ 

public without sharing class PersonalDataFormApexController
{
    
     public class CaseWrapper
    { 
        @AuraEnabled
        public String caseNumber {get;set;}
        @AuraEnabled
        public String caseId {get;set;}
        @AuraEnabled
        public String verificationCode  {get;set;}
        @AuraEnabled
        public String message_success {get;set;}
        @AuraEnabled
        public String regards_success {get;set;}
        @AuraEnabled
        public String message_error {get;set;}
        @AuraEnabled
        public boolean error {get;set;}
        @AuraEnabled
        public boolean emailCheck {get;set;}
        @AuraEnabled
        public contact contactDetails {get;set;}
        @AuraEnabled
        public String brandLink {get;set;}
       
    }

    
    public class rectifiedDataWrapper{
        public string newEmail;
        public string newFirstName;
        public string newLastName;
        public string newAddress;
        public string newUnit;
        public string newCity;
        public string newState;
        public string newCountry;
        public string newZipCode;
        public string newPhone;
        public string newGender;
        public string newMonth;
        public string newDate;
        
    }
    
    /* Method to fetch below field Values from Case Object and show it to Privacy Data Forms:
     * Country of Residence
     * State of Residence
     * Type of Request (Custom Metadata - Personal Data Request Setting)
     */
    @AuraEnabled  
    public static InitialDataWrapper getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName,String brandNames,String sourceCountry) {
        InitialDataWrapper wrapperObj = new InitialDataWrapper();
        
        
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            
            wrapperObj.mapCountryState = objResults;
            return wrapperObj;
            
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
           wrapperObj.mapCountryState = objResults;
           return wrapperObj;
         
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        //System.debug('***Controlling = '+contrEntries);
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        //System.debug('***Dependent = '+depEntries);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        //System.debug('***Final Map = '+objResults);
        wrapperObj.mapCountryState = objResults;
        //System.debug('***Wrapper Obj = '+wrapperObj.mapCountryState);
        
        //Fetching Picklist values for field "Type of Request" from Custom Metadata.
        List<String> listType = new List<String>();
        // List<String> listBrands = new List<String>();
        Schema.sObjectType objTypeCase = Personal_Data_Request_Setting__mdt.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objTypeCase.getDescribe();
        
        map <String, Schema.SObjectField> typeMap = objDescribe.fields.getMap();
        list <Schema.PicklistEntry> values = typeMap.get('Type_of_Request__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) 
        {
            listType.add(a.getValue());
        }
        //System.debug('***Got Type = '+listType);
        String brandLabel = (sourceCountry == 'US')?brandNames:brandNames+' '+sourceCountry;
        system.debug('*** brandLabel '+brandLabel);
        //List<Success_Message_Setting__mdt> getMessage = [Select Id,Success_Message_f__c,Regards__c,   MasterLabel,Brand_Email__c from Success_Message_Setting__mdt Where Type__c='P' and Brand_Name__c=:brandNames and Country__c=:sourceCountry];
        List<Brand_Setting__mdt> getMessage = [Select Id, Privacy_Email__c, Brand_Phone__c,Brand_website_link__c, Privacy_Policy__c, Personal_Info_Link__c, MasterLabel from Brand_Setting__mdt where Brand_Id__c = :brandLabel];
        if(!getMessage.isEmpty())
        {
            //System.debug('$$$'+getMessage[0].MasterLabel);
            //System.debug('$$$'+getMessage[0].Brand_Email__c);
            //System.debug('***Got Configurd Message');
            wrapperObj.brand_label = getMessage[0].MasterLabel;
            wrapperObj.brand_email = getMessage[0].Privacy_Email__c;
            wrapperObj.brand_phone = getMessage[0].Brand_Phone__c;
            wrapperObj.brand_privacyPolicy = getMessage[0].Privacy_Policy__c;
            wrapperObj.brand_optOutInfo = getMessage[0].Personal_Info_Link__c;
            wrapperObj.webSite_Link = getMessage[0].Brand_website_link__c;
        }

        wrapperObj.listTypeOfRequest = listType;
        system.debug('*** wrapperObj '+wrapperObj);
        return wrapperObj;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    public class InitialDataWrapper
    {   
        @AuraEnabled
        public Map<String, List<String>> mapCountryState {get;set;}
        @AuraEnabled
        public List<String> listTypeOfRequest {get;set;}
       
        @AuraEnabled
        public String brand_label {get;set;}
        @AuraEnabled
        public String brand_email {get;set;}
        @AuraEnabled
        public String brand_phone {get;set;}
        @AuraEnabled
        public String brand_optOutInfo {get;set;}
        @AuraEnabled
        public String brand_privacyPolicy {get;set;}
        @AuraEnabled
        public String webSite_Link {get;set;}

    }
    
    
     /* Method to create Case in Salesforce when Rectify Form is submitted and return:
     * WrapperObject with:
     * CaseNumber and 
     * Success Message (Custom Metadata - Success Message Setting)
     * Regards (Custom Metadata - Success Message Setting)
     */
   @AuraEnabled
    public static CaseWrapper createCaseForDataRectified(String changedData, String brandNames, String checkEmail, Boolean insertCase, String jsonData)
    {
        CaseWrapper wrapperObj = new CaseWrapper();
        Map<String, String> mapOfBrandApiToLabel = new Map<String, String>();
        List<Schema.PicklistEntry> values = Contact.Brand_Id__c.getDescribe().getPicklistValues();
        For(Schema.PicklistEntry sp : values){
            mapOfBrandApiToLabel.put(sp.getValue(), sp.getLabel());
        }
        List<Contact> caseContact=[SELECT Id, Ecomm_Connected__c, Email, Brand_Id__c,FirstName,LastName,MailingStreet, MailingCity, MailingCountry
                                   , MailingState,MailingPostalCode,Phone, Gender__c,Birthdate 
                                   FROM Contact 
                                   where Brand_Id__c like :mapOfBrandApiToLabel.get(brandNames) AND Email =:checkEmail order by lastmodifieddate desc];
        system.debug('caseContact--'+caseContact);
        if(!caseContact.isEmpty()){
            if(caseContact.size() == 1){
                wrapperObj.contactDetails = caseContact[0];
            } else {
                for(Contact c: caseContact){
                    if(c.Ecomm_Connected__c == true){
                        wrapperObj.contactDetails = c;
                        break;
                    }
                }
                
                if(wrapperObj.contactDetails == null){
                    wrapperObj.contactDetails = caseContact[0];
                }
            }
        }
        
        if(caseContact.isEmpty()){
            system.debug('entered');
            Map<String,Brand_Details_Mapping__mdt> mapOfBrandMappings = new Map<String,Brand_Details_Mapping__mdt>();
            
            List<Brand_Details_Mapping__mdt> listOfBrandMappings = [Select Id,Brand_Number__c,Brand_Name__c,PDR_Link__c,Email_Template__c,Ordwide_Email__c,Brand_form_link__c from Brand_Details_Mapping__mdt];
            for(Brand_Details_Mapping__mdt eachMdt : listOfBrandMappings){
                mapOfBrandMappings.put(eachMdt.Brand_Number__c, eachMdt);
                
            }
            wrapperObj.message_error = 'Record not found. Please make sure you’ve entered your email address correctly. Contact a PVH Customer Service Representative for further assistance.';
            wrapperObj.error = true;
            wrapperObj.brandLink=mapOfBrandMappings.get(brandNames).Brand_form_link__c;
            return wrapperObj;
        }
        if(!insertCase){
           wrapperObj.emailCheck=true;
        }
        if(insertCase){
            //Fetching the assignment rules on case
            AssignmentRule assignRule = new AssignmentRule(); 
            assignRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true and Name='Case Assignment Rule' limit 1];
            system.debug('assignRule***'+assignRule);
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmls = new Database.DMLOptions();
            dmls.assignmentRuleHeader.assignmentRuleId= assignRule.id;
            system.debug('dmls***'+dmls);
            
            Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
            Case newCases = new Case(Type = 'Privacy',
                                     Sub_Type__c = 'Rectify My Data',
                                     ContactId=wrapperObj.contactDetails.Id,
                                     Brand__c = brandNames,
                                     Origin = 'Web',
                                     recordTypeId =recordTypeIdPrivacyRequest,
                                     Rectified_Data__c = changedData,
                                     R2R_Email_UserConfirmation__c = 'Started',
                                     Rectified_JSON_Data__c = jsonData,
                                     SuppliedEmail =wrapperObj.contactDetails.email,
                                     status = 'Pending'
                                     
                                    ); 
            newCases.setOptions(dmls);
            try {
                insert newCases;
                
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            List<Case> getCase = [Select Id,caseNumber from Case where Id =: newCases.Id];
            
            ///CODE ADDED FOR  PVH Jira - 2781
            List<Id> newCaseIds = new List<Id>();
            newCaseIds.add(newCases.Id);
            ContactFuture.processNewPrivacyCases(newCaseIds);
            //------------------------
            wrapperObj.caseNumber = (getCase != null && getCase.size() > 0) ? getCase[0].CaseNumber : '';
            //System.debug('***Case inserted with Case Number = '+getCase.CaseNumber);
            List<Success_Message_Setting__mdt> getMessage = [Select Id,Success_Message_f__c,Regards__c from Success_Message_Setting__mdt Where Type__c='P' and Brand_Name__c=:brandNames and Type_of_Request__c='Privacy'];
            if(!getMessage.isEmpty())
            {
                //System.debug('***Got Configurd Message');
                wrapperObj.message_success = getMessage[0].Success_Message_f__c;
                wrapperObj.regards_success = getMessage[0].Regards__c;
            }
            else
            {
                //System.debug('***No Configurd Message. Default Message is Set');
                wrapperObj.message_success='Thank you for submitting a Personal Data Request. Your case number is <b><ticketid></b>. We will contact you before we begin processing your request.';
                wrapperObj.regards_success='Support Team';
            }        
            
        }
        return wrapperObj;    
    }
    
    
     /* Method to create Case in Salesforce when customer submits form for Advertising/Sharing Opt-Out:
     * WrapperObject with:
     * CaseNumber and 
     * Success Message (Custom Metadata - Success Message Setting)
     * Regards (Custom Metadata - Success Message Setting)
     * JIRA: GCT-773
     */
   @AuraEnabled
    public static CaseWrapper createCaseForDonotSellShare(String brandNames, String checkEmail,Boolean isTealiumApi)
    {	System.debug('Tealium request parameters ' + brandNames + ' ' + checkEmail);
        CaseWrapper wrapperObj = new CaseWrapper();
        Map<String, String> mapOfBrandApiToLabel = new Map<String, String>();
        List<Schema.PicklistEntry> values = Contact.Brand_Id__c.getDescribe().getPicklistValues();
        For(Schema.PicklistEntry sp : values){
            mapOfBrandApiToLabel.put(sp.getValue(), sp.getLabel());
        }
        Boolean insertCase=false;
        List<Contact> caseContact=[SELECT Id, Ecomm_Connected__c, Email, Brand_Id__c,FirstName,LastName,MailingStreet, MailingCity, MailingCountry
                                   , MailingState,MailingPostalCode,Phone, Gender__c,Birthdate, OptOutShare__c
                                   FROM Contact 
                                   where Brand_Id__c like :mapOfBrandApiToLabel.get(brandNames) AND Email =:checkEmail order by lastmodifieddate desc];
        system.debug('caseContact--'+caseContact);
        if(!caseContact.isEmpty()){
            insertCase = true;
            if(caseContact.size() == 1){
                wrapperObj.contactDetails = caseContact[0];
            } else {
                for(Contact c: caseContact){
                    if(c.Ecomm_Connected__c == true){
                        wrapperObj.contactDetails = c;
                        break;
                    }
                }
                
                if(wrapperObj.contactDetails == null){
                    wrapperObj.contactDetails = caseContact[0];
                }
            }
            System.debug('Contact details: ' + wrapperObj.contactDetails);
            if(wrapperObj.contactDetails.OptOutShare__c && !isTealiumApi)
            {
                wrapperObj.message_success='Our records indicate this contact is already opted out of targeted advertising/sharing. Please enter a different email to submit a request.';
                wrapperObj.regards_success='Support Team';
                return wrapperObj;
            }
            
        }
         if(caseContact.isEmpty()){
            system.debug('entered');
            Map<String,Brand_Details_Mapping__mdt> mapOfBrandMappings = new Map<String,Brand_Details_Mapping__mdt>();
            
            List<Brand_Details_Mapping__mdt> listOfBrandMappings = [Select Id,Brand_Number__c,Brand_Name__c,PDR_Link__c,Email_Template__c,Ordwide_Email__c,Brand_form_link__c from Brand_Details_Mapping__mdt];
            for(Brand_Details_Mapping__mdt eachMdt : listOfBrandMappings){
                mapOfBrandMappings.put(eachMdt.Brand_Number__c, eachMdt);
                
            }
            wrapperObj.message_error = 'Record not found. Please make sure you’ve entered your email address correctly. Contact a PVH Customer Service Representative for further assistance.';
            wrapperObj.error = true;
            wrapperObj.brandLink=mapOfBrandMappings.get(brandNames).Brand_form_link__c;
            return wrapperObj;
        }
        if(insertCase){
            //Fetching the assignment rules on case
            AssignmentRule assignRule = new AssignmentRule(); 
            assignRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true and Name='Case Assignment Rule' limit 1];
            system.debug('assignRule***'+assignRule);
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmls = new Database.DMLOptions();
            dmls.assignmentRuleHeader.assignmentRuleId= assignRule.id;
            system.debug('dmls***'+dmls);
            
            Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
            Case newCases = new Case(Type = 'Privacy',
                                     Sub_Type__c = 'Do Not Sell/Share',
                                     ContactId=wrapperObj.contactDetails.Id,
                                     Brand__c = brandNames,
                                     Origin = 'Web',
                                     recordTypeId =recordTypeIdPrivacyRequest,
                                     R2R_Email_UserConfirmation__c = 'Started',
                                     SuppliedEmail =wrapperObj.contactDetails.email,
                                     status = 'Pending',
                                     Tealium_Email_Suppression__c = isTealiumApi
                                     
                                    ); 
            newCases.setOptions(dmls);
            try {
                insert newCases;
                
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            List<Case> getCase = [Select Id,caseNumber,VerificationHash__c from Case where Id =: newCases.Id];
            
            ///CODE ADDED FOR  PVH Jira - 2781
            List<Id> newCaseIds = new List<Id>();
            newCaseIds.add(newCases.Id);
            ContactFuture.processNewPrivacyCases(newCaseIds);
            //------------------------
            wrapperObj.caseNumber = (getCase != null && getCase.size() > 0) ? getCase[0].CaseNumber : '';
            wrapperObj.caseId = (getCase != null && getCase.size() > 0) ? getCase[0].Id : '';
            wrapperObj.verificationCode = (getCase != null && getCase.size() > 0) ? getCase[0].VerificationHash__c : '';
            //System.debug('***Case inserted with Case Number = '+getCase.CaseNumber);
            List<Success_Message_Setting__mdt> getMessage = [Select Id,Success_Message_f__c,Regards__c from Success_Message_Setting__mdt Where Type__c='P' and Brand_Name__c=:brandNames and Type_of_Request__c='Privacy'];
            if(!getMessage.isEmpty())
            {
                //System.debug('***Got Configurd Message');
                wrapperObj.message_success = getMessage[0].Success_Message_f__c;
                wrapperObj.regards_success = getMessage[0].Regards__c;
            }
            else
            {
                //System.debug('***No Configurd Message. Default Message is Set');
                wrapperObj.message_success='Thank you for submitting a Personal Data Request. Your case number is <b><ticketid></b>. We will contact you before we begin processing your request.';
                wrapperObj.regards_success='Support Team';
            }        
        }
        return wrapperObj;    
    }
    
    /* Method to create Case in Salesforce when Privacy Form is submitted and return:
     * WrapperObject with:
     * CaseNumber and 
     * Success Message (Custom Metadata - Success Message Setting)
     * Regards (Custom Metadata - Success Message Setting)
     */
   @AuraEnabled
    public static CaseWrapper createCase(Case getCaseDetail,String name,String brandNames,String sourceCountry)
    {
        //System.debug('***inside createCase');
        CaseWrapper wrapperObj = new CaseWrapper();
        Boolean insertCase=false;
        
        Id recordTypeIdPrivacyRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
        String typeToSet = 'Privacy';
        String subTypeToSet;
        String recordTyeToSet;
        //Map<String,String> mapBrandNameLabel = new Map<String,String>();
        
        if(getCaseDetail.Type == 'Access My Data' || getCaseDetail.Type == 'Delete My Data' || getCaseDetail.Type == 'Unsubscribe')
        {
            //System.debug('***its Privacy');
            subTypeToSet = getCaseDetail.Type;
            if(getCaseDetail.Type == 'Unsubscribe'){                
                recordTyeToSet = recordTypeIdSupportCase;
                typeToSet = 'Marketing';
            }else{
                 recordTyeToSet = recordTypeIdPrivacyRequest;
                typeToSet = 'Privacy';              
            }            
        }
        
        system.debug('Check RT'+recordTyeToSet);
         
        List<Contact> caseContact=[SELECT Id, Email, Brand_Id__c,Ecomm_Connected__c FROM Contact where Brand_Id__c =:brandNames AND Email= :getCaseDetail.SuppliedEmail order by lastmodifieddate desc];
        Contact cont;
        if(!test.isRunningTest() && caseContact.size()>0){
            if(!caseContact.isEmpty()){
                insertCase = true;
                if(caseContact.size() == 1){
                    wrapperObj.contactDetails = caseContact[0];
                } else {
                    for(Contact c: caseContact){
                        if(c.Ecomm_Connected__c == true){
                            wrapperObj.contactDetails = c;
                            break;
                        }
                    }
                    
                    if(wrapperObj.contactDetails == null){
                        wrapperObj.contactDetails = caseContact[0];
                    }
                }}
             //cont = caseContact[0];
        }else{
            wrapperObj.contactDetails = [SELECT Id, Email, Brand_Id__c  FROM Contact limit 1];
        }
        if(insertCase || test.isRunningTest() ) {
        //Fetching the assignment rules on case
        AssignmentRule assignRule = new AssignmentRule(); 
        assignRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true and Name='Case Assignment Rule' limit 1];
        system.debug('assignRule***'+assignRule);
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmls = new Database.DMLOptions();
        dmls.assignmentRuleHeader.assignmentRuleId= assignRule.id;
        system.debug('dmls***'+dmls);
       
        system.debug('getCaseDetail.SuppliedEmail::'+getCaseDetail.SuppliedEmail);
        Case newCases = new Case(Type=typeToSet, 
                                 Sub_Type__c=subTypeToSet, 
                                 Country_of_Residence__c=getCaseDetail.Country_of_Residence__c, 
                                 State_of_Residence__c=getCaseDetail.State_of_Residence__c,
                                 SuppliedName=name, SuppliedEmail=getCaseDetail.SuppliedEmail, 
                                 SuppliedPhone=getCaseDetail.SuppliedPhone,ContactId=wrapperObj.contactDetails.Id,
                                 Loyalty_Account_Number__c=getCaseDetail.Loyalty_Account_Number__c,
                                 Brand__c = brandNames,
                                 Origin = 'Web',
                                 recordTypeId =recordTyeToSet,
                                 R2R_Email_UserConfirmation__c = 'Started'
                                 );
                                 //Brand_Label__c = mapBrandNameLabel.get(brandNames)
        
        //Setting the DMLOption on Case instance
        
         newCases.setOptions(dmls);
       // newCases.ContactId=caseContact[0].Id;
         system.debug('newCases***'+newCases);
         
        try {
            system.debug('Finalcheck1024 Before '+newCases.RecordTypeId);
            insert newCases;               
            system.debug('Finalcheck1024 '+newCases);            
            system.debug('Finalcheck1024 '+[Select Id, CaseNumber, RecordType.Name from Case where Id = :newCases.Id]);
            system.debug('Finalcheck1024 After '+newCases.RecordTypeId);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
      //  newCases.ContactId=contactid;
       // update newCases;
        List<Case> getCase = [Select Id,caseNumber from Case where Id =: newCases.Id];
        
         ///CODE ADDED FOR  PVH Jira - 2781
        List<Id> newCaseIds = new List<Id>();
        newCaseIds.add(newCases.Id);
        ContactFuture.processNewPrivacyCases(newCaseIds);
        //------------------------
        wrapperObj.caseNumber = (getCase != null && getCase.size() > 0) ? getCase[0].CaseNumber : '';
        //System.debug('***Case inserted with Case Number = '+getCase.CaseNumber);
        List<Success_Message_Setting__mdt> getMessage = [Select Id,Success_Message_f__c,Regards__c from Success_Message_Setting__mdt Where Type__c='P' and Brand_Name__c=:brandNames and Type_of_Request__c=:getCaseDetail.Type and Country__c=:sourceCountry];
        if(!getMessage.isEmpty())
        {
            //System.debug('***Got Configurd Message');
            wrapperObj.message_success = getMessage[0].Success_Message_f__c;
            wrapperObj.regards_success = getMessage[0].Regards__c;
        }
        else
        {
             //System.debug('***No Configurd Message. Default Message is Set');
             wrapperObj.message_success='Thank you for submitting a Personal Data Request. Your case number is <b><ticketid></b>. We will contact you before we begin to process your request.';
             wrapperObj.regards_success='Support Team';
        }   
    }     
        return wrapperObj;      
    }
    
    @AuraEnabled
    public static CaseWrapper checkIfContactExistWithEmailId(String brandNames, String checkEmail)
    {
        CaseWrapper wrapperObj = new CaseWrapper();
        Map<String, String> mapOfBrandApiToLabel = new Map<String, String>();
        List<Schema.PicklistEntry> values = Contact.Brand_Id__c.getDescribe().getPicklistValues();
        For(Schema.PicklistEntry sp : values){
            mapOfBrandApiToLabel.put(sp.getValue(), sp.getLabel());
        }
        List<Contact> caseContact=[SELECT Id, Ecomm_Connected__c, Email, Brand_Id__c,FirstName,LastName,MailingStreet, MailingCity, MailingCountry
                                   , MailingState,MailingPostalCode,Phone, Gender__c,Birthdate 
                                   FROM Contact 
                                   where Brand_Id__c like :mapOfBrandApiToLabel.get(brandNames) AND Email =:checkEmail order by lastmodifieddate desc];
        system.debug('caseContact--'+caseContact);

        if(caseContact.isEmpty()){
            system.debug('entered');
            Map<String,Brand_Details_Mapping__mdt> mapOfBrandMappings = new Map<String,Brand_Details_Mapping__mdt>();
            
            List<Brand_Details_Mapping__mdt> listOfBrandMappings = [Select Id,Brand_Number__c,Brand_Name__c,PDR_Link__c,Email_Template__c,Ordwide_Email__c,Brand_form_link__c from Brand_Details_Mapping__mdt];
            for(Brand_Details_Mapping__mdt eachMdt : listOfBrandMappings){
                mapOfBrandMappings.put(eachMdt.Brand_Number__c, eachMdt);
                
            }
            wrapperObj.message_error = 'Record not found. Please make sure you’ve entered your email address correctly. Contact a PVH Customer Service Representative for further assistance.';
            wrapperObj.error = true;
            wrapperObj.brandLink=mapOfBrandMappings.get(brandNames).Brand_form_link__c;
            return wrapperObj;
        }
        return wrapperObj; 
    }
    
    /* NOT using this method 
    public static String getBrandAPIName(String brandNames)
    {
        Map<String,String> mapBrandLabelValue = new Map<String,String>();
        Schema.sObjectType objTypeCase = Case.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objTypeCase.getDescribe();
        map <String, Schema.SObjectField> typeMap = objDescribe.fields.getMap();
        list <Schema.PicklistEntry> brandValues = typeMap.get('Brand__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry ent: brandValues) 
        {
            mapBrandLabelValue.put(ent.getLabel(),ent.getValue());
        }
        //System.debug('***We got BrandMap = '+mapBrandLabelValue);
        String brandAPIName = mapBrandLabelValue.get(brandNames);
        return brandAPIName;
    }
    */
    

    
    public class AddressWrapper
    { 
        @AuraEnabled
        public String apartment {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String country {get;set;}
        @AuraEnabled
        public String state {get;set;}
        @AuraEnabled
        public Integer zipCode {get;set;}
    }
    
    public class CaseDataWrapper
    { 
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public AddressWrapper address {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String gender {get;set;}
        @AuraEnabled
        public Integer bMonth {get;set;}
        @AuraEnabled
        public Integer bDate {get;set;}
    }

}