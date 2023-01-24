public with sharing class sObjectUtils {

    @AuraEnabled
    public static List<FieldsLabelAndName> getFields(String a_Object_API_Name){
        try {
            Map<String, Schema.SObjectField> M_Objects_Schema_Field = Schema.getGlobalDescribe().get(a_Object_API_Name).getDescribe().fields.getMap();
            List<FieldsLabelAndName> listOfFieldsAndLabels = new List<FieldsLabelAndName>();
            for( String a_Field_Name : M_Objects_Schema_Field.keySet() ) {
                Schema.DescribeFieldResult a_Field_Description = M_Objects_Schema_Field.get( a_Field_Name ).getDescribe();
                listOfFieldsAndLabels.add(new FieldsLabelAndName(a_Field_Description.getName(),a_Field_Description.getLabel() ) );
            }
            return listOfFieldsAndLabels;
        } catch (Exception e) {
            Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FieldsLabelAndName{
        @AuraEnabled public string label {get;set;}
        @AuraEnabled public string  name {get;set;}
        FieldsLabelAndName(String name, String label){
            this.name  = name;
            this.label = label;
        }
    }
}