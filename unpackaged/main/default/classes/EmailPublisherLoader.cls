global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {
    }

    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        Log.push('*** SETTING DEFAULTS ***');
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;


        // Check if the quick action is the standard case feed Send Email action
        Log.push('*** DEFAULTS *** '+defaults);
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
        Log.push('*** DEFAULTS *** '+sendEmailDefaults);

        if (sendEmailDefaults != null) {
            Log.push('*** UPDATING DEFAULTS *** ');
            Case c = [SELECT Status, Reason, Brand__c, RecordTypeId, Type, Sub_Type__c, Brand_Privacy_Email__c FROM Case
            WHERE Id=:sendEmailDefaults.getContextId()];
            Log.push('*** CASE ID *** '+c.Id);
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
					Logger.logException(e);
				}
			}
        }
        Logger.logDebug();
    }
	
    @TestVisible
    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [select id, name from EmailTemplate
            where developername = : templateApiName].id;
        } catch (Exception e) {
            Logger.logError('Unble to locate EmailTemplate using name: ' +
            templateApiName + ' refer to Setup | Communications Templates '
            + templateApiName);
            Logger.logException(e);
        }
        return templateId;
    }
    @TestVisible
    private String getBccAddress(String reason) {
        if (reason != null && reason.equals('Technical'))
        { return 'support_technical@mycompany.com'; }
        else if (reason != null && reason.equals('Billing'))
        { return 'support_billing@mycompany.com'; }
        else { return 'support@mycompany.com'; }
    }


}