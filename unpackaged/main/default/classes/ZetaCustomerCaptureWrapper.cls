/* 
* Objective: Wrapper class for ZetaCustomerCapture 
*
* Date: Oct 2019
*
*/

public class ZetaCustomerCaptureWrapper {
        public String Channel;
        public String Source;
        public String TransactionDate;
        public String Prefix;
        public String FirstName;
        public String MiddleName;
        public String LastName;
        public String Gender;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String City;
        public String State;
        public String PostalCode;
        public String ZIPPlus;
        public String Country;
        public Date DateOfBirth;
        public String EmailAddress;
        public String HomePhone;
        public String WorkPhone;
        public String MobilePhone;
        public Boolean DirectMailOptInFlag;
        public String HomeStore;
        public Boolean LoyaltyFlag;
        public String Buffer1;
        //EmailPreferenceCls;        
        public List<EmailPreferenceCls> EmailPreferenceList = new list<EmailPreferenceCls>();
        //objWrapSMSPreferenceCls
        public List<SMSPreferenceCls> SMSPreferenceList = new list<SMSPreferenceCls>();
        
        public String MobileOptInStoreCode;
        public String StoreCode;
        public String Language;
        //public List<SMSPreferenceList> SMSPreferenceList;
        
        public ZetaCustomerCaptureWrapper(Contact record){
            if(record.Channel__c != null) {
                Channel = record.Channel__c;    
            }
            if(record.Source__c != null) {
                Source  = record.Source__c;
            }

            if(record.Salutation__c != null) {
                Prefix  = record.Salutation__c;    
            }
            if(record.FirstName != null) {
                FirstName  = record.FirstName;
            }
            if(record.MiddleName != null) {
                MiddleName  = record.MiddleName;
            }
            if(record.LastName != null) {
                LastName  = record.LastName;
            }
            if(record.Gender__c != null) {
                Gender  = record.Gender__c;    
            }            
            //Address information
            AddressLine1  = null;
            AddressLine2  = null;
            AddressLine3  = null;
            if(record.MailingStreet != null) {
                String[] arrAddress = record.MailingStreet.split('\n');
                if(arrAddress.size() > 0)
                AddressLine1  = arrAddress[0].replace('\r', '');
                if(arrAddress.size() > 1)
                AddressLine2  = arrAddress[1].replace('\r', '');
                if(arrAddress.size() > 2)
                AddressLine3  = arrAddress[2].replace('\r', '');
            }
            if(record.MailingState != null) {
                City  = record.MailingCity;
            }
            if(record.MailingCity != null) {
                State  = record.MailingState;
            }
            if(record.MailingPostalCode != null) {
                PostalCode  = record.MailingPostalCode;
            }                        
            ZIPPlus  = null;
            if(record.MailingCountry != null) {
                Country  = record.MailingCountry;
            }
            if(record.Email != null) {
                EmailAddress  = record.Email;
            }                       
            //Phone
            if(record.HomePhone != null) {
                HomePhone  = record.HomePhone;
            }            
            WorkPhone  = null;
            if(record.MobilePhone != null) {
                MobilePhone  = record.MobilePhone;
            }
            if(record.DirectMailOptin__c != null) {
                DirectMailOptInFlag = record.DirectMailOptin__c;
            }
            if(record.HomeStore__c != null) {
                HomeStore  = record.HomeStore__c;
            }
            if(record.LoyaltyFlag__c != null) {
                LoyaltyFlag = record.LoyaltyFlag__c;
            }
            Buffer1 = record.id;
            //EmailPreference
            EmailPreferenceCls objWrapEmailPreference = new EmailPreferenceCls(record);
            EmailPreferenceList.add(objWrapEmailPreference);
            //SMSPreferences
            SMSPreferenceCls objWrapSMSPreferenceCls = new SMSPreferenceCls(record);
            SMSPreferenceList.add(objWrapSMSPreferenceCls);
            
            MobileOptInStoreCode  = null;
            if(record.StoreOfCapture__c != null) {
                StoreCode  = record.StoreOfCapture__c;
            } 
            if(record.Language__c != null) {
                Language  = record.Language__c;
            }             
            //date            
            TransactionDate = string.valueOf(record.CreatedDate.format('MM/dd/YYYY')); 
            if(record.Birthdate != null) {
                DateOfBirth     = record.Birthdate;
            }                     
        }
        
        class EmailPreferenceCls {
            public Integer BusinessUnitID;
            public Boolean EmailOptInFlag;
            public List<EmailUserPreferences> EmailUserPreferences;
            
            public EmailPreferenceCls(Contact record) {
                String optInFlag = system.label.false; 
                if(record.EmailOptInStatus__c==SYSTEM.LABEL.Y) {
                   optInFlag = system.label.true; 
                }
                BusinessUnitID = integer.valueof(record.Brand_Id__c);
                EmailOptInFlag = Boolean.valueOf(optInFlag);
                EmailUserPreferences = new List<EmailUserPreferences>();            
            }
        }        
    
        public class EmailUserPreferences {
            public EmailUserPreferences() {                            
            }
        }
        
        public class SMSPreferenceCls {
            public Integer BusinessUnitID;
            public Boolean MobileOptInFlag;
            public List<SMSPreferences> SMSPreferences;
            
            public SMSPreferenceCls(Contact record) {
                String optInFlag = system.label.false; 
                if(record.SMSOptinStatus__c==SYSTEM.LABEL.Y) {
                   optInFlag = system.label.true; 
                }
                BusinessUnitID = integer.valueof(record.Brand_Id__c);
                MobileOptInFlag = Boolean.valueOf(optInFlag);
                SMSPreferences = new List<SMSPreferences>();            
            }
            
        }
        
        public class SMSPreferences {
            public SMSPreferences () {                            
            }
        }
    }