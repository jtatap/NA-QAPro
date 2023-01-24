/**
* @author Magnet360
* @date 2019
*
* @group Case
* @group-content ../../ApexDocContent/Case.htm
*
* @description Trigger Handler on Case that performs a variety of actions
* related to CCPA and Support Cases.
*/
public without sharing class CaseTriggerHandler implements ITrigger {
    List<Id> listCaseId = new List<Id>();
    List<Id> listCaseIdDeleteReq = new List<Id>();
    List<Case> caseListForAccCon = new List<Case>();
    List<Contact> contactListForAccCon = new List<Contact>();
    Static String SupportRecordTypeId = Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
    Map<Id, User> caseOwnersMap = new Map<Id, User>();
    Set<Case> casesToUpload = new Set<Case>();
    public static boolean sentSuccessEmail = false;
    /*******************************************************************************************************
    * @description This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger. <p>
    * <p>
    * Privacy and Support cases that are to be sent back to a users Omni Personal Queue are grouped together
    *
    * @return void
    */
    public void  bulkBefore(){
        if(trigger.isUpdate) {
            Set<String> ownerIds = new Set<String>();
            List<Case> casesToSendToOmni = new List<Case>();
            List<Case> newEmailCases = new List<Case>();
            Id unassignedPrivacyQueueId;
            for(sObject updatedRec :Trigger.New) {
                Case c = (Case)updatedRec;
                Case oldCase = (Case)Trigger.oldMap.get(c.Id);

                if(c.Status != oldCase.Status && c.Status == 'Open' && oldCase.Status != 'New') {
                    casesToUpload.add(c);
                    ownerIds.add(c.OwnerId);
                    //system.debug('casesToUpload***'+casesToUpload);
                }
                    
                if (c.Type == Constants.privacyCaseType &&
                        c.Sub_Type__c != Constants.privacyEmailSubType &&
                        (c.Status == Constants.openStatus && oldCase.Status != Constants.openStatus)) {
                    casesToSendToOmni.add(c);
                }
                if (c.Type == Constants.privacyCaseType &&
                        c.Sub_Type__c != Constants.unsubscribeRequestSubType &&
                        (c.Status == Constants.openStatus && oldCase.Status != Constants.openStatus)) {
                    casesToSendToOmni.add(c);
                }
                if (c.Type == Constants.marketingCaseType && c.Sub_Type__c == Constants.unsubscribeRequestSubType && c.Status == Constants.openStatus && oldCase.Status != Constants.openStatus) {
                    casesToSendToOmni.add(c);
                }
                if (c.Origin == 'Email' && !String.isBlank(c.emailToAddress__c) && String.isBlank(oldCase.emailToAddress__c)) {
                    List<Brand_Setting__mdt> brandSetting1 = [Select Brand_Id__c From Brand_Setting__mdt Where Privacy_Email__c = :c.emailToAddress__c];
                    List<Brand_Setting__mdt> brandSetting2 = [Select Brand_Id__c From Brand_Setting__mdt Where Outbound_Privacy_Email__c = :c.emailToAddress__c];
                    if (brandSetting1.size() > 0 || brandSetting2.size() > 0) {
                        Brand_Setting__mdt brandSetting;
                        if (brandSetting1.size() > 0) {
                            brandSetting = brandSetting1[0];
                        } else {
                            brandSetting = brandSetting2[0];
                        }
                        c.Brand__c = brandSetting.Brand_Id__c;
                        c.Type = Constants.privacyCaseType;
                        c.Sub_Type__c = Constants.privacyEmailSubType;
                        c.RecordTypeId = Constants.supportCaseRecordTypeId;
                        PrivacyCaseTriggerHandler.isFirstRun = True;
                    }
                    casesToSendToOmni.add(c);
                    //system.debug('casesToSendToOmni***'+casesToSendToOmni);
                }
            }
            caseOwnersMap = new Map<Id, User> ([Select Id, Personal_Queue_ID__c from User where Id in :ownerIds]);
            if (casesToSendToOmni.size() > 0) {
                // system.debug('casesToSendToOmni***'+casesToSendToOmni);
                PrivacyCaseQueueHandler.sendCasesToOmni(casesToSendToOmni);
            }
        }

        this.updatePrivacyCaseBrandInfo();

        //added to add brand logo to non-privacy cases for email template support
        this.updateCaseBrandImageLink();

    }



    /*******************************************************************************************************
    * @description This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger. Following Actions take place:<p>
    * <p>
    * After the case has been inserted, Contacts that match either the Email or Phone are queried to be
    * sent to the ContactFuture Methods
    * @return void
    */
    public void bulkAfter(){       
        List<Case> listOfResolvedCases = new List<Case>();
        for(SObject c :Trigger.new) {
            Case newCase = (Case)c;
            if(Trigger.isInsert){
                if(newCase.Origin != 'Phone') {
                    caseListForAccCon.add(newCase);
                }
            } else if(Trigger.isUpdate) {
                if(newCase.Origin == 'Phone' && newCase.ContactId == null & newCase.Supplied_Last_Name__c != null && (newCase.SuppliedEmail != null || newCase.SuppliedPhone != null)) {
                    caseListForAccCon.add(newCase);
                }
            }
        }

        if(caseListForAccCon.size() > 0){


            List<Id> caseId = new List<Id>();
            List<String> EmailList = new List<String>();
            List<String> BrandList = new List<String>();
            List<String> PhoneList = new List<String>();

            for(Case newCase : caseListForAccCon){
                if(newCase.Id !=Null && (newCase.ZdTnCTicketId__c==null && newCase.ZdPVHTicketId__c==null)){
                    caseId.add(newCase.Id);
                    if (newCase.SuppliedEmail != null) {
                        EmailList.add(newCase.SuppliedEmail);
                    }
                    BrandList.add(newCase.Brand__c);
                    if (newCase.SuppliedPhone != null) {
                        PhoneList.add(newCase.SuppliedPhone);
                    }
                }
            }

            contactListForAccCon = [SELECT Id, FirstName, LastName, Email, Brand_Id__c, AccountId, Phone, MobilePhone, HomePhone
            FROM Contact
            WHERE (Email IN :EmailList OR Phone IN :PhoneList) Order BY Brand_Id__c DESC NULLS FIRST, Email DESC NULLS LAST, Phone DESC NULLS LAST, CreatedDate];
        }
    }

    /*******************************************************************************************************
    * @description This method is called iteratively for each record to be inserted during a BEFORE
    * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    *
    * Email to Case origins are split to identify the proper brand for the case
    * Names originated from Emails are formatted so the Contact is preoperly created
    *
    * @return void
    */
    public void  beforeInsert(SObject obj){
        Case cas = (Case)obj;
        system.debug('>>>>>>>cas.Origin'+cas.Origin);
        if(cas.Origin != null && cas.Origin.startsWithIgnoreCase('Email -') && cas.Brand__c == null){
            List<String> e2cRoutings = cas.Origin.split('-');
            cas.Origin = 'Email';
            if(e2cRoutings.size() >= 2){
                cas.Brand__c = e2cRoutings[1].trim();
            }

            if(e2cRoutings.size() == 3){
                cas.Email_Assignment_Code__c = e2cRoutings[2].trim();
            }
            cas.Origin = 'Email';
        }

        //splits email sender name to populate Supplied First Name and Last Name fields on Case, which will help populate the Contact First and Last Name
        if (cas.Origin == 'Email' ) {

            if(cas.SuppliedName != null) {
                List<String> suppliedNameSplitString = cas.SuppliedName.split(' ');

                String newFirstname = '';
                String newLastname = '';
                Integer suppliedNameSplitStringSize = suppliedNameSplitString.size();

                for (Integer i = 0; i < suppliedNameSplitStringSize; i++) {
                    if (suppliedNameSplitStringSize == 1 && i == 0) {
                        newLastname = suppliedNameSplitString[i];
                    } else if (suppliedNameSplitStringSize == 2) {
                        if (i == 0) {
                            newFirstname = suppliedNameSplitString[i];
                        } else if (i == 1) {
                            newLastname = suppliedNameSplitString[i];
                        }
                    } else if (suppliedNameSplitStringSize > 2) {
                        if (i < suppliedNameSplitStringSize - 1) {
                            newFirstname = newFirstname + suppliedNameSplitString[i] + ' ';
                        } else if (i == suppliedNameSplitStringSize - 1) {
                            newLastname = suppliedNameSplitString[i];
                        }
                    }
                }
                cas.Supplied_First_Name__c = newFirstname;
                cas.Supplied_Last_Name__c = newLastname;
            }


        }

        //Added below code to attach the Record type For Email-To-case,when the case is
        //closed and the customer reply to the case then new case gets created
        if(cas.Type == Constants.privacyCaseType) {
            if (cas.Sub_Type__c == Constants.deletionRequestSubType || cas.Sub_Type__c == Constants.accessRequestSubType || cas.Sub_Type__c == Constants.rectifyRequestSubType) {
                cas.RecordTypeId = Constants.privacyRecordTypeId;
                cas.Additional_Privacy_Request_Information__c = 'N/A';
            }
        }
        cas.VerificationHash__c = utilityClass.generateRandomString(16);
        //else  cas.RecordTypeId = SupportRecordTypeId;
    }
    
    
    public void zQueueAssignment(Case c) {
        if(casesToUpload.contains(c) && c.Type != Constants.privacyCaseType) {
            if(caseOwnersMap.containsKey(c.OwnerId)) {
                if(caseOwnersMap.get(c.OwnerId).Personal_Queue_Id__c != null) {
                    c.OwnerId = caseOwnersMap.get(c.OwnerId).Personal_Queue_Id__c;
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description This method is called iteratively for each record to be updated during a BEFORE
    * trigger.<p>
    * <p>
    *
    * @return void
    */
    public void  beforeUpdate(SObject oldSo, SObject so){
        Case c = (Case)so;
        Case oldCase = (Case)oldSo;
        //returns cases to omni queue
        if(c.Status != oldCase.Status && c.Status == 'Open' && oldCase.Status != 'New' && c.Last_Status_Change__c != null){
           if(c.Originating_Queue_Id__c != null) {
                    c.OwnerId = c.Originating_Queue_Id__c;
                } 
        }
        if(c.Type == Constants.privacyCaseType) {
            if (c.Status == Constants.resolved && oldCase.Status != Constants.resolved) {
                c.Privacy_Case_Resolved_Date__c = System.now();
                c.VerificationHash__c = utilityClass.generateRandomString(16);
            }
            if(c.Status == Constants.waitingForResponse && oldCase.Status != Constants.waitingForResponse) {
                c.Privacy_Date_Consumer_Last_Contacted__c = System.now();
            }

            // Change the hash on a status change to 'break' old API request links.
            if(c.Privacy_User_Confirmed_Date__c != oldCase.Privacy_User_Confirmed_Date__c &&
                    c.Privacy_User_Confirmed_Date__c != null) {
                c.VerificationHash__c = utilityClass.generateRandomString(16);
            }

        }
    }

   


    /*******************************************************************************************************
    * @description This method is called iteratively for each record to be deleted during a BEFORE
    * trigger. <p>
    * <p>
    *  No actions are currently defined
    * @return void
    */

    public void  beforeDelete(SObject so){

    }

    /*******************************************************************************************************
    * @description This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field validation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    *<p>
    * @return void
    */
    public void  afterInsert(SObject so){
        Case inputCase = (Case)so;
        if(inputCase.Sub_Type__c == Constants.accessRequestSubType && inputCase.ParentId==null)
            listCaseId.add(inputCase.Id);

        if((inputCase.Sub_Type__c == Constants.deletionRequestSubType||inputCase.Sub_Type__c == Constants.rectifyRequestSubType) && inputCase.ParentId==null)
            listCaseIdDeleteReq.add(inputCase.Id);
    }

    /*******************************************************************************************************
    * @description This method is called iteratively for each record deleted during an AFTER
    * trigger.
    *<p>
    * no actions are currently defined
    * @return void
    */
    public void  afterUpdate(SObject oldSo, SObject so){

        List<Case> listOfResolvedCases = new List<Case>();
        List<Case> listOfOnHoldCases = new List<Case>();
        for(SObject c :Trigger.new) {
            Case newCase = (Case)c;
            Case oldCase = (Case)Trigger.oldMap.get(c.Id);
			 if(Trigger.isUpdate) {
                if(sentSuccessEmail == false && newCase.status == 'Resolved' && (newCase.Sub_Type__c == 'Rectify My Data' || newCase.Sub_Type__c == 'Do Not Sell/Share') && newCase.R2R_Email_UserConfirmation__c == 'Confirmed' && newCase.status != oldCase.Status){
                    system.debug('sss');
                    listOfResolvedCases.add(newCase);
                }
                 if((newCase.status == 'On Hold' || newCase.status == 'Resolved') && newCase.status != oldCase.status && (newCase.sub_Type__c == 'Do Not Sell/Share' || newCase.sub_Type__c == 'Rectify My Data')){
                     listOfOnHoldCases.add(newCase);
                 }
            }
        }
		    if(!listOfResolvedCases.isEmpty()){
                sendSuccessEmails(listOfResolvedCases);
            }
        
        if(!listOfOnHoldCases.isEmpty()){
            if(system.isFuture()){
            	changeCaseOwnerQueue(JSON.serialize(listOfOnHoldCases));
            }else{
                changeCaseOwnerQueueFuture(JSON.serialize(listOfOnHoldCases));
            }
        }
    }
    /*******************************************************************************************************
    * @description This method is called iteratively for each record deleted during an AFTER
    * trigger.
    *<p>
    * no actions are currently defined
    * @return void
    */
    public void  afterDelete(SObject so){

    }

    /*******************************************************************************************************
    * @description This method is called once all records have been processed by the trigger. Use this
    * method to accomplish any final operations such as creation or updates of other records.
    *<p>
    * DML updates on Contacts
    * @return void
    */
    public void andFinally(){

        if(!caseListForAccCon.isEmpty() && !System.isFuture()){
            //If Contact Creation is requested in an update, run immediately, not async
            Boolean runInFuture = !Trigger.isUpdate;
            CaseUtility.updateCaseContactdetails(caseListForAccCon, contactListForAccCon, runInFuture);
        }
    }

    /***********************************************************************************************
    * @description Update privacy cases with brand information pulled from accounts.
    * Iterates over Trigger.New
    */
    private void updatePrivacyCaseBrandInfo() {
        try {
            List<Case> privacyCasesNeedingBrandUpdate = new List<Case>();
            for(Sobject sobjCase : Trigger.New) {
                Case cse = (Case)sobjCase;
                if (cse.Type == Constants.privacyCaseType || (
                        cse.Type == Constants.marketingCaseType &&
                                cse.Sub_Type__c == Constants.unsubscribeRequestSubType
                )
                        ) {
                    if (Trigger.isInsert && String.isNotBlank(cse.Brand__c)) {
                        privacyCasesNeedingBrandUpdate.add(cse);
                    } else {
                        Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
                        if (cse.Brand__c != oldCase.Brand__c) {
                            privacyCasesNeedingBrandUpdate.add(cse);
                        }
                    }
                }
            }
            if (privacyCasesNeedingBrandUpdate.size() > 0) {
                List<Account> brands = [Select Id, Name, Brand_Image_Link__c, Brand_Privacy_Form_Link__c, Brand_Privacy_Email__c, Brand_Privacy_OWA_Name__c, Privacy_Escalation_Email__c From Account Where RecordTypeID = :Constants.brandRecordTypeId];
                Map<String, Account> brandMap = new Map<String, Account>();
                for (Account brand: brands) {
                    brandMap.put(brand.Name, brand);
                }
                Map<String, String> brandValueMap = new Map<String, String>();
                List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
                for (Schema.Picklistentry ple: fieldResult) {
                    brandValueMap.put(ple.getValue(), ple.getLabel());
                }
                Map<String, String> OwaNameEmailMap = new Map<String, String>();
                List<OrgWideEmailAddress> owaList = [Select Id, DisplayName, Address From OrgWideEmailAddress limit 1000];
                for (OrgWideEmailAddress owa : owaList) {
                    OwaNameEmailMap.put(owa.DisplayName, owa.Address);
                }
                for (Case cse : privacyCasesNeedingBrandUpdate) {
                    String brandName = brandValueMap.get(cse.Brand__c);
                    Account brandRecord = brandMap.get(brandName);
                    cse.Brand_Privacy_Form_Link__c = brandRecord.Brand_Privacy_Form_Link__c;
                    cse.Brand_Image_Link__c = brandRecord.Brand_Image_Link__c;
                    cse.Brand_Privacy_Email__c = brandRecord.Brand_Privacy_Email__c;
                    cse.Brand_Privacy_OWA_Name__c = brandRecord.Brand_Privacy_OWA_Name__c;
                    cse.Privacy_Escalation_Email__c = brandRecord.Privacy_Escalation_Email__c;
                    cse.Default_From_Address__c = OwaNameEmailMap.get(cse.Brand_Privacy_OWA_Name__c);
                }

            }
        } catch(Exception e) {
            System.debug('Exception encountered updating Brand' + e);

        }
    }

    /***********************************************************************************************
* @description Update non-privacy cases with brand logo pulled from accounts.
* Iterates over Trigger.New
*/
    private void updateCaseBrandImageLink() {
        try {
            List<Case> casesNeedingBrandImage = new List<Case>();
           for(Sobject sobjCase : Trigger.New) {
                Case cse = (Case)sobjCase;
                if (cse.Type != Constants.privacyCaseType){
                    if (Trigger.isInsert && String.isNotBlank(cse.Brand__c)) {
                        	casesNeedingBrandImage.add(cse);
                    } else if(cse.id!=null){
                        Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
                        if (cse.Brand__c != oldCase.Brand__c) {
                            casesNeedingBrandImage.add(cse);
                        } else if (String.isBlank(cse.Brand_Image_Link__c) && String.isNotBlank(cse.Brand__c)) {
                            casesNeedingBrandImage.add(cse);
                        }
                    }
                }
            }
            if (casesNeedingBrandImage.size() > 0) {
                List<Account> brands = [Select Id, Name, Brand_Image_Link__c, Brand_Privacy_Form_Link__c, Brand_Privacy_Email__c, Brand_Privacy_OWA_Name__c, Privacy_Escalation_Email__c From Account Where RecordTypeID = :Constants.brandRecordTypeId];
                Map<String, Account> brandMap = new Map<String, Account>();
                for (Account brand: brands) {
                    brandMap.put(brand.Name, brand);
                }
                Map<String, String> brandValueMap = new Map<String, String>();
                List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
                for (Schema.Picklistentry ple: fieldResult) {
                    brandValueMap.put(ple.getValue(), ple.getLabel());
                }
                for (Case cse : casesNeedingBrandImage) {
                    String brandName = brandValueMap.get(cse.Brand__c);
                    Account brandRecord = brandMap.get(brandName);
                    cse.Brand_Image_Link__c = brandRecord.Brand_Image_Link__c;
                }

            }
        } catch(Exception e) {
            System.debug('Exception encountered updating Brand' + e);

        }
    }
        /**
* @author       : Juhi Bahrani
* @date       : 07/09/2022
* @description   : This Case trigger update record type on case
*            
*/
    public static void beforeUpdateOnCase(List<Case> newCaseList){
        
        Map<String, Contact> ZdTnCContactMap = new Map<String, Contact>();
        Map<String, Contact> ZdPVHContactMap = new Map<String, Contact>();
        Set<String> setCaseZdTnCUserIds = new Set<String>();
        Set<String> setCaseZdPVHUserIds = new Set<String>();
        Id zdPVHRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdPVH').getRecordTypeId();
        Id zdTnCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdTnC').getRecordTypeId();

        for(Case newCase : newCaseList) {
           if (newCase.ZdTnCTicketId__c != null ) {
               setCaseZdTnCUserIds.add(newCase.ZdTnCUserId__c) ;
               newCase.RecordTypeId = zdTnCRecordTypeId;
           }
           if (newCase.ZdPVHTicketId__c != null ) {
               setCaseZdPVHUserIds.add(newCase.ZdPVHUserId__c) ;
               newCase.RecordTypeId = zdPVHRecordTypeId;
           }
        }
        
        for (Contact c: [SELECT Id, AccountId, ZdTnCUserId__c, ZdPVHUserId__c
                         FROM Contact
                         WHERE ZdTnCUserId__c IN  :setCaseZdTnCUserIds OR ZdPVHUserId__c IN :setCaseZdPVHUserIds ])
        {
            if(c.ZdTnCUserId__c != null)   ZdTnCContactMap.put(c.ZdTnCUserId__c,c);
            if(c.ZdPVHUserId__c!=null)  ZdPVHContactMap.put(c.ZdPVHUserId__c,c);
        }

        
        for(Case newCase : newCaseList) {
            Contact con;
            if(newCase.ZdTnCUserId__c !=null && ZdTnCContactMap.containsKey(newCase.ZdTnCUserId__c)){
                con = ZdTnCContactMap.get(newCase.ZdTnCUserId__c);
            } else if(newCase.ZdPVHUserId__c !=null && ZdPVHContactMap.containsKey(newCase.ZdPVHUserId__c )!=null){
                con = ZdPVHContactMap.get(newCase.ZdPVHUserId__c);
            }
            if(con != null) {
                newCase.ContactId = con.id;
                newCase.AccountId = con.AccountId;
            }
        }
    }
    
    public static void sendSuccessEmails(List<case> listOfCases){
        
        system.debug(';calling me'+listOfCases);
        Map<String,Brand_Details_Mapping__mdt> mapOfBrandMappings = new Map<String,Brand_Details_Mapping__mdt>();
        
        List<Brand_Details_Mapping__mdt> listOfBrandMappings = [Select Id,Brand_Number__c,Success_Email_Template__c,Brand_Name__c,Email_Template__c,Ordwide_Email__c,Donot_sell_share_success_template__c from Brand_Details_Mapping__mdt];
        for(Brand_Details_Mapping__mdt eachMdt : listOfBrandMappings){
            mapOfBrandMappings.put(eachMdt.Brand_Number__c, eachMdt);
            
        }
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(Case cs : listOfCases)
        {
            system.debug('mapOfBrandMappings-'+mapOfBrandMappings);
            
            EmailTemplate templateId;
            if(cs.Sub_Type__c == 'Do Not Sell/Share'){
                system.debug('owdListkkk');
                templateId = [Select id from EmailTemplate where name =: mapOfBrandMappings.get(cs.brand__c).Donot_sell_share_success_template__c];
            }else{
                system.debug('owdListkkklll');
                templateId = [Select id from EmailTemplate where name =: mapOfBrandMappings.get(cs.brand__c).Success_Email_Template__c];
            }
            system.debug('temp id'+templateId);
            List<OrgwideEmailAddress> owdList = [Select Id,displayName from OrgwideEmailAddress where 
                                             displayName = :mapOfBrandMappings.get(cs.brand__c).Ordwide_Email__c];
            system.debug('owdList'+owdList);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(cs.contactId);
            mail.setSaveAsActivity(false);
            mail.orgwideemailaddressid = owdList[0].Id;
            mail.setWhatId(cs.Id);
            allmsg.add(mail);
        }
        system.debug('allmsg-'+allmsg);
        Messaging.sendEmail(allmsg,false);
        sentSuccessEmail = true;
    }
    
	@future
    public static void changeCaseOwnerQueueFuture(String casesString){
        changeCaseOwnerQueue(casesString);
    }
    
    
    public static void changeCaseOwnerQueue(String casesString){
        List<case> listOfCases = (List<case>) JSON.deserialize(casesString, List<case>.class);
        List<Group> listOfQueues = [Select Id, Name from group where name in ('Advertising Opt-Out Request','RTR Request')];
        Map<String,group> mapOfQueues = new Map<String,group>();
        for(Group eachGrp : listOfQueues){
            mapOfQueues.put(eachGrp.name, eachGrp);
        }
        for(Case eachCase : listOfCases){
            if(eachCase.Sub_Type__c == 'Do Not Sell/Share'){
                eachCase.OwnerId = mapOfQueues.get('Advertising Opt-Out Request').id;
            }else if(eachCase.Sub_Type__c == 'Rectify My Data'){
                eachCase.OwnerId = mapOfQueues.get('RTR Request').Id;
            }
            
        }
        update listOfCases;
    }

}