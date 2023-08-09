public class ChildPrivacyCaseActionsHandler {

    @future
    public static void createChildDataOwnerCases(Id caseId) {
        Case cse = [Select Id, Type, OwnerId, AccountId, Brand__c, ContactId,Contact.Country_ds__c, SuppliedEmail, SuppliedName, SuppliedPhone, Origin, Country_of_Residence__c,Rectified_Data__c, State_of_Residence__c, Sub_Type__c, Additional_Privacy_Request_Information__c, Perfect_Match_Found__c, Due_Date__c, Loyalty_Account_Number__c From Case Where Id = :caseId];
        Map<String,String> brandValueMap = new Map<String,String>();
        Group dssQueue = [Select Id, Name from group where name = 'Advertising Opt-Out Request' limit 1];
        Group r2rQueue = [Select Id, Name from group where name = 'RTR Request' limit 1];
        List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
        for (Schema.Picklistentry ple: fieldResult) {
            brandValueMap.put(ple.getValue(), ple.getLabel());
        }
        String brandName = brandValueMap.get(cse.Brand__c);
        system.debug(brandName);
       //if((!string.isblank(cse.Country_of_Residence__c) && cse.Country_of_Residence__c=='Canada') || (!string.isBlank(cse.Contact.Country_ds__c) && cse.Contact.Country_ds__c=='CA'))
        if(((!string.isblank(cse.Country_of_Residence__c) && cse.Country_of_Residence__c=='Canada') || (!string.isBlank(cse.Contact.Country_ds__c) && cse.Contact.Country_ds__c=='CA')) && brandName=='Calvin Klein'){
             brandName=brandName+' '+'Canada';
        }
        List<Contact> dataOwners;
        //system.debug(brandName);
        //system.debug(cse.Sub_Type__c+' '+cse.Perfect_Match_Found__c+' '+Constants.dataOwnerContactRecordTypeId+' '+Constants.dataOwnerSupplemental);

        if (cse.Sub_Type__c == Constants.accessRequestSubType) {
            dataOwners = [Select Id, Email,DataOwner_Subtype__c From Contact Where AccountId  In (Select Id From Account Where Name = :brandName) and System_Type__c = :Constants.dataOwnerSupplemental and RecordTypeId = :Constants.dataOwnerContactRecordTypeId];
        } else {
            if (cse.Perfect_Match_Found__c) {
                dataOwners = [Select Id, Email,DataOwner_Subtype__c From Contact Where AccountId  In (Select Id From Account Where Name = :brandName) and RecordTypeId = :Constants.dataOwnerContactRecordTypeId];
            } else {
                dataOwners = [Select Id, Email,DataOwner_Subtype__c From Contact Where AccountId  In (Select Id From Account Where Name = :brandName) and RecordTypeId = :Constants.dataOwnerContactRecordTypeId and System_Type__c = :Constants.dataOwnerSupplemental ];
            }
             
        }
        //system.debug(dataOwners);
        List<Case> newCases = new List<Case>();
        for (Contact dataOwner : dataOwners) {
            if(!string.isBlank(dataOwner.DataOwner_Subtype__c) && dataOwner.DataOwner_Subtype__c.contains(cse.Sub_Type__c)){
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
                if(cse.Sub_Type__c == 'Rectify My Data'){
                    newCase.ownerId = r2rQueue.Id;
                }
                Log.push('===newcase '+ newCase);
                newCases.add(newCase);
           }
        }   
        insert newCases;
    }

    @future
    public static void handleChildCaseResolved(Id caseId, Id parentId) {
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
            Log.push('===new links' + newLinks);
            Logger.logDebug();
            insert newLinks;
        }
    }

    public static void updateParentCaseIfAllChildrenClosed(Id caseId) {
        List<Case> omniCases = new List<Case>();

        Integer openChildren = [Select Count() From Case Where ParentId = :caseId And Status Not In :Constants.privacyCaseCompletedStatuses];
        Log.push('open children' + openChildren);
        if (openChildren == 0) {
            Case parentCase = [Select Id, Sub_Type__c, Status, Perfect_Match_Found__c, Originating_Queue_Id__c, State_of_Residence__c, RecordTypeId From Case Where Id = :caseId];
            if (parentCase.Status != Constants.resolved && !Constants.privacyCaseCompletedStatuses.contains(parentCase.Status)) {
                Log.push('===status good' + parentCase);
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
                        Integer childProvidedCount = [Select Count() From Case Where ParentId = :caseId And Resolution_Code__c = :Constants.privacyResolvedDataProvided];
                        if ( childProvidedCount == 0) {
                            parentCase.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
                        } else {
                            parentCase.Status = Constants.reviewResponseStatus;
                            omniCases.add(parentCase);
                        }
                    }
                }
              If (UserInfo.getName()!='MuleSoft APIUser'){ 
                if (omniCases.size() > 0) {
                    PrivacyCaseQueueHandler.sendCasesToOmni(omniCases);
                    update omniCases;
                } else {
                    update parentCase;
                }
            }
          
            }
        }
        Logger.logDebug();
    }

}