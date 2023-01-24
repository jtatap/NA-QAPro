/******************************************************************************
* @Description: Generate Loyalty ID for  TH/CK/HE customers which has null value 
* @Date       : Jan 2021
* @JIRA       : NASSC-2694
*
******************************************************************************/

public class LoyaltyIdGeneration
{
    public static Boolean runFlag= true;
    private static Map<String,LoyaltySettings__mdt> loyaltySettingMap=new Map<String,LoyaltySettings__mdt>();
   
    public static void loyaltyIdGenHandler (Map<Id,Contact> conId,set<String> brandSet) 
    {  
        
         system.debug('inside loyaltyidGeneration');
        List<Contact> updateContacts = new List<Contact>();
        Map<Contact,LoyaltyID_Sequence__c> nonLoyaltyContacts = new Map<Contact,LoyaltyID_Sequence__c>();
        Map<String,String> parentContacts = new Map<String,String>();
        Map<String,Contact> childContacts = new Map<String,Contact>();
        
        Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        
        
        for(LoyaltySettings__mdt meta: [Select Id,BrandId__c,IsLoyaltyApplicable__c,Parent_Brand__c,LoyaltyPrefix__c from LoyaltySettings__mdt where BrandId__c IN:brandSet AND IsLoyaltyApplicable__c = true])
        {
            loyaltySettingMap.put(meta.BrandId__c,meta);
        }        
        
        for(Contact con:conId.values())
        {   
            //MetaData brand has match with contact
            if(loyaltySettingMap.containsKey(con.Brand_Id__c))
            {
                //Parent brand is empty in MetaDataType for this contact brand. 
                if(String.isEmpty(loyaltySettingMap.get(con.Brand_Id__c).Parent_Brand__c))
                {                                                   
                    LoyaltyID_Sequence__c lSeq = new LoyaltyID_Sequence__c();
                    nonLoyaltyContacts.put(con,lSeq);
                } 
                //Parent brand is not empty in MetaDataType for this contact brand. 
                else if(String.isNotEmpty(loyaltySettingMap.get(con.Brand_Id__c).Parent_Brand__c))
                {
                    parentContacts.put(con.Email,loyaltySettingMap.get(con.Brand_Id__c).Parent_Brand__c);
                    childContacts.put(con.Email,con);
                    system.debug('childContacts****'+childContacts);
                }
            }
        }
        
        //Creating LoyaltyID_Sequence__c for Contacts iff Parent brand is empty in MetaDataType .
        if(nonLoyaltyContacts.size() > 0)
        {   
            updateContacts.addAll(populateContactsWithLoyaltyIds(nonLoyaltyContacts));
            //populateContactsWithLoyaltyIds(nonLoyaltyContacts);
        }
        
        /* If Parent brand is not empty in MetaDataType*/        
        if(parentContacts.size()>0)
        {
            
            List<Contact> parentContactList = [SELECT ID, Brand_Id__c, Email, LoyaltyID__c, LoyaltyFlag__c, Loyalty_Optin_Date__c
                                               FROM Contact 
                                               WHERE RecordTypeId = :emailRecordTypeId AND Brand_Id__c IN :parentContacts.values() AND Email!=Null AND Email IN :parentContacts.keySet() ];
            
            if(parentContactList.size()>0)
            {
                Map<Contact,LoyaltyID_Sequence__c>  nonParentLoyaltyContacts = new Map<Contact,LoyaltyID_Sequence__c>();
                
                for(Contact parentContact : parentContactList)
                {
                    contact childContact = childContacts.get(parentContact.Email);
                    
                    /* If Parent contact has loyaltyId - then use that to populate in child contact.*/
                    if (parentContact.LoyaltyID__c != null) 
                    {
                        Contact origContactUpdate = new Contact(Id=childContact.Id);
                        origContactUpdate.LoyaltyID__c = parentContact.LoyaltyID__c;
                        if (parentContact.LoyaltyFlag__c != null) origContactUpdate.LoyaltyFlag__c = parentContact.LoyaltyFlag__c;
                        if (parentContact.Loyalty_Optin_Date__c != null) origContactUpdate.Loyalty_Optin_Date__c = parentContact.Loyalty_Optin_Date__c;
                        updateContacts.add(origContactUpdate);
                        system.debug('updateContacts***'+updateContacts);
                    }                    
                    else
                    {
                        LoyaltyID_Sequence__c lSeq = new LoyaltyID_Sequence__c();
                        nonParentLoyaltyContacts.put(parentContact,lSeq);
                    }                    
                }
                /* Check Parent contact has no loyalityId - Creating LoyaltyID_Sequence__c and populate the same in Parent & Child */
                for(Contact parentContact : populateContactsWithLoyaltyIds(nonParentLoyaltyContacts))
                {
                    contact childContact = childContacts.get(parentContact.Email);
                    Contact origContactUpdate = new Contact(Id=childContact.Id);
                    origContactUpdate.LoyaltyID__c= parentContact.LoyaltyID__c;
                    updateContacts.add(parentContact);
                    updateContacts.add(origContactUpdate);
                    system.debug('updateContacts***'+updateContacts);
                }
            }
            
        }
        /* Update all Contacts at once */
        if(updateContacts.size()>0)
        {
            Update updateContacts;
        }
    }
    private static List<Contact> populateContactsWithLoyaltyIds(Map<Contact,LoyaltyID_Sequence__c> nonLoyaltyContacts)
    {
        List<Contact> returnConList = new List<Contact>();
        insert nonLoyaltyContacts.values();
        Set<id> newLoyaltyIds = new Set<id>();
        
        for(SObject sobj: nonLoyaltyContacts.values())
        { 
            newLoyaltyIds.add(sobj.Id);
        }    
        List<LoyaltyID_Sequence__c> loyaltylList =  [Select Id, Name from LoyaltyID_Sequence__c WHERE Id in :newLoyaltyIds];
        Integer index=0;
        for(Contact con: nonLoyaltyContacts.keyset())
        {
            if(String.isNotEmpty(loyaltySettingMap.get(con.Brand_Id__c).LoyaltyPrefix__c))
            {
                Contact origContactUpdate = new Contact(Id=con.Id, LoyaltyID__c = loyaltySettingMap.get(con.Brand_Id__c).LoyaltyPrefix__c + loyaltylList[index].Name);
                returnConList.add(origContactUpdate);
            }
            index++;             
        }
        return returnConList;
    }
    
    public static void hasOptedOutOfEmailUpdated(List<Contact> conList) {
        List<Contact> updatedList=new  List<Contact> ();
       
        for(Contact con:conList){
            if(con.HasOptedOutOfEmail==True && con.EmailOptInStatus__c!='N'){
                con.EmailOptInStatus__c='N';
                con.EmailOptOutDate__c=system.now();
               
            }
            else if (con.HasOptedOutOfEmail==False && con.EmailOptInStatus__c!='Y'){
                con.EmailOptInStatus__c='Y';
                con.EmailOptInDate__c=system.now();
              
            }else if (con.EmailOptInStatus__c=='Y' && con.HasOptedOutOfEmail!=False ){
                con.HasOptedOutOfEmail=False;
                
              
            }else if (con.EmailOptInStatus__c=='N' && con.HasOptedOutOfEmail!=True){
                con.HasOptedOutOfEmail=True;
               
              
            }
           
            
                }
   }
}