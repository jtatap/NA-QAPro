public class TCHistoricalContactHandler
{
    public TCHistoricalContactHandler(){
        
    }
    /*public static boolean flag=true;

    public static void TCcontactTriggerUpdate(set<ID> conListID)
    {

        if(flag=true){
            flag=false;
            List<Contact> newContactList=new List<Contact>();
            List<Contact> existingContactList=new List<Contact>();
            List<Contact> existingConList=new List<Contact>();
            set<String> emailIDSet=new set<String>();
            set<ID> existingEmailSet=new set<ID>();
            Map<String,List<Contact>>  existingConMap=new  Map<String,List<Contact>>();

            List<Contact> cons = [SELECT ID,Name,FirstName,LastName,Email,Brand_Id__c,T_C_Fit_Quiz_Token__c,T_C_Guest__c,T_C_ID__c,	T_C_Purchaser__c,Phone,AccountId,Account.Name,CreatedDate,PVHCreatedDate__c,EmailOptInStatus__c,HasOptedOutOfEmail,
                                  MailingCity,MailingPostalCode,MailingState,MailingStreet,DirectMailOptin__c,OptOutShare__c,EmailOptOutDate__c,Latest_Source__c,Source_System__c,Status__c,MailingCountry,Do_Not_Sync_with_SFMC__c,EmailOptInDate__c
                                  FROM Contact WHERE Id IN :conListID AND Email!=Null AND Brand_Id__c='11' AND CreatedDate=Today];

            for(Contact con:cons)
            {
                emailIDSet.add(con.Email);
            }
            system.debug('emailIDSet***'+emailIDSet);
            for(Contact con :[select Id,Name,FirstName,LastName,Email,Brand_Id__c,T_C_Fit_Quiz_Token__c,T_C_Guest__c,T_C_ID__c,	T_C_Purchaser__c,Phone,MailingCity,MailingPostalCode,
                              MailingState,MailingStreet,AccountId,Account.Name,CreatedDate,PVHCreatedDate__c,EmailOptInStatus__c,HasOptedOutOfEmail,
                              DirectMailOptin__c,EmailOptOutDate__c,Latest_Source__c,Source_System__c,Status__c,OptOutShare__c,MailingCountry,Do_Not_Sync_with_SFMC__c,EmailOptInDate__c
                              from Contact where Email!=Null AND Email IN :emailIDSet AND AccountId != null AND Brand_Id__c='11'
                              AND RecordType.Name ='Email' AND Account.Name!='Dummy Parent Account' AND CreatedDate!=Today order by Email])
            {
                if(existingConMap.containsKey(con.Email))
                    existingConMap.get(con.Email).add(con);
                else
                    existingConMap.put(con.Email,new List<Contact>{con});
            }
            system.debug('existingConList****'+existingConList);
            system.debug('existingConList****'+existingConList.size());

            Map<Id,Contact> ContactUpdatedList=new Map<Id,Contact>();
            List<Contact> ConNewList=new List<Contact>();
            if( existingConMap.values().size()>0 && cons.size()>0)
            {
                system.debug('inside map checking ****');
                for(Contact con: cons)
                {
                    if(existingConMap.containsKey(con.Email))
                    {
                        for(Contact conRec: existingConMap.get(con.Email))
                        {
                            contact existingContact = conRec;

                            system.debug('inside map checking  ****');

                            existingEmailSet.add(con.ID);
                            if(existingContact.FirstName!=con.FirstName)
                            {
                                existingContact.FirstName=con.FirstName;
                            }
                            if(existingContact.LastName!=con.LastName)
                            {
                                existingContact.LastName=con.LastName;
                            }
                            if(existingContact.EmailOptInStatus__c!=con.EmailOptInStatus__c)
                            {
                                existingContact.EmailOptInStatus__c=con.EmailOptInStatus__c;
                            }
                            if(existingContact.EmailOptInDate__c!=con.EmailOptInDate__c)
                            {
                                existingContact.EmailOptInDate__c=con.EmailOptInDate__c;
                            }
                            if(existingContact.EmailOptOutDate__c!=con.EmailOptOutDate__c)
                            {
                                existingContact.EmailOptOutDate__c=con.EmailOptOutDate__c;
                            }
                            if(existingContact.HasOptedOutOfEmail!=con.HasOptedOutOfEmail)
                            {
                                existingContact.HasOptedOutOfEmail=con.HasOptedOutOfEmail;
                            }
                            if(existingContact.DirectMailOptin__c!=con.DirectMailOptin__c)
                            {
                                existingContact.DirectMailOptin__c=con.DirectMailOptin__c;
                            }
                            if(existingContact.PVHCreatedDate__c!=con.PVHCreatedDate__c)
                            {
                                existingContact.PVHCreatedDate__c=con.PVHCreatedDate__c;
                            }
                            if(existingContact.T_C_Fit_Quiz_Token__c!=con.T_C_Fit_Quiz_Token__c)
                            {
                                existingContact.T_C_Fit_Quiz_Token__c=con.T_C_Fit_Quiz_Token__c;
                            }
                            if(existingContact.T_C_Guest__c!=con.T_C_Guest__c)
                            {
                                existingContact.T_C_Guest__c=con.T_C_Guest__c;
                            }
                            if(existingContact.T_C_ID__c!=con.T_C_ID__c)
                            {
                                existingContact.T_C_ID__c=con.T_C_ID__c;
                            }
                            if(existingContact.T_C_Purchaser__c!=con.T_C_Purchaser__c)
                            {
                                existingContact.T_C_Purchaser__c=con.T_C_Purchaser__c;
                            }
                            if(existingContact.Phone!=con.Phone)
                            {
                                existingContact.Phone=con.Phone;
                            }
                             if(existingContact.MailingCity!=con.MailingCity)
                            {
                                existingContact.MailingCity=con.MailingCity;
                            }
                             if(existingContact.MailingState!=con.MailingState)
                            {
                                existingContact.MailingState =con.MailingState;
                            }
                            if(existingContact.MailingStreet !=con.MailingStreet)
                            {
                                existingContact.MailingStreet=con.MailingStreet;
                            }
                            if(existingContact.MailingPostalCode !=con.MailingPostalCode)
                            {
                                existingContact.MailingPostalCode=con.MailingPostalCode;
                            }
                            if(existingContact.OptOutShare__c !=con.OptOutShare__c)
                            {
                                existingContact.OptOutShare__c=con.OptOutShare__c;
                            }
                            existingContact.Latest_Source__c='TC Historical';
                            existingContact.Source_System__c='TC';
                            existingContact.Status__c='Active';
                            existingContact.MailingCountry='US';
                            existingContact.Do_Not_Sync_with_SFMC__c=true;
                            ContactUpdatedList.put(existingContact.Id,existingContact);
                        }
                    }
                    else
                    {
                        ConNewList.add(con);
                    }
                }
            }
            system.debug('ContactUpdatedList****'+ContactUpdatedList);
            system.debug('ContactUpdatedList****'+ContactUpdatedList.size());
            if(ContactUpdatedList.size()>0){
                update ContactUpdatedList.values();
            }
            List<Contact> ConNewListupdated=new List<Contact>();
            if(ConNewList.size()>0){
                for(Contact con:ConNewList){
                    con.Latest_Source__c='TC Historical';
                    con.Source_System__c='TC';
                    con.Status__c='Active';
                    con.MailingCountry='US';
                    con.Do_Not_Sync_with_SFMC__c=true;
                    ConNewListupdated.add(con);
                }
            }

            if(ConNewListupdated.size()>0){
                update ConNewListupdated;
            }
            system.debug('ConNewListupdated****'+ConNewListupdated);
            system.debug('ConNewListupdated****'+ConNewListupdated.size());
            List<Contact> ContactNewList=[select Id,Name,FirstName,Email,Brand_Id__c,AccountId,Account.Name,CreatedDate,PVHCreatedDate__c,EmailOptInStatus__c,HasOptedOutOfEmail,
                                          MailingCity,MailingPostalCode,MailingState,MailingStreet,
                                          DirectMailOptin__c,EmailOptOutDate__c,Latest_Source__c,Source_System__c,Status__c,OptOutShare__c,MailingCountry,Do_Not_Sync_with_SFMC__c,EmailOptInDate__c
                                          from Contact where Email!=Null AND ID IN: existingEmailSet AND AccountId != null AND Brand_Id__c='11'
                                          AND RecordType.Name ='Email' AND Account.Name!='Dummy Parent Account' AND CreatedDate=Today];

            system.debug('ContactNewList****'+ContactNewList);
            system.debug('ContactNewList****'+ContactNewList.size());
            if(ContactNewList.size()>0)
            {
                if(!Test.isRunningTest()){
                Delete ContactNewList;
                }
            }
        }
    }*/
}