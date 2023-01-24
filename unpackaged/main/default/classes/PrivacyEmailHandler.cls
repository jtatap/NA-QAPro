public class PrivacyEmailHandler {
    Map<String,String> brandValueMap = new Map<String,String>();
    Map<String, Id> templateNameToIdMap = new Map<String, Id>();
    Map<String, OrgWideEmailAddress> owaMap = new Map<String, OrgWideEmailAddress>();
    Map<Id, OrgWideEmailAddress> caseToOWAMap = new Map<Id, OrgWideEmailAddress>();
    String genericContactId;

    public PrivacyEmailHandler() {
        List<Schema.Picklistentry> fieldResult = Case.Brand__c.getDescribe().getPicklistValues();
        for (Schema.Picklistentry ple: fieldResult) {
            this.brandValueMap.put(ple.getValue(), ple.getLabel());
        }
        List<EmailTemplate> templates = [Select Id, Name from EmailTemplate limit 1000];
        for (EmailTemplate template : templates) {
            this.templateNameToIdMap.put(template.Name, template.Id);
        }
        List<OrgWideEmailAddress> owaList = [Select Id, DisplayName, Address From OrgWideEmailAddress limit 1000];
        for (OrgWideEmailAddress owa : owaList) {
            this.owaMap.put(owa.DisplayName, owa);
        }

        GenericRecords__c genericContactRecord = GenericRecords__c.getValues(Constants.privacyContactGenericRecordSettingName);
        this.genericContactId = genericContactRecord.recordId__c;

    }

    // THIS METHOD WAS BUILD ASSUMING ALL CASE EMAILS GO TO SUPPLIEDEMAIL.
    // CALL THE OTHER METHOD MOVING FORWARD AND BE EXPLICIT
    public Messaging.SingleEmailMessage createEmail(Case cse, String emailTemplateName) {
        Messaging.SingleEmailMessage mail = createEmail(cse, emailTemplateName, cse.SuppliedEmail);
        return mail;
    }

    public Messaging.SingleEmailMessage createEmail(Case cse, String emailTemplateName, String emailAddress) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        Id templateId = this.templateNameToIdMap.get(emailTemplateName);
        mail.setTemplateId(templateId);

        String brandName = this.brandValueMap.get(cse.Brand__c);
        OrgWideEmailAddress owa = this.owaMap.get(cse.Brand_Privacy_OWA_Name__c);
        if (owa == null) {
            // LOG THIS SOMEWHERE
            return null;
        }
        system.debug('>>>>>>>owa.Id>>>'+owa.Id);
        mail.setOrgWideEmailAddressId(owa.Id);
        this.caseToOWAMap.put(cse.Id, owa);
		system.debug('>>>>emailAddress>>>>>'+emailAddress);
        mail.setToAddresses(new List<String>{emailAddress});
        mail.setSaveAsActivity(false);
        if (String.isNotBlank(cse.ContactId)) {
            mail.setTargetObjectId(cse.ContactId);
        } else {
            mail.setTargetObjectId(this.genericContactId);
        }
        
        mail.setWhatId(cse.Id);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        system.debug('>>>>>>mail>>>>>>'+mail);
        return mail;

    }

    public void sendEmails(List<Messaging.SingleEmailMessage> emails) {
        Messaging.sendEmail(emails);
        this.logEmails(emails);
    }

    private void logEmails(List<Messaging.SingleEmailMessage> emails) {
        List<EmailMessage> emailLog = new List<EmailMessage>();
        for (Messaging.SingleEmailMessage email : emails) {
            EmailMessage emailToLog = new EmailMessage();
            String toAsString='';
            Boolean check = false;
            for (String s : email.getToAddresses()) {
                if (check) toAsString += ',';           
                toAsString += s;
                check = true;
            }
            emailToLog.ToAddress = toAsString;
            emailToLog.Subject = email.getSubject();
            emailToLog.HtmlBody = email.getHtmlBody();
            emailToLog.Incoming = false;
            emailToLog.ParentId = email.getWhatId();
            emailToLog.MessageDate = System.now();
            emailToLog.FromAddress = this.caseToOWAMap.get(email.getWhatId()).Address;
            emailLog.add(emailToLog);
        }
        insert emailLog;

    }

}