/**
* @author       : NeuraFlash, LLC
* @date       : 04/11/2021
* @description   : This class is needed because the privacy logic can only execute once due to its sending emails, 
*           which the CaseTriggerHandler interface does not allow 
*===========================================================
* Ver    Date            Author      Modification
*===========================================================
* 1.0    00/00/0000      -----      Initial Version (Unknown Creation Date)
* 1.1    04/28/2021    Luis Rocha    Adding the missing comparison statement for Marketing and removed system debugs
* 1.2    04/28/2021    Luis Rocha    Added bypassrun for test classes on each method to use, By putting the check at the top of the action we can ensure that bypass behavior is not dependent on external settings or configuration.
*/
public class PrivacyCaseTriggerHandler {
    
    public static Boolean isFirstRun = True;
    @testVisible static Boolean bypassRun = false;
    
    private static Id supportId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Support_Case).getRecordTypeId();
   
    public static void sendEmailsIfNecessary() {
        if(bypassRun) { return; }
        List<Case> privacyCases = new List<Case>();
        List<Id> newCaseIds = new List<Id>();
        List<Id> parentIds = new List<Id>();
        List<Id> dataOwnerIds = new List<Id>();
        List<Case> unsubCases = new List<Case>();
        List<Case> newEmailPrivacyCases = new List<Case>();
        for (sObject sobjCase : Trigger.new) {
            Case cse = (Case)sobjCase;
            if (
            ( cse.Type == Constants.privacyCaseType || cse.Type == System.Label.Marketing) &&
            cse.Sub_Type__c == Constants.unsubscribeRequestSubType
            ){
                unsubCases.add(cse);
            }
            
            if ((cse.RecordTypeId == Constants.dataOwnerCaseRecordTypeId ||  cse.RecordTypeId == Constants.privacyRecordTypeId || cse.RecordTypeId == supportId) && cse.Sub_Type__c !='Rectify My Data') {
                privacyCases.add(cse);
            } else {
                if ( cse.Type == Constants.privacyCaseType && cse.Sub_Type__c == Constants.unsubscribeRequestSubType) {
                    unsubCases.add(cse);
                }
                if (cse.Type == Constants.privacyCaseType && cse.Sub_Type__c == Constants.privacyEmailSubType && cse.Status == Constants.newPrivacyStatus && Trigger.isUpdate ) {
                    Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
                    if (String.isNotBlank(cse.emailToAddress__c) && String.isBlank(oldCase.emailToAddress__c)) {
                        newEmailPrivacyCases.add(cse);
                    }
                }
                continue;
            }
            if (cse.Sub_Type__c == Constants.dataOwnerRequestSubType) {
                if (!parentIds.contains(cse.ParentId)) {
                    parentIds.add(cse.ParentId);
                }
                if (!dataOwnerIds.contains(cse.Data_Owner__c)) {
                    dataOwnerIds.add(cse.Data_Owner__c);
                }
            } else {
                if (Trigger.isInsert) {
                    newCaseIds.add(cse.Id);
                }
            }
        }
        if (privacyCases.size() > 0) {
            if (newCaseIds.size() > 0) {
                ContactFuture.processNewPrivacyCases(newCaseIds);
            }
            sendPrivacyEmailsIfNeeded(privacyCases, parentIds, dataOwnerIds);
            if (Trigger.isUpdate) {
                createChildCasesIfNeeded(privacyCases);
            }
        }
        if (unsubCases.size() > 0) {
            processUnsubCases(unsubCases);
        }
        if (newEmailPrivacyCases.size() > 0) {
            processNewEmailPrivacyCases(newEmailPrivacyCases);
        }
    }

    private static void processNewEmailPrivacyCases(List<Case> newUnsubCases) {
        if(bypassRun) { return; }
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        PrivacyEmailHandler emailHandler = new PrivacyEmailHandler();
        for (Case cse : newUnsubCases) {
            List<Brand_Setting__mdt> brandSetting = [Select Privacy_Auto_Response_Email_Template__c From Brand_Setting__mdt Where Brand_Id__c = :cse.Brand__c];
            if (brandSetting.size() == 0) {
                continue;
            }
            
            Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, brandSetting[0].Privacy_Auto_Response_Email_Template__c, cse.SuppliedEmail);
            if (email == null) {
                continue;
            }
            emailsToSend.add(email);
        }
        emailHandler.sendEmails(emailsToSend);
    }
    private static void processUnsubCases(List<Case> unsubCases) {
        if(bypassRun) { return; }
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        PrivacyEmailHandler emailHandler = new PrivacyEmailHandler();
        for (Case cse : unsubCases) {
            if (Trigger.isInsert && cse.Status == Constants.newPrivacyStatus) {
                Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.U1UnsubscribeEmail, cse.SuppliedEmail);
                if (email == null) {
                    continue;
                }
                emailsToSend.add(email);
            } else if (cse.Status == Constants.resolved && Trigger.isUpdate) {
                Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
                if (oldCase.status != Constants.resolved) {
                    if (cse.Resolution_Code__c == Constants.privacyResolvedNoResponse) {
                        Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.U3UnsubscribeEmail, cse.SuppliedEmail);
                        if (email == null) {
                            continue;
                        }
                        emailsToSend.add(email);
                    } else if (cse.Resolution_Code__c == Constants.privacyResolvedRejectedRequest) {
                        Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.U2UnsubscribeEmail, cse.SuppliedEmail);
                        if (email == null) {
                            continue;
                        }
                        emailsToSend.add(email);
                    }
                }
            }
        }
        emailHandler.sendEmails(emailsToSend);
    }
    private static void createChildCasesIfNeeded(List<Case> cases) {
        if(bypassRun) { return; }
        List<Case> casesNeedingUpdate = new List<Case>();
        List<Account> accountsWithSupplementalDataOwners = [Select Name From Account Where Id In (Select AccountId From Contact Where RecordTypeId = :Constants.dataOwnerContactRecordTypeId And System_Type__c = :Constants.dataOwnerSupplemental)];
        List<String> accountNamesWithSupplemental = new List<String>();
        Map<String,String> brandValueMap = new Map<String,String>();
        List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
        for (Schema.Picklistentry ple: fieldResult) {
            brandValueMap.put(ple.getValue(), ple.getLabel());
        }
        for (Account a : accountsWithSupplementalDataOwners) {
            if (!accountNamesWithSupplemental.contains(a.Name)) {
                accountNamesWithSupplemental.add(a.Name);
            }
        }
        for(Case cse : cases) {
            Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
            if (
                cse.Type == Constants.privacyCaseType && 
                (cse.Sub_Type__c == Constants.accessRequestSubType || cse.Sub_Type__c == Constants.deletionRequestSubType ||cse.Sub_Type__c == Constants.rectifyRequestSubType) && 
                cse.Status == Constants.dataOwnersContacted &&
                oldCase.Status != Constants.dataOwnersContacted
            ) {
                if (cse.Perfect_Match_Found__c) {
                    if (cse.Sub_Type__c == Constants.accessRequestSubType && !accountNamesWithSupplemental.contains(brandValueMap.get(cse.Brand__c))) {
                        //CSR has all data for the brand already
                        Case newCase = new Case(Id=cse.Id);
                        newCase.Status = Constants.reviewResponseStatus;
                        casesNeedingUpdate.add(newCase);
                    } else {
                        //Need to contact data owners for deletion/additional info
                        ChildPrivacyCaseActionsHandler.createChildDataOwnerCases(cse.Id);
                    }
                } else {
                    if (!Constants.privacyNACountries.contains(cse.Country_of_Residence__c)) {
                        // No Match and no NA, resolve the case.
                        Case newCase = new Case(Id=cse.Id);
                        newCase.Status = Constants.resolved;
                        newCase.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
                        casesNeedingUpdate.add(newCase);
                    } else {
                        if (accountNamesWithSupplemental.contains(brandValueMap.get(cse.Brand__c))) {
                            // In NA without a match, but need to see if supplemental owners have data on consumer
                            ChildPrivacyCaseActionsHandler.createChildDataOwnerCases(cse.Id);
                        } else {
                            // In NA, but no supplemental data owners to contact. resolve it.
                            Case newCase = new Case(Id=cse.Id);
                            newCase.Status = Constants.resolved;
                            newCase.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
                            casesNeedingUpdate.add(newCase);
                        }
                    }
                }
            }
        }
        if (casesNeedingUpdate.size() > 0) {
            update casesNeedingUpdate;
        }
    }
    private static void sendPrivacyEmailsIfNeeded(List<Case> cases, List<Id> parentIds, List<Id> dataOwnerIds) {
        if(bypassRun) { return; }
        Map<Id, String> dataOwnerEmailMap = new Map<Id, String>();
        Map<Id, Case> parentCasesMap = new Map<Id, Case>();
        Map<Id, List<String>> dataOwnerAddtionalEmailsMap = new Map<Id, List<String>>();
        if (parentIds.size() > 0) {
            List <Case> parentCases = [Select Id, Sub_Type__c From Case Where Id In :parentIds];
            for (Case parentCase : parentCases) {
                parentCasesMap.put(parentCase.Id, parentCase);
            }
        }
        if (dataOwnerIds.size() > 0) {
            List<Contact> dataOwners= [Select Id, Email, Additional_Email_1__c, Additional_Email_2__c, Additional_Email_3__c, Additional_Email_4__c From Contact Where Id In :dataOwnerIds];
            for (Contact dataOwner : dataOwners) {
                List<String> additionalEmails = new List<String>();
                if (String.isNotBlank(dataOwner.Additional_Email_1__c)) additionalEmails.add(dataOwner.Additional_Email_1__c);
                if (String.isNotBlank(dataOwner.Additional_Email_2__c)) additionalEmails.add(dataOwner.Additional_Email_2__c);
                if (String.isNotBlank(dataOwner.Additional_Email_3__c)) additionalEmails.add(dataOwner.Additional_Email_3__c);
                if (String.isNotBlank(dataOwner.Additional_Email_4__c)) additionalEmails.add(dataOwner.Additional_Email_4__c);
                dataOwnerAddtionalEmailsMap.put(dataOwner.Id, additionalEmails);
                dataOwnerEmailMap.put(dataOwner.Id, dataOwner.Email);
            }
        }
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        PrivacyEmailHandler emailHandler = new PrivacyEmailHandler();
        for (Case cse : cases) {
            if (cse.Type != Constants.privacyCaseType ) {
                continue;
            }
            if (cse.Sub_Type__c == Constants.accessRequestSubType) {
                emailsToSend = processAccessCases(cse, emailsToSend, emailHandler);
            }
            if (cse.Sub_Type__c == Constants.dataOwnerRequestSubType && String.isNotBlank(cse.Id)) {
                emailsToSend = processDataOwnerCases(cse, emailsToSend, emailHandler, parentCasesMap, dataOwnerAddtionalEmailsMap, dataOwnerEmailMap);
            }
            if (cse.Sub_Type__c == Constants.deletionRequestSubType ) {
                emailsToSend = processDeletionCase(cse, emailsToSend, emailHandler);
            }
            if (cse.Sub_Type__c == Constants.rectifyRequestSubType) {
                emailsToSend = processUpdationCase(cse, emailsToSend, emailHandler);
            }
			if (cse.Sub_Type__c == Constants.doNotSellorShare) { // added as part of GCT-772
				emailsToSend = processdoNotSellShareCase(cse, emailsToSend, emailHandler);
			}
            
        }
        if (emailsToSend.size() > 0) {
            emailHandler.sendEmails(emailsToSend);
        }
    }
    private static List<Messaging.SingleEmailMessage> processAccessCases(Case cse, List<Messaging.SingleEmailMessage> emailsToSend, PrivacyEmailHandler emailHandler) {
        if(bypassRun) { return new List<Messaging.SingleEmailMessage>(); }
        if (Trigger.isInsert) {
            Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.A1RequestEmail);
            if (email == null) {
                return emailsToSend;
            }
            emailsToSend.add(email);
        } else if (Trigger.isUpdate) {
            Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
            if (cse.Status == Constants.resolved && oldCase.Status != Constants.resolved) {
                Messaging.SingleEmailMessage email;
                if (cse.Resolution_Code__c == Constants.privacyResolvedDataProvided) {
                    // NO AUTOMATED EMAIL, CSR MANUALLY SENDS
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedRejectedRequest) {
                    email = emailHandler.createEmail(cse, Constants.A2RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedNoResponse) {
                    email = emailHandler.createEmail(cse, Constants.A3RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedStalled) {
                    email = emailHandler.createEmail(cse, Constants.A10RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedNoDataFound) {
                    if (Constants.privacyNACountries.contains(cse.Country_of_Residence__c)) {
                        email = emailHandler.createEmail(cse, Constants.A7RequestEmail);
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    } else {
                        email = emailHandler.createEmail(cse, Constants.A8RequestEmail);
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    }
                }
            }
        }
        return emailsToSend;
        
    }
    private static List<Messaging.SingleEmailMessage> processDeletionCase(Case cse, List<Messaging.SingleEmailMessage> emailsToSend, PrivacyEmailHandler emailHandler) {
        if(bypassRun) { return new List<Messaging.SingleEmailMessage>(); }
        if (Trigger.isInsert) {
            Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.D1RequestEmail);
            if (email == null) {
                return emailsToSend;
            }
            emailsToSend.add(email);
        } else if (Trigger.isUpdate) {
            Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
            if (cse.Status == Constants.resolved && oldCase.Status != Constants.resolved) {
                Messaging.SingleEmailMessage email;
                if (cse.Resolution_Code__c == Constants.privacyResolvedDataDeleted) {
                    email = emailHandler.createEmail(cse, Constants.D4RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                }else if (cse.Resolution_Code__c == Constants.privacyResolvedRejectedRequest) {
                    email = emailHandler.createEmail(cse, Constants.D7RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedNoResponse) {
                    email = emailHandler.createEmail(cse, Constants.D8RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedStalled) {
                    email = emailHandler.createEmail(cse, Constants.D10RequestEmail);
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                } else if (cse.Resolution_Code__c == Constants.privacyResolvedNoDataFound) {
                    if (Constants.privacyNACountries.contains(cse.Country_of_Residence__c)) {
                        email = emailHandler.createEmail(cse, Constants.D5RequestEmail);
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    } else {
                        email = emailHandler.createEmail(cse, Constants.D9RequestEmail);
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    }
                }
            }
        }
        return emailsToSend;
    }
    
    private static List<Messaging.SingleEmailMessage> processUpdationCase(Case cse, List<Messaging.SingleEmailMessage> emailsToSend, PrivacyEmailHandler emailHandler) {
        if(bypassRun) { return new List<Messaging.SingleEmailMessage>(); }
        if (Trigger.isInsert) {
        //    Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.U1RequestEmail);
      /*  Messaging.SingleEmailMessage email = emailHandler.createEmail(cse,'R2RIdentityVerification');
            if (email == null) {
                return emailsToSend;
            }
            emailsToSend.add(email);*/
        } else if (Trigger.isUpdate) {
            Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
            if (cse.Status == Constants.resolved && oldCase.Status != Constants.resolved) {
                Messaging.SingleEmailMessage email;
                if (cse.Resolution_Code__c == Constants.privacyResolvedDataUpdated) {
                    email = emailHandler.createEmail(cse, Constants.U4RequestEmail);//data updated
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                }else if (cse.Resolution_Code__c == Constants.privacyResolvedNoDataFound) {
                    if (Constants.privacyNACountries.contains(cse.Country_of_Residence__c)) {
                        email = emailHandler.createEmail(cse, Constants.U5RequestEmail);//CSR alerts consumer that there is not record to be updated'
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    }else {
                        email = emailHandler.createEmail(cse, Constants.D9RequestEmail);//No Match -> Non EU/NA Consumer -> CSR alerts non NA/EU consumer';
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    }
                }
            }
        }
        return emailsToSend;
    }
	// added as part of GCT-772
	private static List<Messaging.SingleEmailMessage> processdoNotSellShareCase(Case cse, List<Messaging.SingleEmailMessage> emailsToSend, PrivacyEmailHandler emailHandler) {
        if(bypassRun) { return new List<Messaging.SingleEmailMessage>(); }
        if (Trigger.isInsert) {
        //    Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, Constants.U1RequestEmail);
      /*  Messaging.SingleEmailMessage email = emailHandler.createEmail(cse,'R2RIdentityVerification');
            if (email == null) {
                return emailsToSend;
            }
            emailsToSend.add(email);*/
        } else if (Trigger.isUpdate) {
            Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
            if (cse.Status == Constants.resolved && oldCase.Status != Constants.resolved) {
                Messaging.SingleEmailMessage email;
                if (cse.Resolution_Code__c == Constants.privacyResolvedDataUpdated) {
                    email = emailHandler.createEmail(cse, Constants.S4RequestEmail);//data updated
                    if (email == null) {
                        return emailsToSend;
                    }
                    emailsToSend.add(email);
                }else if (cse.Resolution_Code__c == Constants.privacyResolvedNoDataFound) {
                    if (Constants.privacyNACountries.contains(cse.Country_of_Residence__c)) {
                        email = emailHandler.createEmail(cse, Constants.S5RequestEmail);//CSR alerts consumer that there is not record to be updated'
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    } else {
                        email = emailHandler.createEmail(cse, Constants.D9RequestEmail);//No Match -> Non EU/NA Consumer -> CSR alerts non NA/EU consumer';
                        if (email == null) {
                            return emailsToSend;
                        }
                        emailsToSend.add(email);
                    }
                }
            }
        }
        return emailsToSend;
    }
    
    private static List<Messaging.SingleEmailMessage> processDataOwnerCases(Case cse, List<Messaging.SingleEmailMessage> emailsToSend, PrivacyEmailHandler emailHandler, Map<Id, Case> parentCasesMap, Map<Id, List<String>> dataOwnerAddtionalEmailsMap, Map<Id, String> dataOwnerEmailMap) {
        if(bypassRun) { return new List<Messaging.SingleEmailMessage>(); }
        Case parentCase = parentCasesMap.get(cse.ParentId);
        if (Trigger.isInsert) {
            String emailTemplate;
            if (parentCase.Sub_Type__c == Constants.accessRequestSubType) {
                emailTemplate = Constants.A5RequestEmail;
            }else if(parentCase.Sub_Type__c == Constants.deletionRequestSubType){
                emailTemplate = Constants.D3RequestEmail;
            }else if(parentCase.Sub_Type__c == Constants.rectifyRequestSubType){
                emailTemplate = Constants.U3RequestEmail;
            }else if(parentCase.Sub_Type__c == Constants.doNotSellorShare){
                emailTemplate = Constants.S3RequestEmail;
            }
            Messaging.SingleEmailMessage email = emailHandler.createEmail(cse, emailTemplate, dataOwnerEmailMap.get(cse.Data_Owner__c));
            if (email == null) {
                return emailsToSend;
            }
            List<String> additionalEmailAddresses = dataOwnerAddtionalEmailsMap.get(cse.Data_Owner__c);
            if (additionalEmailAddresses.size() > 0) {
                email.setCcAddresses(additionalEmailAddresses);
                    
            }
            emailsToSend.add(email);
        }
        if (Trigger.isUpdate) {
            if(Constants.privacyCaseCompletedStatuses.contains(cse.Status)) {
                Case oldCase = (Case)Trigger.oldMap.get(cse.Id);
                if (!Constants.privacyCaseCompletedStatuses.contains(oldCase.Status)) {
                    system.debug('>>>>>>>>>inside method>>>>>>');
                    ChildPrivacyCaseActionsHandler.handleChildCaseResolved(cse.Id, cse.parentId);
                }
            }
        }
        return emailsToSend;
    }
}