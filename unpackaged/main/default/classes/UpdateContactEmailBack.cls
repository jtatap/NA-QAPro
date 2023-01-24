public class UpdateContactEmailBack {
    
    @InvocableMethod(Label='B2C : update to old Email' Description='When there is an error because of Email change. It will update back to Old Emaill')
    public static void updateEmail(List<String> B2CHistId) {
        System.debug('B2CHistid = '+ B2CHistId);
        B2C_Contact_Integration_History__c C = [select Contact__c,Integration_JSON__c from B2C_Contact_Integration_History__c where Id =: B2CHistId[0]];
        Object result = JSON.deserializeUntyped(C.Integration_JSON__c);
        Map<String, Object> resultMap = (Map<String, Object>)result;
        //System.debug('fault :' + resultMap);
        //System.debug('fault :' + resultMap.get('fault'));
        Map<String, Object> faultMap = (Map<String,Object>)resultMap.get('fault');
        
        //System.debug('Message to Display: '+faultMap.get('message') );
        
        if (faultMap != null && faultMap.containsKey('type') && faultMap.get('type') == 'LoginAlreadyInUseException' ){
            Contact con = [select Id,Email,OldEmail__c,B2C_UserName__c,Email_Updated_by_CSR__c from Contact where Id =: C.Contact__c];
            System.debug('Contact Id: '+ con.Id);
            System.debug('Contact Email:'+ con.Email);
            System.debug('Contact OldEmail:'+ con.OldEmail__c);
            con.Email= con.OldEmail__c;
            con.B2C_UserName__c= con.OldEmail__c;
            con.Email_Updated_by_CSR__c = false;
            con.Email_Address_Reason_Code__c='Verfication Success: login email is already in use';
            update con;
        }
    }
}