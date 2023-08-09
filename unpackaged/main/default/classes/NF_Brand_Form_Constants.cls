public without sharing class NF_Brand_Form_Constants {
    public static Map<String,String> fieldLabels = getFieldLabels();
    public static Map<String,String> fieldMetadata = getFieldMetadata();

    static Map<String,String> getFieldLabels(){
        Map<String,String> fieldLabels = new Map<String,String>();
        fieldLabels.put(SYSTEM.LABEL.Supplied_First_Name_c,SYSTEM.LABEL.First_Name);
        fieldLabels.put(SYSTEM.LABEL.Supplied_Last_Name_c,SYSTEM.LABEL.Last_Name);
        fieldLabels.put(SYSTEM.LABEL.SuppliedEmail,SYSTEM.LABEL.Email);
        fieldLabels.put(SYSTEM.LABEL.SuppliedPhone,SYSTEM.LABEL.Phone_Number);
        fieldLabels.put(SYSTEM.LABEL.Channel_c,SYSTEM.LABEL.Which_team_are_you_attempting_to_reach);
        fieldLabels.put(SYSTEM.LABEL.Reason_Code_c,SYSTEM.LABEL.What_can_we_help_you_with);
        fieldLabels.put(SYSTEM.LABEL.Reason_Code_Details_c,SYSTEM.LABEL.Additional_Details);
        fieldLabels.put('TestField','Test Field');
        fieldLabels.put(SYSTEM.LABEL.Description,SYSTEM.LABEL.Message);
        return fieldLabels;
    }

    static Map<String,String> getFieldMetadata(){
        Map<String,String> fieldMetadata = new Map<String,String>();
        fieldMetadata.put(SYSTEM.LABEL.Channel_c,SYSTEM.LABEL.Brand_Form_Brand_Channel_mdt);
        fieldMetadata.put(SYSTEM.LABEL.Reason_Code_c,SYSTEM.LABEL.Brand_Form_Help_Topics_mdt);
        return fieldMetadata;
    }
}