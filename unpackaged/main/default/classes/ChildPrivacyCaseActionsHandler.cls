public class ChildPrivacyCaseActionsHandler {

    @future
    public static void createChildDataOwnerCases(Id caseId) {
        Case cse = [Select Id, Type, OwnerId, AccountId, Brand__c, ContactId, SuppliedEmail, SuppliedName, SuppliedPhone, Origin, Country_of_Residence__c,Rectified_Data__c, State_of_Residence__c, Sub_Type__c, Additional_Privacy_Request_Information__c, Perfect_Match_Found__c, Due_Date__c, Loyalty_Account_Number__c From Case Where Id = :caseId];
        Map<String,String> brandValueMap = new Map<String,String>();
        Group dssQueue = [Select Id, Name from group where name = 'Advertising Opt-Out Request' limit 1];
        List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
        for (Schema.Picklistentry ple: fieldResult) {
            brandValueMap.put(ple.getValue(), ple.getLabel());
        }
        
        String brandName = brandValueMap.get(cse.Brand__c);
        List<Contact> dataOwners;
        if (cse.Sub_Type__c == Constants.accessRequestSubType) {
            dataOwners = [Select Id, Email From Contact Where AccountId  In (Select Id From Account Where Name = :brandName) and System_Type__c = :Constants.dataOwnerSupplemental and RecordTypeId = :Constants.dataOwnerContactRecordTypeId];
        } else {
            if (cse.Perfect_Match_Found__c) {
                dataOwners = [Select Id, Email From Contact Where AccountId  In (Select Id From Account Where Name = :brandName) and RecordTypeId = :Constants.dataOwnerContactRecordTypeId];
            } else {
                dataOwners = [Select Id, Email From Contact Where AccountId  In (Select Id From Account Where Name = :brandName) and RecordTypeId = :Constants.dataOwnerContactRecordTypeId and System_Type__c = :Constants.dataOwnerSupplemental];
            }
             
        }
		List<Case> newCases = new List<Case>();
        for (Contact dataOwner : dataOwners) {
           
            Case newCase = cse.clone();
            newCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
            newCase.Status = Constants.waitingForResponse;
            newCase.Data_Owner__c = dataOwner.Id;
            newCase.ParentId = cse.Id;
            newCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
            newCase.Description = cse.Rectified_Data__c;
            if(cse.Sub_Type__c == 'Do Not Sell/Share'){
                newCase.ownerId = dssQueue.Id;
            }
            System.debug('===newcase '+ newCase);
            newCases.add(newCase);
        }
        insert newCases;//child case created
    }

    @future
    public static void handleChildCaseResolved(Id caseId, Id parentId) {
        system.debug('inside handle child>>>>>>>>');
        addAttachmentsToParent(caseId, parentId);
        updateParentCaseIfAllChildrenClosed(parentId);
    }

    public static void addAttachmentsToParent(Id caseId, Id parentId) {
        List<EmailMessage> messagesWithAttachments = [Select Id From EmailMessage Where ParentId = :caseId And Incoming=True And HasAttachment=True];
        if (messagesWithAttachments.size() > 0) {
            List<Id> messageIds = new List<Id>();
            for (EmailMessage message : messagesWithAttachments) {
                messageIds.add(message.Id);
            }
            List<ContentDocumentLink> oldLinks = [Select Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility From ContentDocumentLink Where LinkedEntityId In :messageIds];
            List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
            for (ContentDocumentLink oldLink :oldLinks) {
                ContentDocumentLink newLink = oldLink.clone();
                newLink.LinkedEntityId = parentId;
                newLinks.add(newLink);
            }
            System.debug('===new links' + newLinks);
            insert newLinks;
        }
    }

    public static void updateParentCaseIfAllChildrenClosed(Id caseId) {
        system.debug('inside parent method>>>>'+caseId);
        List<Case> omniCases = new List<Case>();

        Integer openChildren = [Select Count() From Case Where ParentId = :caseId And Status Not In :Constants.privacyCaseCompletedStatuses];
        if (openChildren == 0) {
            Case parentCase = [Select Id, Sub_Type__c, Status, Perfect_Match_Found__c, Originating_Queue_Id__c, State_of_Residence__c, RecordTypeId From Case Where Id = :caseId];
            if (parentCase.Status != Constants.resolved && !Constants.privacyCaseCompletedStatuses.contains(parentCase.Status)) {
                System.debug('>>>status good>>>' + parentCase);
                parentCase.Status = Constants.resolved;
                if (parentCase.Sub_Type__c == Constants.deletionRequestSubType || parentCase.Sub_Type__c == Constants.doNotSellorShare){//added as part of GCT-772
                    if (parentCase.Perfect_Match_Found__c) {
                        parentCase.Resolution_Code__c = Constants.privacyResolvedDataDeleted;
                    } else {
                        Integer childDeletionsCount = [Select Count() From Case Where ParentId = :caseId And Resolution_Code__c = :Constants.privacyResolvedDataDeleted];
                        if ( childDeletionsCount == 0) {
                            parentCase.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
                        } else {
                            parentCase.Resolution_Code__c = Constants.privacyResolvedDataDeleted;
                        }
                    }
                    
                }else if (parentCase.Sub_Type__c == Constants.rectifyRequestSubType) {
                    if (parentCase.Perfect_Match_Found__c) {
                        parentCase.Resolution_Code__c = Constants.privacyResolvedDataUpdated;
                    } else {
                        Integer childUpdatedCount = [Select Count() From Case Where ParentId = :caseId And Resolution_Code__c = :Constants.privacyResolvedDataUpdated];
                        if ( childUpdatedCount == 0) {
                            parentCase.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
                        } else {
                            parentCase.Resolution_Code__c = Constants.privacyResolvedDataUpdated;
                        }
                    }
                    
                }else if (parentCase.Sub_Type__c == Constants.accessRequestSubType) {
                    if (parentCase.Perfect_Match_Found__c) {
                        parentCase.Status = Constants.reviewResponseStatus;
                        omniCases.add(parentCase);
                    } else {
                        system.debug('ParentCasee'+parentCase);
                        Integer childProvidedCount = [Select Count() From Case Where ParentId = :caseId And Resolution_Code__c = :Constants.privacyResolvedDataProvided];
                        if ( childProvidedCount == 0) {
                            system.debug('ParentCasee'+parentCase);
                            parentCase.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
                            parentCase.status = 'Resolved';
                        } else {
                            system.debug('ParentCasee'+parentCase);
                            parentCase.Status = Constants.reviewResponseStatus;
                            omniCases.add(parentCase);
                        }
                    }
                }
                system.debug('ParentCasee'+parentCase);
                if (omniCases.size() > 0) {
                    system.debug('ParentCasee'+parentCase);
                    PrivacyCaseQueueHandler.sendCasesToOmni(omniCases);
                    update omniCases;
                } else {
                    system.debug('ParentCasee'+parentCase);
                    update parentCase;
                }
            }
        }
    }
}