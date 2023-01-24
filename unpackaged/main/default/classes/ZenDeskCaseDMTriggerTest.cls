@isTest
public class ZenDeskCaseDMTriggerTest {
    private static testMethod void testUpdateContactIdAccountIdOnCaseForZendeskCaseMigration()
        {
            Id zdPVHRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdPVH').getRecordTypeId();
            Id zdTnCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdTnC').getRecordTypeId();
            Test.startTest();
            List<Account> lstAccount = new List<Account>();
            lstAccount.add(new Account(Name='Test Account ABC'));
            lstAccount.add(new Account(Name='Test Account PQR'));
            insert lstAccount;
            
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(new Contact( ZdTnCUserId__c = '230000', AccountId = lstAccount[1].Id, LastName = 'Test Contact PQR', FirstName='jay', Brand_Id__c='1', Email='test1@mail.com'));
            lstContact.add(new Contact( ZdPVHUserId__c = '44449999', AccountId = lstAccount[0].Id, LastName = 'Test Contact ABC', FirstName='joe', Brand_Id__c='2', Email='test2@mail.com'));
           
            insert lstContact;






            List<Case> lstCase = new List<Case>();
            lstCase.add(new Case(RecordTypeId = zdTnCRecordTypeId, Subject='ZdTnCTicketId__c present ', Origin = 'Email' , SuppliedEmail = 'abc@gmail.com' ,
                    ZdTnCUserId__c = '230000',ZdTnCTicketId__c = '3333999', Source_System__c = 'Zendesk T&C', Status = 'Closed', CreatedByMethod__c='Data Migration',
                    Brand__c='1'
            ));
            lstCase.add(new Case(RecordTypeId = zdPVHRecordTypeId, Subject='ZdPVHTicketId__c present', Origin = 'Email' , SuppliedEmail = 'abc@gmail.com' ,
                    ZdPVHUserId__c = '44449999', ZdPVHTicketId__c = '44449999', Source_System__c = 'Zendesk PVH', Status = 'Closed', CreatedByMethod__c='Data Migration',
                    Brand__c='1'
            ));

            lstCase.add(new Case(RecordTypeId = zdPVHRecordTypeId, Subject='ZdPVH child ticket1', Origin = 'Email' , SuppliedEmail = 'abc2@gmail.com' ,
                    ZdPVHUserId__c = '44449999', ZdPVHTicketId__c = '44', ZdParentTicketId__c='44449999',
                    Source_System__c = 'Zendesk PVH', Status = 'Closed', CreatedByMethod__c='Data Migration',
                    Reason_Code__c ='Corporate', Reason_Code_Details__c ='Other',Brand__c='1'
            ));

            lstCase.add(new Case(RecordTypeId = zdPVHRecordTypeId, Subject='ZdPVH child ticket2', Origin = 'Email' , SuppliedEmail = 'abc3@gmail.com' ,
                    ZdPVHUserId__c = '44449999', ZdPVHTicketId__c = '45',ZdParentTicketId__c='44449999',
                    Source_System__c = 'Zendesk PVH', Status = 'Closed', CreatedByMethod__c='Data Migration',
                    Reason_Code__c ='Corporate', Reason_Code_Details__c ='Other',Brand__c='1'
            ));
            insert lstCase;


            ZdBatch_relateParentCases thisBatch2 = new ZdBatch_relateParentCases();
            Database.executeBatch(thisBatch2);


            
            Test.stopTest();
            
            List <Case> casesAfter = [select id, ContactId, ZdTnCTicketId__c, ZdTnCUserId__c, ZdPVHTicketId__c, ZdPVHUserId__c, Contact.Id, Contact.ZdPVHUserId__c, Contact.ZdTnCUserId__c from Case];

            for (Case c: casesAfter){
                System.debug('*** case: '+ c);
            }

        }

}