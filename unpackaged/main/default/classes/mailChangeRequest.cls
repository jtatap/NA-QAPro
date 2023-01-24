public class mailChangeRequest{
    
    
    @InvocableMethod(label='mailChangeRequest' description='Trigger to old mail')
    public static void mailChangeRequest(list<Case> cse) {    
        System.debug('Limits.getQueries -mailChangeRequest '+ Limits.getQueries());
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<String, Id> templateNameToIdMap = new Map<String, Id>();
        PrivacyEmailHandler emailHandler = new PrivacyEmailHandler();
        List<EmailTemplate> templates = [Select Id, Name from EmailTemplate where Name in ('A1 - Email Change Confirmation request','A1 - Email Change Confirmation request-TH')];
        system.debug('Case Id is '+ cse[0].Id +  '   End'); 
        system.debug('Brand Lookup value is '+ cse[0].Brand_Lookup_Search__c + '   End'); 
         String mailid =  '%' + cse[0].Brand_Lookup_Search__c + '%';
        system.debug('Mail Id is '+ mailid + '   End'); 
        
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress where Address like :'%customerservice@support%' and displayName like :mailid limit 1].id;
        system.debug('Email id is '+ orgWideEmailId + '   End');
        System.debug('Limits.getQueries -mailChangeRequest-2 '+ Limits.getQueries());
        for (EmailTemplate template : templates) {
            templateNameToIdMap.put(template.Name, template.Id);
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        //Id templateId = templateNameToIdMap.get('A1 - Email Change Confirmation request');
        if (cse[0].Brand_Lookup_Search__c =='Calvin Klein'){
            mail.setTemplateId(templateNameToIdMap.get('A1 - Email Change Confirmation request'));
        }
        else if (cse[0].Brand_Lookup_Search__c =='Tommy'){
            mail.setTemplateId(templateNameToIdMap.get('A1 - Email Change Confirmation request-TH'));
        }        
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setToAddresses(new List<String>{cse[0].ContactEmail});
        mail.setSaveAsActivity(true);
        mail.setTargetObjectId(cse[0].ContactId);
        mail.setWhatId(cse[0].Id);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        
        emailsToSend.add(mail);
        system.debug('Case record is '+ cse[0]);
        system.debug('Email Template is '+ Constants.A1RequestEmail);
        system.debug('Target Mail Id is' + cse[0].ContactEmail);
        System.debug('And the mail is '+ mail);
        System.debug('Size of list of mails'+ emailsToSend.size());
        Messaging.sendEmail(emailsToSend);
    }
}