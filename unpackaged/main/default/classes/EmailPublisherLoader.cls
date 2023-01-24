global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {
    }

    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        system.debug('*** SETTING DEFAULTS ***');
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;


        // Check if the quick action is the standard case feed Send Email action
        system.debug('*** DEFAULTS *** '+defaults);
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults &&
                    defaults.get(j).getTargetSObject().getSObjectType() ==
                            EmailMessage.sObjectType &&
                    defaults.get(j).getActionName().equals('Case.SendEmail') &&
                    defaults.get(j).getActionType().equals('SendEmail')) {
                sendEmailDefaults =
                        (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                break;
            }
        }
        system.debug('*** DEFAULTS *** '+sendEmailDefaults);

        if (sendEmailDefaults != null) {
            system.debug('*** UPDATING DEFAULTS *** ');
            Case c = [SELECT Status, Reason, Brand__c, RecordTypeId, Type, Sub_Type__c, Brand_Privacy_Email__c FROM Case
            WHERE Id=:sendEmailDefaults.getContextId()];
            system.debug('*** CASE ID *** '+c.Id);
			If (c.RecordTypeId == Constants.privacyRecordTypeId || c.RecordTypeId == Constants.dataOwnerCaseRecordTypeId || c.Type == Constants.privacyCaseType || c.Sub_Type__c == Constants.unsubscribeRequestSubType)
			{
                EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();
                emailMessage.ValidatedFromAddress = c.Brand_Privacy_Email__c;
				 //Add any logic specific to Privacy Requests here
			}
			else 
			{
				EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();
				// Set BCC address to make sure each email goes for audit
				try{
					Brand_Setting__mdt bs = [Select MasterLabel, DeveloperName, Brand_Email__c  from Brand_Setting__mdt where Brand_Id__c = :c.Brand__c];
					emailMessage.ValidatedFromAddress = bs.Brand_Email__c;
				} catch(QueryException e) {
					system.debug('*** EmailPublisherLoader - Exception raised setting validated From Address *** '+c.Id);
				}
			}
        }
    }

    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [select id, name from EmailTemplate
            where developername = : templateApiName].id;
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' +
                    templateApiName + ' refer to Setup | Communications Templates '
                    + templateApiName);
        }
        return templateId;
    }
    private String getBccAddress(String reason) {
        if (reason != null && reason.equals('Technical'))
        { return 'support_technical@mycompany.com'; }
        else if (reason != null && reason.equals('Billing'))
        { return 'support_billing@mycompany.com'; }
        else { return 'support@mycompany.com'; }
    }


}