//Description: 
public without sharing class ContactCheck {
    @AuraEnabled
    public static String getContactId(Id CaseId){
        list<Case> conId = [select ContactId,Brand__c from Case where Id =:CaseId];
        
        if (conId[0].ContactId != NULL){
            Contact con = [select Id,B2C_Is_Enabled__c,B2C_Is_Locked__c,Brand_Id__c from Contact where Id=:conId[0].ContactId];
            if (con.B2C_Is_Enabled__c==false){
                Return SYSTEM.LABEL.This_Customer_Account_is_Disabled_you_cannot_place_an_Order;
            }
            else{
                if (con.B2C_Is_Locked__c == true){
                    Return SYSTEM.LABEL.This_Customer_Account_is_Locked_please_unlock_before_placing_an_Order;
                }
                else{
                    if(con.Brand_Id__c != conId[0].Brand__c){
                        Return 'Brand of Case is not same as the Contact';
                    }
                    else{
                    	Return conId[0].ContactId;            
                    }
            		
                }
            }
        }
        else {
            Return SYSTEM.LABEL.STOP_You_must_create_a_contact_record_or_associate_contact_record_with_an_exist;
        }
    }
    
	@AuraEnabled
    public static Boolean eCommConnectedFlag(Id contactId){
        list<Contact> con = [select Ecomm_Connected__c from Contact where Id =:contactId and Ecomm_Connected__c =:true and B2C_Customer_No__c !=:''];
        if (con.isEmpty() == True){
            Return true;
        }
        else {
        	Return false;    
        }
        
    }
    
    @AuraEnabled
    public static Contact eCommOtherCont(Id contactId){
        list<Contact> conList = [select Email,FirstName,LastName,LoyaltyID__c from Contact where Id =:contactId];
        if (conList[0].Email != ''){
        	String mail = conList[0].Email;
            Contact conEcomm = [select Id,FirstName,LastName,Email,Ecomm_Connected__c,LoyaltyID__c,Brand__c from Contact where Ecomm_Connected__c =true and B2C_Customer_No__c !=:''
                                and Email = :mail and FirstName =:conList[0].FirstName and LastName=:conList[0].LastName
                                and LoyaltyID__c =:conList[0].LoyaltyID__c limit 1];
            if (conEcomm.Id == NULL)
            {
            	return NULL;    
            }
            else {
                return conEcomm;
            }
        }
        else{
            return NULL;
        }
    }
    
    @AuraEnabled
    public static Id linkContact(Id CaseId, List<Contact> Cont){
        list<Case> cs = [select Id,ContactId from Case where Id =:CaseId];
        if (cs[0].ContactId != NULL && Cont[0].Id !=NULL){
        	cs[0].ContactId = Cont[0].Id;    
        }
        update cs[0];
        return Cont[0].Id;
    }
    
}