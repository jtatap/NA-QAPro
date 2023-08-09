public without sharing class getContact {
	@AuraEnabled
    public static String getContactDetails(Id contactId){
        Log.push('Limits.getQueries -getContact '+ Limits.getQueries());
        Contact con = [select Email,Ecomm_Connected__c,B2C_Customer_No__c from Contact where Id =:contactId limit 1];
        list<Case> cas= [select Id,Contactid,Brand__c from Case where ContactId =:contactId order by CreatedDate desc limit 1];
        String retMessage='';
        if ((con.B2C_Customer_No__c =='' || con.Ecomm_Connected__c == false) && cas.isEmpty()==true){
            retMessage =SYSTEM.LABEL.As_contact_selected_is_not_Ecomm_Connected_and_Case_assigned_you_will_be_unable;
        }
        else{ 
            if ((con.B2C_Customer_No__c =='' || con.Ecomm_Connected__c == false) && cas.isEmpty()==false){
            retMessage =SYSTEM.LABEL.As_contact_selected_is_not_Ecomm_Connected_you_will_be_unable_to_update;
        	}
            else { 
                if (con.B2C_Customer_No__c !='' && con.Ecomm_Connected__c == true && cas.isEmpty()==true){
           		retMessage =SYSTEM.LABEL.Contact_should_have_case_assigned;
        		}
            }    
        	if (con.B2C_Customer_No__c !='' && con.Ecomm_Connected__c == true && cas.isEmpty()==false && cas[0].Brand__c==NULL){
            	retMessage =SYSTEM.LABEL.Linked_case_should_have_Brand_Linked;
        	}
        }
        Logger.logDebug();    
        Return retMessage;
    }
    
    @AuraEnabled
    public static String getOldMail (Id contactId){
        List<Contact> con = [select Email,Ecomm_Connected__c from Contact where Id =:contactId limit 1];
        System.debug('con'+con);
        Return con[0].Email;
    }
    
    
    @AuraEnabled
    public static Boolean searchMail (String mailId){
        list<Contact> con = [select Email from Contact where Email =:mailId];
        Return con.isEmpty();
    }
    
    @AuraEnabled
    public static Void updateCSREmailField (Id contactId, String mailId){
        Contact con = [select Id, TriggerCSREmailFlow__c,Email_Updated_by_CSR__c from Contact where Id =:contactId limit 1];
        con.TriggerCSREmailFlow__c = mailId;
        con.Email_Updated_by_CSR__c = false;
        con.CSR_Trigger_PB__c = true;
        Log.push('Limits.getQueries -getContact:updateCSREmailField--line45 '+ Limits.getQueries());
        update con;
        Log.push('Limits.getQueries -getContact:updateCSREmailField--line47 '+ Limits.getQueries());
        Logger.logDebug();
    }
    
}