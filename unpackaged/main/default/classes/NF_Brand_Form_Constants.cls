public without sharing class NF_Brand_Form_Constants {
    public static Map<String,String> fieldLabels = getFieldLabels();
    public static Map<String,String> fieldMetadata = getFieldMetadata();

    static Map<String,String> getFieldLabels(){
        Map<String,String> fieldLabels = new Map<String,String>();
        fieldLabels.put('Supplied_First_Name__c','First Name');
        fieldLabels.put('Supplied_Last_Name__c','Last Name');
        fieldLabels.put('SuppliedEmail','Email');
        fieldLabels.put('SuppliedPhone','Phone Number');
        fieldLabels.put('Channel__c','Which team are you attempting to reach?');
        fieldLabels.put('Reason_Code__c','What can we help you with?');
        fieldLabels.put('Reason_Code_Details__c','Additional Details');
        fieldLabels.put('TestField','Test Field');
        fieldLabels.put('Description','Message');
        return fieldLabels; 
    }

    static Map<String,String> getFieldMetadata(){
        Map<String,String> fieldMetadata = new Map<String,String>();
        fieldMetadata.put('Channel__c','Brand_Form_Brand_Channel__mdt');
        fieldMetadata.put('Reason_Code__c','Brand_Form_Help_Topics__mdt');
        return fieldMetadata;
    }
}