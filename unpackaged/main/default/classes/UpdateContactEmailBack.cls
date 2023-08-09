public class UpdateContactEmailBack{
    @InvocableMethod(Label = 'B2C : update to old Email'Description = 'When there is an error because of Email change. It will update back to Old Emaill')
    public static void updateEmail(List<String> B2CHistId){
        Log.push('B2CHistid = ' + B2CHistId);
        B2C_Contact_Integration_History__c C = [select Contact__c, Integration_JSON__c
                                                from B2C_Contact_Integration_History__c
                                                where Id = :B2CHistId[0]];
        Object result = JSON.deserializeUntyped(C.Integration_JSON__c);
        Map<String, Object> resultMap = (Map<String, Object>)result;
        //Log.push('fault :' + resultMap);
        //Log.push('fault :' + resultMap.get('fault'));
        Map<String, Object> faultMap = (Map<String, Object>)resultMap.get('fault');

        //Log.push('Message to Display: '+faultMap.get('message') );

        if (faultMap != null && faultMap.containsKey('type') && faultMap.get('type') == SYSTEM.LABEL.LoginAlreadyInUseException){
            Contact con = [select Id, Email, OldEmail__c, B2C_UserName__c, Email_Updated_by_CSR__c
                           from Contact
                           where Id = :C.Contact__c];
            Log.push('Contact Id: ' + con.Id);
            Log.push('Contact Email:' + con.Email);
            Log.push('Contact OldEmail:' + con.OldEmail__c);
            con.Email = con.OldEmail__c;
            con.B2C_UserName__c = con.OldEmail__c;
            con.Email_Updated_by_CSR__c = false;
            con.Email_Address_Reason_Code__c = SYSTEM.LABEL.Verfication_Success_login_email_is_already_in_use;
            update con;
            Logger.logDebug();
        }
    }

}