public without sharing class ecommContactCase {
    @AuraEnabled
    public static String getContactId(Id CaseId){
        
        list<Case> conId = [select ContactId,Brand__c from Case where Id =:CaseId];
        if (conId[0].Brand__c == NULL){
            Return SYSTEM.LABEL.Case_should_have_Brand_Linked;
        }
        else{
            if (conId[0].ContactId != NULL){
                Boolean ecomm = eCommConnectedFlag(conId[0].ContactId);
                if (ecomm == true){
                    Return conId[0].ContactId;
                }
                else{
                    Contact con = [select Id,B2C_Is_Enabled__c,B2C_Is_Locked__c from Contact where Id=:conId[0].ContactId];
                    if (con.B2C_Is_Enabled__c==false){
                        Return SYSTEM.LABEL.The_Customer_Account_is_disabled;
                    }
                    else{
                        if (con.B2C_Is_Locked__c == true){
                            Return SYSTEM.LABEL.The_Customer_Account_is_Locked;
                        }
                        else{
                            Return conId[0].ContactId;        
                        }
                    }
                }
            }
            else {
                Return SYSTEM.LABEL.Please_associate_the_Case_with_an_existing_or_a_New_Contact;
            }
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
        list<Contact> conList = [select Email,FirstName,LastName,LoyaltyID__c,Brand__c from Contact where Id =:contactId];
        if (conList[0].Email != ''){
        	String mail = conList[0].Email;
            Contact conEcomm = [select Id,FirstName,LastName,Email,Ecomm_Connected__c,LoyaltyID__c,Brand__c from Contact where Ecomm_Connected__c =true and B2C_Customer_No__c !=:''
                                and Email = :mail and FirstName =:conList[0].FirstName and LastName=:conList[0].LastName and Brand__c =:conList[0].Brand__c
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