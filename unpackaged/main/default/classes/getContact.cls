public without sharing class getContact {
	@AuraEnabled
    public static String getContactDetails(Id contactId){
        System.debug('Limits.getQueries -getContact '+ Limits.getQueries());
        Contact con = [select Email,Ecomm_Connected__c,B2C_Customer_No__c from Contact where Id =:contactId limit 1];
        list<Case> cas= [select Id,Contactid,Brand__c from Case where ContactId =:contactId order by CreatedDate desc limit 1];
        String retMessage='';
        if ((con.B2C_Customer_No__c =='' || con.Ecomm_Connected__c == false) && cas.isEmpty()==true){
            retMessage ='As contact selected is not Ecomm Connected and Case assigned, you will be unable to update';
        }
        else{ 
            if ((con.B2C_Customer_No__c =='' || con.Ecomm_Connected__c == false) && cas.isEmpty()==false){
            retMessage ='As contact selected is not Ecomm Connected, you will be unable to update';
        	}
            else { 
                if (con.B2C_Customer_No__c !='' && con.Ecomm_Connected__c == true && cas.isEmpty()==true){
           		retMessage ='Contact should have case assigned';
        		}
            }    
        	if (con.B2C_Customer_No__c !='' && con.Ecomm_Connected__c == true && cas.isEmpty()==false && cas[0].Brand__c==NULL){
            	retMessage ='Linked case should have Brand Linked';
        	}
        }    
        Return retMessage;
    }
    
    @AuraEnabled
    public static String getOldMail (Id contactId){
        List<Contact> con = [select Email,Ecomm_Connected__c from Contact where Id =:contactId limit 1];
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
        System.debug('Limits.getQueries -getContact:updateCSREmailField--line45 '+ Limits.getQueries());
        update con;
        System.debug('Limits.getQueries -getContact:updateCSREmailField--line47 '+ Limits.getQueries());
    }
    
}