public class R2RChangeRequestSendEmail{
    
    @InvocableMethod(label='R2RChangeRequest' description='Trigger to old email')
    public static void mailChangeRequest(List<flowInputs> flowInputsList) {    
        system.debug('flowInputsList='+flowInputsList);
        
        Map<String,String> mapOfBrands = new Map<String,String>();
		Schema.DescribeFieldResult fieldResult = Case.Brand__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			mapOfBrands.put(pickListVal.getValue(),pickListVal.getLabel());
		}     
		
        Map<String,Brand_Details_Mapping__mdt> mapOfBrandMappings = new Map<String,Brand_Details_Mapping__mdt>();
        
        List<Brand_Details_Mapping__mdt> listOfBrandMappings = [Select Id,Brand_Number__c,Brand_Name__c,Email_Template__c,Email_template_donot_share_Sell__c,Ordwide_Email__c from Brand_Details_Mapping__mdt];
        for(Brand_Details_Mapping__mdt eachMdt : listOfBrandMappings){
            mapOfBrandMappings.put(eachMdt.Brand_Number__c, eachMdt);
            
        }
        
        
        List<Messaging.SingleEmailMessage> lsem = new List<Messaging.SingleEmailMessage>();
        List<OrgwideEmailAddress> owdList = [Select Id,displayName from OrgwideEmailAddress where 
                                             displayName = :mapOfBrandMappings.get(flowInputsList[0].brandName).Ordwide_Email__c];

        system.debug('mapOfBrands'+mapOfBrands);
        OrgwideEmailAddress owdToAssign = owdList[0];
        system.debug('flowInputsList[0].brandName'+flowInputsList[0].brandName);
        List<EmailTemplate> templates; 
        if(flowInputsList[0].subType == 'Do Not Sell/Share'){
            templates = [SELECT Id,Name FROM EmailTemplate 
                                         WHERE Name = :mapOfBrandMappings.get(flowInputsList[0].brandName).Email_template_donot_share_Sell__c];
           
            system.debug('templates***'+templates);
        }else{
           templates = [SELECT Id,Name FROM EmailTemplate 
                                         WHERE Name = :mapOfBrandMappings.get(flowInputsList[0].brandName).Email_Template__c];
            system.debug('templates***'+templates);
        }
        
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();   
        sem.setTemplateId(templates[0].Id);
        sem.setSaveAsActivity(true);
        sem.setTargetObjectId(flowInputsList[0].contactId);
        sem.setWhatId(flowInputsList[0].caseId);
        sem.setUseSignature(false);
        sem.setTreatTargetObjectAsRecipient(true);
        sem.setOrgWideEmailAddressId(owdToAssign.Id);
        lsem.add(sem);
        Messaging.sendEmail(lsem);
    }
    public class flowInputs{
        @InvocableVariable
        public String emailAddress;
        @InvocableVariable
        public String caseId;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String brandName;
        @InvocableVariable
        public String subType;
    }
}